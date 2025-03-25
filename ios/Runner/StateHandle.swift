import Foundation

class VPNStateHandler: FlutterStreamHandler {
    private static var streamSink: FlutterEventSink?
    private static let logger = VPNLogger()
    
    private class VPNLogger {
        func logStateChange(state: Int, error: String?) {
            print("VPN State Changed - State: \(state), Error: \(error ?? "none")")
        }
    }

    static func handleVPNStateChange(_ vpnState: Int, vpnError: String? = nil) {
        logger.logStateChange(state: vpnState, error: vpnError)
        guard let currentSink = streamSink else {
            return
        }

        if let errorMsg = vpnError {
            let flutterError = createFlutterError(state: vpnState, message: errorMsg)
            currentSink(flutterError)
            return
        }

        currentSink(vpnState)
    }
    
    private static func createFlutterError(state: Int, message: String) -> FlutterError {
        return FlutterError(code: "\(state)",
                          message: message,
                          details: nil)
    }

    func handleStreamListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        VPNStateHandler.streamSink = events
        return nil
    }

    func handleStreamCancel(withArguments arguments: Any?) -> FlutterError? {
        VPNStateHandler.streamSink = nil
        return nil
    }
    
    // Flutter Stream Handler Protocol Implementation
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return handleStreamListen(withArguments: arguments, eventSink: events)
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return handleStreamCancel(withArguments: arguments)
    }
}
