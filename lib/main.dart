import 'package:citizenservices/welcomepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'package:get/get.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: ColorPalette.themeBlue,
        statusBarIconBrightness: Brightness.light));
    return GetMaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: ColorPalette.themeBlue,
        accentColor: ColorPalette.themeBlue,
        canvasColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      home: const WelComePage(),
    );
  }
}
