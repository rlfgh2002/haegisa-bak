import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haegisa2/controllers/gallery/GalleryListSingle.dart';
import 'package:haegisa2/models/Gallery/GalleryListObject.dart';
import 'package:haegisa2/models/statics/statics.dart';

class GalleryListWidget extends StatelessWidget {
  String title = "";
  String title2 = "";
  String thumb = "";
  String thumb2 = "";

  VoidCallback onTap;
  GalleryListObject obj;

  GalleryListWidget({
    String title,
    String title2,
    String thumb,
    String thumb2,
    VoidCallback onTap,
    GalleryListObject obj,
  }) {
    this.title = title;
    this.title2 = title2;
    this.thumb = thumb;
    this.thumb2 = thumb2;
    this.obj = obj;
    this.onTap = onTap;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        systemNavigationBarColor:
            Colors.black // Dark == white status bar -- for IOS.
        ));

    double paddingSize = 16;
    double buttonSize = 70;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: FlatButton(
        child: Column(
          children: <Widget>[
            Container(
              child: Image.network(
                  "http://www.mariners.or.kr/uploads/photoNews/Thumb_" + thumb,
                  width: ((screenWidth - (paddingSize * 1.0)) - buttonSize)),
            ),
            Container(
                child: Text(
                  this.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Statics.shared.colors.titleTextColor,
                      fontSize: Statics.shared.fontSizes.content),
                  textAlign: TextAlign.start,
                ),
                width: ((screenWidth - (paddingSize * 1.0)) - buttonSize)),
            Row(
              children: <Widget>[
                Container(
                  child: Text(this.obj.regDate,
                      style: TextStyle(
                          color: Statics.shared.colors.captionColor,
                          fontSize: Statics.shared.fontSizes.small)),
                  padding: const EdgeInsets.only(top: 2),
                ),
                DateTime.now()
                            .difference(DateTime.parse(this.obj.regDate))
                            .inDays <=
                        7
                    ? Container(
                        child: Text(
                          " N",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: Statics.shared.fontSizes.verySmall,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.justify,
                        ),
                      )
                    : Container(),
              ],
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new GallerylistSingle(obj: obj)));
        },
      ),

      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Statics.shared.colors.lineColor)),
      ),
      //height: 80,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
      alignment: Alignment.center,
    );
  }
}
