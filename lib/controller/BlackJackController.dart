import '../helper/helpers.dart';
import '../helper/variables.dart';
import 'APIController.dart';
import 'package:get/get.dart';

import 'APIProvider.dart';
import 'SettingController.dart';
import 'UserController.dart';

class BlackJackController extends GetxController with StateMixin<dynamic> {
  late final ApiProvider apiProvider;
  late final SettingController settingController;
  late final UserController userController;
  late final Helper helper;

  var data;

  BlackJackController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  Future<Map<String, dynamic>?> find(
      {Map<String, dynamic> params = const {}}) async {
    change(GetStatus.loading());

    final parsedJson = await apiProvider.fetch(
      Variable.LINK_FIND_BLACKJACK,
      param: params,
      method: 'get',
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
    );
    // print(parsedJson);
    if (parsedJson == null) {
      // change(GetStatus.empty());
      return parsedJson;
    } else if (parsedJson['error'] != null) {
      // change(GetStatus.empty());
      return {'message': parsedJson['error'], 'status': 'danger'};
    } else {
      data = parsedJson;
      // change(GetStatus.success(data));
      return data;
    }
  }

  Future<Map<String, dynamic>?> play(
      {Map<String, dynamic> params = const {}}) async {
    final parsedJson = await apiProvider.fetch(
      Variable.LINK_PLAY_BLACKJACK,
      param: params,
      method: 'post',
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
    );
    // print(parsedJson);
    if (parsedJson == null || parsedJson['error'] != null) {
      return null;
    } else {
      data = parsedJson;
      return data;
    }
  }
}
