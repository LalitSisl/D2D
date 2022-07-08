import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:citizenservices/homepage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/time.dart';
import 'constants.dart';
import 'network/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class CitizenDetails extends StatefulWidget {
  String id;
  CitizenDetails({Key? key, required this.id}) : super(key: key);

  @override
  _CitizenDetailsState createState() => _CitizenDetailsState();
}

class _CitizenDetailsState extends State<CitizenDetails> {
  bool _switchValue = false;
  final TimeController controller = Get.put(TimeController());
  Timer? timer;
  var _len;
  late List<bool> valuefirst;
  final FocusNode noteFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _transectionController = TextEditingController();
  final _applicationController = TextEditingController();
  bool isLoactionUpdate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    method();
  }

  var id;
  var email;
  var mobile;
  void method() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    id = _prefs.getString("user_id");
    email = _prefs.getString("email");
    mobile = _prefs.getString("mobile");
    Detail();
  }

  bool isLoading = false;
  var data;
  Future<void> Detail() async {
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
          "sr_id": "${widget.id}"
        });
        var response =
            await http.post(Uri.parse("${API.CITIZEN_DETAIL}"), body: body);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            setState(() {
              data = convertJson["data"];
              print('data $data');
              if (data['currentstatusid'] == "11") {
                _switchValue = true;
                valuefirst = List<bool>.filled(data["documents"].length, true);
              } else {
                valuefirst = List<bool>.filled(data["documents"].length, false);
              }
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

  Future<void> update(String tid, String number, String note) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = jsonEncode(<String, String>{
          "user_id": id,
          "email": "$email",
          "mobile": "$mobile",
          "sr_id": "${widget.id}",
          "status": "7",
          "t_id": "$tid",
          "app_no": "$number",
          "note": "$note"
        });
        var response =
            await http.post(Uri.parse("${API.UPDATE_SUBMIT}"), body: body);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            print('data $convertJson');

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomePage(id: "check")));
            setState(() {
              isLoactionUpdate = false;
            });
            controller.stop();
          } else {
            Fluttertoast.showToast(
                msg: convertJson['error_msg'], gravity: ToastGravity.BOTTOM);
            setState(() {
              isLoactionUpdate = false;
            });
          }
        } catch (e) {
          print(e.toString());
          setState(() {
            isLoactionUpdate = false;
          });
          // Fluttertoast.showToast(
          //     msg: "Something went wrong, try again later",
          //     gravity: ToastGravity.BOTTOM);
        }
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "No internet connection. Connect to the internet and try again.",
          gravity: ToastGravity.BOTTOM);
      setState(() {
        isLoactionUpdate = false;
      });
    }
  }

  Future<void> checkboxUpdate() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = jsonEncode(<String, String>{
          "user_id": id,
          "email": "$email",
          "mobile": "$mobile",
          "sr_id": "${widget.id}",
          "status": "11",
        });
        var response = await http.post(Uri.parse("${API.UPDATE}"), body: body);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomePage(id: "check")));
            setState(() {
              isLoactionUpdate = false;
            });
          } else {
            Fluttertoast.showToast(
                msg: convertJson['error_msg'], gravity: ToastGravity.BOTTOM);
            setState(() {
              isLoactionUpdate = false;
            });
          }
        } catch (e) {
          print(e.toString());
          Fluttertoast.showToast(
              msg: "Something went wrong, try again later",
              gravity: ToastGravity.BOTTOM);
          setState(() {
            isLoactionUpdate = false;
          });
        }
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "No internet connection. Connect to the internet and try again.",
          gravity: ToastGravity.BOTTOM);
      setState(() {
        isLoactionUpdate = false;
      });
    }
  }

  File? Hotelfile;

  Future<void> uploadImage(file) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var request =
            http.MultipartRequest('POST', Uri.parse("${API.UPLOAD_IMAGE}"));
        request.files
            .add(await http.MultipartFile.fromPath('image_name', file));
        request.fields['user_id'] = id;
        request.fields['mobile'] = '$mobile';
        request.fields['srid'] = '${widget.id}';
        print(id);
        print(mobile);
        print(widget.id);

        var res = await request.send();

        try {
          if (res.statusCode == 200) {
            var responseBody = await http.Response.fromStream(res);
            var myData = json.decode(responseBody.body);
            print('data ${myData['data']}');
            print('data is ok');

            setState(() {
              isLoactionUpdate = false;
            });
          } else {
            // Fluttertoast.showToast(
            //     msg: convertJson['error_msg'], gravity: ToastGravity.BOTTOM);
            setState(() {
              isLoactionUpdate = false;
            });
          }
        } catch (e) {
          print(e.toString());
          Fluttertoast.showToast(
              msg: "Something went wrong, try again later",
              gravity: ToastGravity.BOTTOM);
          setState(() {
            isLoactionUpdate = false;
          });
        }
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "No internet connection. Connect to the internet and try again.",
          gravity: ToastGravity.BOTTOM);
      setState(() {
        isLoactionUpdate = false;
      });
    }
  }

  var counter = 0;
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
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 4, 74, 90),
        title: const Text('Citizen Details',
            style: TextStyle(
                fontFamily: FFamily.avenir,
                color: ColorPalette.white,
                fontSize: FSize.dp16,
                letterSpacing: 1,
                fontWeight: FWeight.semiBold)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Form(
                key: _formKey,
                child: ListView(
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${data["servicename"]}",
                      style: const TextStyle(
                          fontFamily: FFamily.avenir,
                          color: Color.fromARGB(255, 11, 10, 10),
                          fontSize: FSize.dp16,
                          fontWeight: FWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      '${data["date"]} ${data["time"]}',
                      style: const TextStyle(
                          fontFamily: FFamily.avenir,
                          color: Color.fromARGB(255, 11, 10, 10),
                          fontSize: FSize.dp14,
                          fontWeight: FWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sr No.',
                          style: TextStyle(
                              color: ColorPalette.textGrey,
                              fontSize: FSize.dp12,
                              letterSpacing: 0,
                              fontWeight: FWeight.semiBold),
                        ),
                        const SizedBox(
                          width: 63,
                        ),
                        Flexible(
                          child: Text(
                            data["srno"],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 12, 67, 112),
                                fontSize: FSize.dp14,
                                letterSpacing: 0,
                                fontWeight: FWeight.regular),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name',
                          style: TextStyle(
                              color: ColorPalette.textGrey,
                              fontSize: FSize.dp12,
                              letterSpacing: 0,
                              fontWeight: FWeight.semiBold),
                        ),
                        const SizedBox(
                          width: 63,
                        ),
                        Flexible(
                          child: Text(
                            data["name"],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 12, 67, 112),
                                fontSize: FSize.dp14,
                                letterSpacing: 0,
                                fontWeight: FWeight.regular),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          width: 52,
                        ),
                        Flexible(
                          child: Text(
                            data["address"],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 12, 67, 112),
                                fontSize: FSize.dp14,
                                letterSpacing: 0,
                                fontWeight: FWeight.regular),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                              color: ColorPalette.textGrey,
                              fontSize: FSize.dp12,
                              letterSpacing: 0,
                              fontWeight: FWeight.semiBold),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: Text(
                            data["email"] ?? 'lalit_sisl@gmail.com',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 12, 67, 112),
                                fontSize: FSize.dp14,
                                letterSpacing: 0,
                                fontWeight: FWeight.regular),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mobile Number',
                          style: TextStyle(
                              color: ColorPalette.textGrey,
                              fontSize: FSize.dp12,
                              letterSpacing: 0,
                              fontWeight: FWeight.semiBold),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Flexible(
                          child: Text(
                            data["mobile"],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 12, 67, 112),
                                fontSize: FSize.dp14,
                                letterSpacing: 0,
                                fontWeight: FWeight.regular),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Disclaimer',
                          style: TextStyle(
                              color: ColorPalette.textGrey,
                              fontSize: FSize.dp12,
                              letterSpacing: 0,
                              fontWeight: FWeight.semiBold),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        Flexible(
                          child: Text(
                            data["disclaimer"],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 12, 67, 112),
                                fontSize: FSize.dp14,
                                letterSpacing: 0,
                                fontWeight: FWeight.regular),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Document checklist:",
                      style: TextStyle(
                          fontFamily: FFamily.avenir,
                          color: Color.fromARGB(255, 11, 10, 10),
                          fontSize: FSize.dp14,
                          fontWeight: FWeight.semiBold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '1.',
                          style: EWTWidget.subHeadingTextStyle,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          ' Photograph',
                          style: TextStyle(
                              fontFamily: FFamily.avenir,
                              color: Color.fromARGB(255, 51, 49, 49),
                              fontSize: FSize.dp14,
                              fontWeight: FWeight.regular),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          '2.',
                          style: EWTWidget.subHeadingTextStyle,
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        const Text(
                          'PRS/AAY Proof Document',
                          style: TextStyle(
                              fontFamily: FFamily.avenir,
                              color: Color.fromARGB(255, 51, 49, 49),
                              fontSize: FSize.dp14,
                              fontWeight: FWeight.regular),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          '3.',
                          style: EWTWidget.subHeadingTextStyle,
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        const Expanded(
                            child: Text(
                          'Address Proof Document Type Delhi Only.(test)',
                          style: TextStyle(
                              fontFamily: FFamily.avenir,
                              color: Color.fromARGB(255, 51, 49, 49),
                              fontSize: FSize.dp14,
                              fontWeight: FWeight.regular),
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service URL:',
                          style: TextStyle(
                              fontFamily: FFamily.avenir,
                              color: Color.fromARGB(255, 11, 10, 10),
                              fontSize: FSize.dp14,
                              fontWeight: FWeight.semiBold),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              String url = '${data["url"]}';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              data["url"],
                              style: EWTWidget.pieChartTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tracking URL:',
                          style: TextStyle(
                              fontFamily: FFamily.avenir,
                              color: Color.fromARGB(255, 11, 10, 10),
                              fontSize: FSize.dp14,
                              fontWeight: FWeight.semiBold),
                        ),
                        const SizedBox(
                          width: 21,
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              String url = '${data["trackingurl"]}';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              data["trackingurl"],
                              style: EWTWidget.pieChartTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Fees and charges:',
                      style: TextStyle(
                          fontFamily: FFamily.avenir,
                          color: Color.fromARGB(255, 11, 10, 10),
                          fontSize: FSize.dp14,
                          fontWeight: FWeight.semiBold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GOVERNMENT FEE:',
                              style: EWTWidget.subminsubnormalHeadingsTextStyle,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'SERVICE FEE:',
                              style: EWTWidget.subminsubnormalHeadingsTextStyle,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'APPLICABLE TAX:',
                              style: EWTWidget.subminsubnormalHeadingsTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["fees"],
                                style:
                                    EWTWidget.subminsubnormalHeadingsTextStyle,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                data["servicefees"],
                                style:
                                    EWTWidget.subminsubnormalHeadingsTextStyle,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                data["tax"],
                                style:
                                    EWTWidget.subminsubnormalHeadingsTextStyle,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          'Govt Payment mode:',
                          style: EWTWidget.subHeadingTextStyle,
                        ),
                        const SizedBox(
                          width: 35,
                        ),
                        Text(
                          data["payment_mode"],
                          style: const TextStyle(
                              fontFamily: FFamily.avenir,
                              color: Colors.lightBlueAccent,
                              fontSize: FSize.dp14,
                              fontWeight: FWeight.regular),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Document to be collected:",
                      style: TextStyle(
                          fontFamily: FFamily.avenir,
                          color: Color.fromARGB(255, 11, 10, 10),
                          fontSize: FSize.dp14,
                          fontWeight: FWeight.semiBold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data["documents"] != null &&
                                data["documents"].isNotEmpty
                            ? data["documents"].length
                            : 0,
                        itemBuilder: (context, index) {
                          return FormField<bool>(
                            builder: (state) {
                              return Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      data['currentstatusid'] == "11"
                                          ? IgnorePointer(
                                              child: Checkbox(
                                                focusNode: noteFocus,
                                                value: valuefirst[index],
                                                onChanged: (v) {},
                                              ),
                                            )
                                          : Checkbox(
                                              focusNode: noteFocus,
                                              value: valuefirst[index],
                                              onChanged: (value) {
                                                setState(() {
                                                  valuefirst[index] = value!;
                                                  // state.didChange(value);
                                                  // var length =
                                                  //     data["documents"].length;
                                                  // if (valuefirst[index] ==
                                                  //     true) {
                                                  //   var count = counter++;
                                                  //   print('count $counter');
                                                  // }
                                                  // if (counter == length) {
                                                  //   checkboxUpdate();
                                                  // }
                                                });
                                              }),
                                      Flexible(
                                          child: Text(data["documents"][index]
                                              ["name"])),
                                    ],
                                  ),
//display error in matching theme
                                  Text(
                                    state.errorText ?? '',
                                    style: TextStyle(
                                      color: Theme.of(context).errorColor,
                                    ),
                                  )
                                ],
                              );
                            },
//output from validation will be displayed in state.errorText (above)
                            validator: (value) {
                              if (!valuefirst[index]) {
                                noteFocus.requestFocus();
                                return 'Please check your documents';
                              } else {
                                return null;
                              }
                            },
                          );
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                            child: Text('Have you already '
                                'Registered Application on E-District portal?')),
                        FlutterSwitch(
                          height: 20.0,
                          width: 40.0,
                          padding: 4.0,
                          toggleSize: 15.0,
                          borderRadius: 10.0,
                          //activeColor: lets_cyan,
                          value: _switchValue,
                          onToggle: (value) {
                            setState(() {
                              _switchValue = value;
                            });
                          },
                        ),
                      ],
                    ),
                    //const SizedBox(height: 10),
                    _switchValue == true
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Transaction Id:',
                                    style: EWTWidget.subHeadingTextStyle,
                                  ),
                                  const SizedBox(
                                    width: 70,
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: TextFormField(
                                        autofocus: false,
                                        controller: _transectionController,
                                        decoration: const InputDecoration(
                                          isDense: true,

                                          contentPadding: EdgeInsets.fromLTRB(
                                              0.0, 10.0, 20.0, 10.0),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorPalette.textGrey),
                                            //  when the TextFormField in unfocused
                                          ),
                                          // hintStyle: TextStyle(fontSize: 14),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorPalette.textGrey),
                                            //  when the TextFormField in unfocused
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorPalette.textGrey),
                                          ),
                                          //labelStyle: EWTWidget.fieldLabelTextStyle,
                                        ),
                                        // inputFormatters: [
                                        //   FilteringTextInputFormatter.deny(RegExp(
                                        //       r'!@#<>?":_``~;[]\|=-+)(*&^%1234567890')),
                                        // ],
                                        keyboardType: TextInputType.text,
                                        style: EWTWidget.fieldValueTextStyle,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'The field is mandatory';
                                          } else if (!RegExp(r'^[a-zA-Z0-9]+$')
                                              .hasMatch(value)) {
                                            return 'Enter valid id';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Application Number:',
                                    style: EWTWidget.subHeadingTextStyle,
                                  ),
                                  const SizedBox(
                                    width: 33,
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: TextFormField(
                                        autofocus: false,
                                        controller: _applicationController,
                                        decoration: const InputDecoration(
                                          isDense: true,

                                          contentPadding: EdgeInsets.fromLTRB(
                                              0.0, 10.0, 20.0, 10.0),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorPalette.textGrey),
                                            //  when the TextFormField in unfocused
                                          ),
                                          // hintStyle: TextStyle(fontSize: 14),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorPalette.textGrey),
                                            //  when the TextFormField in unfocused
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorPalette.textGrey),
                                          ),
                                          //labelStyle: EWTWidget.fieldLabelTextStyle,
                                        ),
                                        keyboardType: TextInputType.text,
                                        style: EWTWidget.fieldValueTextStyle,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'The field is mandatory';
                                          } else if (!RegExp(r'^[a-zA-Z0-9]+$')
                                              .hasMatch(value)) {
                                            return 'Enter valid Number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(children: [
                                Text(
                                  'Notes:',
                                  style: EWTWidget.subHeadingTextStyle,
                                ),
                                const SizedBox(
                                  width: 120,
                                ),
                                Flexible(
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorPalette.textGrey),
                                        //  when the TextFormField in unfocused
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorPalette.textGrey),
                                        //  when the TextFormField in unfocused
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorPalette.textGrey),
                                      ),
                                      //labelStyle: EWTWidget.fieldLabelTextStyle,
                                    ),
                                    keyboardType: TextInputType.text,
                                    style: EWTWidget.fieldValueTextStyle,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'The field is mandatory';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ]),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 30,
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          // ignore: unnecessary_null_comparison
                                          Hotelfile == null
                                              ? const Text('Upload File')
                                              : Text(
                                              Hotelfile!.path,
                                              textAlign: TextAlign.start,
                                              style:
                                                  const TextStyle(fontSize: 10),
                                                ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          //To change to file picker
                                          onPressed: () async {
                                            final ImagePicker _picker =
                                            ImagePicker(); //added type ImagePicker
                                            var image = await _picker.getImage(
                                                source: ImageSource.camera);
                                            // CroppedFile? croppedFile =
                                            // await ImageCropper().cropImage(
                                            //   sourcePath: image!.path,
                                            // );
                                            File compressedFile =
                                            await FlutterNativeImage.compressImage(
                                              image!.path,
                                              quality: 50,
                                            );

                                            if (compressedFile != null) {
                                              setState(() {
                                                Hotelfile = File(compressedFile.path);
                                                uploadImage(Hotelfile!.path);
                                              });
                                            } else {
                                              /*setState(() {
                                  isLoading = false;
                                });*/
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            color: ColorPalette.textGrey,
                                          ),
                                        ),
                                        IconButton(
                                          //To change to file picker
                                          onPressed: () async {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles();
                                            var compressedFile =
                                                (await FlutterImageCompress
                                                    .compressWithFile(result!
                                                        .files.single.path!));
                                            if (result != null) {
                                              setState(() {
                                                Hotelfile =
                                                    File(result.files.single.path!);
                                                uploadImage(Hotelfile!.path);
                                              });
                                            } else {}
                                          },
                                          icon: const Icon(
                                            Icons.attach_file,
                                            color: ColorPalette.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    isLoactionUpdate
                        ? Center(
                            child: Container(
                                height: 30,
                                width: 30,
                                child: const CircularProgressIndicator()))
                        : Container(
                            width: width,
                            // margin: EdgeInsets.only(left: 30.0, right: 30.0),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(Dimension.dp8),
                                color: const Color.fromARGB(255, 86, 91, 92)),
                            child: RawMaterialButton(
                              elevation: Dimension.dp00,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoactionUpdate = true;
                                  });
                                  _switchValue == true
                                      ? update(
                                          _transectionController.text,
                                          _applicationController.text,
                                          _noteController.text)
                                      : checkboxUpdate();
                                } else {}
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(Dimension.dp10),
                                child: Text(
                                  'SUBMIT',
                                  style: EWTWidget.buttonTextStyle,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
    ));
  }
}
