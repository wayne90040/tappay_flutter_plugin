import Flutter
import UIKit
import TPDirect
import AdSupport
import Foundation
import PassKit

public enum Call {
    case setupTappay
    case isCardValid
    case getPrime

    // Easy Pay
    case isEasyWalletAvailable
    case getEasyWalletPrime
    case redirectToEasyWallet

    // Line Pay
    case isLinePayAvailable
    case getLinePayPrime
    case redirectToLinePay

    // Apple Pay
    case setupMerchant
    case setupConsumer
    case setupCart
    case addCartItem
    case canMakeApplePayments
    case startApplePay

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
        case "setupMerchant":
            self = .setupMerchant
        case "setupConsumer":
            self = .setupConsumer
        case "setupCart":
            self = .setupCart
        case "addCartItem":
            self = .addCartItem
        case "canMakeApplePayments":
            self = .canMakeApplePayments
        case "startApplePay":
            self = .startApplePay
        default:
            self = .undefined
        }
    }
}

public class SwiftTappayflutterpluginPlugin: NSObject, FlutterPlugin {

    var merchant : TPDMerchant!
    var consumer : TPDConsumer!
    var cart     : TPDCart!
    var applePay : TPDApplePay!

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
            setupTappay(args: args) { error in
                result(error)
            }

        case .isCardValid:
            result(isCardValid(args: args))
            
        case .getPrime:
            getPrime(args: args) { prime in
                result(prime)
            } failCallBack: { message in
                result(message)
            }
            
        case .isEasyWalletAvailable:
            result(isEasyWalletAvailable())
            
        case .getEasyWalletPrime:
            getEasyWalletPrime(args: args) { prime in
                result(prime)
            } failCallBack: { message in
                result(message)
            }
            
        case .redirectToEasyWallet:
            redirectToEasyWallet(args: args) { callBack in
                result(callBack)
            }
            
        case .isLinePayAvailable:
            result(isLinePayAvailable())
            
        case .getLinePayPrime:
            getLinePayPrime(args: args) { prime in
                result(prime)
            } failCallBack: { message in
                result(message)
            }

        case .redirectToLinePay:
            redirectToLinePay(args: args) { callBack in
                result(callBack)
            }

        case .setupMerchant:
            setupMerchant(args: args)

        case .setupConsumer:
            setupConsumer(args: args)

        case .setupCart:
            setupCart(args: args)

        case .addCartItem:
            addCartItem(args: args)

        case .canMakeApplePayments:
            result(canMakeApplePayments())

        case .startApplePay:
            startApplePay()

        default:
            result("iOS \(UIDevice.current.systemVersion)")
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
}

// MARK: - Easy Wallet
extension SwiftTappayflutterpluginPlugin {
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
}

// MARK: - Line Pay
extension SwiftTappayflutterpluginPlugin {
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

// MARK: - Apple Pay
extension SwiftTappayflutterpluginPlugin {

    // TODO:
    private func setupMerchant(args: [String: Any]) {
        merchant = TPDMerchant()
        merchant.merchantName = args["merchantName"] as? String ?? ""
        merchant.merchantCapability = .capability3DS
        merchant.applePayMerchantIdentifier = args["applePayMerchantIdentifier"] as? String ?? ""
        merchant.countryCode = args["countryCode"] as? String ?? ""
        merchant.currencyCode = args["currencyCode"] as? String ?? ""
        merchant.supportedNetworks = [.visa]
    }

    // TODO:
    private func setupConsumer(args: [String: Any]) {
        consumer = TPDConsumer()
        consumer.requiredShippingAddressFields = [.email, .name, .phone]
        consumer.requiredBillingAddressFields = [.postalAddress]
    }

    // TODO:
    private func setupCart(args: [String: Any]) {
        cart = TPDCart()
        cart.isAmountPending = args["isAmountPending"] as? Bool ?? false
        cart.isShowTotalAmount = args["isShowTotalAmount"] as? Bool ?? false
    }

    private func addCartItem(args: [String: Any]) {
        let item = TPDPaymentItem(
            itemName: args["itemName"] as? String ?? "",
            withAmount: NSDecimalNumber(string: args["withAmount"] as? String ?? "")
        )
        cart.add(item)
    }

    private func canMakeApplePayments() -> Bool {
        TPDApplePay.canMakePayments(usingNetworks: merchant.supportedNetworks)
    }

    private func startApplePay() {
        applePay = TPDApplePay.setupWthMerchant(merchant, with: consumer, with: cart, withDelegate: self)
        applePay.startPayment()
    }
}

extension SwiftTappayflutterpluginPlugin: TPDApplePayDelegate {

    public func tpdApplePayDidStartPayment(_ applePay: TPDApplePay!) {
        debugPrint("=====================================================")
        debugPrint("Apple Pay On Start")
        debugPrint("=====================================================")
    }

    public func tpdApplePay(_ applePay: TPDApplePay!, didSuccessPayment result: TPDTransactionResult!) {
        debugPrint("=====================================================")
        print("Apple Pay Did Success ==> Amount : \(result.amount.stringValue)")
        debugPrint("shippingContact.name : \(applePay.consumer.shippingContact?.name?.givenName ?? "") \( applePay.consumer.shippingContact?.name?.familyName ?? "")")
        debugPrint("shippingContact.emailAddress : \(applePay.consumer.shippingContact?.emailAddress ?? "")")
        debugPrint("shippingContact.phoneNumber : \(applePay.consumer.shippingContact?.phoneNumber?.stringValue ?? "")")
        debugPrint("=====================================================")


    }

