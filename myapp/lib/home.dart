import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'web_view_stack.dart';

class EnvironmentConfig {
  static const brokerUrl = String.fromEnvironment('BROKER_URL');
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Completer<WebViewController>();
  //buildWebViewStack()
  //List<Widget> _widgets = []; //..length = 2;

  var _widgets = <Widget>[];
  @override
  void initState() {
    super.initState();
    //_widgets[0] = buildWebViewStack(context);
  }

  @override
  Widget build(BuildContext context) {
    //_widgets[0] = buildWebViewStack(context);
    // setState(() {
    //   _widgets[0] = buildWebViewStack(context);
    // });
    _widgets.add(buildWebViewStack(context));
    return buildStack(context);
  }

  Widget buildScaffold(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: Builder(builder: (BuildContext context) {
      return buildWebViewStack(context);
    })));
  }

  JavascriptChannel _fingerprintJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Findgerprint',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Widget createRedWidget() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
    );
  }

  Widget buildStack(BuildContext context) {
    return Stack(
      //alignment: Alignment.center,
      children: _widgets,

      // [ buildWebViewStack(context), ]
      // if (loadingPercentage < 100)
      //   LinearProgressIndicator(
      //     value: loadingPercentage / 100.0,
      //   ),
    );
  }

  Widget buildWebViewStack(BuildContext context) {
    return WebViewStack(
        controller: controller, url: EnvironmentConfig.brokerUrl);
  }
}
