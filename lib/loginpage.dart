import 'dart:convert';
import 'dart:io';

import 'package:citizenservices/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  var isLoading = false;

  bool _isObscure = true;

  bool isAuth = false;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkbio();
  }

  checkbio()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("user_id") == null){
      print('ok');
    }else{
      checkBiometric();
    }
  }

  var zoneid = [];
  Future<void> login(user, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body =
            jsonEncode(<String, String>{"email": user, "password": pass});
        var response = await http.post(Uri.parse("${API.LOGIN}"), body: body);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            var data = convertJson['data'];
            sharedPreferences.setString('user_id', data["user_id"]);
            sharedPreferences.setString('name', data["name"]);
            sharedPreferences.setString('email', data["email"]);
            sharedPreferences.setString('mobile', data["mobile"]);
           print(sharedPreferences.getString("name"));

            Fluttertoast.showToast(
                msg: convertJson['success_msg'], gravity: ToastGravity.BOTTOM);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => HomePage(id: "check")));

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: convertJson['error_msg'], gravity: ToastGravity.BOTTOM);
          }
        } catch (e) {
          print(e.toString());
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Something went wrong, try again later",
              gravity: ToastGravity.BOTTOM);
        }
      }
    } on SocketException catch (_) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "No internet connection. Connect to the internet and try again.",
          gravity: ToastGravity.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: ColorPalette.themeBlue,
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorPalette.white,
          body: SizedBox(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(),
                      const SizedBox(
                        height: 100,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: Dimension.dp15, right: Dimension.dp15),
                        child: Column(
                          children: [
                            const Image(
                              height: Dimension.dp80,
                              image: AssetImage(ImageAssets.cs),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              Constant.login,
                              style: EWTWidget.largeHeadings,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: Dimension.dp40,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: Dimension.dp40, right: Dimension.dp40),
                        child: Form(

                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _userNameController,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(14.0),
                                    labelText: 'User Name',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.text,
                                style: EWTWidget.fieldValueTextStyle,
                                validator: (value){
                                  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                                  if (value!.isEmpty) {
                                    return 'Email is required';
                                  }
                                    RegExp regex = RegExp(pattern);
                                  if (!(regex.hasMatch(value)))
                                    return "Invalid Email";
                                  return null;
                                },
                                      ),
                              const SizedBox(
                                height: Dimension.dp20,
                              ),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(10.0),
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _isObscure,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: EWTWidget.fieldValueTextStyle,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'The field is mandatory';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: Dimension.dp50,
                              ),
                              Container(
                                width: width,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(Dimension.dp8),
                                    color:
                                        const Color.fromARGB(255, 86, 91, 92)),
                                child: RawMaterialButton(
                                  elevation: Dimension.dp00,
                                  onPressed: () {
                                    // Navigator.of(context).pushReplacement(
                                    //     MaterialPageRoute(
                                    //         builder: (BuildContext context) =>
                                    //             HomePage()));
                                    if (_formKey.currentState!.validate()) {
                                      login(_userNameController.text,
                                          _passwordController.text);
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(Dimension.dp7),
                                    child: Text(
                                      Constant.login,
                                      style: EWTWidget.buttonTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: Dimension.dp10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.08,
                      ),
                      Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Text(
                          Constant.designedBy,
                          style: EWTWidget.extraSmallTextStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
