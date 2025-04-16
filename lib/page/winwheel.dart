import 'package:games/controller/SettingController.dart';
import 'package:games/controller/UserController.dart';
import 'package:games/widget/AppBar.dart';
import 'package:games/widget/MyButton.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/WinWheel.dart';
import '../widget/loader.dart';

class WinWheelPage extends StatelessWidget {
  WinWheelPage({super.key}) {
    if (!setting.appLoaded()) Get.offNamed('/');
  }

  final WinwheelController _winwheelController = WinwheelController();
  final SettingController setting = Get.find<SettingController>();
  final UserController userController = Get.find<UserController>();
  RxBool loading = RxBool(false);
  Map? winWheelRes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyAppBar(
          child: Column(
        children: [
          SizedBox(height: 20),
          WinWheel(
            labels: setting.winwheel['labels'],
            controller: _winwheelController,
            onCompleted: () {
              if (winWheelRes == null) return;
              if (winWheelRes?['prize'] != null) {
                userController
                    .updateBalance(int.tryParse("${winWheelRes?['prize']}"));
              }
              if (winWheelRes?['message'] != null) {
                userController.helper.showToast(
                    msg: winWheelRes?['message'],
                    status: winWheelRes?['status']);
              }
            },
          ),
          SizedBox(height: 20),
          MyButton(
            onPressed: () async {
              loading.value = true;
              winWheelRes = await userController.winWheel();

              loading.value = false;
              if (winWheelRes?['index'] != null) {
                _winwheelController.spinToSelectedIndex(winWheelRes?['index']);
              }
            },
            label: 'rotate_winwheel'.tr,
          ),
        ],
      )),
    );
  }
}
