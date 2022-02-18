import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app_js_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'app_auth_api.dart';
import 'check_internet.dart';

class WebViewStack extends StatefulWidget {
  WebViewStack({required this.url, Key? key}) : super(key: key);

  final String url;

  final waitMillisWhenPageFinished = Platform.isAndroid
      ? Duration(milliseconds: 100)
      : Duration(milliseconds: 1000);

  final controller = Completer<WebViewController>();

  @override
  _WebViewStackState createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  int _loadingPercentage = 0;
  final _checkInternet = CheckInternet();
  final _appJsChannel = AppJavascriptChannel();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  initState() {
    super.initState();
    _checkInternet.checkConnection(context);
  }

  @override
  void dispose() {
    debugPrint('dispose');

    _checkInternet.listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: Builder(builder: (BuildContext context) {
      return buildStack(context);
    })));
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: buildStack(context),
    ));
  }
*/
/*
  @override
  Widget build(BuildContext context) {
    return buildStack(context);
  }
*/

  Widget buildStack(BuildContext context) {
    return Stack(
      //alignment: Alignment.center,
      children: [
        ...buidlWidgets(),
        //if (_loadingPercentage < 100) Text("Loading ..."),
        if (_loadingPercentage < 100)
          LinearProgressIndicator(
            value: _loadingPercentage / 100.0,
          ),
      ],
    );
  }

  Set<Widget> buidlWidgets() {
    Set<Widget> widgets = Set();
    widgets.add(buildWebView(context));
    if (kDebugMode) {
      Widget w = FloatingActionButton(
          child: Icon(Icons.import_export, size: 32),
          onPressed: () async {
            _appJsChannel.sendDeviceready(await widget.controller.future);
          });
      widgets.add(w);
    }
    return widgets;
  }

  Widget buildWebView(BuildContext context) {
    SurfaceAndroidWebView;
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      zoomEnabled: true,
      debuggingEnabled: true,
      javascriptChannels:
          <JavascriptChannel>[_appJavascriptChannel(context)].toSet(),
      onWebViewCreated: (webViewController) {
        if (kDebugMode) {
          print('*** onWebViewCreated, $webViewController');
        }
        //isAppJsLoaded = false;
        webViewController.clearCache();
        widget.controller.complete(webViewController);
      },
      onWebResourceError: (error) {
        widget.controller.completeError(error);
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
          _loadingPercentage = 0;
        });
      },
      onProgress: (progress) {
        setState(() {
          _loadingPercentage = progress;
        });
      },
      onPageFinished: (url) {
        //final path = Uri.parse(url).path;
        if (kDebugMode) {
          print('Page finished loading: $url');
        }
        setState(() {
          _loadingPercentage = 100;
        });

        if (url.indexOf('ionelmanolache') > -1 ||
            url.indexOf('fortune-login') > -1 ||
            url.indexOf('flatex-cfd-login') > -1 ||
            url.indexOf('cfdapp.comdirect.de') > -1) {
          //
          _appJsChannel.setupJavascriptChannel(
              context, widget.controller, widget.waitMillisWhenPageFinished);
          //
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
        }
        return NavigationDecision.navigate;
      },
    );
  }

//======================================================
  Future<Map<String, dynamic>> _api_set(Map<String, dynamic> data) async {
    bool isAuth = await LocalAuthApi.authenticate(null);
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
    bool isAuth = await LocalAuthApi.authenticate(usermessage);
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
    bool value = await LocalAuthApi.hasBiometrics();
    return {"resp": value};
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

          final ctrl = await widget.controller.future;
          ctrl.runJavascript(jscript);
        });
  }
}
