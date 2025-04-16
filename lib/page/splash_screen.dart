
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:games/widget/loader.dart';
import 'package:get/get.dart';

import '../controller/UserController.dart';
import '../helper/styles.dart';
import '../widget/MyButton.dart';

class SplashScreen extends StatelessWidget {
  final bool isLoading;
  late final Style style;
  late final UserController userController;

  SplashScreen({Key? key, this.isLoading = false}) : super(key: key) {
    style = Get.find<Style>();
    userController = Get.find<UserController>();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Material(
        child: Container(
          decoration:   BoxDecoration(
            // gradient: style.splashBackground,
            image: DecorationImage(
                image: const AssetImage("assets/images/main_back.jpg"),
                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    style.primaryColor.withAlpha(20), BlendMode.screen),
                opacity: .1),
          ),
          width: Get.width,
          padding: EdgeInsets.all(style.cardMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Padding(
              //   padding:   EdgeInsets.symmetric(vertical:style.imageHeight),
              //   child: BlinkAnimation(
              //     child: Image.asset('assets/images/icon.png',
              //         height: style.cardVitrinHeight),
              //   ),
              // ),
              Container(
                  width: Get.width / 3,
                  child: Loader(
                    color: Colors.white,
                  ))
            ],
          ),
        ),
      );
    } else {
      return Material(
        child: Container(
          decoration: BoxDecoration(
            gradient: style.mainGradientBackground,
            image: DecorationImage(
                image: const AssetImage("assets/images/main_back.jpg"),

                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    style.primaryColor.withOpacity(.1), BlendMode.multiply),
                opacity: .1),
          ),
          width: Get.width,
          padding: EdgeInsets.all(style.cardMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/icon.png',
                  height: style.gridHeight),
              SizedBox(height: style.cardMargin * 2),
              Text(
                'check_network'.tr,
                style: style.textMediumLightStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: style.cardMargin * 2),
              MyButton(
                label: 'retry'.tr,
                onPressed: () => userController.getUser(refresh: true),
              )
            ],
          ),
        ),
      );
    }
  }
}
