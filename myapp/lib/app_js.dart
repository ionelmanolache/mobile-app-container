import 'package:webview_flutter/webview_flutter.dart';

class AppJs {
  static Future<void> _onCheckidstatus(
      WebViewController controller, String jsCode) async {
    await controller.runJavascript(jsCode);
  }
}
