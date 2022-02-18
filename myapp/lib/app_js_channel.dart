import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppJavascriptChannel {
  //
  setupJavascriptChannel(
      BuildContext context,
      Completer<WebViewController> controller,
      final Duration milliseconds) async {
    String jsToInject = await jsInjectionString(context);
    controller.future
        // workaround for ios
        .then((ctrl) => wait(ctrl, milliseconds))
        .then((ctrl) => runJavascript(ctrl, jsToInject))
        //.then((c) => Future.delayed(const Duration(milliseconds: 500), () => c))
        .then((ctrl) => sendDeviceready(ctrl))
        .whenComplete(() => {debugPrint('done appjs')})
        .catchError(handleError);
  }

  // Load a string asset
  Future<String> loadStringAsset(BuildContext context, String asset) async {
    return await DefaultAssetBundle.of(context).loadString(asset);
  }

// Build the javascript injection string
  Future<String> jsInjectionString(BuildContext context) async {
    debugPrint('*** load appjs');
    String appJsScript = await loadStringAsset(context, 'assets/app.js');
    return "const appJs = document.createElement('script');"
        "appJs.textContent = `$appJsScript`;"
        "document.head.append(appJs);";
  }

  sendDeviceready(WebViewController value) {
    debugPrint('*** dispatch deviceready');
    value.runJavascript(
        'window.document.dispatchEvent(new Event("deviceready"));');
  }

  Future<WebViewController> wait(
      WebViewController controller, final Duration duration) async {
    debugPrint('*** wait ${duration.inMilliseconds} millis');
    // workaround for ios
    return Future.delayed(duration, () => controller);
  }

  Future<WebViewController> runJavascript(
      WebViewController controller, String jsScript) async {
    await controller.runJavascript(jsScript);
    return controller;
  }

  runJavascriptWith(Completer<WebViewController> controller, String jsScript) {
    controller.future
        .then((c) => c.runJavascript(jsScript))
        .whenComplete(() => {debugPrint('done runJavascript')})
        .catchError((e) => {debugPrint(e)});
  }

  runJavascriptWithDelay(Completer<WebViewController> controller,
      final Duration duration, String jsScript) {
    controller.future
        .then((c) => Future.delayed(duration, () => c))
        .then((c) => c.runJavascript(jsScript))
        .whenComplete(() => {debugPrint('done runJavascriptWithDelay')})
        .catchError((e) => {debugPrint(e)});
  }

  handleError(e) {
    debugPrint('*** ERROR: $e');
  }
}
