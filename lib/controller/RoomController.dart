import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/helpers.dart';
import '../helper/variables.dart';
import '../model/Daberna.dart';
import '../model/Room.dart';
import '../page/daberna_game.dart';
import 'APIProvider.dart';
import 'SettingController.dart';
import 'UserController.dart';

class RoomController extends GetxController with StateMixin<List<Room>> {
  List<Room> _data = [];
  bool loading = false;

  int get currentLength => _data.length;

  List<Room> get data => _data;

  set data(List<Room> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late final UserController userController;
  late final Helper helper;

  RoomController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  Future<List<Room>?> getData({
    Map<String, dynamic>? param,
  }) async {
    loading = true;
    update();
    if (param != null && param['page'] == 'clear') {
      _data.clear();
      change(GetStatus.loading());
    }

    Map<String, dynamic> params = param ?? {};
    // print(params);
    final parsedJson = await apiProvider.fetch(Variable.LINK_GET_ROOMS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson == null ||
        parsedJson['data'] == null ||
        parsedJson['data'].length == 0) {
      loading = false;
      change(GetStatus.empty());

      return [];
    } else {
      _data = parsedJson["data"].map<Room>((el) => Room.fromJson(el)).toList();
      loading = false;
      change(GetStatus.success(_data));

      return _data;
    }
  }

  Future<List<Room>?> find({
    Map<String, dynamic>? param,
  }) async {
    Map<String, dynamic> params = param ?? {};
    // print(params);
    final parsedJson = await apiProvider.fetch(Variable.LINK_GET_ROOMS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson == null ||
        parsedJson['data'] == null ||
        parsedJson['data'].length == 0) {
      return [];
    } else {
      _data = parsedJson["data"].map<Room>((el) => Room.fromJson(el)).toList();

      return _data;
    }
  }

  Future payAndJoinRoom(
      {required String roomType, required int cardCount}) async {
    final parsedJson = await apiProvider.fetch(Variable.LINK_JOIN_ROOM,
        method: 'post',
        param: {'card_count': cardCount, 'room_type': roomType},
        ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson?['error'] != null) {
      helper.showToast(msg: parsedJson?['error'], status: 'danger');
      return parsedJson;
    } else if (parsedJson == null ||
        parsedJson['data'] == null ||
        parsedJson['data'].length == 0) {
      loading = false;

      return parsedJson;
    } else {
      loading = false;

      return parsedJson;
    }
  }

  void startGame({required Daberna daberna}) {
    // Get.back();
    // Get.to(() => DabernaGame(daberna: daberna));
    Get.offNamed('/DabernaGame', arguments: daberna);
  }
}
