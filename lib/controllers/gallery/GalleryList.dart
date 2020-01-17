import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haegisa2/controllers/gallery/GallerylistSingle.dart';
import 'package:haegisa2/controllers/SplashScreen/SplashScreen.dart';
import 'package:haegisa2/controllers/mainTabBar/MainTabBar.dart';
import 'package:haegisa2/controllers/mainTabBar/MiddleWare.dart';
import 'package:haegisa2/models/Gallery/GalleryListObject.dart';
import 'package:haegisa2/models/statics/UserInfo.dart';
import 'package:haegisa2/models/statics/strings.dart';
import 'package:haegisa2/models/statics/statics.dart';
import 'package:haegisa2/views/GalleryListWidget/GalleryListWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GalleryList extends StatefulWidget {
  bool isFirstInit = true;
  GalleryList({Key key}) : super(key: key);
  List<Widget> myList = [];
  List<Widget> galleryList = [];

  @override
  _GalleryListState createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> {
  final _scaffold = GlobalKey<ScaffoldState>();

  void refreshList(int pCurrent, pTotal) {
    widget.myList = [];
    double screenWidth = MediaQuery.of(context).size.width;
    Widget topView = Container(
      child: Stack(
        children: [
          Image.asset(
            "Resources/Images/bgGallery.png",
            width: screenWidth,
            height: 100,
          ),
        ],
      ),
      alignment: Alignment.center,
      height: 100,
    );
    Widget blueSplitter = Container(
        color: Statics.shared.colors.blueLineColor,
        height: 3,
        margin:
            const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10));
    widget.myList.add(topView);
    widget.myList.add(blueSplitter);

    widget.myList.addAll(this.widget.galleryList); // fetch from server

    if (pTotal > pCurrent) {
      Widget downloadMoreView = Container(
        child: FlatButton(
          child: Container(
            child: Text(Strings.shared.controllers.magazines.downloadMoreKey,
                style: TextStyle(
                    color: Statics.shared.colors.mainColor,
                    fontSize: Statics.shared.fontSizes.supplementary,
                    fontWeight: FontWeight.w200)),
            alignment: Alignment.center,
          ),
          onPressed: () {
            // download 5 more magazines ...
            this.download5MoreNotices(page: pCurrent + 1);
          },
          padding: const EdgeInsets.all(0),
        ),
        decoration: BoxDecoration(
            border:
                Border.all(width: 1, color: Statics.shared.colors.mainColor)),
        width: screenWidth,
        height: 60,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 20, right: 16, left: 16, bottom: 20),
      );
      widget.myList.add(downloadMoreView);
    }
    setState(() {});
  }

  void download5MoreNotices({int page = 1}) async {
    http.get(Statics.shared.urls.galleryList(page: page)).then((val) {
      if (val.statusCode == 200) {
        print(
            "::::::::::::::::::::: [ Getting NoticesList Start ] :::::::::::::::::::::");
        print("BODY: ${val.body.toString()}");
        var myJson = json.decode(utf8.decode(val.bodyBytes));

        int code = myJson["code"];
        if (code == 200) {
          List<GalleryListObject> myReturnList = [];
          int pTotal = myJson["totalPageNum"];
          int pCurrent = myJson["nowPageNum"];
          List<dynamic> rows = myJson["rows"];

          List<Widget> newList = [];
          rows.forEach((item) {
            GalleryListObject object = GalleryListObject(
              subject: item["subject"].toString(),
              no: item["no"],
              content: item["content"].toString(),
              regDate: item["regDate"].toString(),
              writer: item["writer"].toString(),
              fileUrl_1: item["fileUrl_1"].toString(),
              fileUrl_2: item["fileUrl_2"].toString(),
              fileUrl_3: item["fileUrl_3"].toString(),
              fileUrl_4: item["fileUrl_4"].toString(),
              realFileName1: item["realFileName1"].toString(),
              realFileName2: item["realFileName2"].toString(),
              realFileName3: item["realFileName3"].toString(),
              realFileName4: item["realFileName4"].toString(),
              serverFileName_1: item["serverFileName_1"].toString(),
              serverFileName_2: item["serverFileName_2"].toString(),
              serverFileName_3: item["serverFileName_3"].toString(),
              serverFileName_4: item["serverFileName_4"].toString(),
            );
            newList.add(GalleryListWidget(
              title: item["subject"].toString(),
              title2: item["subject_2"].toString(),
              thumb: item["serverFileName_1"].toString(),
              thumb2: item["serverFileName_1_2"].toString(),
              obj: object,
            ));
          });
          if (page == 1) {
            this.widget.galleryList = newList;
          } else {
            this.widget.galleryList.addAll(newList);
          }
          this.refreshList(pCurrent, pTotal);
        }
        print(
            "::::::::::::::::::::: [ Getting NoticesList End ] :::::::::::::::::::::");
      } else {
        print(
            ":::::::::::::::::: on Getting NoticesList error :: Server Error ::::::::::::::::::");
      }
    }).catchError((error) {
      print(
          ":::::::::::::::::: on Getting NoticesList error : ${error.toString()} ::::::::::::::::::");
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        systemNavigationBarColor:
            Colors.black // Dark == white status bar -- for IOS.
        ));
    if (widget.isFirstInit) {
      download5MoreNotices(page: 1);
      widget.isFirstInit = false;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        title: Container(
            child: Text("협회활동",
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
        child: ListView(
          children: this.widget.myList,
        ),
        color: Colors.white,
      ), // end Body
      key: _scaffold,
    );
  }
}
