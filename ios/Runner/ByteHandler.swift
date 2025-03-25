import NetworkExtension
import Flutter

class BytesHandler {
    static var shared = BytesHandler()
    private var timer: Timer?
    private var eventSink: FlutterEventSink?
    
    func startTracking(vpnManager: NEVPNManager, eventSink: @escaping FlutterEventSink) {
        self.eventSink = eventSink
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateBytes(vpnManager: vpnManager)
        }
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateBytes(vpnManager: NEVPNManager) {
        guard let session = vpnManager.connection as? NETunnelProviderSession else {
            return
        }
        
        guard let messageData = "get-traffic-stats".data(using: .utf8) else {
            return
        }
        
        do {
            try session.sendProviderMessage(messageData) { responseData in
                guard let response = responseData,
                      let statsString = String(data: response, encoding: .utf8) else {
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
                    DispatchQueue.main.async {
                        self.eventSink?(stats)
                    }
                }
            }
        } catch {
            print("Failed to get traffic stats: \(error.localizedDescription)")
        }
    }
}
