import 'package:flutter/material.dart';
import 'package:haegisa2/models/statics/statics.dart';

class NoticeWidget extends StatelessWidget {

  String title = "";
  String shortDescription = "";
  String time = "";
  double avatarRadius = 30;
  String avatarLink = "Resources/Icons/img_notice.png";
  NoticeType type = NoticeType.Notice;
  VoidCallback onTapped;

  NoticeWidget({
    String title = "",
    String shortDescription = "",
    String time = "",
    NoticeType type = NoticeType.Notice,
    VoidCallback onTapped
    }){
    this.title = title;
    this.shortDescription = shortDescription;
    this.time = time;
    this.type = type;
    this.onTapped = onTapped;

    switch(type){
      case NoticeType.Notice:
        this.avatarLink = "Resources/Icons/img_notice.png";
        break;
      case NoticeType.Survey:
        this.avatarLink = "Resources/Icons/img_survey.png";
        break;
      case NoticeType.Vote:
        this.avatarLink = "Resources/Icons/img_vote.png";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenSize = MediaQuery.of(context).size.width;

    return Container(color: Colors.white,margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: FlatButton(
          padding: const EdgeInsets.all(0),
          onPressed: (){this.onTapped();},
          child: Container(padding: const EdgeInsets.only(left: 8, right: 8),
        child: Row(children: [
          CircleAvatar(
            radius: this.avatarRadius,
            backgroundImage: new AssetImage(this.avatarLink),
            backgroundColor: Colors.white,
          ),
          SizedBox(width: 10),
          Column(
            children: [
              Container(child: Row(
                children: [
                  Container(child: Text(this.title,style: TextStyle(fontSize: Statics.shared.fontSizes.content, color: Statics.shared.colors.titleTextColor), overflow: TextOverflow.fade,),
                  width: screenSize - 100 - 100,),
                  Container(child: Text(this.time, style: TextStyle(color: Statics.shared.colors.subTitleTextColor, fontSize: Statics.shared.fontSizes.supplementary),overflow: TextOverflow.fade,),
                    width: 100,),
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),width: screenSize-100),
              SizedBox(height: 5),
              Container(child: Text(this.shortDescription,style: TextStyle(fontSize: Statics.shared.fontSizes.content, color: Statics.shared.colors.subTitleTextColor)
                ,overflow: TextOverflow.fade,
              ),width: screenSize-100,)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
          ),
          SizedBox(width: 10),
        ]
        ),
      ),
          highlightColor: Color.fromRGBO(244, 248, 255, 1),
      ),
    );
  }
}

enum NoticeType
{
  Notice,Vote,Survey
}
