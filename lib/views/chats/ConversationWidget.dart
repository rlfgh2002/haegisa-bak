import 'package:flutter/material.dart';
import 'package:haegisa2/models/statics/statics.dart';

class ConversationWidget extends StatelessWidget {

  double avatarRadius = 30;

  String convId = "";
  String title = "";
  int badges = 0;
  String avatarLink = "";
  String avatarName = "";
  String shortDescription = "";
  String time = "";
  VoidCallback onTapped;

  ConversationWidget({String title = "", int badges = 0, String avatarLink = "", String avatarName = "", String shortDescription = "",String time = "", VoidCallback onTapped, String convId = ""}){
    this.title = title;
    this.badges = badges;
    this.avatarLink = avatarLink;
    this.avatarName = avatarName;
    this.shortDescription = shortDescription;
    this.time = time;
    this.onTapped = onTapped;
    this.convId = convId;
  }

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(width: 5,height: 5,decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),color: Colors.red),margin: const EdgeInsets.only(top: 20),);

    NetworkImage avatar;
    if(this.avatarLink != ""){
      avatar = NetworkImage(this.avatarLink);
    }

    return Container(color: Colors.white, height: 100,margin: const EdgeInsets.only(top: 5),
      child: FlatButton(
        child: Container(padding: const EdgeInsets.only(left: 24, right: 24),
          child: Row(children: [
            Container(child: CircleAvatar(
              child: Center(child: Text(this.avatarName, style: TextStyle(color: Colors.white, fontSize: Statics.shared.fontSizes.titleInContent))),
              radius: this.avatarRadius,
              backgroundImage: avatar,
              backgroundColor: Statics.shared.colors.mainColor,
            ),width: 60,height: 60),
            SizedBox(width: 10),
            Column(
            children: [
              Container(child: Text(this.title,style: TextStyle(fontSize: Statics.shared.fontSizes.titleInContent, color: Statics.shared.colors.titleTextColor)),
              width: MediaQuery.of(context).size.width - 60 - 10 - 48 - 10 - 16 - 90,
                height: 50,
              ),
              SizedBox(height: 5),
              Text(this.shortDescription,style: TextStyle(fontSize: Statics.shared.fontSizes.subTitleInContent, color: Statics.shared.colors.subTitleTextColor)),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
        ),
            SizedBox(width: 10),
            Expanded(child: Container()),
            Container(child: Column(
              children: [
                Text(this.time, style: TextStyle(color: Statics.shared.colors.subTitleTextColor, fontSize: Statics.shared.fontSizes.supplementary),),
                badge
              ],
              crossAxisAlignment: CrossAxisAlignment.end,
            ), alignment: Alignment.topRight, padding: const EdgeInsets.only(top: 24),)
          ]
          ),
        ),
        padding: const EdgeInsets.all(0),
        onPressed: (){
          this.onTapped();
        },
      ),
    );
  }
}