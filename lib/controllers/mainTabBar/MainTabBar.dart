import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haegisa2/controllers/Chat/Chat.dart';
import 'package:haegisa2/controllers/chats/Chats.dart';
import 'package:haegisa2/controllers/notices/Notices.dart';
import 'package:haegisa2/models/Vote/VoteObject.dart';
import 'package:haegisa2/models/statics/statics.dart';
import 'MiddleWare.dart';
import 'package:haegisa2/models/DataBase/MyDataBase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:haegisa2/models/Chat/chatObject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainTabBar extends StatefulWidget {
  final MyDataBase db = MyDataBase();
  FirebaseMessaging mainFirebaseMessaging = FirebaseMessaging();

  String myUserId = '';
  static MainTabBar mainTabBar;
  static MainTabBarState myChild;
  MiddleWare mdw = MiddleWare.shared;

  @override
  MainTabBarState createState()
  {
    MainTabBar.mainTabBar = this;
    return MainTabBarState();
  }

}

class MainTabBarState extends State<MainTabBar> with TickerProviderStateMixin {
  static BottomNavigationBar navBar;

  void getAllSurveys({String uid}) async {

    String url = Statics.shared.urls.searchSurveys(uid);
    await http.get(url).then((val){
      if(val.statusCode == 200){
        print("OUTPUT: ${val.body.toString()}");
        Map<String, dynamic> body = json.decode(val.body.trim());
        if(body['code'] == "200")
        {
          var myList = body['table'];
          for(int i = 0; i < myList.length; i++){
            widget.db.checkSurveyExist(no: myList[i]['no'].toString(),onNoResult: (){
              widget.db.insertSurvey(
                  no: myList[i]['no'].toString(),
                  bd_idx: myList[i]['bd_idx'].toString(),
                  start_date: myList[i]['start_date'].toString(),
                  end_date: myList[i]['end_date'].toString(),
                  subject: myList[i]['subject'].toString(),
                  content: myList[i]['contents'].toString(),
                  q_cnt: myList[i]['q_cnt'].toString(),
                  onAdded:(){
                    getSurveysAnswers(uid: uid, idx: myList[i]['bd_idx'].toString(),onSent: (response){
                      var data = response['data'];
                      widget.db.insertSurveyAnswer(
                          idx: data['idx'].toString(),
                          status: data['status'].toString(),
                          answer1: data['a1'].toString(),
                          answer2: data['a2'].toString(),
                          answer3: data['a3'].toString(),
                          answer4: data['a4'].toString(),
                          answer5: data['a5'].toString(),
                          answer6: data['a6'].toString(),
                          onAdded: (){
                            if(Notices.staticNoticesPage != null && Notices.staticNoticesPage.myChild != null){
                              Notices.staticNoticesPage.myChild.refreshNotices();
                            }
                          }
                      );
                    });
                  }
              );
            },
              onResult: (items){}
            );
          }
        }
      }
    }).catchError((error){
      print(":::::::::::::::::: on getting Survey error : ${error.toString()} ::::::::::::::::::");
    });
  }
  void getSurveysAnswers({onSent(Map<String, dynamic> jj), String uid, String idx}) async {

    var url = Statics.shared.urls.searchSurveysAnswers(uid, idx);
    await http.get(url).then((val){
      if(val.statusCode == 200){
        print("OUTPUT: ${val.body.toString()}");
        var j = jsonDecode(val.body);
        print("OUTPUT JSON: ${j.toString()}");
        onSent(j);
      }
    }).catchError((error){
      print(":::::::::::::::::: on getting Surevey Answers error : ${error.toString()} ::::::::::::::::::");
    }).whenComplete((){
      print("::::::::::::::::::::: [ SEND URL SURVEY ANSWERS ] :::::::::::::::::::::");
      print("URL: ${url.toString()}");
      print("::::::::::::::::::::: [ SEND URL SURVEY ANSWERS ] :::::::::::::::::::::");
    });
  }
  void getVoteAnswers({String url, onSent(Map<String, dynamic> jj)}) async {

    await http.get(url).then((val){
      if(val.statusCode == 200){
        print("OUTPUT: ${val.body.toString()}");
        var j = jsonDecode(val.body);
        print("OUTPUT JSON: ${j.toString()}");
        onSent(j);
      }
    }).catchError((error){
      print(":::::::::::::::::: on getting Vote Answers error : ${error.toString()} ::::::::::::::::::");
    }).whenComplete((){
      print("::::::::::::::::::::: [ SEND URL VOTE ] :::::::::::::::::::::");
      print("URL: ${url.toString()}");
      print("::::::::::::::::::::: [ SEND URL VOTE ] :::::::::::::::::::::");
    });
  }
  void firebaseCloudMessaging_Listeners() async{

    print("::::::::::::::::::::::::: [ Firebase Listening ] :::::::::::::::::::::::::");

    if (Platform.isIOS) iOS_Permission();

    widget.mainFirebaseMessaging.getToken().then((token){
      print(token);
    });


    widget.mainFirebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message Main $message');
        analiseMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        analiseMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        analiseMessage(message);
      },
    );


  }
  void iOS_Permission() {
    widget.mainFirebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    widget.mainFirebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }
  void analiseMessage(Map<String, dynamic> message){
    ChatObject chatItem = ChatObject.fromJson(message);
    if(message['data']['notificationType'].toString() == "chat"){
      widget.db.checkConversationExist(userId: chatItem.notificationFromId,onResult: (res){
        widget.db.insertChat(
            convId: chatItem.notificationConversationId,
            userId: chatItem.notificationFromId,
            content: chatItem.notificationContent,
            date: chatItem.notificationRegDate,
            isYours: "FALSE",
            onAdded: (){
              if(Chats.staticChatsPage != null){
                Chats.staticChatsPage.refresh();
              }

              if(Chat.staticChatPage != null){
                if(Chat.staticChatPage.isInThisPage == true){
                  Chat.staticChatPage.myChild.addMessageToList(
                      msg: chatItem.notificationContent,
                      isYours: false,
                      date: chatItem.notificationRegDate,
                      senderName: chatItem.notificationFromName
                  );
                }
              }
            }
        );
      },onNoResult: (){
        widget.db.insertConversation(
            userId: chatItem.notificationFromId,
            convId: chatItem.notificationConversationId,
            createDate: chatItem.notificationRegDate,
            fromName: chatItem.notificationFromName,
            onInserted: (){
              print(":::::::::::::::::: [new conversation added] ::::::::::::::::::");
              widget.db.insertChat(
                  convId: chatItem.notificationConversationId,
                  userId: chatItem.notificationFromId,
                  content: chatItem.notificationContent,
                  date: chatItem.notificationRegDate,
                  isYours: "FALSE",
                  onAdded: (){
                    if(Chats.staticChatsPage != null){
                      Chats.staticChatsPage.refresh();
                    }
                    if(Chat.staticChatPage != null){
                      if(Chat.staticChatPage.isInThisPage == true){
                        Chat.staticChatPage.myChild.addMessageToList(
                            msg: chatItem.notificationContent,
                            isYours: false,
                            date: chatItem.notificationRegDate,
                            senderName: chatItem.notificationFromName
                        );
                      }
                    }
                  }
              );
            },
            onNoInerted: (){
              print(":::::::::::::::::: [new conversation not added !] ::::::::::::::::::");
            }
        );
      });
      // chat notification
    }
    else{
      if(message['data']['notificationType'].toString() == "vote"){
        // vote notification
        VoteObject voteItem = VoteObject.fromJson(message);
        widget.db.insertVote(voteItem: voteItem,onAdded: (){

          String url = "${voteItem.httpPath.toString()}&userId=${this.widget.myUserId}&mode=view";
          url = url.replaceAll("https://", "http://");
          getVoteAnswers(url: url,onSent: (response){

            widget.db.insertAnswer(onAdded: (){
              if(Notices.staticNoticesPage != null){
                Notices.staticNoticesPage.myChild.refreshNotices();
              }
            },idx: voteItem.idx, status: response['data']['status'].toString(),
              answer1: response['data']['a1'].toString(),
              answer2: response['data']['a2'].toString(),
              answer3: response['data']['a3'].toString(),
              answer4: response['data']['a4'].toString(),
              answer5: response['data']['a5'].toString(),
              answer6: response['data']['a6'].toString(),
            );

          });
        });
      } // Vote Notification
    }
  }
  void getUserId({onGetUserId(String userId)}) async
  {
    await SharedPreferences.getInstance().then((val){
      String uid = val.getString("app_user_login_info_userid");
      this.widget.myUserId = uid;
      onGetUserId(uid);
    });
  }

  @override
  void initState()
  {
    MainTabBar.myChild = this;
    MiddleWare.shared.tabc = TabController(
        length: MiddleWare.shared.myTabBarList.length, vsync: this);

    getUserId(onGetUserId: (uid){
      getAllSurveys(uid: uid);
    });
    firebaseCloudMessaging_Listeners();
    print("Main TabBar New...");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clickToChangeMenu(index) {
    setState(() {
      MiddleWare.shared.currentIndex = index;
      MiddleWare.shared.tabc.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    MainTabBarState.navBar = BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: new Image.asset("Resources/Icons/btn_main.png", width: 25),
            activeIcon:
                new Image.asset("Resources/Icons/btn_main_ac.png", width: 25),
            title: Text("")),
        BottomNavigationBarItem(
            icon:
                new Image.asset("Resources/Icons/btn_finduser.png", width: 50),
            activeIcon: new Image.asset("Resources/Icons/btn_finduser_ac.png",
                width: 50),
            title: Text("")),
        BottomNavigationBarItem(
            icon: new Image.asset("Resources/Icons/btn_chat.png", width: 25),
            activeIcon:
                new Image.asset("Resources/Icons/btn_chat_ac.png", width: 25),
            title: Text("")),
        BottomNavigationBarItem(
            icon: new Image.asset("Resources/Icons/btn_notice.png", width: 25),
            activeIcon:
                new Image.asset("Resources/Icons/btn_notice_ac.png", width: 25),
            title: Text("")),
        BottomNavigationBarItem(
            icon: new Image.asset("Resources/Icons/btn_mymenu.png", width: 40),
            activeIcon:
                new Image.asset("Resources/Icons/btn_mymenu_ac.png", width: 40),
            title: Text("")),
      ],
      backgroundColor: Colors.white30,
      fixedColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: MiddleWare.shared.currentIndex,
      onTap: (index) {
        clickToChangeMenu(index);
      },
    );

    return new Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        children: MiddleWare.shared.myTabBarList,
        controller: MiddleWare.shared.tabc,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: MainTabBarState.navBar,
    );
  }
}