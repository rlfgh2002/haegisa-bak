import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:haegisa2/controllers/Chat/Chat.dart';
import 'package:haegisa2/controllers/chats/Chats.dart';
import 'package:haegisa2/controllers/notices/Notices.dart';
import 'package:haegisa2/models/Vote/VoteObject.dart';
import 'package:haegisa2/models/myFuncs.dart';
import 'package:haegisa2/models/statics/UserInfo.dart';
import 'package:haegisa2/models/statics/statics.dart';
import 'package:haegisa2/models/statics/strings.dart';
import 'package:haegisa2/views/MainTabBar/locationPopUpWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'MiddleWare.dart';
import 'package:haegisa2/models/DataBase/MyDataBase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:haegisa2/models/Chat/chatObject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:haegisa2/views/MainTabBar/NoInternetPopUp.dart';
import 'package:geolocator/geolocator.dart';

class MainTabBar extends StatefulWidget {
  final MyDataBase db = MyDataBase();
  FirebaseMessaging mainFirebaseMessaging = FirebaseMessaging();
  Position userLocation;

  StreamSubscription subscription;
  String myUserId = '';
  static MainTabBar mainTabBar;
  static MainTabBarState myChild;
  MiddleWare mdw = MiddleWare.shared;

  @override
  MainTabBarState createState() {
    MainTabBar.mainTabBar = this;
    return MainTabBarState();
  }
}

class MainTabBarState extends State<MainTabBar> with TickerProviderStateMixin {
  static MainTabBarState shared = MainTabBarState();
  static String btnChat = "Resources/Icons/btn_chat.png";
  static String btnChatAc = "Resources/Icons/btn_chat_ac.png";
  static String btnNotice = "Resources/Icons/btn_notice.png";
  static String btnNoticeAc = "Resources/Icons/btn_notice_ac.png";

  MainTabBarState() {}
  DateTime backButtonPressTime;
  static BottomNavigationBar navBar;
  Geolocator geolocator = Geolocator();
  final GlobalKey<MainTabBarState> _scaffoldKey =
      new GlobalKey<MainTabBarState>();

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  static Future<void> setBadge(
      BuildContext context, String type, bool newMessage) {
    MainTabBarState state =
        context.findAncestorStateOfType<State<MainTabBar>>();

    //비동기로 변경하면서 state의 상태를 먼저 체크 후 뱃지 변경

    state.setState(() {
      if (type == "chat") {
        if (newMessage == true) {
          btnChat = "Resources/Icons/btn_chat_new.png";
          btnChatAc = "Resources/Icons/btn_chat_ac_new.png";
        } else {
          btnChat = "Resources/Icons/btn_chat.png";
          btnChatAc = "Resources/Icons/btn_chat_ac.png";
        }
      } else if (type == "notice") {
        if (newMessage == true) {
          btnNotice = "Resources/Icons/btn_notice_new.png";
          btnNoticeAc = "Resources/Icons/btn_notice_ac_new.png";
        } else {
          btnNotice = "Resources/Icons/btn_notice.png";
          btnNoticeAc = "Resources/Icons/btn_notice_ac.png";
        }
      }
    });
  }