    public func tpdApplePay(_ applePay: TPDApplePay!, didFailurePayment result: TPDTransactionResult!) {
        debugPrint("=====================================================")
        debugPrint("Apple Pay Did Failure ==> Message : \(result.message ?? ""), ErrorCode : \(result.status)")
        debugPrint("=====================================================")
    }

    public func tpdApplePayDidCancelPayment(_ applePay: TPDApplePay!) {
        debugPrint("=====================================================")
        debugPrint("Apple Pay Did Cancel")
        debugPrint("=====================================================")
    }

    public func tpdApplePayDidFinishPayment(_ applePay: TPDApplePay!) {
        debugPrint("=====================================================")
        debugPrint("Apple Pay Did Finish")
        debugPrint("=====================================================")
    }

    public func tpdApplePay(_ applePay: TPDApplePay!, didSelect shippingMethod: PKShippingMethod!) {
        debugPrint("=====================================================")
        debugPrint("======> didSelectShippingMethod: ")
        debugPrint("Shipping Method.identifier : \(shippingMethod.identifier?.description ?? "")")
        debugPrint("Shipping Method.detail : \(shippingMethod.detail ?? "")")
        debugPrint("=====================================================")
    }

    public func tpdApplePay(_ applePay: TPDApplePay!, didSelect paymentMethod: PKPaymentMethod!, cart: TPDCart!) -> TPDCart! {
        debugPrint("=====================================================");
        debugPrint("======> didSelectPaymentMethod: ");
        debugPrint("=====================================================");
        return self.cart;
    }

    public func tpdApplePay(_ applePay: TPDApplePay!, canAuthorizePaymentWithShippingContact shippingContact: PKContact?) -> Bool {
        debugPrint("=====================================================")
        debugPrint("======> canAuthorizePaymentWithShippingContact ")
        debugPrint("shippingContact.name : \(shippingContact?.name?.givenName ?? "") \(shippingContact?.name?.familyName ?? "")")
        debugPrint("shippingContact.emailAddress : \(shippingContact?.emailAddress ?? "")")
        debugPrint("shippingContact.phoneNumber : \(shippingContact?.phoneNumber?.stringValue ?? "")")
        debugPrint("=====================================================")
        return true;
    }

    // With Payment Handle
    public func tpdApplePay(_ applePay: TPDApplePay!, didReceivePrime prime: String!, withExpiryMillis expiryMillis: Int, with cardInfo: TPDCardInfo, withMerchantReferenceInfo merchantReferenceInfo: [AnyHashable : Any]!) {
        // 1. Send Your Prime To Your Server, And Handle Payment With Result
        // ...
        debugPrint("=====================================================");
        debugPrint("======> didReceivePrime");
        debugPrint("Prime : \(prime!)");
        debugPrint("Expiry millis : \(expiryMillis)");
        debugPrint("total Amount :   \(applePay.cart.totalAmount!)")
        debugPrint("Client IP : \(applePay.consumer.clientIP!)")
        debugPrint("merchantReferenceInfo : \(merchantReferenceInfo["affiliateCodes"]!)")
        debugPrint("shippingContact.name : \(applePay.consumer.shippingContact?.name?.givenName ?? "") \(applePay.consumer.shippingContact?.name?.familyName ?? "")");
        debugPrint("shippingContact.emailAddress : \(applePay.consumer.shippingContact?.emailAddress ?? "")");
        debugPrint("shippingContact.phoneNumber : \(applePay.consumer.shippingContact?.phoneNumber?.stringValue ?? "")");

        let paymentMethod = consumer.paymentMethod!

        debugPrint("type : \(paymentMethod.type.rawValue)")
        debugPrint("Network : \(paymentMethod.network!.rawValue)")
        debugPrint("Display Name : \(paymentMethod.displayName!)")

        debugPrint("=====================================================");

        DispatchQueue.main.async {
            let payment = "Use below cURL to proceed the payment.\ncurl -X POST \\\nhttps://sandbox.tappaysdk.com/tpc/payment/pay-by-prime \\\n-H \'content-type: application/json\' \\\n-H \'x-api-key: partner_6ID1DoDlaPrfHw6HBZsULfTYtDmWs0q0ZZGKMBpp4YICWBxgK97eK3RM\' \\\n-d \'{ \n \"prime\": \"\(prime!)\", \"partner_key\": \"partner_6ID1DoDlaPrfHw6HBZsULfTYtDmWs0q0ZZGKMBpp4YICWBxgK97eK3RM\", \"merchant_id\": \"GlobalTesting_CTBC\", \"details\":\"TapPay Test\", \"amount\": \(applePay.cart.totalAmount!.stringValue), \"cardholder\": { \"phone_number\": \"+886923456789\", \"name\": \"Jane Doe\", \"email\": \"Jane@Doe.com\", \"zip_code\": \"12345\", \"address\": \"123 1st Avenue, City, Country\", \"national_id\": \"A123456789\" }, \"remember\": true }\'"

            debugPrint(payment)
        }

        // 2. If Payment Success, set paymentReault = ture.
        let paymentReault = true;
        applePay.showPaymentResult(paymentReault)
    }
}
