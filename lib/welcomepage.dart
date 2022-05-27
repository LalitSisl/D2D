import 'dart:async';

import 'package:citizenservices/homepage.dart';

import 'loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelComePage extends StatefulWidget {
  const WelComePage({Key? key}) : super(key: key);

  @override
  _WelComePageState createState() => _WelComePageState();
}

class _WelComePageState extends State<WelComePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3), () => navigation());
    // startTimer();
  }

  void navigation() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user_id = sharedPreferences.getString("user_id");
    if (user_id != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false);
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: ColorPalette.themeBlue,
        statusBarIconBrightness: Brightness.light));
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorPalette.white,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              /* Positioned(
                top: Dimension.dp00,
                child: Container(
                  height: height * Dimension.dp04,
                  width: width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            ImageAssets.background,
                          ),
                          fit: BoxFit.fill)),
                ),
              ),*/
              /*Positioned(
                top: height * .02,
                left: Dimension.dp00,
                right: Dimension.dp00,
                child: Center(
                  child: Container(
                    child: Image(
                      height: Dimension.dp60,
                      width: Dimension.dp60,
                      image: AssetImage(ImageAssets.logo),
                    ),
                  ),
                ),
              ),*/
              Positioned(
                top: height * Dimension.dp01,
                left: Dimension.dp00,
                right: Dimension.dp00,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      Constant.cs,
                      style: TextStyle(
                          fontFamily: FFamily.avenir,
                          color: ColorPalette.themeBlue,
                          fontSize: FSize.dp24,
                          letterSpacing: 1.5,
                          fontWeight: FWeight.semiBold),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: Dimension.dp10,
                      left: Dimension.dp30,
                      right: Dimension.dp30),
                  child: const Image(
                    image: AssetImage(ImageAssets.splash),
                  ),
                ),
              ),
              Positioned(
                bottom: Dimension.dp20,
                left: Dimension.dp00,
                right: Dimension.dp00,
                child: Center(
                  child: Text(
                    Constant.designedBy,
                    style: EWTWidget.extraSmallTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
