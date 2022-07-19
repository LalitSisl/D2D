import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'network/api.dart';

class Completed extends StatefulWidget {
  const Completed({Key? key}) : super(key: key);

  @override
  _CompletedState createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  DateTime selectedDate1 = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  var startDate;
  var endDate;
  _selectDate1(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate1,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate1) {
      Completed();
      setState(() {
        selectedDate1 = selected;
        var inputFormat = DateFormat('yyyy-MM-dd');
        var startDateParse = inputFormat.parse('$selectedDate1');
        var startFormat = DateFormat('dd/MM/yyyy');
        startDate = startFormat.format(startDateParse);
      });
    }
  }

  _selectDate2(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate1.subtract(const Duration(days: 0)),
      firstDate: selectedDate1.subtract(const Duration(days: 0)),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate2) {
      Completed();
      setState(() {
        selectedDate2 = selected;
        var inputFormat = DateFormat('yyyy-MM-dd');
        var startDateParse = inputFormat.parse('$selectedDate2');
        var startFormat = DateFormat('dd/MM/yyyy');
        endDate = startFormat.format(startDateParse);
      });
    }
  }

  final dates = <Widget>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    method();
    fetchdate();
  }

  var currentDate;
  var previous;
  fetchdate() {
    setState(() {
      isLoading = true;
    });
    DateTime today = DateTime.now();
    //currentDate = today;
    var inputFormat1 = DateFormat('yyyy-MM-dd');
    var startDateParse1 = inputFormat1.parse('$today');
    var startFormat1 = DateFormat('dd/MM/yyyy');
    endDate = startFormat1.format(startDateParse1);
    DateTime futureDate = DateTime.now().subtract(const Duration(days: 7));
    var inputFormat = DateFormat('yyyy-MM-dd');
    var startDateParse = inputFormat.parse('$futureDate');
    var startFormat = DateFormat('dd/MM/yyyy');
    startDate = startFormat.format(startDateParse);
    // previous = futureDate;

    print("cuurent $currentDate");
    print("future $previous");
  }

  var id;
  var email;
  var mobile;
  var token;
  void method() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    id = _prefs.getString("user_id");
    email = _prefs.getString("email");
    mobile = _prefs.getString("mobile");
    token = _prefs.getString("token");
    Completed();
  }

  bool isLoading = false;
  var data;
  var startfetch;
  var endfetch;
  var recordDate;
  Future<void> Completed() async {
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
          "from": "$startDate",
          "to": "$endDate"
        });
        Map<String, String> headers = {
          "Authorization": "Bearer $token"
        };
        var response =
            await http.post(Uri.parse("${API.COMPLETED}"), body: body, headers: headers);
        try {
          var convertJson = jsonDecode(response.body);
          if (convertJson["status"]) {
            data = convertJson["data"];

            //setState(() {
            var inputFormat = DateFormat('yyyy-MM-dd');
            var startDateParse = inputFormat.parse('${data['from_date']}');
            var startFormat = DateFormat('dd/MM/yyyy');
            startDate = startFormat.format(startDateParse);

            var inputFormat1 = DateFormat('yyyy-MM-dd');
            var startDateParse1 = inputFormat1.parse('${data['to_date']}');
            var startFormat1 = DateFormat('dd/MM/yyyy');
            endDate = startFormat1.format(startDateParse1);
            // });

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Data Range",
                        style: TextStyle(
                            fontFamily: FFamily.avenir,
                            color: Colors.grey,
                            fontSize: FSize.dp14,
                            fontWeight: FWeight.regular),
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: (() => _selectDate1(context)),
                          child: Row(
                            children: [
                              Text(
                                startDate ?? '00/00/0000',
                                style: TextStyle(
                                    fontFamily: FFamily.avenir,
                                    color: Colors.grey.shade700,
                                    fontSize: FSize.dp14,
                                    fontWeight: FWeight.regular),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.date_range,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          "to",
                          style: TextStyle(
                              fontFamily: FFamily.avenir,
                              color: Color.fromARGB(255, 11, 10, 10),
                              fontSize: FSize.dp14,
                              fontWeight: FWeight.regular),
                        ),
                        GestureDetector(
                          onTap: (() => _selectDate2(context)),
                          child: Row(
                            children: [
                              Text(
                                endDate ?? '00/00/0000',
                                style: TextStyle(
                                    fontFamily: FFamily.avenir,
                                    color: Colors.grey.shade700,
                                    fontSize: FSize.dp14,
                                    fontWeight: FWeight.regular),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.date_range,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => Completed(),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data['service_requests'] != null &&
                                  data['service_requests'].isNotEmpty
                              ? data['service_requests'].length
                              : 0,
                          itemBuilder: (context, index) {
                            var inputFormat1 = DateFormat('yyyy-MM-dd');
                            var startDateParse1 = inputFormat1.parse(
                                '${data['service_requests'][index]['date']}');
                            var startFormat1 = DateFormat('dd/MM/yyyy');
                            recordDate = startFormat1.format(startDateParse1);
                            return Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 4, 74, 90),

                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$recordDate (${data['service_requests'][index]
                                          ['data']
                                              .length} records)',
                                          style: const TextStyle(
                                              fontFamily: FFamily.avenir,
                                              color: Colors.white,
                                              fontSize: FSize.dp14,
                                              fontWeight: FWeight.regular),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                    itemCount: data['service_requests'][index]
                                                    ['data'] !=
                                                null &&
                                            data['service_requests'][index]
                                                    ['data']
                                                .isNotEmpty
                                        ? data['service_requests'][index]
                                                ['data']
                                            .length
                                        : 0,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            /* Navigator.of(context).push(
                                                          MaterialPageRoute(builder: (BuildContext context) => const CitizenDetails()));
                                                */
                                          },
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              elevation: 7,
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  // rowProfile('Date:                         ', '${data[index]["appointmentdate"]}'),
                                                  // const SizedBox(
                                                  //   height: 5,
                                                  // ),
                                                  rowProfile(
                                                      'Appointment Time:',
                                                      data['service_requests']
                                                              [index]['data'][i]
                                                          ['appointmenttime']),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  rowProfile(
                                                      'Sr No:                       ',
                                                      data['service_requests']
                                                              [index]['data'][i]
                                                          ['srno']),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  rowProfile(
                                                      'Name:                      ',
                                                      data['service_requests']
                                                              [index]['data'][i]
                                                          ['name']),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10),
                                                    child: Row(
                                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text(
                                                          'Service:                    ',
                                                          style: TextStyle(
                                                              color:
                                                                  ColorPalette
                                                                      .grey,
                                                              fontSize:
                                                                  FSize.dp12,
                                                              letterSpacing: 0,
                                                              fontWeight: FWeight
                                                                  .semiBold),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Flexible(
                                                            child: Text(
                                                          data['service_requests']
                                                                      [index]
                                                                  ['data'][i]
                                                              ['serviceName'],
                                                          style: const TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      159,
                                                                      161,
                                                                      163),
                                                              fontSize:
                                                                  FSize.dp12,
                                                              letterSpacing: 0,
                                                              fontWeight:
                                                                  FWeight
                                                                      .regular),
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              )),
                                        ),
                                      );
                                    }),
                              ],
                            );
                          }),
                    ),
                  ),
                ],
              ),
      ),
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
                color: ColorPalette.grey,
                fontSize: FSize.dp12,
                letterSpacing: 0,
                fontWeight: FWeight.semiBold),
          ),
          const SizedBox(
            width: 20,
          ),
          Flexible(
              child: Text(
            text,
            style: const TextStyle(
                color: Color.fromARGB(255, 159, 161, 163),
                fontSize: FSize.dp12,
                letterSpacing: 0,
                fontWeight: FWeight.regular),
          )),
        ],
      ),
    );
  }
}









