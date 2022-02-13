import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_cache_manager/flutter_cache_manager.dart';
//import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:local_auth/local_auth.dart';
import 'app_auth_api.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({required this.controller, required this.url, Key? key})
      : super(key: key);

  final String url;

  final Completer<WebViewController> controller;

  @override
  _WebViewStackState createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  bool _hasBioSensor = false;
  bool _isDispatchPageFinished = false;

  var loadingPercentage = 0;
  var _webViewController;

  @override
  initState() {
    super.initState();
    //_checkBiometrics();
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
      //alignment: Alignment.center,
      children: [
        buildWebView(context),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }

  _checkBiometrics() async {
    _hasBioSensor = await LocalAuthApi.hasBiometrics();
  }

  Future<bool> _checkAuth() async {
    return await LocalAuthApi.authenticate();
    //return isAuth;
  }

  JavascriptChannel _appJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'MobileApp',
        onMessageReceived: (JavascriptMessage jsmmessage) {
          print(jsmmessage.message);
          if (_hasBioSensor &&
              jsmmessage.message.length == 7 &&
              'checkid' == jsmmessage.message) {
            _onCheckidstatus(_webViewController, context);
          }
        });
  }

  Widget buildWebView(BuildContext context) {
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      zoomEnabled: true,
      javascriptChannels:
          <JavascriptChannel>[_appJavascriptChannel(context)].toSet(),
      onWebViewCreated: (webViewController) {
        print('*** onWebViewCreated, $webViewController');
        setState(() {
          _webViewController = webViewController;
        });
      },
      onWebResourceError: (error) {
        print('***** Error: $error');
        print('*****[' +
            error.description +
            '] [' +
            error.errorCode.toString() +
            '] [' +
            error.errorType.toString() +
            '] [' +
            error.failingUrl.toString() +
            ']');
        //widget.webViewController
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
        //final path = Uri.parse(url).path;
        if (kDebugMode) {
          print('Page finished loading: $url');
        }
        setState(() {
          loadingPercentage = 100;
        });

        if (url.indexOf('ionelmanolache') > -1 ||
            url.indexOf('fortune-login') > -1) {
          _dispatchPageFinished(this._webViewController, context);
        }
      },
      navigationDelegate: (navigation) async {
        print('***navigationDelegate, $navigation');
        if (navigation.url.contains('documents') ||
            navigation.url.contains('pdf')) {
          await launch(navigation.url);
          return NavigationDecision.prevent;
        } else {
          return NavigationDecision.navigate;
        }
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
    );
  }

  Future<void> _dispatchPageFinished(
      WebViewController _webController, BuildContext context) async {
    print('dispatchPageFinished (1)');
    // if (!_isDispatchPageFinished) {
    //   print('dispatchPageFinished (2)');

    String appJs = await jsInjectionString(context, 'assets/app.js');
    _webController.runJavascript(appJs);

    await _webController.runJavascript(
        'window.document.dispatchEvent(createEvent("deviceready", {}));'); // {hasBioSensor:$_hasBioSensor}));');
  }

  Future<void> _onCheckidstatus(
      WebViewController controller, BuildContext context) async {
    bool isAuth = await _checkAuth();
    String jsScript =
        'checkidStatus({checkidstatus:$isAuth, biometrics:$_hasBioSensor})';
    await controller.runJavascript(jsScript);
  }

  Future<void> _onAddToCache(
      WebViewController controller, BuildContext context) async {
    await controller.runJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  // Build the javascript injection string
  Future<String> jsInjectionString(BuildContext context, String asset) async {
    String appJsScript = await loadStringAsset(context, asset);
    return "const appJs = document.createElement('script');"
        "appJs.textContent = `$appJsScript`;"
        "document.head.append(appJs);";
  }

  // Load a string asset
  Future<String> loadStringAsset(BuildContext context, String asset) async {
    return await DefaultAssetBundle.of(context).loadString(asset);
  }
}
