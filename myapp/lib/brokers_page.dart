import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrokersPage extends StatefulWidget {
  const BrokersPage({Key? key}) : super(key: key);
  @override
  _BrokersPageState createState() => _BrokersPageState();
}

class _BrokersPageState extends State<BrokersPage> {
  final _controller = Completer<WebViewController>();

  var _brokers = {
    'comdirect-PROD': 'https://cfdapp.comdirect.de/lp/cfdapp/login',
    'flatex-PROD': 'https://konto.flatex.de/flatex-cfd-login',
    'prelive2-comdirect':
        'https://cfd2.staging.sgmarkets.com/fortune-web-server/static/fortune-login/mobilelogin.html',
    'prelive2-login':
        'https://cfd2.staging.sgmarkets.com/fortune-web-server/static/fortune-login/index.html'
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 96),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 48),
                    Expanded(child: buildBrokers()),
                  ],
                  // _brokers.entries
                  //     .map((e) => _urlButton(context, e.key, e.value))
                  //     .toList();
                ),
              ),
              // Positioned(
              //   left: 16,
              //   top: 24,
              //   child: GestureDetector(
              //     onTap: () => Navigator.of(context).pop(),
              //     child: Icon(Icons.arrow_back, size: 32),
              //   ),
              // ),
            ],
          ),
        ),
      );

  Widget buildBrokers() {
    List<MapEntry<String, String>> brokers = _brokers.entries.toList();

    if (brokers.isEmpty) {
      return Center(
        child: Text(
          'There are no users!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      return ListView.separated(
        itemCount: brokers.length,
        separatorBuilder: (context, index) => Container(height: 12),
        itemBuilder: (context, index) {
          final broker = brokers[index];

          return _urlButton(context, broker.key, broker.value);
        },
      );
    }
  }

  Widget _urlButton(BuildContext context, String name, String url) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: FlatButton(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
          child: Text(name),
          onPressed: () => _handleURLButtonPress(context, url),
        ));
  }

  void _handleURLButtonPress(BuildContext context, String url) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WebViewStack(controller: _controller, url: url)));
  }
}
