import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:citizenservices/homepage.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'Controller/time.dart';
import 'citizendetails.dart';
import 'constants.dart';
import 'package:battery_info/battery_info_plugin.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:citizenservices/network/api.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class Assigned extends StatefulWidget {
  const Assigned({Key? key}) : super(key: key);

  @override
  _AssignedState createState() => _AssignedState();
}

class _AssignedState extends State<Assigned>
    with SingleTickerProviderStateMixin {
  final TimeController controller = Get.put(TimeController());
  final _formKey = GlobalKey<FormState>();
  //final _controller = TextEditingController();
  List<TextEditingController>? _controllers = [];
  List<String> _playerList = [];
  int selectedTabIndex = 0;
  bool showField = false;

  var selectedindex;
  var text;
  bool isLoading = false;
  late double lat;
  late double long;
  var id;
  var email;
  var mobile;
  var data;
  var btnText;
  GeoCode geoCode = GeoCode();
  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    method();
    check();
    getLocation();
  }

  void method() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    id = _prefs.getString("user_id");
    email = _prefs.getString("email");
    mobile = _prefs.getString("mobile");
    bettery = (await BatteryInfoPlugin().androidBatteryInfo)?.batteryLevel;

    Assigned();
  }

  check() {
    timer?.cancel();
  }

  Future<void> Assigned() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = jsonEncode(<String, String>{
          "user_id": id,
          "email": "$email",
          "mobile": "$mobile",
        });
        var response =
            await http.post(Uri.parse("${API.ASSIGNED}"), body: body);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            setState(() {
              data = convertJson["data"];
            });
            // Fluttertoast.showToast(
            //     msg: convertJson['success_msg'], gravity: ToastGravity.BOTTOM);

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

  var bettery;


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
    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });
    print('posi ${position.latitude}');
    print(position.longitude);
  }

  Future<void> userInfo(String srID) async {
    if (mounted) {
      setState(() {
        getLocation();
      });
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = jsonEncode(<String, String>{
          "userid": "$id",
          "lat": "$lat",
          "long": "$long",
          "bt": "$bettery",
          "srid": "$srID"
        });
        var response =
            await http.post(Uri.parse("${API.USER_INFO}"), body: body);
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

  void openMap(double? lati, double? longi) async {
    String mapOptions = [
      'saddr=$lat,$long',
      'daddr=$lati,$longi',
      'dir_action=navigate'
    ].join('&');

    final url = 'https://www.google.com/maps?$mapOptions';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool st = true;
  Future<void> started(String asignedid) async {
    //await controller.timerun(asignedid);

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = jsonEncode(<String, String>{
          "user_id": id,
          "email": "$email",
          "mobile": "$mobile",
          "sr_id": "$asignedid",
          "status": "3",
        });
        var response = await http.post(Uri.parse("${API.UPDATE}"), body: body);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            var startdata = convertJson['data'];
            controller.timerun(asignedid);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage()), // this mainpage is your page to refresh
              (Route<dynamic> route) => false,
            );

            print('start $startdata');
            print('status ${convertJson['status']}');
          } else {
            Fluttertoast.showToast(
                msg: convertJson['error_msg'], gravity: ToastGravity.BOTTOM);
          }
        } catch (e) {
          print(e.toString());
          Fluttertoast.showToast(
              msg: "Something went wrong, try again later1",
              gravity: ToastGravity.BOTTOM);
        }
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "No internet connection. Connect to the internet and try again.",
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future<void> Reached(String asignedid) async {
    //await Assigned();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = jsonEncode(<String, String>{
          "user_id": id,
          "email": "$email",
          "mobile": "$mobile",
          "sr_id": "$asignedid",
          "status": "4",
        });
        var response = await http.post(Uri.parse("${API.UPDATE}"), body: body);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            var reacheddata = convertJson['data'];

            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    CitizenDetails(id: asignedid)));
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

  var assign_id;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: RefreshIndicator(
                    onRefresh: () => Assigned(),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            data != null && data.isNotEmpty ? data.length : 0,
                        itemBuilder: (context, index) {
                          //_controllers!.add(TextEditingController());
                          var inputFormat = DateFormat('yyyy-MM-dd');
                          var startDateParse = inputFormat
                              .parse('${data[index]['appointmentdate']}');
                          var startFormat = DateFormat('dd/MMMM/yyyy');
                          var startDate = startFormat.format(startDateParse);
                          print(data[index]['status_id']);

                          if (data[index]['status_id'] == "1" ||
                              data[index]['status_id'] == "2" ||
                              data[index]['status_id'] == "12") {
                            btnText = "START";
                          } else if (data[index]['status_id'] == "3") {
                            btnText = "REACHED";
                          } else if (data[index]['status_id'] == "4") {
                            btnText = "Collect Doc.";
                          } else if (data[index]['status_id'] == "11") {
                            btnText = "Complete";
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 7,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            startDate,
                                            style: const TextStyle(
                                                fontFamily: FFamily.avenir,
                                                color: Color.fromARGB(
                                                    255, 11, 10, 10),
                                                fontSize: FSize.dp14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            data[index]['appointmenttime'],
                                            style: const TextStyle(
                                                fontFamily: FFamily.avenir,
                                                color: Color.fromARGB(
                                                    255, 11, 10, 10),
                                                fontSize: FSize.dp14,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          '${data[index]['serviceName']}',
                                          style: const TextStyle(
                                              fontFamily: FFamily.avenir,
                                              color: Color.fromARGB(
                                                  255, 11, 10, 10),
                                              fontSize: FSize.dp16,
                                              fontWeight: FontWeight.w600),
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    rowProfile('Sr.No    ',
                                        ' ${data[index]['srno']}${data[index]['id']}'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    rowProfile(
                                        'Name    ', '${data[index]['name']}'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    rowProfile('Mobile   ',
                                        '${data[index]['mobile']}'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    data[index]['alternate_mobile'] != null &&
                                            data[index]['alternate_mobile'] !=
                                                "0"
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 5),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Alternate No.',
                                                        style: TextStyle(
                                                            color: ColorPalette
                                                                .textGrey,
                                                            fontSize:
                                                                FSize.dp12,
                                                            letterSpacing: 0,
                                                            fontWeight: FWeight
                                                                .semiBold),
                                                      ),
                                                      const SizedBox(
                                                        width: 7,
                                                      ),
                                                      Flexible(
                                                          child: Text(
                                                        '${data[index]['alternate_mobile']}',
                                                        style: const TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    12,
                                                                    67,
                                                                    112),
                                                            fontSize:
                                                                FSize.dp14,
                                                            letterSpacing: 0,
                                                            fontWeight: FWeight
                                                                .regular),
                                                      )),
                                                    ])),
                                          )
                                        : Container(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Address',
                                            style: TextStyle(
                                                color: ColorPalette.textGrey,
                                                fontSize: FSize.dp12,
                                                letterSpacing: 0,
                                                fontWeight: FWeight.semiBold),
                                          ),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          Flexible(
                                              child: Text(
                                            '${data[index]['address']} ${data[index]['address2']} ${data[index]['address3']} ${data[index]['pincodeid']}',
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 12, 67, 112),
                                                fontSize: FSize.dp14,
                                                letterSpacing: 0,
                                                fontWeight: FWeight.regular),
                                          )),
                                          // const SizedBox(
                                          //   width: 20,
                                          // ),
                                          // selectedindex == index
                                          //     ? SizedBox(
                                          //         width: 100,
                                          //         height: 50,
                                          //         child: TextFormField(
                                          //           autofocus: false,
                                          //           obscureText: false,
                                          //           controller:
                                          //               _controllers![index],
                                          //           decoration:
                                          //               const InputDecoration(
                                          //                   border:
                                          //                       OutlineInputBorder(),
                                          //                   contentPadding:
                                          //                       EdgeInsets.symmetric(
                                          //                           vertical:
                                          //                               5,
                                          //                           horizontal:
                                          //                               5),
                                          //                   //labelText: 'OTP',
                                          //                   hintText:
                                          //                       'Enter OTP',
                                          //                   hintStyle:
                                          //                       TextStyle(
                                          //                           fontSize:
                                          //                               12)),
                                          //           validator: (value) {
                                          //             if (value!.isEmpty) {
                                          //               return 'Empty field';
                                          //             }
                                          //             return null;
                                          //           },
                                          //         ),
                                          //       )
                                          //     : Container(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              String url = Platform.isIOS
                                                  ? 'tel://${data[index]['mobile']}'
                                                  : 'tel:${data[index]['mobile']}';
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              width: 80,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black87,
                                                    width: 1.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.call,
                                                color: ColorPalette.grey,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              var query =
                                                  "${data[index]['address']} ${data[index]['address2']} ${data[index]['address3']}";
                                              List<Location> locations =
                                                  await locationFromAddress(
                                                      query);
                                              //var newPlace = await geoCode.forwardGeocoding(address: "malviya nagar delhi");
                                              print(
                                                  'lat: ${locations[0].latitude}');
                                              print(
                                                  'lat: ${locations[0].longitude}');
                                              openMap(locations[0].latitude,
                                                  locations[0].longitude);
                                              // try {
                                              // Coordinates coordinates = await geoCode.forwardGeocoding(address: query);
                                              // print("Latitude: ${coordinates.latitude}");
                                              // print("Longitude: ${coordinates.longitude}");
                                              // double? lat = coordinates.latitude;
                                              // double? lobng = coordinates.longitude;
                                              // openMap(lat, long);
                                              // } catch (e) {
                                              // print(e);
                                              //
                                              // }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              width: 80,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black87,
                                                    width: 1.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Image(
                                                image:
                                                    AssetImage(ImageAssets.map1),
                                                color: Colors.grey,
                                                height: 24,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedindex = index;
                                              });
                                              // var id = data[index]["id"];
                                              // if (data[index]['status_id'] ==
                                              //     2) {
                                              //   setState(() {
                                              //     st = true;
                                              //   });
                                              // } else if (data[index]
                                              //         ['status_id'] ==
                                              //     3) {
                                              //   setState(() {
                                              //     st = false;
                                              //   });
                                              // }

                                              if (data[index]
                                                          ['status_id'] ==
                                                      "1" ||
                                                  data[index]['status_id'] ==
                                                      "2" ||
                                                  data[index]['status_id'] ==
                                                      "12") {
                                                var id = data[index]["id"];
                                                AlertDialog alert = AlertDialog(
                                                  title: const Text("Are You Sure?"),
                                                  content: Text("You are about to start service ${data[index]["id"]} ${data[index]["appointmenttime"]}"),
                                                  actions: [
                                                    ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.grey),
                                                ),

                                                child: const Text("No"),
                                                    onPressed: () {
                                              Navigator.of(context).pop();
                                              },
                                              ),
                                                    ElevatedButton(
                                                      child: const Text("Yes"),
                                                      onPressed: () {
                                                        started(id);
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                              ],
                                                );

                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return alert;
                                                  },
                                                );
                                               // started(id);
                                              } else if (data[index]
                                                      ['status_id'] ==
                                                  "3") {
                                                var id = data[index]["id"];
                                                Reached(id);
                                              } else if (data[index]
                                                          ['status_id'] ==
                                                      "4" ||
                                                  data[index]['status_id'] ==
                                                      "11") {
                                                var id = data[index]["id"];
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            CitizenDetails(
                                                                id: id)));
                                              }

                                              // if (st == true) {
                                              //   var id = data[index]["id"];
                                              //   started(id);
                                              //   setState(() {
                                              //     st = false;
                                              //   });
                                              // } else if (st == false) {
                                              //   var id = data[index]["id"];
                                              //   Reached(id);
                                              //   setState(() {
                                              //     st = true;
                                              //   });
                                              // }
                                            },
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.5,
                                                        horizontal: 5),
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black87,
                                                      width: 1.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      btnText,
                                                      // data[index]['status_id'] >
                                                      //         "2"
                                                      //     ? "REACHED"
                                                      //     : btnText,
                                                      style: EWTWidget
                                                          .minsubnormalHeadingsTextStyle,
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      size: 13,
                                                    ),
                                                  ],
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                )),
                          );
                        }),
                  ),
                )),
    );
  }

  void showAlertDialog(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: 180,
            child: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        'Verify',
                        style: EWTWidget.normalHeadingsTextStyle,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "An OTP will be sent to the customer informing the visit.",
                        style: EWTWidget.minsubnormalHeadingsTextStyle,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        "Do you want to start the journey?",
                        style: EWTWidget.minsubnormalHeadingsTextStyle,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("CANCLE"),
                        onPressed: () {},
                      ),
                      TextButton(
                        child: const Text("CONFIRM"),
                        onPressed: () {
                          setState(() {
                            showField = true;
                            btnText = "REACHED";
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            margin: const EdgeInsets.only(bottom: 0, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim),
          child: child,
        );
      },
    );
  }

  Widget rowProfile(String heading, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            heading,
            style: const TextStyle(
                color: ColorPalette.textGrey,
                fontSize: FSize.dp12,
                letterSpacing: 0,
                fontWeight: FWeight.semiBold),
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
              child: Text(
            text,
            style: const TextStyle(
                color: Color.fromARGB(255, 12, 67, 112),
                fontSize: 13,
                letterSpacing: 0,
                fontWeight: FWeight.regular),
          )),
        ],
      ),
    );
  }
}
