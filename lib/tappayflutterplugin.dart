import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

enum TapPayServerType { sandBox, production }

enum TPDCardType { unknown, visa, masterCard, jcb, americanExpress, unionPay }

enum TPDCardAuthMethod { panOnly, cryptogram3ds }

enum TPDMethod {
  setupTappay,
  isCardValid,
  getPrime,
  isEasyWalletAvailable,
  getEasyWalletPrime,
  redirectToEasyWallet,
  parseToEasyWalletResult,
  getEasyWalletResult,
  isLinePayAvailable,
  getLinePayPrime,
  redirectToLinePay,
  parseToLinePayResult,
  getLinePayResult,
  preparePaymentData,
  requestPaymentData,
  getGooglePayPrime,
  setupMerchant,
  setupConsumer,
  setupCart,
  addCartItem,
  canMakeApplePayments,
  startApplePay
}

extension TPDMethodExtension on TPDMethod {
  String get name {
    switch (this) {
      case TPDMethod.setupTappay:
        return "setupTappay";
      case TPDMethod.isCardValid:
        return "isCardValid";
      case TPDMethod.getPrime:
        return "getPrime";
      case TPDMethod.isEasyWalletAvailable:
        return "isEasyWalletAvailable";
      case TPDMethod.getEasyWalletPrime:
        return "getEasyWalletPrime";
      case TPDMethod.redirectToEasyWallet:
        return "redirectToEasyWallet";
      case TPDMethod.parseToEasyWalletResult:
        return "parseToEasyWalletResult";
      case TPDMethod.getEasyWalletResult:
        return "getEasyWalletResult";
      case TPDMethod.isLinePayAvailable:
        return "isLinePayAvailable";
      case TPDMethod.getLinePayPrime:
        return "getLinePayPrime";
      case TPDMethod.redirectToLinePay:
        return "redirectToLinePay";
      case TPDMethod.parseToLinePayResult:
        return "parseToLinePayResult";
      case TPDMethod.getLinePayResult:
        return "getLinePayResult";
      case TPDMethod.preparePaymentData:
        return "preparePaymentData";
      case TPDMethod.requestPaymentData:
        return "requestPaymentData";
      case TPDMethod.getGooglePayPrime:
        return "getGooglePayPrime";
      case TPDMethod.setupMerchant:
        return "setupMerchant";
      case TPDMethod.setupConsumer:
        return "setupConsumer";
      case TPDMethod.setupCart:
        return "setupCart";
      case TPDMethod.addCartItem:
        return "addCartItem";
      case TPDMethod.canMakeApplePayments:
        return "canMakeApplePayments";
      case TPDMethod.startApplePay:
        return "startApplePay";
    }
  }
}

class PrimeModel {
  String? status;
  String? message;
  String? prime;

  PrimeModel({
    this.status,
    this.message,
    this.prime,
  });

  PrimeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    prime = json['prime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['prime'] = this.prime;
    return data;
  }
}

class TPDEasyWalletResult {
  String? status;
  String? recTradeId;
  String? orderNumber;
  String? bankTransactionId;

  TPDEasyWalletResult({
    this.status,
    this.recTradeId,
    this.orderNumber,
    this.bankTransactionId,
  });

  TPDEasyWalletResult.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    recTradeId = json['recTradeId'];
    orderNumber = json['orderNumber'];
    bankTransactionId = json['bankTransactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['recTradeId'] = this.recTradeId;
    data['orderNumber'] = this.orderNumber;
    data['bankTransactionId'] = this.bankTransactionId;
    return data;
  }
}

class TPDLinePayResult {
  String? status;
  String? recTradeId;
  String? orderNumber;
  String? bankTransactionId;

  TPDLinePayResult({
    this.status,
    this.recTradeId,
    this.orderNumber,
    this.bankTransactionId,
  });

  TPDLinePayResult.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    recTradeId = json['recTradeId'];
    orderNumber = json['orderNumber'];
    bankTransactionId = json['bankTransactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['recTradeId'] = this.recTradeId;
    data['orderNumber'] = this.orderNumber;
    data['bankTransactionId'] = this.bankTransactionId;
    return data;
  }
}

class Tappayflutterplugin {
  static const MethodChannel _channel =
      const MethodChannel('tappayflutterplugin');

