import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({required this.controller, required this.url, Key? key})
      : super(key: key);

  final String url;

  final Completer<WebViewController> controller;

  @override
  _WebViewStackState createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;
  @override
  void initState() {
    super.initState();
    //if (Platform.isAndroid) {
    // WebView.platform = SurfaceAndroidWebView();
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: Builder(builder: (BuildContext context) {
      return buildStack(context);
    })));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return buildStack(context);
  // }

  Widget buildStack(BuildContext context) {
    return Stack(
      children: [
        WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (webViewController) {
            widget.controller.complete(webViewController);
          },
          onPageStarted: (url) {
            if (kDebugMode) {
              print('Page started loading: $url');
            }
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            if (kDebugMode) {
              print('Page finished loading: $url');
            }
            setState(() {
              loadingPercentage = 100;
            });
          },
          navigationDelegate: (navigation) {
            // final host = Uri.parse(navigation.url).host;
            // if (host.contains('youtube.com')) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text(
            //         'Blocking navigation to $host',
            //       ),
            //     ),
            //   );
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }
}
