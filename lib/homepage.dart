import 'dart:convert';
import 'dart:io';

import 'package:citizenservices/assigned.dart';
import 'package:citizenservices/completed.dart';
import 'package:citizenservices/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

import 'network/api.dart';

class HomePage extends StatefulWidget {
  var id;
  HomePage({Key? key, this.id}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  TextStyle alltask = EWTWidget.fieldLabelTextStyle;
  TextStyle mytask = EWTWidget.buttonTextStyle;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    mainmethod();
    //checkbio();
    method();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      if (_tabController!.index == 0) {
        alltask = EWTWidget.fieldLabelTextStyle;
        mytask = EWTWidget.buttonTextStyle;
      } else {
        mytask = EWTWidget.fieldLabelTextStyle;
        alltask = EWTWidget.buttonTextStyle;
      }
    });
  }

  var name;
  var name1;
  var email;
  mainmethod() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      name = sharedPreferences.getString("name");
      String capitalize(name) => name[0].toUpperCase();
      name1 = capitalize(name);
      email = sharedPreferences.getString("email");
    });
  }

  clearPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }

  bool isAuth = false;
  checkbio() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (widget.id == null) {
      checkBiometric();
    } else if (sharedPreferences.getString("user_id") == null) {
      print('ok');
    } else {}
  }

  void checkBiometric() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      print("error biome trics $e");
    }
    print("biometric is available: $canCheckBiometrics");
    List<BiometricType>? availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      print("error enumerate biometrics $e");
    }
    print("following biometrics are available");
    if (availableBiometrics!.isNotEmpty) {
      availableBiometrics.forEach((ab) {
        print("\ttech: $ab");
      });
    } else {
      print("no biometrics are available");
    }

    bool authenticated = false;

    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Touch your finger on the sensor to login',
          useErrorDialogs: true,
          stickyAuth: false
          // androidAuthStrings:AndroidAuthMessages(signInTitle: "Login to HomePage")
          );
    } catch (e) {
      print("error using biometric auth: $e");
    }

    setState(() {
      isAuth = authenticated ? true : false;
    });

    print("authenticated: $authenticated");
  }

  var id;

  var mobile;
  void method() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    id = _prefs.getString("user_id");
    email = _prefs.getString("email");
    mobile = _prefs.getString("mobile");
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: ColorPalette.themeBlue,
        statusBarIconBrightness: Brightness.light));
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded,size: 22,),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              titleSpacing: 0,
              backgroundColor: const Color.fromARGB(255, 4, 74, 90),
              title: const Text('Delhi Doorstep Services',
                  style: TextStyle(
                      fontFamily: FFamily.avenir,
                      color: ColorPalette.white,
                      fontSize: FSize.dp16,
                      letterSpacing: 0.5,
                      fontWeight: FWeight.semiBold)),
            ),
            drawer: Drawer(
              child: Container(
                color: Colors.white,
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 4, 74, 90),
                      ),
                      accountName: Text(name ?? "User"),
                      accountEmail: Text(email ?? "user@gmail.com"),
                      currentAccountPicture: CircleAvatar(

                        backgroundColor: Colors.orange,
                        child: Text(
                          "$name1",
                          style: const TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: (){
                        clearPref();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                        child: Row(
                          children: const [
                             Icon(
                              Icons.logout,
                              size: 18,
                            ),
                              SizedBox(width: 12,),
                            Text("Logout",style: TextStyle(
                              fontSize: 15
                            ),),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      //width: width * Dimension.dp08,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimension.dp15),
                        border: Border.all(
                            width: Dimension.dp1,
                            color: const Color.fromARGB(255, 4, 74, 90)),
                        color: const Color.fromARGB(255, 4, 74, 90),
                      ),
                      child: TabBar(
                        unselectedLabelColor: ColorPalette.white,
                        unselectedLabelStyle:
                            const TextStyle(color: ColorPalette.white),
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimension.dp15),
                            border: Border.all(
                                width: Dimension.dp1,
                                color: ColorPalette.themeBlue),
                            color: ColorPalette.white),
                        controller: _tabController,
                        tabs: [
                          Tab(
                            // child: isLoading
                            //     ? Center(
                            //         child: SizedBox(
                            //             height: 10,
                            //             width: 10,
                            //             child: CircularProgressIndicator()))
                            //     :
                            child: Text(
                              // assi != null
                              //     ? "Assigned($assi)"
                              "Assigned",
                              style: alltask,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Completed",
                              style: mytask,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                // const SizedBox(
                //   height: Dimension.dp05,
                // ),
                Flexible(
                  child: SizedBox(
                    //margin: EdgeInsets.only(bottom: 30),
                    height: height,
                    child: TabBarView(
                      controller: _tabController,
                      children: [Assigned(), Completed()],
                    ),
                  ),
                ),
              ],
            )));
  }
}
