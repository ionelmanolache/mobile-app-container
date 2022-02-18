import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CheckInternet {
  late StreamSubscription<InternetConnectionStatus> listener;
  //String internetStatus = "Unknown";
  //String contentmessage = "Unknown";
  bool supressFlag = true;

  void _showDialog(String title, String content, BuildContext context) {
    if (supressFlag) {
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

  void _showInternetStatus(BuildContext context, String contentmessage) {
    if (supressFlag) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          contentmessage,
        ),
      ),
    );
  }

  checkConnection(BuildContext context) async {
    //InternetConnectionChecker().checkInterval = Duration(seconds: 10);
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          //InternetStatus = "Connected to the Internet";
          //_showDialog(flag, InternetStatus, contentmessage, context);
          _showInternetStatus(context, "Internet status changed: CONNECTED");
          supressFlag = false;
          break;
        case InternetConnectionStatus.disconnected:
          //InternetStatus = "You are disconnected to the Internet.";
          //contentmessage = "Please check your internet connection";
          //_showDialog(false, InternetStatus, contentmessage, context);
          _showInternetStatus(context, "Internet status changed: DISCONNECTED");
          break;
      }
    });
    return await InternetConnectionChecker().connectionStatus;
  }
}