//  ListView.builder(
//                                     itemCount: data['service_requests'][index]
//                                                     ['data'] !=
//                                                 null &&
//                                             data['service_requests']['data']
//                                                 .isNotEmpty
//                                         ? data['service_requests']['data']
//                                             .length
//                                         : 0,
//                                     itemBuilder: (context, i) {
//                                       return Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 5),
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             /* Navigator.of(context).push(
//                                                           MaterialPageRoute(builder: (BuildContext context) => const CitizenDetails()));
//                                                 */
//                                           },
//                                           child: Card(
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15.0),
//                                               ),
//                                               elevation: 7,
//                                               child: Column(
//                                                 children: [
//                                                   const SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   // rowProfile('Date:                         ', '${data[index]["appointmentdate"]}'),
//                                                   // const SizedBox(
//                                                   //   height: 5,
//                                                   // ),
//                                                   rowProfile(
//                                                       'Appointment Time:',
//                                                       '${data[index]["appointmenttime"]}'),
//                                                   const SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   rowProfile(
//                                                       'Sr No:                       ',
//                                                       '${data[index]["srno"]} ${data[index]["id"]}'),
//                                                   const SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   rowProfile(
//                                                       'Name:                      ',
//                                                       '${data[index]["name"]}'),
//                                                   const SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets
//                                                             .symmetric(
//                                                         horizontal: 10),
//                                                     child: Row(
//                                                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                       children: [
//                                                         const Text(
//                                                           'Service:                    ',
//                                                           style: TextStyle(
//                                                               color:
//                                                                   ColorPalette
//                                                                       .grey,
//                                                               fontSize:
//                                                                   FSize.dp12,
//                                                               letterSpacing: 0,
//                                                               fontWeight: FWeight
//                                                                   .semiBold),
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 20,
//                                                         ),
//                                                         Flexible(
//                                                             child: Text(
//                                                           "${data[index]["serviceName"]}",
//                                                           style: const TextStyle(
//                                                               color: Color
//                                                                   .fromARGB(
//                                                                       255,
//                                                                       159,
//                                                                       161,
//                                                                       163),
//                                                               fontSize:
//                                                                   FSize.dp12,
//                                                               letterSpacing: 0,
//                                                               fontWeight:
//                                                                   FWeight
//                                                                       .regular),
//                                                         )),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 20,
//                                                   ),
//                                                 ],
//                                               )),
//                                         ),
//                                       );
//                                     }),