  static Future<String> get platformVersion async =>
      await _channel.invokeMethod('getPlatformVersion');

  /// 設置Tappay環境
  static Future<void> setupTapPay({
    required int appId,
    required String appKey,
    required TapPayServerType serverType,
    required Function(String) errorMessage,
  }) async {
    String st = '';
    switch (serverType) {
      case TapPayServerType.sandBox:
        st = 'sandBox';
        break;
      case TapPayServerType.production:
        st = 'production';
        break;
    }

    final String? error = await _channel.invokeMethod(
      TPDMethod.setupTappay.name,
      {
        'appId': appId,
        'appKey': appKey,
        'serverType': st,
      },
    );

    if (error != null) {
      errorMessage(error);
    }
  }

  /// 檢查信用卡的有效性
  static Future<bool> isCardValid({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String ccv,
  }) async {
    final bool isValid = await _channel.invokeMethod(
      TPDMethod.isCardValid.name,
      {
        'cardNumber': cardNumber,
        'dueMonth': dueMonth,
        'dueYear': dueYear,
        'ccv': ccv,
      },
    );
    return isValid;
  }

  /// 取得Prime
  static Future<PrimeModel> getPrime({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String ccv,
  }) async {
    String response = await _channel.invokeMethod(
      TPDMethod.getPrime.name,
      {
        'cardNumber': cardNumber,
        'dueMonth': dueMonth,
        'dueYear': dueYear,
        'ccv': ccv,
      },
    );

    return PrimeModel.fromJson(json.decode(response));
  }

  /// 檢查是否有安裝 Easy Wallet
  static Future<bool> isEasyWalletAvailable() async =>
      await _channel.invokeMethod(
        TPDMethod.isEasyWalletAvailable.name,
        {},
      );

  /// 取得 Easy Wallet Prime
  static Future<PrimeModel> getEasyWalletPrime({
    required String universalLink,
  }) async {
    String response = await _channel.invokeMethod(
      TPDMethod.getEasyWalletPrime.name,
      {
        'universalLink': universalLink,
      },
    );
    return PrimeModel.fromJson(json.decode(response));
  }

  /// 重導向至 Easy Wallet
  static Future<TPDEasyWalletResult> redirectToEasyWallet({
    required String universalLink,
    required String paymentUrl,
  }) async {
    String result = await _channel.invokeMethod(
      TPDMethod.redirectToEasyWallet.name,
      {
        'universalLink': universalLink,
        'paymentUrl': paymentUrl,
      },
    );
    return TPDEasyWalletResult.fromJson(json.decode(result));
  }

  /// 解析 Easy Wallet Result
  static Future<void> parseToEasyWalletResult({
    required String universalLink,
    required String uri,
  }) async =>
      await _channel.invokeMethod(
        TPDMethod.parseToEasyWalletResult.name,
        {
          'universalLink': universalLink,
          'uri': uri,
        },
      );

  /// 取得Easy wallet result
  static Future<TPDEasyWalletResult?> getEasyWalletResult() async {
    String result = await _channel.invokeMethod(
      TPDMethod.getEasyWalletResult.name,
    );
    try {
      return TPDEasyWalletResult.fromJson(json.decode(result));
    } catch (e) {
      return null;
    }
  }

  /// 檢查是否有安裝 Line Pay
  static Future<bool> isLinePayAvailable() async => await _channel.invokeMethod(
        TPDMethod.isLinePayAvailable.name,
        {},
      );

  /// 取得Line pay prime
  static Future<PrimeModel> getLinePayPrime({
    required String universalLink,
  }) async {
    String response = await _channel.invokeMethod(
      TPDMethod.getLinePayPrime.name,
      {
        'universalLink': universalLink,
      },
    );
    return PrimeModel.fromJson(json.decode(response));
  }

  /// 重導向至LinePay
  static Future<TPDLinePayResult> redirectToLinePay({
    required String universalLink,
    required String paymentUrl,
  }) async {
    String result = await _channel.invokeMethod(
      TPDMethod.redirectToLinePay.name,
      {
        'universalLink': universalLink,
        'paymentUrl': paymentUrl,
      },
    );
    return TPDLinePayResult.fromJson(json.decode(result));
  }