  void getAllSurveys({String uid}) async {
    String url = Statics.shared.urls.searchSurveys(uid, "search", "");
    widget.db.deleteSurvey();
    widget.db.deleteSurveyAnswer();
    await http.get(url).then((val) {
      if (val.statusCode == 200) {
        print("OUTPUT: ${val.body.toString()}");
        final String responseBody = utf8.decode(val.bodyBytes);
        Map<String, dynamic> body = json.decode(responseBody.trim());
        if (body['code'] == "200") {
          var myList = body['table'];
          for (int i = 0; i < myList.length; i++) {
            widget.db.checkSurveyExist(
                no: myList[i]['no'].toString(),
                onNoResult: () {
                  widget.db.insertSurvey(
                      no: myList[i]['no'].toString(),
                      isDone: myList[i]['status'].toString() == "Y"
                          ? "TRUE"
                          : "FALSE",
                      bd_idx: myList[i]['bd_idx'].toString(),
                      start_date: myList[i]['start_date'].toString(),
                      end_date: myList[i]['end_date'].toString(),
                      subject: myList[i]['subject'].toString(),
                      content: myList[i]['contents'].toString(),
                      q_cnt: myList[i]['q_cnt'].toString(),
                      onAdded: () {
                        getSurveysAnswers(
                            uid: uid,
                            idx: myList[i]['bd_idx'].toString(),
                            onSent: (response) {
                              if (response['code'].toString() == "200") {
                                Map<String, dynamic> dataAnswers =
                                    response['table'][0]['q_title'];
                                int qCnt =
                                    int.parse(myList[i]['q_cnt'].toString());

                                for (int j = 0; j < qCnt; j++) {
                                  String qStr = "q${(j + 1).toString()}";
                                  var qItems = dataAnswers['${qStr}_item'];
                                  int qItemsCount = qItems.length;

                                  String ans1 = "";
                                  String ans2 = "";
                                  String ans3 = "";
                                  String ans4 = "";
                                  String ans5 = "";
                                  String ans6 = "";
                                  String ans7 = "";
                                  String ans8 = "";

                                  for (int z = 0; z < qItemsCount; z++) {
                                    if (z == 0) {
                                      ans1 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                    if (z == 1) {
                                      ans2 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                    if (z == 2) {
                                      ans3 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                    if (z == 3) {
                                      ans4 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                    if (z == 4) {
                                      ans5 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                    if (z == 5) {
                                      ans6 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                    if (z == 6) {
                                      ans7 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                    if (z == 7) {
                                      ans8 = qItems[
                                          "${qStr.toString()}_${(z + 1).toString()}"];
                                    }
                                  } // for loop 2

                                  print(
                                      "**************************************************");
                                  print("ANS 1 : ${ans1}");
                                  print("ANS 2 : ${ans2}");
                                  print("ANS 3 : ${ans3}");
                                  print("ANS 4 : ${ans4}");
                                  print("ANS 5 : ${ans5}");
                                  print("ANS 6 : ${ans6}");
                                  print("ANS 7 : ${ans7}");
                                  print("ANS 8 : ${ans8}");
                                  print(
                                      "q Title : ${dataAnswers['q${(j + 1).toString()}'].toString()}");
                                  print("QN : ${(j + 1).toString()}");
                                  print(
                                      "**************************************************");

                                  widget.db.insertSurveyAnswer(
                                      idx: myList[i]['bd_idx'].toString(),
                                      qTitle:
                                          dataAnswers['q${(j + 1).toString()}']
                                              .toString(),
                                      qN: (j + 1).toString(),
                                      answer1: ans1,
                                      answer2: ans2,
                                      answer3: ans3,
                                      answer4: ans4,
                                      answer5: ans5,
                                      answer6: ans6,
                                      answer7: ans7,
                                      answer8: ans8,
                                      cnt: qCnt.toString(),
                                      onAdded: () {
                                        print("ADDDEDDDD TOOO SANS");
                                        if (Notices.staticNoticesPage != null &&
                                            Notices.staticNoticesPage.myChild !=
                                                null) {
                                          Notices.staticNoticesPage.myChild
                                              .refreshNotices();
                                        }
                                      });
                                } // for loop
                              }
                            });
                      });
                },
                onResult: (items) {});
          }
        }
      }
    }).catchError((error) {
      print(
          ":::::::::::::::::: on getting Survey error : ${error.toString()} ::::::::::::::::::");
    });
  }

  void getSurveysAnswers(
      {onSent(Map<String, dynamic> jj), String uid, String idx}) async {
    var url = Statics.shared.urls.searchSurveysAnswers(uid, idx);
    await http.get(url).then((val) {
      if (val.statusCode == 200) {
        print("OUTPUT: ${val.body.toString()}");
        var j = json.decode(utf8.decode(val.bodyBytes));
        print("OUTPUT JSON: ${j.toString()}");
        onSent(j);
      }
    }).catchError((error) {
      print(
          ":::::::::::::::::: on getting Surevey Answers error : ${error.toString()} ::::::::::::::::::");
    }).whenComplete(() {
      print(
          "::::::::::::::::::::: [ SEND URL SURVEY ANSWERS ] :::::::::::::::::::::");
      print("URL: ${url.toString()}");
      print(
          "::::::::::::::::::::: [ SEND URL SURVEY ANSWERS ] :::::::::::::::::::::");
    });
  }

  void getVoteAnswers({String url, onSent(Map<String, dynamic> jj)}) async {
    await http.get(url).then((val) {
      if (val.statusCode == 200) {
        print("OUTPUT: ${val.body.toString()}");
        var j = json.decode(utf8.decode(val.bodyBytes));
        print("OUTPUT JSON: ${j.toString()}");
        onSent(j);
      }
    }).catchError((error) {
      print(
          ":::::::::::::::::: on getting Vote Answers error : ${error.toString()} ::::::::::::::::::");
    }).whenComplete(() {
      print("::::::::::::::::::::: [ SEND URL VOTE ] :::::::::::::::::::::");
      print("URL: ${url.toString()}");
      print("::::::::::::::::::::: [ SEND URL VOTE ] :::::::::::::::::::::");
    });
  }

  static void staticGetVoteAnswers(
      {String url, onSent(Map<String, dynamic> jj)}) async {
    await http.get(url).then((val) {
      if (val.statusCode == 200) {
        print("OUTPUT: ${val.body.toString()}");
        var j = json.decode(utf8.decode(val.bodyBytes));
        print("OUTPUT JSON: ${j.toString()}");
        onSent(j);
      }
    }).catchError((error) {
      print(
          ":::::::::::::::::: on getting Vote Answers error : ${error.toString()} ::::::::::::::::::");
    }).whenComplete(() {
      print("::::::::::::::::::::: [ SEND URL VOTE ] :::::::::::::::::::::");
      print("URL: ${url.toString()}");
      print("::::::::::::::::::::: [ SEND URL VOTE ] :::::::::::::::::::::");
    });
  }

  void firebaseCloudMessaging_Listeners() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(
        "::::::::::::::::::::::::: [ Firebase Listening ] :::::::::::::::::::::::::");

    widget.mainFirebaseMessaging.getToken().then((token) {
      print("FCM TOKEN : ${token.toString()}");
    });

    widget.mainFirebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          print('MSGX=> on messageX Main $message');
          Map<String, dynamic> body = {'data': []};
          body['data'] = message;
          analiseMessage(body, true, false);
          if (body['data']['notificationType'].toString().toLowerCase() ==
              "chat") {
            setState(() {
              btnChat = "Resources/Icons/btn_chat_new.png";
              btnChatAc = "Resources/Icons/btn_chat_ac_new.png";
            });
          } else
            setState(() {
              btnNotice = "Resources/Icons/btn_notice_new.png";
              btnNoticeAc = "Resources/Icons/btn_notice_ac_new.png";
            });
        } else {
          if (message['notification']['title'] == null &&
              message['notification']['body'] == null &&
              message['data']['justNotify'] == null) {
            print('MSGX=> on messageX Main $message');
            analiseMessage(message, true, false);

            if (message['data']['notificationType'].toString().toLowerCase() ==
                "chat") {
              setState(() {
                btnChat = "Resources/Icons/btn_chat_new.png";
                btnChatAc = "Resources/Icons/btn_chat_ac_new.png";
              });
            } else
              setState(() {
                btnNotice = "Resources/Icons/btn_notice_new.png";
                btnNoticeAc = "Resources/Icons/btn_notice_ac_new.png";
              });
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('MSGX=> on resumeX $message');
        if (Platform.isIOS) {
          Map<String, dynamic> body = {'data': []};
          body['data'] = message;
          analiseMessage(body, false, true);
        } else {
          analiseMessage(message, false, true);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('MSGX=> on launchX $message');
        if (Platform.isIOS) {
          Map<String, dynamic> body = {'data': []};
          body['data'] = message;
          analiseMessage(body, false, true);
        } else {
          analiseMessage(message, false, true);
        }
      },
      onBackgroundMessage:
          (Platform.isIOS) ? null : fcmBackgroundMessageHandler,
    );
  }

  static Future<dynamic> fcmBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    print('MSGX=> on Background $message');

    final MyDataBase myDb = MyDataBase();

    ChatObject chatItem = ChatObject.fromJson(message);

    String seen = "0";
    if (Chat.staticChatPage != null) {
      if (Chat.staticChatPage.isInThisPage == true) {
        if (chatCurrentConvId == chatItem.notificationConversationId) {
          seen = "1";
        }
      }
    }

    print(message['data']['notificationType']);

    if (message['data']['notificationType'].toString() == null) {
    } // notificationType is null
    else {
      if (message['data']['notificationType'].toString() == "chat") {
        String convId = chatItem.notificationConversationId;
        if (chatItem.notificationFromId == 'mariners123') {
          convId = "x0x0";
        }
        myDb.checkConversationExist(
            userId: chatItem.notificationFromId,
            convId: convId,
            onResult: (res) {
              myDb.insertChat(
                  convId: convId,
                  userId: chatItem.notificationFromId,
                  content: chatItem.notificationContent,
                  date: chatItem.notificationRegDate,
                  seen: seen,
                  isYours: "FALSE",
                  onAdded: () {});
            },
            onNoResult: () {
              myDb.insertConversation(
                  userId: chatItem.notificationFromId,
                  convId: convId,
                  createDate: chatItem.notificationRegDate,
                  fromName: chatItem.notificationFromName,
                  onInserted: () {
                    myDb.checkChatExistByUser(
                        chatId: chatItem.chatId,
                        onNoResult: () {
                          myDb.insertChat(
                              convId: convId,
                              userId: chatItem.notificationFromId,
                              content: chatItem.notificationContent,
                              date: chatItem.notificationRegDate,
                              seen: seen,
                              isYours: "FALSE",
                              chatId: chatItem.chatId,
                              onAdded: () {});
                        });
                  },
                  onNoInerted: () {});
            });
        // chat notification
        sharedPreferences.setBool("app_new_badge_chat", true);

        sharedPreferences.commit();
        return;
      } else {
        if (message['data']['notificationType'].toString() == "vote") {
          // vote notification
          VoteObject voteItem = VoteObject.fromJson(message);
          myDb.checkVoteExist(
              bd_idx: voteItem.idx.toString(),
              onNoResult: () {
                myDb.insertVote(
                    voteItem: voteItem,
                    onAdded: () {
                      staticGetUserId(onGetUserId: (uid) {
                        String url =
                            "${voteItem.httpPath.toString()}&userId=${uid}&mode=view";
                        url = url.replaceAll("https://", "http://");
                        staticGetVoteAnswers(
                            url: url,
                            onSent: (response) {
                              myDb.insertAnswer(
                                onAdded: () {},
                                idx: voteItem.idx,
                                status: response['data']['status'].toString(),
                                answer1: response['data']['a1'].toString(),
                                answer2: response['data']['a2'].toString(),
                                answer3: response['data']['a3'].toString(),
                                answer4: response['data']['a4'].toString(),
                                answer5: response['data']['a5'].toString(),
                                answer6: response['data']['a6'].toString(),
                              );
                            });
                      });

                      /* GOTO VOTE PAGE */
                      /* GOTO VOTE PAGE */
                    });
              });
        } // Vote Notification
        else if (message['data']['notificationType'].toString().toLowerCase() ==
            "notice") {
          VoteObject noticeItem = VoteObject.fromJson(message);

          myDb.insertNotice(
              fromId: noticeItem.fromId,
              fromName: noticeItem.fromName,
              subject: noticeItem.subject,
              noticeId: "",
              content: noticeItem.content,
              onInserted: (status) {
                if (status) {
                } // on inserted
                else {} // on no inserted
              });
        } // Notice Notification
        else if (message['data']['notificationType'].toString().toLowerCase() ==
            "qna") {
          if (message['data']['subject'] != null) {
            myDb.insertQna(
                idx: message['data']['idx'],
                subject: message['data']['subject'],
                regDate: message['data']['regDate'],
                onInserted: (status) {
                  if (status) {
                  } // on inserted
                  else {} // on no inserted
                });
          }
        }

        sharedPreferences.setBool("app_new_badge_notice", true);
        sharedPreferences.commit();
      }
    } // notificationType is NOT null

    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    return null;
    // Or do other work.
  }

  void analiseMessage(
      Map<String, dynamic> message, bool isOnMessage, bool isOnResume) {
    ChatObject chatItem = ChatObject.fromJson(message);

    String seen = "0";
    if (Chat.staticChatPage != null) {
      if (Chat.staticChatPage.isInThisPage == true) {
        if (chatCurrentConvId == chatItem.notificationConversationId) {
          seen = "1";
        }
      }
    }

    if (message['data']['notificationType'].toString() == null) {
    } // notificationType is null
    else {
      if (message['data']['notificationType'].toString() == "chat") {
        // 주석 해제 할 시 해당 채팅방으로 이동
        // 주석 처리할 시 그냥 단순히 채팅 탭으로 이동
        if (isOnResume) {
          // this.widget.mdw.shouldMoveToThisConvId =
          //     message['data']['conversationId'].toString();
          // this.widget.mdw.shouldMoveToThisFromName =
          //     message['data']['fromName'].toString();
          // this.widget.mdw.shouldMoveToThisFromId =
          //     message['data']['fromId'].toString();
          setState(() {
            MiddleWare.shared.currentIndex = 2;
            MiddleWare.shared.tabc.animateTo(2, duration: Duration(seconds: 0));
          });

          if (Platform.isAndroid) {
            return;
          } //아이폰은 return 넣으면 다음으로 넘어가지 않아서 데이터 저장이 안됨. 안드로이드는 return 없으면 노티 누르면 해당 데이터가 저장되서 중복으로 저장이 됨
        }

        String convId = chatItem.notificationConversationId;
        if (chatItem.notificationFromId == 'mariners123') {
          convId = "x0x0";
        }

        widget.db.checkConversationExist(
            userId: chatItem.notificationFromId,
            convId: convId,
            onResult: (res) {
              widget.db.checkChatExistByUser(
                  chatId: chatItem.chatId,
                  onNoResult: () {
                    widget.db.insertChat(
                        convId: convId,
                        userId: chatItem.notificationFromId,
                        content: chatItem.notificationContent,
                        date: chatItem.notificationRegDate,
                        chatId: chatItem.chatId,
                        seen: seen,
                        isYours: "FALSE",
                        onAdded: () {
                          if (Chats.staticChatsPage != null) {
                            Chats.staticChatsPage.refresh();
                          }

                          if (seen == "1") {
                            Chat.staticChatPage.myChild.addMessageToList(
                                msg: chatItem.notificationContent,
                                isYours: false,
                                date: chatItem.notificationRegDate,
                                senderName: chatItem.notificationFromName);
                          }
                        });
                  },
                  onResult: (res) {
                    print("::::::: CHAT FINDER: ${res.length} :::::::");
                  });
            },
            onNoResult: () {
              widget.db.insertConversation(
                  userId: chatItem.notificationFromId,
                  convId: convId,
                  createDate: chatItem.notificationRegDate,
                  fromName: chatItem.notificationFromName,
                  onInserted: () {
                    print(
                        ":::::::::::::::::: [new conversation added] ::::::::::::::::::");

                    widget.db.checkChatExistByUser(
                        chatId: chatItem.chatId,
                        onNoResult: () {
                          widget.db.insertChat(
                              convId: convId,
                              userId: chatItem.notificationFromId,
                              content: chatItem.notificationContent,
                              date: chatItem.notificationRegDate,
                              chatId: chatItem.chatId,
                              seen: seen,
                              isYours: "FALSE",
                              onAdded: () {
                                if (Chats.staticChatsPage != null) {
                                  Chats.staticChatsPage.refresh();
                                }

                                if (seen == "1") {
                                  Chat.staticChatPage.myChild.addMessageToList(
                                      msg: chatItem.notificationContent,
                                      isYours: false,
                                      date: chatItem.notificationRegDate,
                                      senderName:
                                          chatItem.notificationFromName);
                                }

                                Future.delayed(Duration(seconds: 2))
                                    .then((val) {
                                  print(
                                      ":::::::::::::::::: [GOING TO CHAT PAGE] ::::::::::::::::::");
                                  if (isOnMessage != true) {
                                    /* GOTO CHAT PAGE */
                                    setState(() {
                                      MiddleWare.shared.tabc.animateTo(2);
                                      Chats.staticChatsPage.myChild.openChat(
                                          convId: convId,
                                          uId: message['data']['fromId'],
                                          uName: message['data']['fromName'],
                                          withDuration: true);
                                    });
                                    /* GOTO CHAT PAGE */
                                  }
                                  print(
                                      ":::::::::::::::::: [GOING TO CHAT PAGE] ::::::::::::::::::");
                                });
                              });
                        },
                        onResult: (res) {
                          print("::::::: CHAT FINDER: ${res.length} :::::::");
                        });
                  },
                  onNoInerted: () {
                    print(
                        ":::::::::::::::::: [new conversation not added !] ::::::::::::::::::");
                  });
            });
        // chat notification
      } else {
        if (message['data']['notificationType'].toString() == "vote") {
          // vote notification

          if (isOnResume) {
            this.widget.mdw.shouldMoveToThisVoteId =
                message['data']['idx'].toString();
            setState(() {
              MiddleWare.shared.currentIndex = 3;
              MiddleWare.shared.tabc
                  .animateTo(3, duration: Duration(seconds: 0));
              Notices.staticNoticesPage.myChild.refreshNotices();
              print(":::::: notices should be refreshed ::::::");
            });
            if (Platform.isAndroid) {
              return;
            } //아이폰은 return 넣으면 다음으로 넘어가지 않아서 데이터 저장이 안됨. 안드로이드는 return 없으면 노티 누르면 해당 데이터가 저장되서 중복으로 저장이 됨
          }

          VoteObject voteItem = VoteObject.fromJson(message);
          widget.db.checkVoteExist(
              bd_idx: voteItem.idx.toString(),
              onNoResult: () {
                widget.db.insertVote(
                    voteItem: voteItem,
                    onAdded: () {
                      String url =
                          "${voteItem.httpPath.toString()}&userId=${this.widget.myUserId}&mode=view";
                      url = url.replaceAll("https://", "http://");
                      getVoteAnswers(
                          url: url,
                          onSent: (response) {
                            widget.db.insertAnswer(
                              onAdded: () {
                                if (Notices.staticNoticesPage != null) {
                                  Notices.staticNoticesPage.myChild
                                      .refreshNotices();
                                }
                              },
                              idx: voteItem.idx,
                              status: response['data']['status'].toString(),
                              answer1: response['data']['a1'].toString(),
                              answer2: response['data']['a2'].toString(),
                              answer3: response['data']['a3'].toString(),
                              answer4: response['data']['a4'].toString(),
                              answer5: response['data']['a5'].toString(),
                              answer6: response['data']['a6'].toString(),
                            );
                          });

                      if (Notices.staticNoticesPage != null) {
                        Notices.staticNoticesPage.myChild.refreshNotices();
                      }
                    });
              });
        } // Vote Notification
        else if (message['data']['notificationType'].toString().toLowerCase() ==
            "notice") {
          if (isOnResume) {
            //this.widget.mdw.shouldMoveToThisVoteId = message['data']['idx'].toString();
            setState(() {
              MiddleWare.shared.currentIndex = 3;
              MiddleWare.shared.tabc
                  .animateTo(3, duration: Duration(seconds: 0));
              Notices.staticNoticesPage.myChild.refreshNotices();
              print(":::::: notices should be refreshed ::::::");
            });
            if (Platform.isAndroid) {
              return;
            } //아이폰은 return 넣으면 다음으로 넘어가지 않아서 데이터 저장이 안됨. 안드로이드는 return 없으면 노티 누르면 해당 데이터가 저장되서 중복으로 저장이 됨
          }

          VoteObject noticeItem = VoteObject.fromJson(message);
          if (noticeItem.subject != null) {
            String noticeId = randomChatId();
            widget.db.insertNotice(
                fromId: noticeItem.fromId,
                fromName: noticeItem.fromName,
                subject: noticeItem.subject,
                noticeId: noticeId,
                content: noticeItem.content,
                onInserted: (status) {
                  if (status) {
                  } // on inserted
                  else {} // on no inserted
                });
          }
          if (Notices.staticNoticesPage != null) {
            Notices.staticNoticesPage.myChild.refreshNotices();
          }
        } // Notice Notification
        else if (message['data']['notificationType'].toString().toLowerCase() ==
            "qna") {
          if (isOnResume) {
            //this.widget.mdw.shouldMoveToThisVoteId = message['data']['idx'].toString();
            setState(() {
              MiddleWare.shared.currentIndex = 3;
              MiddleWare.shared.tabc
                  .animateTo(3, duration: Duration(seconds: 0));
              Notices.staticNoticesPage.myChild.refreshNotices();
              print(":::::: notices should be refreshed ::::::");
            });
            if (Platform.isAndroid) {
              return;
            } //아이폰은 return 넣으면 다음으로 넘어가지 않아서 데이터 저장이 안됨. 안드로이드는 return 없으면 노티 누르면 해당 데이터가 저장되서 중복으로 저장이 됨
          }

          if (message['data']['subject'] != null) {
            widget.db.insertQna(
                idx: message['data']['idx'],
                subject: message['data']['subject'],
                regDate: message['data']['regDate'],
                onInserted: (status) {
                  if (status) {
                  } // on inserted
                  else {} // on no inserted
                });
          }
          if (Notices.staticNoticesPage != null) {
            Notices.staticNoticesPage.myChild.refreshNotices();
          }
        } // Notice Notification
      }
    } // notificationType is NOT null
  }

  void getUserId({onGetUserId(String userId)}) async {
    await SharedPreferences.getInstance().then((val) {
      String uid = val.getString("app_user_login_info_userid");
      this.widget.myUserId = uid;
      onGetUserId(uid);
    });
  }

  static void staticGetUserId({onGetUserId(String userId)}) async {
    await SharedPreferences.getInstance().then((val) {
      String uid = val.getString("app_user_login_info_userid");
      onGetUserId(uid);
    });
  }

  void getVersion() async {
    var infomap = new Map<String, dynamic>();
    infomap["mode"] = userInformation.userDeviceOS;

    return http
        .post(Strings.shared.controllers.jsonURL.getVersion, body: infomap)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      //final String responseBody = response.body; //한글 깨짐
      final String responseBody = utf8.decode(response.bodyBytes);
      var responseJSON = json.decode(responseBody);
      var code = responseJSON["code"];
      var data = responseJSON['version'];

      if (statusCode == 200) {
        if (code == 200) {
          // If the call to the server was successful, parse the JSON
          //print(int.parse(data.replaceAll(".", "")));
          //print(int.parse(userInformation.appVersion.replaceAll(".", "")));
          if (int.parse(data.replaceAll(".", "")) >
              int.parse(userInformation.appVersion.replaceAll(".", ""))) {
            return showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => AlertDialog(
                      title: new Text("알림"),
                      content: new Text("새 버전이 있습니다. 다운로드 하시겠습니까?",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        new FlatButton(
                          child: new Text("취소",
                              style: TextStyle(
                                  fontSize:
                                      Statics.shared.fontSizes.supplementary,
                                  color: Colors.black)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text(
                            "확인",
                            style: TextStyle(
                                fontSize:
                                    Statics.shared.fontSizes.supplementary,
                                color: Colors.black),
                          ),
                          onPressed: () async {
                            var url = "";
                            if (Platform.isIOS == true) {
                              url =
                                  "http://apps.apple.com/kr/app/%ED%95%9C%EA%B5%AD%ED%95%B4%EA%B8%B0%EC%82%AC%ED%98%91%ED%9A%8C/id1485498659";
                            } else {
                              url =
                                  "https://play.google.com/store/apps/details?id=com.mariners.heagisa2&hl=ko";
                            }

                            var url2 = Uri.encodeFull(url).toString();
                            if (await canLaunch(url2)) {
                              await launch(url2);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                      ],
                    ));
          }
        } else {
          // If that call was not successful, throw an error.
          throw Exception('Failed to load post');
        }
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    });
  }

  @override
  void initState() {
    MainTabBar.myChild = this;
    MiddleWare.shared.tabc = TabController(
        length: MiddleWare.shared.myTabBarList.length, vsync: this);
    getUserId(onGetUserId: (uid) {
      getAllSurveys(uid: uid);
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      firebaseCloudMessaging_Listeners();
    });

    getVersion();
    //filedownloaderInitialize();
    print("Main TabBar New...");

    widget.subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result.index == 2) {
        // no internet connected
        showNoInternet(context);
      }
    });
    checkNewBadge();

    this.updateUserLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.subscription.cancel();
  }

  // void filedownloaderInitialize() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await FlutterDownloader.initialize();
  // }

  void updateUserLocation() async {
    print("...::: Checking Location Start :::...");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      print("...::: updating user location... :::...");
      geolocator.isLocationServiceEnabled().then((val) {
        if (val) {
          geolocator.checkGeolocationPermissionStatus().then((val) {
            if (val.value == 2) {
              geolocator
                  .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
                  .then((val) {
                this.widget.userLocation = val;
                if ((val.longitude >= 125.385888 &&
                        val.longitude <= 130.164875) &&
                    (val.latitude >= 34.076705 && val.latitude <= 38.991721)) {
                  print("...::: the user is inside of korea. :-) :::...");
                } else {
                  print("... ::: the user is not inside of korea! :-( :::...");
                  showLocationPopUp(_scaffoldKey.currentContext);
                }
              }).catchError((error) {
                print(
                    "...::: updating user location was failed => ${error.toString()} :::...");
                //showLocationPopUp(_scaffoldKey.currentContext);
              });
            } else {
              print(
                  "...::: updating user location was failed => (access to GPS failed) :::...");
              //showLocationPopUp(_scaffoldKey.currentContext);
            }
          });
        } else {
          print(
              "...::: updating user location was failed => (GPS Service was disabled) :::...");
          //showLocationPopUp(_scaffoldKey.currentContext);
        }
      });
    }
    print("...::: Checking Location End :::...");
  }

  void clickToChangeMenu(index) {
    setState(() {
      print(index);
      MiddleWare.shared.currentIndex = index;
      MiddleWare.shared.tabc.animateTo(index);
    });
  }

  void checkInternet(BuildContext ctx) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      showNoInternet(ctx);
    }
  }

  void showNoInternet(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return NoInternetAlertWidget(
            popUpWidth: MiddleWare.shared.screenWidth,
            onPressClose: () {
              Navigator.pop(context);
            },
          ).dialog();
        });
  }

  void showLocationPopUp(BuildContext ctx) {
    SharedPreferences.getInstance().then((val) {
      String strDate = val.getString("__LOCATION_POPUP_7_DAYS");
      if (strDate != null && strDate != "") {
        DateTime c1 = DateTime.parse(strDate);
        if (DateTime.now().difference(c1).inDays > 7) {
          showDialog(
              context: ctx,
              builder: (BuildContext context) {
                return LocationPopUpWidget(
                    popUpWidth: MiddleWare.shared.screenWidth - 32,
                    onPressClose: () {
                      Navigator.pop(context);
                    },
                    onPress7DaysNoSee: () {
                      SharedPreferences.getInstance().then((val) {
                        val.setString(
                            "__LOCATION_POPUP_7_DAYS", "${DateTime.now()}");
                      });
                    }).dialog();
              });
        }
      } else {
        showDialog(
            context: ctx,
            builder: (BuildContext context) {
              return LocationPopUpWidget(
                  popUpWidth: MiddleWare.shared.screenWidth - 32,
                  onPressClose: () {
                    Navigator.pop(context);
                  },
                  onPress7DaysNoSee: () {
                    SharedPreferences.getInstance().then((val) {
                      val.setString(
                          "__LOCATION_POPUP_7_DAYS", "${DateTime.now()}");
                      Navigator.pop(context);
                    });
                  }).dialog();
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        systemNavigationBarColor:
            Colors.black // Dark == white status bar -- for IOS.
        ));
    MainTabBarState.navBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: new Image.asset("Resources/Icons/btn_main.png", width: 50),
            activeIcon:
                new Image.asset("Resources/Icons/btn_main_ac.png", width: 50),
            title: Text("")),
        BottomNavigationBarItem(
            icon:
                new Image.asset("Resources/Icons/btn_finduser.png", width: 50),
            activeIcon: new Image.asset("Resources/Icons/btn_finduser_ac.png",
                width: 50),
            title: Text("")),
        BottomNavigationBarItem(
            icon: new Image.asset(btnChat, width: 50),
            activeIcon: new Image.asset(btnChatAc, width: 50),
            title: Text("")),
        BottomNavigationBarItem(
            icon: new Image.asset(btnNotice, width: 50),
            activeIcon: new Image.asset(btnNoticeAc, width: 50),
            title: Text("")),
        BottomNavigationBarItem(
            icon: new Image.asset("Resources/Icons/btn_mymenu.png", width: 50),
            activeIcon:
                new Image.asset("Resources/Icons/btn_mymenu_ac.png", width: 50),
            title: Text("")),
      ],
      backgroundColor: Colors.white,
      fixedColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: MiddleWare.shared.currentIndex,
      onTap: (index) {
        clickToChangeMenu(index);
      },
    );

    MiddleWare.shared.screenWidth = MediaQuery.of(context).size.width;
    checkInternet(context);

    return new WillPopScope(
        onWillPop: () async => _onBackPressed(),
        child: new Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body: TabBarView(
            children: MiddleWare.shared.myTabBarList,
            controller: MiddleWare.shared.tabc,
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: MainTabBarState.navBar,
        ));
  }

  Future<bool> onWillPop(BuildContext context) async {
    const snackBarDuration = Duration(seconds: 3);

    final snackBar = SnackBar(
      content: Text('Press back again to leave'),
      duration: snackBarDuration,
    );

    DateTime currentTime = DateTime.now();

    bool backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            currentTime.difference(backButtonPressTime) > snackBarDuration;

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = currentTime;
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    }

    return true;
  }

  Future<bool> _onBackPressed() {
    if (MiddleWare.shared.currentIndex != 0) {
      clickToChangeMenu(0);
    } else {
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => AlertDialog(
                title: new Text("앱 종료"),
                content: new Text("앱을 종료하시겠습니까?",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: Statics.shared.fontSizes.supplementary)),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("취소",
                        style: TextStyle(
                            fontSize: Statics.shared.fontSizes.supplementary,
                            color: Colors.black)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text(
                      "종료",
                      style: TextStyle(
                          fontSize: Statics.shared.fontSizes.supplementary,
                          color: Colors.red),
                    ),
                    onPressed: () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                  ),
                ],
              ));
    }
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }

  void checkNewBadge() {
    widget.db.chatBadge(onResult: (res) {
      if (res != "0") {
        setState(() {
          btnChat = "Resources/Icons/btn_chat_new.png";
          btnChatAc = "Resources/Icons/btn_chat_ac_new.png";
        });
      }
    });
    widget.db.noticeBadge(onResult: (res) {
      if (res != "0") {
        setState(() {
          btnNotice = "Resources/Icons/btn_notice_new.png";
          btnNoticeAc = "Resources/Icons/btn_notice_ac_new.png";
        });
      }
    });
    widget.db.qnaBadge(onResult: (res) {
      if (res != "0") {
        setState(() {
          btnNotice = "Resources/Icons/btn_notice_new.png";
          btnNoticeAc = "Resources/Icons/btn_notice_ac_new.png";
        });
      }
    });
  }
}
