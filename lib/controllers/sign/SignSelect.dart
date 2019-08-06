import 'package:flutter/material.dart';
import 'package:haegisa2/main.dart';
import 'package:haegisa2/controllers/sign/SignAuth.dart';
import 'package:haegisa2/controllers/member/find_id.dart';
import 'package:haegisa2/controllers/member/join.dart';
import 'MiddleWare.dart';
import 'dart:async';
import 'dart:convert';
import 'SignIn.dart';
import 'package:haegisa2/models/statics/statics.dart';
import 'package:haegisa2/models/statics/strings.dart';
import 'package:haegisa2/models/statics/UserInfo.dart';
import 'package:haegisa2/views/buttons/Buttons.dart';
import 'package:haegisa2/models/statics/UserInfo.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

String idValue = "";
String passValue = "";
String jsonMsg = "";

class SignSelect extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignSelect> {
  @override
  Widget build(BuildContext context) {
    MiddleWare.shared.screenSize = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    int deviceWidth = MediaQuery.of(context).size.width.round().toInt();
    return new WillPopScope(
      onWillPop: () async => false,
      // onWillPop: () async {
      //   Future.value(
      //       false); //return a `Future` with false value so this route cant be popped or closed.
      // },
      child: new Scaffold(
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                child: Image.asset('Resources/Icons/login_sign.png',
                    width: 72, height: 72),
              ),
              Container(
                child: Text(Strings.shared.controllers.signSelect.title1,
                    style: TextStyle(
                        color: Statics.shared.colors.titleTextColor,
                        fontSize: Statics.shared.fontSizes.title)), // Text
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20, bottom: 10),
              ),
              Container(
                  child: Row(
                    children: [
                      FlatButton(
                        child: Row(children: [
                          Text(Strings.shared.controllers.signSelect.button1,
                              style: TextStyle(
                                  color: Statics.shared.colors.titleTextColor,
                                  fontSize:
                                      Statics.shared.fontSizes.supplementary)),
                          Image.asset('Resources/Icons/btn_next_blue.png',
                              width: 28, height: 28),
                        ]),
                        onPressed: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new SignIn()));
                        },
                      ),
                    ], // Row Children
                    mainAxisAlignment: MainAxisAlignment.center,
                  ), // Row
                  alignment: Alignment.center),
              Container(
                child: Image.asset(
                  'Resources/Icons/Line2.png',
                ),
                padding: EdgeInsets.only(
                  top: deviceHeight / 20,
                  bottom: deviceHeight / 20,
                ),
              ),
              Container(
                child: Image.asset('Resources/Icons/login_join.png',
                    width: 72, height: 72),
              ),
              Container(
                child: Text(Strings.shared.controllers.signSelect.title2,
                    style: TextStyle(
                        color: Statics.shared.colors.titleTextColor,
                        fontSize: Statics.shared.fontSizes.title)), // Text
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20, bottom: 10),
              ),
              Container(
                  child: Row(
                    children: [
                      FlatButton(
                        child: Row(children: [
                          Text(Strings.shared.controllers.signSelect.button2,
                              style: TextStyle(
                                  color: Statics.shared.colors.titleTextColor,
                                  fontSize:
                                      Statics.shared.fontSizes.supplementary)),
                          Image.asset('Resources/Icons/btn_next_green.png',
                              width: 28, height: 28),
                        ]),
                        onPressed: () {
                          // Navigator.push(
                          //     context,
                          //     new MaterialPageRoute(
                          //         builder: (context) => new Join()));
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new SignAuth()));
                        },
                      ),
                    ], // Row Children
                    mainAxisAlignment: MainAxisAlignment.center,
                  ), // Row
                  alignment: Alignment.center),
            ], // Row Children
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ), // Row

          padding: const EdgeInsets.only(left: 32, right: 32),
          width: MiddleWare.shared.screenSize,
          alignment: Alignment(0.0, 0.0),
        ), // Container
      ),
    );
  }
}

Future<Result> createPost(String url, {Map body}) async {
  jsonMsg = "";
  return http
      .post(
    url,
    body: body,
  )
      .then((http.Response response) {
    final int statusCode = response.statusCode;
    //final String responseBody = response.body; //한글 깨짐
    final String responseBody = utf8.decode(response.bodyBytes);
    var responseJSON = json.decode(responseBody);
    jsonMsg = responseJSON['msg'];

    if (statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var table = responseJSON["table"];
      for (var result in table) {
        return Result.fromJson(result);
      }
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  });
}

//JSON 데이터
class Result {
  final String idx;
  final String member_idx;
  final String id;
  final String member_name;

  Result({this.idx, this.member_idx, this.id, this.member_name});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      idx: json['idx'],
      member_idx: json['member_idx'],
      id: json['id'],
      member_name: json['member_name'],
    );
  }
}

Widget makeText(String title, {double width, double height}) {
  return Container(
    child: Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 23.0),
      ),
    ),
    width: width,
    height: height,
    decoration: BoxDecoration(color: Colors.red[300]),
    margin: EdgeInsets.all(10.0),
  );
}