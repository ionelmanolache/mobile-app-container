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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: Builder(builder: (BuildContext context) {
      return WebViewStack(
          controller: controller, url: EnvironmentConfig.brokerUrl);
    })));
  }
}
