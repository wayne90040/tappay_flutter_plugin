import 'package:flutter/material.dart';
import 'package:tappayflutterplugin/tappayflutterplugin.dart';
import 'constant.dart';

class LinePayScreen extends StatefulWidget {
  @override
  _LinePayScreenState createState() => _LinePayScreenState();
}

class _LinePayScreenState extends State<LinePayScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('LinePay'),
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
                onPressed: () async {
                  var isLinePayAvailable =
                      await Tappayflutterplugin.isLinePayAvailable();
                  print(isLinePayAvailable.toString());
                },
                child: Text('isLinePayAvailable'),
              ),
            ),
            Container(
              color: Colors.blue,
              child: MaterialButton(
                onPressed: () async {
                  var prime = await Tappayflutterplugin.getLinePayPrime();
                  print(prime);
                },
                child: Text('getLinePayPrime'),
              ),
            ),
          ],
        ),
      );
}