  /// 解析line pay result
  static Future<void> parseToLinePayResult({
    required String universalLink,
    required String uri,
  }) async =>
      await _channel.invokeMethod(
        TPDMethod.parseToLinePayResult.name,
        {
          'universalLink': universalLink,
          'uri': uri,
        },
      );

  /// 取得line pay result
  static Future<TPDLinePayResult?> getLinePayResult() async {
    String result = await _channel.invokeMethod(
      TPDMethod.getLinePayResult.name,
    );
    try {
      return TPDLinePayResult.fromJson(json.decode(result));
    } catch (e) {
      return null;
    }
  }

  /// GooglePay prepare payment data
  static Future<void> preparePaymentData({
    required List<TPDCardType> allowedNetworks,
    required List<TPDCardAuthMethod> allowedAuthMethods,
    required String merchantName,
    required bool isPhoneNumberRequired,
    required bool isShippingAddressRequired,
    required bool isEmailRequired,
  }) async {
    List<int> networks = [];
    for (var i in allowedNetworks) {
      int value;
      switch (i) {
        case TPDCardType.unknown:
          value = 0;
          break;
        case TPDCardType.visa:
          value = 2;
          break;
        case TPDCardType.masterCard:
          value = 3;
          break;
        case TPDCardType.jcb:
          value = 1;
          break;
        case TPDCardType.americanExpress:
          value = 4;
          break;
        case TPDCardType.unionPay:
          value = 5;
          break;
      }
      networks.add(value);
    }
    List<int> methods = [];
    for (var i in allowedAuthMethods) {
      int value;
      switch (i) {
        case TPDCardAuthMethod.panOnly:
          value = 0;
          break;
        case TPDCardAuthMethod.cryptogram3ds:
          value = 1;
          break;
      }
      methods.add(value);
    }

    await _channel.invokeMethod(
      TPDMethod.preparePaymentData.name,
      {
        'allowedNetworks': networks,
        'allowedAuthMethods': methods,
        'merchantName': merchantName,
        'isPhoneNumberRequired': isPhoneNumberRequired,
        'isShippingAddressRequired': isShippingAddressRequired,
        'isEmailRequired': isEmailRequired,
      },
    );
  }

  /// request google pay payment data
  static Future<void> requestPaymentData(
    String totalPrice,
    String currencyCode,
  ) async =>
      await _channel.invokeMethod(
        TPDMethod.requestPaymentData.name,
        {
          'totalPrice': totalPrice,
          'currencyCode': currencyCode,
        },
      );

  /// Get google pay prime
  static Future<void> getGooglePayPrime() async =>
      await _channel.invokeMethod(TPDMethod.getGooglePayPrime.name);

  /// Setup Apple Pay Merchant
  static Future<void> setupMerchant({
    required String merchantName,
    required String applePayMerchantIdentifier,
    required String countryCode,
    required String currencyCode,
  }) async =>
      await _channel.invokeMethod(
        TPDMethod.setupMerchant.name,
        {
          'merchantName': merchantName,
          'applePayMerchantIdentifier': applePayMerchantIdentifier,
          'countryCode': countryCode,
          'currencyCode': currencyCode,
        },
      );

  /// Setup Apple Pay Consumer
  static Future<void> setupConsumer() async => await _channel.invokeMethod(
        TPDMethod.setupConsumer.name,
        {},
      );

  /// Setup Apple Pay Cart
  static Future<void> setupCart() async => await _channel.invokeMethod(
        TPDMethod.setupCart.name,
        {
          'isAmountPending': true,
          'isShowTotalAmount': false,
        },
      );

  /// Add Item to Cart when use Apple Pay
  static Future<void> addCartItem({
    required String itemName,
    required String withAmount,
  }) async =>
      await _channel.invokeMethod(
        TPDMethod.addCartItem.name,
        {
          'itemName': itemName,
          'withAmount': withAmount,
        },
      );

  /// Can use apple pay
  static Future<bool> canMakeApplePayments() async =>
      await _channel.invokeMethod(
        TPDMethod.canMakeApplePayments.name,
        {},
      );

  /// Start Apple pay
  static Future<void> startApplePay() async => await _channel.invokeMethod(
        TPDMethod.startApplePay.name,
        {},
      );
}
