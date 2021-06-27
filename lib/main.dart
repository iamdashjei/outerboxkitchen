import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/utils/hex_color.dart';

import 'src/features/login/screens/app_authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper().initDatabase();
  await FlutterStatusbarcolor.setStatusBarColor(Colors.orange);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: Colors.orange
  // ));
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kitchen App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AppAuthentication(),
    );
  }
}