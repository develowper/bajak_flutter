import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:games/main.dart';
import 'package:games/page/register_login_screen.dart';
import 'package:http/http.dart' as http;

import '../controller/APIProvider.dart';
import '../controller/SettingController.dart';
import '../helper/helpers.dart';
import '../helper/variables.dart';
import '../model/User.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:pushpole/pushpole.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helper/helpers.dart';
import '../page/shop.dart';
import 'APIProvider.dart';
import 'UserFilterController.dart';
import 'dart:html' as html;

class UserController extends GetxController
    with StateMixin<User>, GetTickerProviderStateMixin {
  late final box = GetStorage();
  var _ACCESS_TOKEN;

  late final Helper helper;
  late final SettingController settingController;

  late UserFilterController filterController;
  User user = User.nullUser();
  Map<String, dynamic> _userInfo = {};
  List<dynamic> userShops = [];
  Map<String, dynamic> userRef = {};

  Map<String, dynamic> get userInfo => _userInfo;

  set userInfo(Map<String, dynamic> value) {
    _userInfo = value;
  }

  get ACCESS_TOKEN => _ACCESS_TOKEN.val;

  set ACCESS_TOKEN(value) {
    _ACCESS_TOKEN.val = value;
  }

  late final ApiProvider apiProvider;
  ScrollPhysics parentScrollPhysics = BouncingScrollPhysics();

  ScrollPhysics childScrollPhysics = NeverScrollableScrollPhysics();

  ScrollController parentScrollController = ScrollController();
  ScrollController childScrollController = ScrollController();

  late TabController tabControllerProfile;
  final profileTabs = [
    Tab(text: 'user_info'.tr),
    Tab(text: 'user_lawyer_info'.tr),
  ];

  late TabController tabControllerShop;

  UserController() {
    _ACCESS_TOKEN = ReadWriteValue('ACCESS_TOKEN', '', () => box);

    // _ACCESS_TOKEN.val = '';
    apiProvider = Get.find<ApiProvider>();
    helper = Get.find<Helper>();
    settingController = Get.find<SettingController>();
    filterController = Get.put(UserFilterController(this));

    tabControllerShop = TabController(length: 2, vsync: this, initialIndex: 0);
    tabControllerProfile =
        TabController(length: 2, vsync: this, initialIndex: 0);
    tabControllerProfile.addListener(() {
      parentScrollController.animateTo(0,
          duration: Duration(milliseconds: 700), curve: Curves.ease);
      update();
    });
  }

// final username = ''.val('username');
// final age = 0.val('age');
// final price = 1000.val('price', getBox: _otherBox);

// or

  @override
  void onInit() async {
    // ACCESS_TOKEN = '';
    // await getUser(refresh: true);

    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateAge() {
    // final age = 0.val('age');
    // or
    final age = ReadWriteValue('age', 0 /*, () => box*/);

    age.val = 1; // will save to box
    final realAge = age.val; // will read from box
  }

  Future<dynamic> preAuth({
    required String phone,
  }) async {
    return await apiProvider.fetch(Variable.LINK_PRE_AUTH,
        param: {
          'phone': phone,
        },
        method: 'post',
        tryReminded: ApiProvider.maxRetry);
  }

  Future<dynamic> login({
    // required String phone,
    required String username,
    required String password,
    required String passwordVerify,
  }) async {
    await Helper.getPackageInfo();
    final parsedJson = await apiProvider
        .fetch(Variable.LINK_USER_LOGIN, method: 'post', param: {
      // 'phone': phone,
      'username': username,
      'password': password,
      'password_verification': passwordVerify,
      'push_id': await helper.getPushId(),
      'app_version':
          "${Helper.packageInfo?.version}|${Helper.packageInfo?.buildNumber}"
    });
    // print(parsedJson);
    if (parsedJson == null) {
      User u = User.nullUser();
      change(GetStatus.empty());
      return null;
    } else if (parsedJson['token'] == null) {
      User u = User.nullUser();
      // change(null, status: RxStatus.error('verify_error'.tr));
      helper.showToast(
          msg: parsedJson['error'] ?? 'verify_error'.tr, status: 'danger');
      return parsedJson;
    } else {
      // user = User.fromJson(parsedJson);
      ACCESS_TOKEN = parsedJson['token'];
      Helper.localStorage(key: 'USER', write: jsonEncode(parsedJson));
      Helper.localStorage(key: 'ACCESS_TOKEN', write: parsedJson['token']);
      helper.showToast(
          msg: parsedJson['message'] ?? 'welcome'.tr, status: 'success');
      user = await getUser(refresh: true);
      change(GetStatus.success(user));
      return user;
    }
  }

  Future<dynamic> register({
    required String phone,
    // required String code,
    // required String email,
    // required String fullname,
    required String username,
    required String password,
    required String passwordVerify,
    // required String inviter,
  }) async {
    await Helper.getPackageInfo();
    var params = {
      'app_version':
          "${Helper.packageInfo?.version}|${Helper.packageInfo?.buildNumber}",
      'phone': phone,
      // 'phone_verify': code,
      // 'fullname': fullname,
      'username': username,
      // 'email': email,
      'password': password,
      'password_confirmation': passwordVerify,
      // 'marketer_code': inviter,
      'push_id': await helper.getPushId(),
      'market': Variable.MARKET,
    };

    final parsedJson = await apiProvider.fetch(Variable.LINK_USER_REGISTER,
        param: params, method: 'post');
    // print(parsedJson);

    if (parsedJson == null) {
      User u = User.nullUser();
      change(GetStatus.empty());

      return null;
    } else if (parsedJson['error'] != null) {
      helper.showToast(
          msg: parsedJson['error'] ?? 'check_network'.tr, status: 'danger');
      return {'status': 'error'};
    } else if (parsedJson['token'] == null) {
      User u = User.nullUser();
      // change(null, status: RxStatus.error('verify_error'.tr));
      helper.showToast(msg: 'verify_error'.tr, status: 'danger');
      return parsedJson;
    } else {
      user = User.fromJson(parsedJson);
      ACCESS_TOKEN = parsedJson['token'];
      Helper.localStorage(key: 'USER', write: jsonEncode(parsedJson));
      // await getUser();
      helper.showToast(
          msg: parsedJson['message'] ?? 'welcome'.tr, status: 'success');
      setSuccess(user);
      settingController.getData();
      return user;
    }
  }

  Future<User> getUser({refresh = false}) async {
    if (user != null && !refresh) {
      change(GetStatus.success(user!));
      await filterController.initFilters();
      return user;
    }
    var u = '';
    if (refresh) {
      Helper.localStorage(key: 'USER', write: '');
    } else {
      u = Helper.localStorage(key: 'USER', def: '');
    }

    if (u != '') {
      user = User.fromJson(jsonDecode(u));
      await filterController.initFilters();
      change(GetStatus.success(user!));
      return user;
    }
    final parsedJson = await apiProvider.fetch(Variable.LINK_GET_USER_INFO,
        ACCESS_TOKEN: ACCESS_TOKEN, method: 'get', param: {});
    // print(parsedJson);
    if (parsedJson == null) {
      //internet error
      change(GetStatus.empty());
      return User.nullUser();
    } else if (parsedJson['status'] == null ||
        parsedJson['status'] != 'success') {
      // print(parsedJson);
      helper.showToast(
          msg: parsedJson['error'] ?? 'token_error'.tr, status: 'danger');
      change(GetStatus.error('token_error'.tr));
      return User.nullUser();
    } else {
      if (parsedJson['financial'] != null) {
        parsedJson['user']['financial'] = parsedJson['financial'];
      }
      user = User.fromJson(parsedJson['user']);

      await filterController.initFilters();
      change(GetStatus.success(user!));
      settingController.getData();
      return user;
    }
  }

  Future edit({required Map<String, dynamic> params, String? type}) async {
    params['type'] = type;
    final parsedJson = (await apiProvider.fetch(Variable.LINK_UPDATE_PROFILE,
            param: params, ACCESS_TOKEN: ACCESS_TOKEN, method: 'post')) ??
        {'status': 'error', 'error': 'check_network'.tr};
    if (parsedJson['error'] != null) {
      helper.showToast(msg: parsedJson['error'], status: 'danger');
      return {'status': 'error'};
    }
    if (parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'danger');
      return {'status': 'danger'};
    }
    return parsedJson;
  }

  void logout() async {
    ACCESS_TOKEN = '';
    user = User.nullUser();
    // Get.offAll(() =>  GetMaterialApp());
    await getUser(refresh: true);
  }

  bool hasPlan({bool goShop = false, bool message = false}) {
    DateTime? dt =
        user?.expiresAt != null ? DateTime.tryParse(user!.expiresAt!) : null;

    bool res = ACCESS_TOKEN == '' ||
        dt == null ||
        ((dt.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch) <=
            0);

    if (res) {
      if (goShop) Get.to(() => ShopPage());
      if (message) {
        helper.showToast(msg: 'please_buy_plan'.tr, status: 'danger');
      }
    }

    return !res;
  }

  recoverPassword({String? phone}) async {
    var parsedJson = (await apiProvider.fetch(
            Variable.LINK_USER_FORGET_PASSWORD,
            param: {'phone': phone},
            method: 'post')) ??
        {};
    if (parsedJson['error'] != null) {
      helper.showToast(
          msg: (parsedJson['error'] is String)
              ? parsedJson['error']
              : parsedJson['error']?[parsedJson['error'].keys.elementAt(0)]?[0],
          status: 'danger');
    }
    if (await canLaunchUrlString(parsedJson['url'])) {
      launchUrlString(parsedJson['url']);
    }
    return parsedJson;
  }

// Future<bool> sendActivationCode({required String phone}) async {
//   return await settingController.sendActivationCode(phone: phone);
// }

  List categories() {
    return settingController.categories.toList();
  }

  String category(String? category_id) {
    var t = categories()
        .firstWhereOrNull((element) => element['id'] == category_id);
    return t == null ? '' : t['title'];
  }

  Future<bool> getTelegramConnectLink() async {
    final res = await apiProvider.fetch(Variable.LINK_TELEGRAM_CONNECT,
        method: 'post', ACCESS_TOKEN: ACCESS_TOKEN);

    if (res == null || res['status'] != null && res['status'] != 'success') {
      return false;
    }
    if (res['status'] != null &&
        res['status'] == 'success' &&
        res['url'] != null) {
      if (await canLaunchUrlString(res['url'])) {
        launchUrlString(res['url'], mode: LaunchMode.externalApplication);
      }
    }

    return true;
  }

  Future buy(Map<String, String> params) async {
    final parsedJson = await apiProvider.fetch(Variable.LINK_BUY,
        param: params, ACCESS_TOKEN: ACCESS_TOKEN, method: 'post');
    return parsedJson;
  }

  void refreshUserInfo({params}) {
    if (params['user_balance'] != null) {
      user.financial.balance = params['user_balance'];
    }
    // update();
    // change(GetStatus.empty());
    change(GetStatus.success(user));
  }

  void updateBalance(balance, {bool reset = false}) async {
    if (balance == null || balance == 0) {
      user.financial.balance += 0;
    } else {
      user.financial.balance += balance as int;
    }
    print("updateBalance ${balance} to ${user.financial.balance}");
    // change(GetStatus.empty());
    update();
    if (reset) {
      await getUser(refresh: true);
    }
  }

  getPayUrl({required String amount}) async {
    final parsedJson = await apiProvider.fetch(Variable.LINK_MAKE_TRANSACTION,
        param: {
          'amount': amount,
          'type': 'charge',
          'from_type': 'user',
          'app_version': "${Helper.packageInfo?.buildNumber}"
        },
        ACCESS_TOKEN: ACCESS_TOKEN,
        method: 'post');
    if (parsedJson == null ||
        parsedJson['status'] == null ||
        parsedJson['status'] != 'success') {
      // print(parsedJson);
      helper.showToast(msg: parsedJson?['error'] ?? ''.tr, status: 'danger');
    } else if (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // On iOS Safari, use html directly for better compatibility
      html.window.open(parsedJson['url'], '_blank');
    } else if (parsedJson['url'] != null &&
        await canLaunchUrlString(parsedJson['url'])) {
      launchUrlString(parsedJson['url']);
    }
    return parsedJson;
  }

  cardTocard({
    required String amount,
    required String card,
  }) async {
    final parsedJson = await apiProvider.fetch(Variable.LINK_MAKE_TRANSACTION,
        param: {
          'amount': amount,
          'card': card,
          'to_card': settingController.cardToCard['card'],
          'type': 'cardtocard',
          'from_type': 'user',
          'app_version': "${Helper.packageInfo?.buildNumber}"
        },
        ACCESS_TOKEN: ACCESS_TOKEN,
        method: 'post');
    var status = parsedJson?['status'] ?? 'danger';
    if (parsedJson == null ||
        parsedJson['status'] == null ||
        parsedJson['status'] != 'success') {
      // print(parsedJson);
      helper.showToast(msg: parsedJson?['error'] ?? ''.tr, status: 'danger');
    } else if (parsedJson['message'] != null) {
      helper.showToast(
          msg: parsedJson['message'] ?? 'request_error'.tr,
          status: parsedJson['status']);
    }
    return {'status': status};
  }

  Future winWheel() async {
    final parsedJson = await apiProvider.fetch(Variable.LINK_MAKE_TRANSACTION,
        param: {
          'type': 'winwheel',
          'app_version': "${Helper.packageInfo?.buildNumber}"
        },
        ACCESS_TOKEN: ACCESS_TOKEN,
        method: 'post');
    if (parsedJson == null || parsedJson['error'] != null) {
      // print(parsedJson);
      helper.showToast(
          msg: parsedJson?['error'] ?? 'request_error'.tr, status: 'danger');
    }

    return parsedJson;
  }

  Future withdraw({required String amount}) async {
    final parsedJson = await apiProvider.fetch(Variable.LINK_MAKE_TRANSACTION,
        param: {
          'amount': amount,
          'type': 'withdraw',
          'app_version': "${Helper.packageInfo?.buildNumber}"
        },
        ACCESS_TOKEN: ACCESS_TOKEN,
        method: 'post');
    if (parsedJson == null || parsedJson['error'] != null) {
      // print(parsedJson);
      helper.showToast(
          msg: parsedJson?['error'] ?? 'request_error'.tr, status: 'danger');
    } else if (parsedJson['message'] != null) {
      helper.showToast(
          msg: parsedJson['message'], status: parsedJson['status']);
    }

    return parsedJson ?? {'status': 'danger', 'message': 'request_error'.tr};
  }
}
