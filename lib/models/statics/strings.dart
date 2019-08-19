class Strings {
  static Strings shared = Strings();
  _Strings() {}

  _StringsControllers controllers = _StringsControllers();
  _StringsDialogs dialogs = _StringsDialogs();
}

class _StringsDialogs {
  String vote = "투표";
  String votingPeriod = "투표기간";
  String bottomLableVoteDialog = "비밀투표를 원칙으로 진행됩니다.";
  String closeBtnTitle = "닫기";
  String applyVoteBtn = "투표하기";

  String toVoteKeyword = "투표에";
  String pleaseJoinUsThankYouKeyword = "참여해주셔서 감사합니다";
  String descriptionUnderCompleteDialog = "결과는 투표종료 후 협회에서 알려드릴 예정입니다.";

  String survey = "설문조사";
  String surveyingPeriod = "설문기간";
  String submitBtnTitle = "제출하기";

  String wouldYouLikeToBlockPart1Red = "차단";
  String wouldYouLikeToBlockPart2 = "하시겠어요?";
  String blockPopUpCaption = "차단하시면 다시 대화를 하실 수 없어요";
  String btnBlockTitle = "차단";
}

class _StringsControllers {
  _StringsControllerHome home = _StringsControllerHome();
  _StringsControllerFindUser findUser = _StringsControllerFindUser();
  _StringsControllerChats chats = _StringsControllerChats();
  _StringsControllerChat chat = _StringsControllerChat();
  _StringsControllerNotices notices = _StringsControllerNotices();
  _StringsControllerProfile profile = _StringsControllerProfile();
  _StringsSignInController signIn = _StringsSignInController();
  _StringSignSelectController signSelect = _StringSignSelectController();
  _StringTermController term = _StringTermController();
  _StringJsonURL jsonURL = _StringJsonURL();
}

// HOME Controller //
class _StringsControllerHome {}
// HOME Controller //

// FIND USER Controller //
class _StringsControllerFindUser {}
// FIND USER Controller //

// CHATS Controller //
class _StringsControllerChats {
  String pageTitle = "채팅";
}
// CHATS Controller //

// Single Chat Controller //
class _StringsControllerChat {
  String hintChatTextField = "메시지를 입력하세요"; // please enter your message
  String conversationPermission = "대화허락";
  String conversationBlock = "대화차단";
  String errorWhileSendingChatMessage = "메시지가 전송되지 않았습니다!"; // Message Not Sent
}
// Single Chat Controller //

// NOTICES Controller //
class _StringsControllerNotices {
  String pageTitle = "푸시알림";
  String noPushNotificationYet = "푸시알림이 아직 없습니다";
  _StringsControllerNoticesSnackBar snackBar =
      _StringsControllerNoticesSnackBar();
}

class _StringsControllerNoticesSnackBar {
  String votingPeriodIsOver = "투표기간이 종료되었습니다.";
}
// NOTICES Controller //

// PROFILE Controller //
class _StringsControllerProfile {
  String appTitle = " 내 메뉴";
  String memberType1 = "님은 정회원 입니다";
  String memberType2 = "님은 준회원 입니다";
  String feehistory = "회비납부 내역";
  String inquiry = "1:1문의";
  String occasion = "경조사 통보";
  String advisory = "해기 자문센터";
  String terms = "이용약관";
  String alarm = "알림 수신동의";
  String infoModify = "내 정보 수정";
  String appVersion = "앱 버전";

  //정보수정
  String userinfoTitle = "내 정보 수정";
  String userName = "이름";
  String userType = "자격";
  String userPhone = "전화번호";
  String userMail = "이메일";
  String userSchool = "출신학교";
  String userGisu = "기수";
  String save = "저장";
  String modify = "수정";
}
// PROFILE Controller //

