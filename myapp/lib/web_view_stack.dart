import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'app_auth_api.dart';
import 'check_internet.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({required this.controller, required this.url, Key? key})
      : super(key: key);

  final String url;

  final Completer<WebViewController> controller;

  @override
  _WebViewStackState createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var loadingPercentage = 0;
  var _webViewController;
  CheckInternet checkInternet = CheckInternet();

  @override
  initState() {
    super.initState();
    checkInternet.checkConnection(context);
  }

  @override
  void dispose() {
    checkInternet.listener.cancel();
    super.dispose();
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

  Widget buildWebView(BuildContext context) {
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      zoomEnabled: true,
      javascriptChannels:
          <JavascriptChannel>[_appJavascriptChannel(context)].toSet(),
      onWebViewCreated: (webViewController) {
        if (kDebugMode) {
          print('*** onWebViewCreated, $webViewController');
        }
        setState(() {
          _webViewController = webViewController;
        });
      },
      onWebResourceError: (error) {
        if (kDebugMode) {
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
        }
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
            url.indexOf('fortune-login') > -1 ||
            url.indexOf('flatex-cfd-login') > -1 ||
            url.indexOf('cfdapp.comdirect.de') > -1) {
          _dispatchPageFinished(this._webViewController, context);
        }
      },
      navigationDelegate: (navigation) async {
        if (kDebugMode) {
          print('***navigationDelegate, $navigation');
        }
        if (navigation.url.contains('documents') ||
            navigation.url.contains('pdf')) {
          if (kDebugMode) {
            print('*** PDF download!, $navigation');
          }
          await launch(navigation.url);
          return NavigationDecision.prevent;
        } else {
          return NavigationDecision.navigate;
        }
      },
    );
  }

  Future<void> _dispatchPageFinished(
      WebViewController _webController, BuildContext context) async {
    if (kDebugMode) {
      print('dispatchPageFinished');
    }

    String appJs = await jsInjectionString(context, 'assets/app.js');
    _webController.runJavascript(appJs);

    await _webController.runJavascript(
        'window.document.dispatchEvent(createEvent("deviceready", {}));');
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

//======================================================
  Future<Map<String, dynamic>> _api_set(Map<String, dynamic> data) async {
    bool isAuth = await _checkAuth(null);
    if (isAuth) {
      String key = data["key"];
      Map<String, dynamic> value = data["value"];
      String jsonValue = json.encode(value);

      final SharedPreferences prefs = await _prefs;
      prefs.setString(key, jsonValue);
      return {"resp": true};
    }
    return {"resp": false};
  }

  Future<Map<String, dynamic>> _api_verify(Map<String, dynamic> data) async {
    var key = data["key"].toString();
    var usermessage = data["usermessage"].toString();
    bool isAuth = await _checkAuth(usermessage);
    final SharedPreferences prefs = await _prefs;
    String value = (prefs.getString(key) ?? "");
    return (isAuth && value.trim().length > 0) ? {"resp": value} : {};
  }

  Future<Map<String, dynamic>> _api_has(Map<String, dynamic> data) async {
    var key = data["key"].toString();
    final SharedPreferences prefs = await _prefs;
    String value = (prefs.getString(key) ?? "");
    bool hasValue = value.trim().length > 0;
    return {"resp": hasValue};
  }

  Future<Map<String, dynamic>> _api_delete(Map<String, dynamic> data) async {
    var key = data["key"].toString();
    final SharedPreferences prefs = await _prefs;
    bool value = await prefs.remove(key);
    return {"resp": value};
  }

  Future<Map<String, dynamic>> _api_isavailable(
      Map<String, dynamic> data) async {
    bool value = await _checkBiometrics();
    return {"resp": value};
  }

  //======================================================
  Future<bool> _checkBiometrics() async {
    return await LocalAuthApi.hasBiometrics();
  }

  Future<bool> _checkAuth(final String? userMessage) async {
    return await LocalAuthApi.authenticate(userMessage);
  }

  //======================================================
  get _functions => <String, Function>{
        "has": _api_has,
        "setvalue": _api_set,
        "verify": _api_verify,
        "delete": _api_delete,
        "isavailable": _api_isavailable
      };

  JavascriptChannel _appJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'MobileApp',
        onMessageReceived: (JavascriptMessage msg) async {
          String jsMsg = msg.message;
          if (kDebugMode) {
            print("(1) onMessageReceived=$jsMsg");
          }

          Map<String, dynamic> message = jsonDecode(jsMsg);
          final respData = await _functions[message["api"]](message["data"]);

          message["data"] = respData;
          var respJson = jsonEncode(message);
          String jscript =
              'window.plugins.fingerprint.receiveMessage($respJson)';

          await _webViewController.runJavascript(jscript);
        });
  }
}
