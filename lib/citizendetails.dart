import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:citizenservices/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/time.dart';
import 'constants.dart';
import 'network/api.dart';
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
              valuefirst = List<bool>.filled(data["documents"].length, false);
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
    setState(() {
      isLoactionUpdate = true;
    });
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
            setState(() {
              _prefs.setBool("timer_stop", true);
            });
            Navigator.push(context,
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
            var reacheddata = convertJson['data'];
            print('checkboxUpdate $reacheddata');
            print('status ${convertJson['status']}');
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
                      data["servicename"] ?? "--NA--",
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
                                      Checkbox(
                                          focusNode: noteFocus,
                                          value: valuefirst[index],
                                          onChanged: (value) {
                                            setState(() {
//save checkbox value to variable that store terms and notify form that state changed
                                              valuefirst[index] = value!;
                                              state.didChange(value);
                                              var length =
                                                  data["documents"].length;
                                              // print(length);

                                              // print(valuefirst[index]);

                                              if (valuefirst[index] == true) {
                                                var count = counter++;
                                                print('count $counter');
                                              }
                                              if (counter == length) {
                                                checkboxUpdate();
                                              }
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

                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ColorPalette.textGrey),
                                  //  when the TextFormField in unfocused
                                ),
                                // hintStyle: TextStyle(fontSize: 14),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ColorPalette.textGrey),
                                  //  when the TextFormField in unfocused
                                ),
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ColorPalette.textGrey),
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
                          width: 37,
                        ),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              autofocus: false,
                              controller: _applicationController,
                              decoration: const InputDecoration(
                                isDense: true,

                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ColorPalette.textGrey),
                                  //  when the TextFormField in unfocused
                                ),
                                // hintStyle: TextStyle(fontSize: 14),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ColorPalette.textGrey),
                                  //  when the TextFormField in unfocused
                                ),
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ColorPalette.textGrey),
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
                        ),
                      ],
                    ),
                    Row(children: [
                      Text(
                        'Notes:',
                        style: EWTWidget.subHeadingTextStyle,
                      ),
                      const SizedBox(
                        width: 115,
                      ),
                      Flexible(
                        child: TextFormField(
                          autofocus: false,
                          controller: _noteController,
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: ColorPalette.textGrey),
                              //  when the TextFormField in unfocused
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: ColorPalette.textGrey),
                              //  when the TextFormField in unfocused
                            ),
                            border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: ColorPalette.textGrey),
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
                      height: 20,
                    ),
                    isLoactionUpdate ? Center(child: Container(
                        height: 30,
                        width: 30,
                        child: const CircularProgressIndicator())):
                    Container(
                      width: width,
                      // margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimension.dp8),
                          color: const Color.fromARGB(255, 86, 91, 92)),
                      child: RawMaterialButton(
                        elevation: Dimension.dp00,
                        onPressed: () async {


                          if (_formKey.currentState!.validate()) {
                            controller.stop();
                            update(
                                _transectionController.text,
                                _applicationController.text,
                                _noteController.text);
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
