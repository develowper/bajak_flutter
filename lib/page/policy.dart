import 'package:games/widget/AppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/SettingController.dart';
import '../helper/styles.dart';

class PolicyPage extends StatelessWidget {
  PolicyPage({super.key}) {}

  SettingController setting = Get.find<SettingController>();
  Style style = Get.find<Style>();

  @override
  Widget build(BuildContext context) {
    if (!setting.appLoaded()) {
      Get.offNamed('/');
      return Center();
    }
    return Scaffold(
      body: MyAppBar(
          child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(style.cardMargin),
          margin: EdgeInsets.all(style.cardMargin),
          decoration: BoxDecoration(
              color: style.secondaryColor,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(style.cardMargin),
                  bottom: Radius.circular(style.cardMargin))),
          child: Text(
            setting.policy,
            style: style.textMediumStyle,
          ),
        ),
      )),
    );
  }
}
