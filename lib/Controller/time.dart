import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:citizenservices/network/api.dart';
import 'package:geocoding/geocoding.dart';


import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class TimeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    method();

    getLocation(); // prints 1
  }

  // List<Map<String, double>> arrey = [
  //   {
  //     'lat': 28.5290,
  //     'long': 77.2050,
  //   },
  //   {
  //     'lat': 28.5479,
  //     'long': 77.2031,
  //   },
  //   {
  //     'lat': 28.6330,
  //     'long': 77.2194,
  //   },
  //   {
  //     'lat': 28.5332,
  //     'long': 77.2042,
  //   },
  //   {
  //     'lat': 28.5649,
  //     'long': 77.2403,
  //   }
  // ];

  var id;
  var email;
  var mobile;
  var name;
  var bettery;
  var token;
  void method() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    id = _prefs.getString("user_id");
    email = _prefs.getString("email");
    mobile = _prefs.getString("mobile");
    name = _prefs.getString("name");
    token = _prefs.getString("token");
    bettery = (await BatteryInfoPlugin().androidBatteryInfo)?.batteryLevel;
  }

  Timer? timer;
  timerun(String assignedId) {
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => userInfo(assignedId));
  }

  var lat;
  var long;
  var value;
  Future<void> userInfo(String srID) async {
    getLocation();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // var rng = Random();
        // for (var i = 0; i < 1; i++) {
        //   //print(rng.nextInt(5));
        //    value = rng.nextInt(5);
        // }
        var body = jsonEncode(<String, String>{
          "userid": "$id",
          "lat": "$lat",
          "long": "$long",
          "bt": "$bettery",
          "srid": "$srID",
          "mobile": "$mobile",
          "name": "$name"
        });
        Map<String, String> headers = {
          "Authorization": "Bearer $token"
        };
        var response =
            await http.post(Uri.parse("${API.USER_INFO}"), body: body,headers: headers);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            print(convertJson['success_msg']);
            // Fluttertoast.showToast(
            //     msg: convertJson['success_msg'], gravity: ToastGravity.BOTTOM);

          } else {
            Fluttertoast.showToast(
                msg: convertJson['error_msg'], gravity: ToastGravity.BOTTOM);
          }
        } catch (e) {
          print(e.toString());

          Fluttertoast.showToast(
              msg: "Something went wrong, try again later",
              gravity: ToastGravity.BOTTOM);
        }
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "No internet connection. Connect to the internet and try again.",
          gravity: ToastGravity.BOTTOM);
    }
  }

  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    lat = position.latitude;
    long = position.longitude;

    print('posi ${position.latitude}');
    print(position.longitude);
  }

  stop() {
    timer!.cancel();
  }

}
