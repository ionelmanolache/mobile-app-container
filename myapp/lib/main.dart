import 'package:flutter/material.dart';
import 'brokers_page.dart';
import 'home.dart';
//import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  //await Permission.storage.request();

  //var p1 = Permission.accessMediaLocation.value;
  //var p2 = Permission.manageExternalStorage.value;
  //print('**** accessMediaLocation = $p1');
  //print('**** manageExternalStorage = $p2');

  runApp(const MyApp());
}
//void main() => runApp(const MaterialApp(home: const BrokersPage()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(), //BrokersPage(),
    );
  }
}