// SIGN IN Controller //
class _StringsSignInController {
  String title1 = "내 손안의";
  String title2 = "한국해기사협회";
  String subTitle = "홈페이지 가입시 사용한 계정으로 로그인 할 수 있습니다.";
  String txtHintUser = "아이디";
  String txtHintPass = "비밀번호";
  String txtHintPass2 = "비밀번호 확인";
  String forgetPasswordTitle = "비밀번호 찾기";
  String findIDTitle = "아이디 찾기";
  String loginBtnTitle = "로그인";
  String enterID = "아이디를 입력하세요.";
  String enterPass = "비밀번호를 입력하세요.";
  String wrongID = "아이디를 확인하세요.";
  String wrongPass = "비밀번호가 불일치합니다. 다시 입력해주세요.";
  String findID1 = "회원님의 아이디는";
  String findID2 = "입니다.";
  String findID3 = "아이디는 6자리 이상 입력해주세요.";
  String findPass = "비밀번호가 다릅니다.";
  String findPass2 = "비밀번호는 영문,숫자,특수문자 조합 6~16자리 입니다.";
  String error = "사용할수 없는 계정입니다. 관리자에게 연락해주세요.";
  String error2 = "이미 사용중인 계정입니다.";
  String change = "변경하기";
  String submit = "가입하기";
  String already = "가입된 정보가 있습니다.";
  String nomember = "가입된 아이디가 없습니다.";
  String joinTitle = "회원가입";
  String joinContent = "지금 회원가입하고\n협회소식을 손쉽게 받아보세요.";
}
// SIGN IN Controller //

// SIGN SELECT Controller //
class _StringSignSelectController {
  String title1 = "기존 홈페이지\n회원이신가요?";
  String title2 = "신규회원이신가요?";
  String title3 = "본 서비스는";
  String title3_1 = "한국해기사협회 정,준회원만\n사용가능한 서비스입니다.";
  String title3_2 = "사용가능한 서비스입니다.";
  String title4 = "본인인증";
  String title5 = "고객님의 본인확인을 위하여\n본인인증이 필요합니다.";
  String button1 = "로그인하기 ";
  String button2 = "회원가입하기 ";
  String confirm = "확인";
}
// SIGN SELECT Controller //

// JSON URL //
class _StringJsonURL {
  String authJson = "http://www.mariners.or.kr/member/mobile_join.php";
  String loginJson =
      "http://www.mariners.or.kr/app_middle/member/login_json.php";
  String logininfoJson =
      "http://www.mariners.or.kr/app_middle/member/login_info_json.php";
  String findPW =
      "http://www.mariners.or.kr/app_middle/member/find_pw_json.php";
  String joinJson = "http://www.mariners.or.kr/app_middle/member/join_json.php";
  String userinfoJson =
      "http://www.mariners.or.kr/app_middle/member/user_info_json.php";
  String terms =
      "https://www.mariners.or.kr/app_middle/terms/service_term.html";
  String privacy =
      "https://www.mariners.or.kr/app_middle/terms/privacy_term.html";
  String homeJson = "http://www.mariners.or.kr/app_middle/etc/main_json.php";
  String button2 = "회원가입하기 ";
}
// JSON URL //

class _StringTermController {
  //terms and policy
  String terms_title = '약관 동의';
  String terms_title_detial = '본 서비스는 한국해기사협회\n정,준회원만 사용가능한 서비스입니다.';
  String terms_terms_title = '서비스 이용 약관 동의';
  String terms_policy_title = '개인정보 수집 및 이용 동의';
  String terms_policy_need = '(필수)';
  String terms_notification_title = '마케팅 정보 앱 푸시알림 수신';
  String terms_accept_all_title = '모두 확인 및 동의합니다.';
  String terms_accept_no = '필수 약관은 모두 동의 해야 서비스가 시작됩니다.';
  String terms_view = '보기';
  String terms_next = '다음';
  String terms_get_started = '시작하기';
  String terms_privacy_statement = '개인정보취급방침';
  String terms_term_detail_tile = '이용약관';
}
