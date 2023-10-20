import Flutter
import UIKit
import TPDirect
import AdSupport
import Foundation

public enum Call {
    case setupTappay
    case isCardValid
    case getPrime
    case isEasyWalletAvailable
    case getEasyWalletPrime
    case redirectToEasyWallet
    case isLinePayAvailable
    case getLinePayPrime
    case redirectToLinePay
    case undefined

    init?(_ call: String) {
        switch call {
        case "setupTappay":
            self = .setupTappay
        case "isCardValid":
            self = .isCardValid
        case "getPrime":
            self = .getPrime
        case "isEasyWalletAvailable":
            self = .isEasyWalletAvailable
        case "getEasyWalletPrime":
            self = .getEasyWalletPrime
        case "redirectToEasyWallet":
            self = .redirectToEasyWallet
        case "isLinePayAvailable":
            self = .isLinePayAvailable
        case "getLinePayPrime":
            self = .getLinePayPrime
        case "redirectToLinePay":
            self = .redirectToLinePay
        default:
            self = .undefined
        }
    }
}

public class SwiftTappayflutterpluginPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tappayflutterplugin", binaryMessenger: registrar.messenger())
        let instance = SwiftTappayflutterpluginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        TPDLinePay.addExceptionObserver(#selector(tappayLinePayExceptionHandler(notofication:)))
        TPDEasyWallet.addExceptionObserver(#selector(tappayEasyWalletExceptionHandler(notofication:)))
        return true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        TPDLinePay.handle(url)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            let easyWalletHandled = TPDEasyWallet.handleUniversalLink(url)
            if (easyWalletHandled) {
                return true
            }
        }
        return true
    }
    
    @objc private func tappayLinePayExceptionHandler(notofication: Notification) {
        let result = TPDLinePay.parseURL(notofication)
        debugPrint("status: \(result.status)")
        debugPrint("orderNumber: \(result.orderNumber ?? "")")
        debugPrint("recTradeid: \(result.recTradeId ?? "")")
        debugPrint("bankTransactionId: \(result.bankTransactionId ?? "")")
    }
    
    @objc private func tappayEasyWalletExceptionHandler(notofication: Notification) {
        guard let result = TPDEasyWallet.parseURL(notofication) else {
            debugPrint("TPDEasyWalletResult is nil")
            return
        }
        debugPrint("status: \(result.status)")
        debugPrint("orderNumber: \(result.orderNumber ?? "")")
        debugPrint("recTradeid: \(result.recTradeId ?? "")")
        debugPrint("bankTransactionId: \(result.bankTransactionId ?? "")")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        let method = Call(call.method) ?? .undefined
        guard let args = call.arguments as? [String:Any] else {
            result("args cast error")
            return
        }

        switch method {
        case .setupTappay:
            setupTappay(args: args) { (error) in
                result(error)
            }
            
        case .isCardValid:
            result(isCardValid(args: args))
            
        case .getPrime:
            getPrime(args: args) { (prime) in
                result(prime)
            } failCallBack: { (message) in
                result(message)
            }
            
        case .isEasyWalletAvailable:
            result(isEasyWalletAvailable())
            
        case .getEasyWalletPrime:
            getEasyWalletPrime(args: args) { (prime) in
                result(prime)
            } failCallBack: { (message) in
                result(message)
            }
            
        case .redirectToEasyWallet:
            redirectToEasyWallet(args: args) { (callBack) in
                result(callBack)
            }
            
        case .isLinePayAvailable:
            result(isLinePayAvailable())
            
        case .getLinePayPrime:
            getLinePayPrime(args: args) { (prime) in
                result(prime)
            } failCallBack: { (message) in
                result(message)
            }

        case .redirectToLinePay:
            redirectToLinePay(args: args) { (callBack) in
                result(callBack)
            }

        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    /// 設置 `Tappay` 環境
    private func setupTappay(args: [String: Any], errorMessage: @escaping(String) -> Void) {
        
        var message = ""
        
        let appId = (args["appId"] as? Int32 ?? 0)
        let appKey = (args["appKey"] as? String ?? "")
        let serverType = (args["serverType"] as? String ?? "")
        
        if appId == 0 {
            message += "appId error"
        }
        
        if appKey.isEmpty {
            message += "/appKey error"
        }
        
        if serverType.isEmpty {
            message += "/serverType error"
        }
        
        if !message.isEmpty {
            errorMessage(message)
            return
        }

        let type = serverType == "sandBox" ? TPDServerType.sandBox : TPDServerType.production

        TPDSetup.setWithAppId(appId, withAppKey: appKey, with: type)
//        TPDSetup.shareInstance().setupIDFA(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
//        TPDSetup.shareInstance().serverSync()
    }
    
    /// 檢查信用卡的有效性
    private func isCardValid(args: [String:Any]) -> Bool {
        
        let cardNumber = (args["cardNumber"] as? String ?? "")
        let dueMonth = (args["dueMonth"] as? String ?? "")
        let dueYear = (args["dueYear"] as? String ?? "")
        let ccv = (args["ccv"] as? String ?? "")

        guard let cardValidResult = TPDCard.validate(
            withCardNumber: cardNumber,
            withDueMonth: dueMonth,
            withDueYear: dueYear,
            withCCV: ccv)
        else {
            return false
        }
        return cardValidResult.isCardNumberValid && cardValidResult.isExpiryDateValid && cardValidResult.isCCVValid
    }
    
    /// 取得 `Prime`
    private func getPrime(args: [String: Any], prime: @escaping(String) -> Void, failCallBack: @escaping(String) -> Void) {
        
        let cardNumber = (args["cardNumber"] as? String ?? "")
        let dueMonth = (args["dueMonth"] as? String ?? "")
        let dueYear = (args["dueYear"] as? String ?? "")
        let ccv = (args["ccv"] as? String ?? "")
        
        let card = TPDCard.setWithCardNumber(cardNumber, withDueMonth: dueMonth, withDueYear: dueYear, withCCV: ccv)
        card
            .onSuccessCallback { (tpPrime, cardInfo, cardIdentifier, merchantReferenceInfo) in
                if let tpPrime = tpPrime {
                    prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"\(tpPrime)\"}")
                }
            }
            .onFailureCallback { (status, message) in
                failCallBack("{\"status\":\"\(status)\", \"message\":\"\(message)\", \"prime\":\"\"}")
            }
            .createToken(withGeoLocation: "UNKNOWN")
    }
    
    /// 檢查是否有安裝 Easy wallet
    private func isEasyWalletAvailable() -> Bool {
        TPDEasyWallet.isEasyWalletAvailable()
    }
    
    /// 取得Easy wallet prime
    private func getEasyWalletPrime(args: [String:Any], prime: @escaping(String) -> Void, failCallBack: @escaping(String) -> Void) {
        
        let universalLink = (args["universalLink"] as? String ?? "")
        
        if (universalLink.isEmpty) {
            failCallBack("{\"status\":\"\", \"message\":\"universalLink is empty\", \"prime\":\"\"}")
            return
        }
        
        let easyWallet = TPDEasyWallet.setup(withReturUrl: universalLink)
        easyWallet.onSuccessCallback { (tpPrime) in
            
            if let tpPrime = tpPrime {
                prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"\(tpPrime)\"}")
            }
            
        }.onFailureCallback { (status, message) in
            
            failCallBack("{\"status\":\"\(status)\", \"message\":\"\(message)\", \"prime\":\"\"}")
            
        }.getPrime()
        
    }
    
    /// 重導向至Easy wallet
    private func redirectToEasyWallet(args: [String:Any], callBack: @escaping(String) -> Void) {

        let universalLink = (args["universalLink"] as? String ?? "")
        let easyWallet = TPDEasyWallet.setup(withReturUrl: universalLink)
        
        let paymentUrl = (args["paymentUrl"] as? String ?? "")
        easyWallet.redirect(paymentUrl) { result in
            callBack("{\"status\":\"\(String(result.status))\", \"recTradeId\":\"\(String(result.recTradeId))\", \"orderNumber\":\"\(String(result.orderNumber))\", \"bankTransactionId\":\"\(String(result.bankTransactionId))\"}")
        }
    }
    
    /// 檢查是否有安裝Line pay
    private func isLinePayAvailable() -> Bool {
        TPDLinePay.isLinePayAvailable()
    }
    
    
    /// 取得line pay prime
    private func getLinePayPrime(args: [String:Any], prime: @escaping(String) -> Void, failCallBack: @escaping(String) -> Void) {
        
        let universalLink = (args["universalLink"] as? String ?? "")
        
        if (universalLink.isEmpty) {
            failCallBack("{\"status\":\"\", \"message\":\"universalLink is empty\", \"prime\":\"\"}")
            return
        }
        
        let linePay = TPDLinePay.setup(withReturnUrl: universalLink)
        linePay
            .onSuccessCallback { (tpPrime) in
                if let tpPrime = tpPrime {
                    prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"\(tpPrime)\"}")
                }
            }
            .onFailureCallback { (status, message) in
                failCallBack("{\"status\":\"\(status)\", \"message\":\"\(message)\", \"prime\":\"\"}")

            }
            .getPrime()
        
    }
    
    /// 重導向至 Line Pay
    private func redirectToLinePay(args: [String:Any], callBack: @escaping(String) -> Void) {
        let universalLink = (args["universalLink"] as? String ?? "")
        let linePay = TPDLinePay.setup(withReturnUrl: universalLink)
        let paymentUrl = (args["paymentUrl"] as? String ?? "")
        
//        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
//                    return w.isHidden == false
//         }).first?.rootViewController
        
        guard let vc = UIApplication.shared.delegate?.window??.rootViewController else {
            return
        }
        
        linePay.redirect(paymentUrl, with: vc) { result in
            callBack("{\"status\":\"\(String(result.status))\", \"recTradeId\":\"\(String(result.recTradeId))\", \"orderNumber\":\"\(String(result.orderNumber))\", \"bankTransactionId\":\"\(String(result.bankTransactionId))\"}")
        }
    }
}
