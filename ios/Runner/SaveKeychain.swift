// Identifiers
let svcID = "MyKestrel"
let usrAcc = "Kestrel"
let accGrp = "KestrelVPN"

// Arguments for the keychain queries
var secAttrAccGrpSwift = NSString(format: kSecClass)

let secClsVal: String = kSecClass as String
let secAttrAccVal: String = kSecAttrAccount as String
let secValDataVal: String = kSecValueData as String
let secClsGenPwdVal: String = kSecClassGenericPassword as String
let secAttrSvcVal: String = kSecAttrService as String
let secMatchLmtVal: String = kSecMatchLimit as String
let secRetDataVal: String = kSecReturnData as String
let secMatchLmtOneVal: String = kSecMatchLimitOne as String
let secAttrGenVal: String = kSecAttrGeneric as String
let secAttrAccValVal: String = kSecAttrAccessible as String
let secRetPersRefVal: String = kSecReturnPersistentRef as String

class KeychainService: NSObject {
    var svcName: String

    init(svcName: String = "Kestrel VPN") {
        self.svcName = svcName
    }

    func saveItem(k: String, v: String) {
        let kData = convertToData(k)
        let vData = convertToData(v)

        let kchainQry = createKeychainQuery(kData: kData, vData: vData)

        // Delete any existing items
        SecItemDelete(kchainQry as CFDictionary)
        SecItemAdd(kchainQry as CFDictionary, nil)
    }

    func loadItem(k: String) -> Data? {
        let kData = convertToData(k)
        let kchainQry = createLoadQuery(kData: kData)

        var res: AnyObject?
        let sts = SecItemCopyMatching(kchainQry as CFDictionary, &res)

        return sts == noErr ? res as? Data : nil
    }

    private func convertToData(_ str: String) -> Data {
        return str.data(using: .utf8, allowLossyConversion: false)!
    }

    private func createKeychainQuery(kData: Data, vData: Data) -> NSMutableDictionary {
        let kchainQry = NSMutableDictionary()
        kchainQry[secClsVal] = secClsGenPwdVal
        kchainQry[secAttrGenVal] = kData
        kchainQry[secAttrAccVal] = kData
        kchainQry[secAttrSvcVal] = self.svcName
        kchainQry[secAttrAccValVal] = kSecAttrAccessibleAfterFirstUnlock
        kchainQry[secValDataVal] = vData
        return kchainQry
    }

    private func createLoadQuery(kData: Data) -> NSMutableDictionary {
        let kchainQry = NSMutableDictionary()
        kchainQry[secClsVal] = secClsGenPwdVal
        kchainQry[secAttrGenVal] = kData
        kchainQry[secAttrAccVal] = kData
        kchainQry[secAttrSvcVal] = self.svcName
        kchainQry[secAttrAccValVal] = kSecAttrAccessibleAfterFirstUnlock
        kchainQry[secMatchLmtVal] = secMatchLmtOneVal
        kchainQry[secRetPersRefVal] = kCFBooleanTrue
        return kchainQry
    }
}
