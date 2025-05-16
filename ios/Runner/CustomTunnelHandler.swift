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

// Custom protocols for dependency injection
protocol TunnelProviderManaging {
    func configureTunnel(config: TunnelConfiguration, completion: @escaping (Result<Bool, TunnelError>) -> Void)
    func terminateTunnel(completion: @escaping (Result<Bool, TunnelError>) -> Void)
}

protocol TunnelStateReporting {
    var currentTunnelState: TunnelState { get }
    func monitorState(callback: @escaping (TunnelState) -> Void)
}

// Custom enums for better type safety
enum TunnelState: String {
    case active = "connected"
    case establishing = "connecting"
    case inactive = "disconnected"
    case terminating = "disconnecting"
    case unstable = "reasserting"
    case failed = "invalid"
    
    static func from(vpnStatus: NEVPNStatus) -> TunnelState {
        switch vpnStatus {
        case .connected: return .active
        case .connecting: return .establishing
        case .disconnected: return .inactive
        case .disconnecting: return .terminating
        case .reasserting: return .unstable
        case .invalid: return .failed
        @unknown default: return .inactive
        }
    }
}

enum TunnelError: Error {
    case configurationFailure(String)
    case operationFailure(String)
    case invalidState(String)
    case systemError(Error)
}

struct TunnelConfiguration {
    let serverEndpoint: String
    let tunnelProtocolConfig: String
    let bundleIdentifier: String
    let description: String
}

// Main handler with dependency injection
@available(iOS 15.0, *)
public class SecureTunnelHandler {
    private let tunnelManager: TunnelProviderManaging
    private let stateReporter: TunnelStateReporting
    private var isReady: Bool = false
    
    public static let shared = SecureTunnelHandler()
    private static let queue = DispatchQueue(label: "com.securetunnel.handler")
    
    init(tunnelManager: TunnelProviderManaging = DefaultTunnelManager(),
         stateReporter: TunnelStateReporting = DefaultTunnelStateReporter()) {
        self.tunnelManager = tunnelManager
        self.stateReporter = stateReporter
    }
    
    public func prepareTunnel(description: String, result: @escaping FlutterResult) {
        guard !description.isEmpty else {
            result(FlutterError(code: "CONFIG_ERROR",
                              message: "Invalid tunnel description provided",
                              details: nil))
            return
        }
        
        SecureTunnelHandler.queue.async { [weak self] in
            self?.isReady = true
            result(self?.stateReporter.currentTunnelState.rawValue)
        }
    }
    
    public func establishTunnel(server: String, config: String, bundleId: String, result: @escaping FlutterResult) {
        let tunnelConfig = TunnelConfiguration(
            serverEndpoint: server,
            tunnelProtocolConfig: config,
            bundleIdentifier: bundleId,
            description: "SecureTunnel"
        )
        
        SecureTunnelHandler.queue.async { [weak self] in
            self?.tunnelManager.configureTunnel(config: tunnelConfig) { tunnelResult in
                switch tunnelResult {
                case .success(let established):
                    result(established)
                case .failure(let error):
                    result(FlutterError(code: "TUNNEL_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
                }
            }
        }
    }
    
    public func terminateTunnel(result: @escaping FlutterResult) {
        SecureTunnelHandler.queue.async { [weak self] in
            self?.tunnelManager.terminateTunnel { tunnelResult in
                switch tunnelResult {
                case .success(let terminated):
                    result(terminated)
                case .failure(let error):
                    result(FlutterError(code: "TERMINATION_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
                }
            }
        }
    }
    
    // Add this public method
    public func getCurrentState() -> String {
        return stateReporter.currentTunnelState.rawValue
    }
}

// Default implementations
@available(iOS 15.0, *)
class DefaultTunnelManager: TunnelProviderManaging {
    private var providerManager: NETunnelProviderManager?
    
    func configureTunnel(config: TunnelConfiguration, completion: @escaping (Result<Bool, TunnelError>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            if let error = error {
                completion(.failure(.systemError(error)))
                return
            }
            
            self?.providerManager = managers?.first ?? NETunnelProviderManager()
            let customProtocol = NETunnelProviderProtocol()
            customProtocol.providerBundleIdentifier = config.bundleIdentifier
            customProtocol.serverAddress = config.serverEndpoint
            customProtocol.providerConfiguration = ["tunnelConfig": config.tunnelProtocolConfig]
            
            self?.providerManager?.protocolConfiguration = customProtocol
            self?.providerManager?.isEnabled = true
            
            self?.saveAndStartTunnel(completion: completion)
        }
    }
    
    private func saveAndStartTunnel(completion: @escaping (Result<Bool, TunnelError>) -> Void) {
        providerManager?.saveToPreferences { [weak self] error in
            if let error = error {
                completion(.failure(.operationFailure(error.localizedDescription)))
                return
            }
            
            self?.providerManager?.loadFromPreferences { error in
                if let error = error {
                    completion(.failure(.operationFailure(error.localizedDescription)))
                    return
                }
                
                guard let session = self?.providerManager?.connection as? NETunnelProviderSession else {
                    completion(.failure(.invalidState("Invalid tunnel session")))
                    return
                }
                
                do {
                    try session.startTunnel()
                    completion(.success(true))
                } catch {
                    completion(.failure(.systemError(error)))
                }
            }
        }
    }
    
    func terminateTunnel(completion: @escaping (Result<Bool, TunnelError>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                completion(.failure(.systemError(error)))
                return
            }
            
            guard let session = managers?.first?.connection as? NETunnelProviderSession else {
                completion(.failure(.invalidState("No active tunnel found")))
                return
            }
            
            session.stopTunnel()
            completion(.success(true))
        }
    }
}

@available(iOS 15.0, *)
class DefaultTunnelStateReporter: TunnelStateReporting {
    var currentTunnelState: TunnelState {
        // Create a semaphore to handle async code in sync property
        let semaphore = DispatchSemaphore(value: 0)
        var state: TunnelState = .inactive
        
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            defer { semaphore.signal() }
            
            if let error = error {
                NSLog("Error loading preferences: \(error.localizedDescription)")
                state = .failed
                return
            }
            
            guard let manager = managers?.first else {
                state = .inactive
                return
            }
            
            state = TunnelState.from(vpnStatus: manager.connection.status)
        }
        
        // Wait for async operation to complete
        _ = semaphore.wait(timeout: .now() + 2.0)
        return state
    }
    
    func monitorState(callback: @escaping (TunnelState) -> Void) {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { notification in
            guard let connection = notification.object as? NEVPNConnection else { return }
            callback(TunnelState.from(vpnStatus: connection.status))
        }
    }
}

// Flutter stream handler implementation
class TunnelStateStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private let stateReporter: TunnelStateReporting
    
    init(stateReporter: TunnelStateReporting = DefaultTunnelStateReporter()) {
        self.stateReporter = stateReporter
        super.init()
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        stateReporter.monitorState { [weak self] state in
            self?.eventSink?(state.rawValue)
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
