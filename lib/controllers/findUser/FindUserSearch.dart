import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haegisa2/controllers/Chat/Chat.dart';
import 'package:haegisa2/models/DataBase/MyDataBase.dart';
import 'package:haegisa2/models/SearchMembers/MemberObject.dart';
import 'package:haegisa2/models/SearchMembers/SearchMemberObject.dart';
import 'package:haegisa2/models/User.dart';
import 'package:haegisa2/models/statics/strings.dart';
import 'package:haegisa2/models/statics/statics.dart';
import 'package:http/http.dart' as http;

class MiddleWare {
  List<MemberObject> membersList = [];
  TextEditingController ctrlTxtSearch = TextEditingController();

  _MiddleWare() {}
  static MiddleWare shared = MiddleWare();
}

class FindUserSearch extends StatefulWidget {
  final db = MyDataBase();
  bool isMyFirstInit = true;
  FindUserSearch({Key key}) : super(key: key);

  @override
  _FindUserSearchState createState() => _FindUserSearchState();
}

class _FindUserSearchState extends State<FindUserSearch> {
  final _scaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  searchMembers(String name) async {
    print(
        "::::::::::::::::::::: [ START SEARCHING MEMBERS ] :::::::::::::::::::::");
    final response = await http.post(Statics.shared.urls.searchMembers, body: {
      'mode': 'search',
      'searchName': name,
      'pageNum': '1',
    });

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      var responseBodyJson = json.decode(utf8.decode(response.bodyBytes));
      print(
          "::::::::::::::::::::: [ START SEARCHING MEMBERS ... ]=>[${responseBodyJson.toString()}] ::::::::::::::::::::: ");
      if (responseBodyJson['code'] == 100) {
        setState(() {
          MiddleWare.shared.membersList = [];
        });
      } else if (responseBodyJson['code'] == 200) {
        List<SearchMemberObject> searchedItems = [];
        if (responseBodyJson['rowsCnt'] > 0) {
          print(
              "::::::::::::::::::::: [ START SEARCHING MEMBERS ]=> [${responseBodyJson.toString()}] :::::::::::::::::::::");
          List<dynamic> rows = responseBodyJson['rows'];
          for (int i = 0; i < rows.length; i++) {
            searchedItems.add(SearchMemberObject.fromJson(rows[i]));
          } // for loop

          setState(() {
            MiddleWare.shared.membersList = [];
            MiddleWare.shared.ctrlTxtSearch.text = "";
            for (int i = 0; i < searchedItems.length; i++) {
              String convIdFromDb = 'xxx';
              this.widget.db.checkConversationExistByUser(
                  userId: searchedItems[i].userId,
                  onResult: (res) {
                    convIdFromDb = res["convId"];
                  },
                  onNoResult: () {
                    convIdFromDb = 'xxx';
                  });

              MemberObject obj = MemberObject(
                title: searchedItems[i].userName,
                shortDescription: searchedItems[i].schoolName +
                    " " +
                    searchedItems[i].schoolGisu +
                    "기",
                hasBlueBadge: true,
                onTapped: () {
                  String cID = convIdFromDb; // Conversation ID
                  User usr = User(
                      UID: "${searchedItems[i].userId}",
                      fullName: "${searchedItems[i].userName}",
                      avatar: "",
                      caption: "${searchedItems[i].schoolName}",
                      gisu: "${searchedItems[i].schoolGisu}");

                  Navigator.push(
                      _scaffold.currentContext,
                      new MaterialPageRoute(
                          builder: (context) => new Chat(
                              title: "${searchedItems[i].userName}",
                              conversationId: cID,
                              user: usr)));
                }, // on Tapped
              );

              MiddleWare.shared.membersList.add(obj);
            } // for loop
          });
        } else {
          setState(() {
            MiddleWare.shared.membersList = [];
          });
          print("There Are Nothing!");
        }
      } // results
    } else {
      // If that response was not OK, throw an error.
      setState(() {});
      print("Failed to load post Server Error");
      throw Exception('Failed to load post Server Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        systemNavigationBarColor:
            Colors.black // Dark == white status bar -- for IOS.
        ));

    double height = MediaQuery.of(context).size.height;
    Color iconSearchColor =
        Statics.shared.colors.mainColor; //Color.fromRGBO(241,244,250, 1);

    Widget dataView = ListView(
      children: MiddleWare.shared.membersList,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
    );
    Widget notFoundView = Container(
      child: Column(
        children: <Widget>[
          Image.asset("Resources/Icons/wondeIconr.png", width: 60),
          SizedBox(height: 20),
          Text(Strings.shared.controllers.findUser.notFound,
              style: TextStyle(
                  fontSize: Statics.shared.fontSizes.content,
                  color: Statics.shared.colors.captionColor)),
        ],
      ),
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 120),
    );

    Widget shoW = Container();
    if (MiddleWare.shared.membersList.length > 0) {
      shoW = dataView;
    } else {
      if (!this.widget.isMyFirstInit) {
        shoW = notFoundView;
      }
    }
    this.widget.isMyFirstInit = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        title: Container(
            child: Text(Strings.shared.controllers.findUser.pageTitle,
                style: TextStyle(
                    color: Statics.shared.colors.titleTextColor,
                    fontSize: Statics.shared.fontSizes.subTitle,
                    fontWeight: FontWeight.bold)),
            margin: const EdgeInsets.only(left: 8)),
        centerTitle: false,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromRGBO(0, 0, 0, 1)),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
                autofocus: true,
                maxLines: 1,
                minLines: 1,
                controller: MiddleWare.shared.ctrlTxtSearch,
                onSubmitted: (search) {
                  if (search.isNotEmpty) {
                    searchMembers(search);
                  } // is Not Empty
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText:
                      Strings.shared.controllers.findUser.searchPlaceHolder,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.only(
                      left: 32, right: 32, top: 20, bottom: 20),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 2, color: Color.fromRGBO(241, 244, 250, 1)),
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  hintStyle: TextStyle(
                      fontSize: Statics.shared.fontSizes.content,
                      color: Statics.shared.colors.subTitleTextColor),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.only(right: 8),
                    icon: Image.asset("Resources/Icons/icon_search.png",
                        height: 22,
                        alignment: Alignment.bottomRight,
                        color: iconSearchColor),
                    onPressed: () {
                      if (MiddleWare.shared.ctrlTxtSearch.text.isNotEmpty) {
                        searchMembers(MiddleWare.shared.ctrlTxtSearch.text);
                      } // is Not Empty
                    },
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                ),
                style: TextStyle(
                  fontSize: Statics.shared.fontSizes.content,
                  color: Statics.shared.colors.titleTextColor,
                ),
              ),
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
              height: 61,
              color: Colors.white,
            ),
            Container(
              child: shoW,
              height: height - 141,
              color: Colors.white,
            ),
          ],
        ), // Column
      ), // end Body
      key: _scaffold,
    );
  }
}
