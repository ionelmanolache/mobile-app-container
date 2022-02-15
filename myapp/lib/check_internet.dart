import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CheckInternet {
  late StreamSubscription<InternetConnectionStatus> listener;
  var InternetStatus = "Unknown";
  var contentmessage = "Unknown";
  bool flag = true;

  void _showDialog(
      bool flag, String title, String content, BuildContext context) {
    if (flag) {
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text(title),
              content: new Text(content),
              actions: <Widget>[
                new TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("Close"))
              ]);
        });
  }

  checkConnection(BuildContext context) async {
    //InternetConnectionChecker().checkInterval = Duration(seconds: 10);
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          InternetStatus = "Connected to the Internet";
          contentmessage = "Connected to the Internet";
          _showDialog(flag, InternetStatus, contentmessage, context);
          flag = false;
          break;
        case InternetConnectionStatus.disconnected:
          InternetStatus = "You are disconnected to the Internet. ";
          contentmessage = "Please check your internet connection";
          _showDialog(false, InternetStatus, contentmessage, context);
          break;
      }
    });
    return await InternetConnectionChecker().connectionStatus;
  }
}
