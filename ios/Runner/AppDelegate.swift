import Flutter
import UIKit
import Foundation
import NetworkExtension
import Security

class VPNStreamHandler: NSObject, FlutterStreamHandler {
    private weak var appDelegate: AppDelegate?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        super.init()
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        appDelegate?.eventSink = events
        appDelegate?.bytesHandler.startTracking(vpnManager: appDelegate?.vpnManager ?? NEVPNManager.shared()) { stats in
            events(stats)
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        appDelegate?.bytesHandler.stopTracking()
        appDelegate?.eventSink = nil
        return nil
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var EVENT_CHANNEL_VPN_STAGE: String = "com.kestralvpn.app/state"
    private var METHOD_CHANNEL_VPN_CONTROL: String = "com.kestralvpn.app/vpn"
    let bytesHandler = BytesHandler.shared
    var eventSink: FlutterEventSink?
    var vpnManager: NEVPNManager {
        return NEVPNManager.shared()
    }
    var vpnStatus: NEVPNStatus {
        return vpnManager.connection.status
    }
    private let keychainService = KeychainService()
    private var isConfigSaved = false
    private var wireguardPlugin: WireguardHandler?
    
    private override init() {
        super.init()
        debugPrint("Notification Initialized")
        DispatchQueue.main.async { [weak self] in
                    self?.checkInitialVPNState()
                }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleStatusChange), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    private func checkInitialVPNState() {
            vpnManager.loadFromPreferences { [weak self] error in
                guard let self = self else { return }
                
                if error == nil {
                    let currentState = self.vpnManager.connection.status
                    debugPrint("Initial VPN State: \(currentState)")
                    
                    switch currentState {
                    case .connected:
                        VPNStateHandler.handleVPNStateChange(IPVPNState.connected.rawValue)
                    case .connecting:
                        VPNStateHandler.handleVPNStateChange(IPVPNState.connecting.rawValue)
                    case .disconnecting:
                        VPNStateHandler.handleVPNStateChange(IPVPNState.disconnecting.rawValue)
                    case .disconnected, .invalid:
                        // Treat both disconnected and invalid as disconnected state
                        VPNStateHandler.handleVPNStateChange(IPVPNState.disconnected.rawValue)
                    case .reasserting:
                        VPNStateHandler.handleVPNStateChange(IPVPNState.connecting.rawValue)
                    @unknown default:
                        VPNStateHandler.handleVPNStateChange(IPVPNState.disconnected.rawValue)
                    }
                } else {
                    debugPrint("Failed to load VPN preferences: \(error?.localizedDescription ?? "Unknown error")")
                    VPNStateHandler.handleVPNStateChange(IPVPNState.disconnected.rawValue)
                }
            }
        }
        

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleStatusChange(_ notification: Notification?) {
        switch vpnStatus {
        case .connected:
            VPNStateHandler.handleVPNStateChange(IPVPNState.connected.rawValue)
        case .disconnected:
            VPNStateHandler.handleVPNStateChange(IPVPNState.disconnected.rawValue)
        case .connecting:
            VPNStateHandler.handleVPNStateChange(IPVPNState.connecting.rawValue)
        case .disconnecting:
            VPNStateHandler.handleVPNStateChange(IPVPNState.disconnecting.rawValue)
        case .invalid:
            VPNStateHandler.handleVPNStateChange(IPVPNState.error.rawValue)
        case .reasserting:
            VPNStateHandler.handleVPNStateChange(IPVPNState.connecting.rawValue)
        @unknown default:
            debugPrint("Unknown switch statement: \(vpnStatus)")
        }
        debugPrint("VPN State from notification: \(vpnStatus)")
    }

    private func handleError(_ message: String) {
        debugPrint(message)
        VPNStateHandler.handleVPNStateChange(IPVPNState.error.rawValue, vpnError: message)
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // Register IPSec channels
        let vpnControlM = FlutterMethodChannel(
            name: METHOD_CHANNEL_VPN_CONTROL, binaryMessenger: controller.binaryMessenger)
        let vpnStageE = FlutterEventChannel(
            name: EVENT_CHANNEL_VPN_STAGE, binaryMessenger: controller.binaryMessenger)
        
        let streamHandler = VPNStreamHandler(appDelegate: self)
        vpnStageE.setStreamHandler(streamHandler)
        
        // Register WireGuard handler
        wireguardPlugin = WireguardHandler()
        
        vpnControlM.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            switch call.method {
                
            case "initializeWireguard":
                let wireguard = WireguardHandler()
                wireguard.setup(description: "Kestrel VPN", result: result)
                break;
            case "connect":
                guard let args = call.arguments as? [String: String] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments for 'connect' method are missing or invalid", details: nil))
                    return
                }
                
                // Check VPN type and route accordingly
                let vpnType = args["VpnType"] ?? "ipsec"
                
                if vpnType == "wireguard" {
                    // Handle WireGuard connection
                    guard let wgConfig = args["WireGuardConfig"],
                          let serverAddress = args["Server"],
                          let bundleId = args["ProviderBundleIdentifier"] else {
                        result(FlutterError(code: "INVALID_CONFIG", message: "WireGuard configuration is missing required parameters", details: nil))
                        return
                    }
                    
                    debugPrint("Wireguard is connecting")
                    print("Connecting Wireguard.....")
                    
                    // Initialize WireGuard
                    WireguardHandler.vpnUtility.activateVPN(
                        server: serverAddress,
                        config: wgConfig,
                        bundleId: bundleId
                    ) { success in
                        result(success)
                    }
                } else {
                    // Handle IPSec connection
                    self.connect(
                        result: result,
                        vpnType: "ipsec",
                        vpnServer: args["Server"] ?? "",
                        vpnUsername: args["Username"] ?? "",
                        vpnPassword: args["Password"] ?? "",
                        vpnSecret: args["Secret"],
                        vpnDescription: "KestrelVPN",
                        disconnectOnSleep: args["DisconnectOnSleep"] == "true"
                    )
                }
                
            case "disconnectWireguard":
                self.wireguardPlugin?.stop(result: result)
                
            case "disconnect":
                // Check current VPN type and disconnect accordingly
                
                    self.vpnManager.connection.stopVPNTunnel()
                    result(nil)
                
            case "getWireguardStatus":
                // Check WireGuard status
                let wgStatus = WireguardHandler.vpnUtility.statusString()
                    debugPrint("Wiregaurd Status: \(wgStatus)")
                    result(wgStatus)
                
            case "getCurrentState":
                
                switch self.vpnStatus {
                case .connecting:
                    result(IPVPNState.connecting.rawValue)
                case .connected:
                    result(IPVPNState.connected.rawValue)
                case .disconnecting:
                    result(IPVPNState.disconnecting.rawValue)
                case .disconnected:
                    result(IPVPNState.disconnected.rawValue)
                case .invalid:

                    result(IPVPNState.error.rawValue)
                case .reasserting:
                    result(IPVPNState.connecting.rawValue)
                @unknown default:
                    debugPrint("Unknown switch statement: \(self.vpnStatus)")
                }

            case "getTrafficStats":
                guard let connection = self.vpnManager.connection as? NETunnelProviderSession,
                      self.vpnStatus == .connected else {
                    // Return empty stats when not connected or no connection
                    let emptyStats: [String: Any] = [
                        "bytesIn": 0,
                        "bytesOut": 0
                    ]
                    result(emptyStats)
                    return
                }
                
                guard let messageData = "get-traffic-stats".data(using: .utf8) else {
                    result(FlutterError(code: "ENCODING_ERROR", message: "Could not encode message", details: nil))
                    return
                }
                
                do {
                    try connection.sendProviderMessage(messageData) { responseData in
                        DispatchQueue.main.async {
                            guard let response = responseData,
                                  let statsString = String(data: response, encoding: .utf8) else {
                                let emptyStats: [String: Any] = [
                                    "bytesIn": 0,
                                    "bytesOut": 0
                                ]
                                result(emptyStats)
                                return
                            }
                            
                            let components = statsString.components(separatedBy: ",")
                            
                            if components.count == 2,
                               let bytesIn = Int(components[0]),
                               let bytesOut = Int(components[1]) {
                                let stats: [String: Any] = [
                                    "bytesIn": bytesIn,
                                    "bytesOut": bytesOut
                                ]
                                result(stats)
                            } else {
                                let emptyStats: [String: Any] = [
                                    "bytesIn": 0,
                                    "bytesOut": 0
                                ]
                                result(emptyStats)
                            }
                        }
                    }
                } catch {
                    let emptyStats: [String: Any] = [
                        "bytesIn": 0,
                        "bytesOut": 0
                    ]
                    result(emptyStats)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }

    @available(iOS 9.0, *)
    func connect(
        result: FlutterResult,
        vpnType: String,
        vpnServer: String,
        vpnUsername: String,
        vpnPassword: String,
        vpnSecret: String?,
        vpnDescription: String?,
        disconnectOnSleep: Bool
    ) {
        vpnManager.loadFromPreferences { error in
            guard error == nil else {
                let msg = "VPN Preferences error: \(error!.localizedDescription)"
                debugPrint(msg)
                VPNStateHandler.handleVPNStateChange(IPVPNState.error.rawValue, vpnError: msg)
                return
            }

            let passwordKey = "vpn_\(vpnType)_password"
            let secretKey = "vpn_\(vpnType)_secret"
            self.keychainService.saveItem(k: passwordKey, v: vpnPassword)
            if let secret = vpnSecret {
                self.keychainService.saveItem(k: secretKey, v: secret)
            }

            let protocolConfig = NEVPNProtocolIPSec()
            protocolConfig.serverAddress = vpnServer
            protocolConfig.username = vpnUsername
            protocolConfig.passwordReference = self.keychainService.loadItem(k: passwordKey)
            protocolConfig.authenticationMethod = .sharedSecret
            if let secret = vpnSecret {
                protocolConfig.sharedSecretReference = self.keychainService.loadItem(k: secretKey)
            }
            protocolConfig.localIdentifier = ""
            protocolConfig.remoteIdentifier = ""
            
            protocolConfig.useExtendedAuthentication = true
            debugPrint("VPN Sleep: \(disconnectOnSleep)")
            protocolConfig.disconnectOnSleep = disconnectOnSleep
            self.vpnManager.protocolConfiguration = protocolConfig
            
            self.vpnManager.localizedDescription = vpnDescription
            self.vpnManager.isOnDemandEnabled = false

            self.vpnManager.isEnabled = true
            


            self.vpnManager.saveToPreferences { error in
                guard error == nil else {
                    let msg = "VPN Preferences error: \(error!.localizedDescription)"
                    debugPrint(msg)
                    VPNStateHandler.handleVPNStateChange(IPVPNState.error.rawValue, vpnError: msg)
                    return
                }

                self.vpnManager.loadFromPreferences { error in
                    guard error == nil else {
                        let msg = "VPN Preferences error: \(error!.localizedDescription)"
                        debugPrint(msg)
                        VPNStateHandler.handleVPNStateChange(IPVPNState.error.rawValue, vpnError: msg)
                        return
                    }

                    self.isConfigSaved = true
                    self.startTunnel()
                }
            }
        }
        result(nil)
    }

    private func startTunnel() {
        do {
            try self.vpnManager.connection.startVPNTunnel()
        } catch {
            let msg = "Start tunnel error: \(error.localizedDescription)"
            debugPrint(msg)
            VPNStateHandler.handleVPNStateChange(IPVPNState.error.rawValue, vpnError: msg)
        }
    }
}

enum IPVPNState: Int {
    case disconnected = 0
    case connecting = 1
    case connected = 2
    case disconnecting = 3
    case error = 4
}
