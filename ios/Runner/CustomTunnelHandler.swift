//
//  WireguardHandler.swift
//  Runner
//
//  Created by Hassan on 11/05/2025.
//

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import Cocoa
#else
#error("Unsupported platform")
#endif

import NetworkExtension

/// Main handler for WireGuard VPN operations, exposed to Flutter.
public class WireguardHandler {
    public static var vpnUtility = VPNUtility()
    public static var eventSink: FlutterEventSink?
    private var isInitialized = false

    /// Prepares the VPN manager with a description.
    public func setup(description: String, result: @escaping FlutterResult) {
        guard !description.isEmpty else {
            result(FlutterError(code: "-3", message: "Description is empty", details: nil))
            return
        }
        WireguardHandler.vpnUtility.vpnDescription = description
        WireguardHandler.vpnUtility.prepareManager { error in
            if let error = error {
                result(FlutterError(code: "-4", message: error.localizedDescription, details: nil))
            } else {
                result(WireguardHandler.vpnUtility.statusString())
            }
        }
        self.isInitialized = true
    }

    /// Starts a WireGuard VPN connection.
    public func start(server: String, config: String, bundleId: String, result: @escaping FlutterResult) {
        WireguardHandler.vpnUtility.activateVPN(
            server: server,
            config: config,
            bundleId: bundleId
        ) { success in
            result(success)
        }
    }

    /// Stops the WireGuard VPN connection.
    public func stop(result: @escaping FlutterResult) {
        WireguardHandler.vpnUtility.deactivateVPN { success in
            result(success)
        }
    }
}

/// Listens for VPN status changes and streams them to Flutter.
class VPNStatusStreamHandler: NSObject, FlutterStreamHandler {
    private var statusSink: FlutterEventSink?
    private var observer: NSObjectProtocol?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
        }
        observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NEVPNStatusDidChange,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self = self,
                  let sink = self.statusSink,
                  let conn = notification.object as? NEVPNConnection else { return }
            sink(WireguardHandler.vpnUtility.statusString(for: conn.status))
        }
        self.statusSink = events

        NETunnelProviderManager.loadAllFromPreferences { managers, _ in
            events(WireguardHandler.vpnUtility.statusString(for: managers?.first?.connection.status))
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
        }
        statusSink = nil
        return nil
    }
}

@available(iOS 15.0, *)
public class VPNUtility {
    var manager: NETunnelProviderManager?
    var bundleId: String?
    var vpnDescription: String?
    var groupId: String?
    var server: String?
    var eventSink: FlutterEventSink?

    /// Loads or creates the VPN manager.
    func prepareManager(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                completion(error)
            } else {
                self.manager = managers?.first ?? NETunnelProviderManager()
                completion(nil)
            }
        }
    }

    func statusString(for status: NEVPNStatus? = nil) -> String {
        let state = status ?? manager?.connection.status
        
        // Debug logging
        debugPrint("Converting VPN status: \(String(describing: state))")
        
        switch state {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .disconnected:
            return "disconnected"
        case .disconnecting:
            return "disconnecting"
        case .invalid:
            // Check if we actually have an active connection despite invalid status
            if let manager = self.manager,
               manager.isEnabled,
               manager.protocolConfiguration != nil {
                return "connected"
            }
            return "invalid"
        case .reasserting:
            return "connecting"
        case .none:
            return "disconnected"
        @unknown default:
            return "disconnected"
        }
    }

    /// Returns the current VPN status as a string.
    func statusString() -> String {
        return statusString(for: manager?.connection.status)
    }

    /// Configures and starts the VPN tunnel.
    func activateVPN(
        server: String,
        config: String,
        bundleId: String,
        completion: @escaping (Bool) -> Void
    ) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if error != nil {
                completion(false)
                return
            }
            let tunnelManager = self.manager ?? NETunnelProviderManager()
            let proto = NETunnelProviderProtocol()
            proto.providerBundleIdentifier = bundleId
            proto.serverAddress = server
            proto.providerConfiguration = ["wgQuickConfig": config]
            tunnelManager.protocolConfiguration = proto
            tunnelManager.isEnabled = true

            tunnelManager.saveToPreferences { error in
                if error != nil {
                    completion(false)
                    return
                }
                tunnelManager.loadFromPreferences { error in
                    if error != nil {
                        completion(false)
                        return
                    }
                    guard let session = tunnelManager.connection as? NETunnelProviderSession else {
                        completion(false)
                        return
                    }
                    do {
                        try session.startTunnel(options: nil)
                        completion(true)
                    } catch {
                        completion(false)
                    }
                }
            }
        }
    }

    /// Stops the VPN tunnel if running.
    func deactivateVPN(completion: @escaping (Bool) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if error != nil {
                completion(false)
                return
            }
            guard let tunnelManager = managers?.first,
                  let session = tunnelManager.connection as? NETunnelProviderSession else {
                completion(false)
                return
            }
            switch session.status {
            case .connected, .connecting, .reasserting:
                session.stopTunnel()
                completion(true)
            default:
                completion(false)
            }
        }
    }
}
