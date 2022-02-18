import 'package:flutter/material.dart';
import 'brokers_page.dart';
import 'home.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const MyApp());
}
//void main() => runApp(const MaterialApp(home: const BrokersPage()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "CFD2",
        theme: appThemeLight(),
        /*
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.blue,
        ),
        */
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: Text("mIFE")),
          // body: SafeArea(child: Builder(builder: (BuildContext context) {
          //   return const BrokersPage();
          // })),
          body: Center(
            child: const BrokersPage(),
          ),
        ));
  }

  ThemeData appThemeLight() {
    return ThemeData.light().copyWith(
        // scaffoldBackgroundColor: Colors.blue,
        primaryColor: Colors.blue);
  }

  ThemeData appTheme() {
    return ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue);
  }
}
