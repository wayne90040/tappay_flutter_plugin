import 'package:flutter/material.dart';
import 'package:tappayflutterplugin/tappayflutterplugin.dart';
import 'constant.dart';

class GooglePayScreen extends StatefulWidget {
  @override
  _GooglePayScreenState createState() => _GooglePayScreenState();
}

class _GooglePayScreenState extends State<GooglePayScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('GooglePay'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'appId: ${appId.toString()}',
              textAlign: TextAlign.center,
            ),
            Text(
              'appKey: $appKey',
              textAlign: TextAlign.center,
            ),
            Text(
              'serverType: ${serverType == TapPayServerType.sandBox ? 'sandBox' : 'production'}',
              textAlign: TextAlign.center,
            ),
            Container(
              color: Colors.blue,
              child: MaterialButton(
                onPressed: () {
                  Tappayflutterplugin.setupTapPay(
                      appId: appId,
                      appKey: appKey,
                      serverType: TapPayServerType.sandBox,
                      errorMessage: (error) {
                        print(error);
                      });
                },
                child: Text('Setup Tappay'),
              ),
            ),
            Container(
              color: Colors.blue,
              child: MaterialButton(
                onPressed: () {
                  Tappayflutterplugin.preparePaymentData(
                    allowedNetworks: [
                      TPDCardType.masterCard,
                    ],
                    allowedAuthMethods: [
                      TPDCardAuthMethod.panOnly,
                    ],
                    merchantName: 'TEST MERCHANT',
                    isShippingAddressRequired: false,
                    isEmailRequired: false,
                    isPhoneNumberRequired: false,
                  );
                },
                child: Text('Prepare google pay'),
              ),
            ),
            Container(
              color: Colors.blue,
              child: MaterialButton(
                onPressed: () async {
                  await Tappayflutterplugin.requestPaymentData('100', 'TWD');
                },
                child: Text('Request payment data'),
              ),
            ),
            Container(
              color: Colors.blue,
              child: MaterialButton(
                onPressed: () async {
                  await Tappayflutterplugin.getGooglePayPrime();
                },
                child: Text('Get google pay prime'),
              ),
            ),
          ],
        ),
      );
}
