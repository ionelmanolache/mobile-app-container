import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_cache_manager/flutter_cache_manager.dart';
//import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:local_auth/local_auth.dart';
import 'local_auth_api.dart';

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

  //LocalAuthentication authentication = LocalAuthentication();

  var loadingPercentage = 0;
  var _webViewController;
//...later on, probably in response to some event:
//_webViewController.loadUrl('http://dartlang.org/');

  @override
  initState() {
    super.initState();
    //_hasBioSensor = await LocalAuthApi.hasBiometrics();
    //if (Platform.isAndroid) {
    // WebView.platform = SurfaceAndroidWebView();
    //}
    // call method immediately when app launch
    _checkBiometrics();
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

  _checkBiometrics() async {
    _hasBioSensor = await LocalAuthApi.hasBiometrics();
  }

  Future<bool> _checkAuth() async {
    return await LocalAuthApi.authenticate();
    //return isAuth;
  }

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

  Future<void> _dispatchPageFinished(
      WebViewController controller, BuildContext context) async {
    print('dispatchPageFinished (1)');
    if (!_isDispatchPageFinished) {
      print('dispatchPageFinished (2)');

      await controller.runJavascript(
          'window.document.dispatchEvent(new CustomEvent("testevent", {details:"*hello*"}));');

      String jsScript =
          'devicepagefinished({isAvailable:$_hasBioSensor, keyusername:"savedUsername", keypassword:"savedPassword"});';
      print('jsScript=$jsScript');

      await controller.runJavascript(jsScript);

      //_isDispatchPageFinished = true;
    }
    // ignore: deprecated_member_use
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
        // webViewController.clearCache();

        //widget.controller.complete(webViewController);
        //this._webViewController = webViewController;
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
        if (kDebugMode) {
          print('Page finished loading: $url');
        }
        setState(() {
          loadingPercentage = 100;
        });
        final path = Uri.parse(url).host;
        if (path.contains('ionelmanolache')) {
          _dispatchPageFinished(this._webViewController, context);
        }
      },
      navigationDelegate: (navigation) async {
        print('***navigationDelegate, $navigation');
        // if (navigation.url.endsWith('.pdf') || navigation.url.contains('pdf')) {
        //   File file = await DefaultCacheManager().getSingleFile(navigation.url);
        //   var filePath = file.path;
        //   var filesize = file.lengthSync();
        //   print('**** file=[$filePath] ($filesize)');
        //   //PdfView(path: file.path);
        //   return NavigationDecision.prevent;
        // }

        // final path = Uri.parse(navigation.url).path;
        // if (path.contains('pdf')) {
        //   var x = WebView(
        //     initialUrl: (navigation.url),
        //     javascriptMode: JavascriptMode.unrestricted,
        //   );
        //   return NavigationDecision.prevent;
        // }

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

  Widget buildStack0(BuildContext context) {
    //var webView = WebView();
    //var wc = WebChromeClient();
    //webView. se.setWebChromeClient(new MyWebChromeClient());
    //webView.

    return Stack(
      children: [
        WebView(
          initialUrl: widget.url,
          zoomEnabled: true,
          javascriptMode: JavascriptMode.unrestricted,

          //initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,

          //pluginState: WebSettings.PluginState.ON,
          // allowFileAccessFromFileURLs: true,
          // allowUniversalAccessFromFileURLs: true,
          // allowContentAccess: true,
          // allowFileAccess: true,

          onWebViewCreated: (webViewController) {
            print('*** onWebViewCreated, $webViewController');
            webViewController.clearCache();
            widget.controller.complete(webViewController);
            this._webViewController = webViewController;
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
            if (kDebugMode) {
              print('Page finished loading: $url');
            }
            setState(() {
              loadingPercentage = 100;
            });
          },
          navigationDelegate: (navigation) {
            print('***navigationDelegate, $navigation');

            // final path = Uri.parse(navigation.url).path;
            // if (path.contains('pdf')) {
            //   var x = WebView(
            //     initialUrl: (navigation.url),
            //     javascriptMode: JavascriptMode.unrestricted,
            //   );
            //   return NavigationDecision.prevent;
            // }

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

  // permission() async {
  //   await Permission.storage.request();
  // }
}
