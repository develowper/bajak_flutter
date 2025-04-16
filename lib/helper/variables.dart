import 'dart:ui';

import 'package:flutter/services.dart';

class Variable {
  // static String DOMAIN = "http://172.16.6.2:11835";
  static String DOMAIN = "http://127.0.0.1:3298";

  // static String DOMAIN = "https://daberna.soheilmarket.ir";

  static String LINK_STORAGE = "${DOMAIN}/storage";
  static String LINK_STORAGE_USERS = "${DOMAIN}/storage/users";
  static String LINK_STORAGE_ROOMS = "${DOMAIN}";
  static String LINK_POLICY = "${DOMAIN}/policy";

  static String APIDOMAIN = "${DOMAIN}/api";

  static String LINK_GET_USER_INFO = "${APIDOMAIN}/user/info";
  static String LINK_PRE_AUTH = "${APIDOMAIN}/user/preAuth";
  static String LINK_USER_FORGET_PASSWORD = "${APIDOMAIN}/user/forget";
  static String LINK_USER_LOGIN = "${APIDOMAIN}/user/login";
  static String LINK_USER_REGISTER = "${APIDOMAIN}/user/register";
  static String LINK_GET_SETTINGS = "${APIDOMAIN}/settings";
  static String LINK_UPDATE_AVATAR = "${APIDOMAIN}/user/updateavatar";
  static String LINK_UPDATE_EMAIL = "${APIDOMAIN}/user/updateemail";
  static String LINK_UPDATE_PROFILE = "${APIDOMAIN}/user/update";
  static String LINK_UPDATE_PASSWORD = "${APIDOMAIN}/user/changepassword";

  static String LINK_TELEGRAM_CONNECT = "${APIDOMAIN}/user/telegram/connect";
  static String LINK_GET_TICKETS = "${APIDOMAIN}/ticket/search";
  static String LINK_UPDATE_TICKET = "${APIDOMAIN}/ticket/update";
  static String LINK_CREATE_TICKET = "${APIDOMAIN}/ticket/create";
  static String LINK_CREATE_TICKET_CHAT = "${APIDOMAIN}/ticket/chat/create";

  static String LINK_GET_ROOMS = "${APIDOMAIN}/room/get";
  static String LINK_JOIN_ROOM = "${APIDOMAIN}/room/join";

  static String LINK_FIND_DOOZ = "${APIDOMAIN}/dooz/find";
  static String LINK_PLAY_DOOZ = "${APIDOMAIN}/dooz/play";

  static String LINK_FIND_BLACKJACK = "${APIDOMAIN}/blackjack/find";
  static String LINK_PLAY_BLACKJACK = "${APIDOMAIN}/blackjack/play";

  static String LINK_BUY = "${APIDOMAIN}/payment/buy";
  static String LINK_GET_TRANSACTIONS = "${APIDOMAIN}/transaction/search";
  static String LINK_MAKE_TRANSACTION = "${APIDOMAIN}/transaction/create";

  static String LINK_GET_ADV = "${APIDOMAIN}/adv/get";
  static String LINK_ADV_CLICK = "${APIDOMAIN}/adv/click";

  static String LINK_SEND_LOG = "${APIDOMAIN}/send-log";

//  static Map<String, dynamic> params3 = {'page': '1', 'group_id': '3'};
//  static Map<String, dynamic> params4 = {'page': '1', 'group_id': '4'};

  static Locale LOCALE =
      LANG != 'fa' ? Locale('en', 'US') : Locale('fa', 'IR'); //bazaar
  static String MARKET = ''; //bazaar,myket,bank
  static String BOT_ID = 'dbrna_bot';
  static String APP_ID = '1';
  static String LANG = 'fa';
  static String PHONE = "";
  static String SERVICE_NAME = 'dabernaBajak';
  static String FOLDER_NAME = 'Daberna_Bajak';
  static String APP_NAME = 'daberna_bajak';

  // static String APP_LABEL = 'Esteghlal';

  static String PACKAGE = 'com.bajak.daberna';

  static String SERVICE_DEVELOPER = MARKET == 'bazaar'
      ? ''
      : MARKET == 'myket'
          ? ''
          : '';

  static String APP_ADDRESS = MARKET == 'bazaar'
      ? "https://cafebazaar.ir/app/$PACKAGE"
      : MARKET == 'myket'
          ? "https://myket.ir/app/$PACKAGE"
          : "https://play.google.com/store/apps/details?id=$PACKAGE&hl=${Variable.LANG}";
  static String APP_LABEL = LANG == 'fa' ? 'دبرنا' : 'Daberna';

  static List<String> KEYWORDS = [
    'دبرنا',
    'بازی',
    'bingo',
    'tambola',
    'dooz',
    'twelve mens morris',
    '12 mens morris',
    'nine mens morris',
    '9 mens morris',
  ];

// static String SERVICE_DEVELOPER =
//     'https://cafebazaar.ir/developer/mojtaba-rajabi';
//
// static String APP_ADDRESS = "https://cafebazaar.ir/app/$PACKAGE";
//   static String APP_ADDRESS = "https://myket.ir/app/$PACKAGE";
//   static String SERVICE_DEVELOPER = 'https://myket.ir/developer/$PACKAGE';
}

enum Commands { RefreshWallpapers }
