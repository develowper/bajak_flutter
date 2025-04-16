import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/SettingController.dart';
import '../helper/styles.dart';

class DrawerMenu extends StatelessWidget {
  late final VoidCallback onTap;
  Style style = Get.find<Style>();
  late ButtonStyle buttonStyle;
  SettingController settingController = Get.find<SettingController>();

  DrawerMenu({super.key, required this.onTap}) {
    buttonStyle = ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(style.cardMargin / 2)),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) {
            return states.contains(WidgetState.pressed)
                ? style.secondaryColor
                : null;
          },
        ),
        backgroundColor:
            WidgetStatePropertyAll(style.secondaryColor.withOpacity(.2)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          side: BorderSide(color: style.secondaryColor),
          borderRadius: BorderRadius.all(
            Radius.circular(style.cardBorderRadius / 2),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(),
        child: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(style.cardMargin),
                  child: ClipRRect(
                    child: Image.asset('assets/images/icon.png'),
                    borderRadius: BorderRadius.circular(style.cardBorderRadius),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  child: Padding(
                    padding: EdgeInsets.all(style.cardMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (false)
                          TextButton.icon(
                            style: buttonStyle,
                            onPressed: () async {
                              settingController.goTo('site');
                            },
                            label: Text(
                              'site'.tr,
                              style: style.textBigStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            icon: Icon(Icons.link, color: Colors.white),
                          ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {
                            settingController.goTo('contact_us');
                          },
                          label: Text(
                            'contact_us'.tr,
                            style: style.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.headset_mic_rounded,
                              color: Colors.white),
                        ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {
                            settingController.goTo('your_comments');
                          },
                          label: Text(
                            'your_comments'.tr,
                            style: style.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.star_border, color: Colors.white),
                        ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {
                            settingController.goTo('update');
                          },
                          label: Text(
                            'update'.tr,
                            style: style.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.download_outlined,
                              color: Colors.white),
                        ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {
                            SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
                          },
                          label: Text(
                            'exit'.tr,
                            style: style.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.exit_to_app, color: Colors.white),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: style.cardMargin),
                          child: Text(
                            "${'label'.tr} (${'version'.tr} ${settingController.appInfo?.versionName})",
                            textAlign: TextAlign.center,
                            style: style.textSmallLightStyle.copyWith(
                                color: Colors.white.withOpacity(.5),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
