import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/SettingController.dart';
import '../helper/styles.dart';
import 'MyNetworkImage.dart';
import 'bounce.dart';
import 'shakeanimation.dart';

class BannerCard extends StatelessWidget {
  late Style style;
  late SettingController settingController;
  late MaterialColor colors;
  late EdgeInsets margin;
  late BorderRadius borderRadius;
  late List<dynamic> data;
  Color? titleColor;
  TextStyle? titleStyle;
  final icon;
  final title;
  final onClick;
  final background;
  final subtitle;

  BannerCard(
      {EdgeInsets? margin,
      MaterialColor? colors,
      required this.background,
      required this.title,
      required this.icon,
      this.onClick,
      Color? this.titleColor,
      BorderRadius? borderRadius,
      this.titleStyle,
      String? this.subtitle}) {
    style = Get.find<Style>();
    settingController = Get.find<SettingController>();
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: style.cardMargin / 8,
          horizontal: style.cardMargin,
        );
    this.colors = colors ?? style.primaryMaterial;
    this.borderRadius =
        borderRadius ?? BorderRadius.circular(style.cardBorderRadius);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   Future.delayed(
    //       Duration(seconds: 1),
    //       () => Get.to(PlayerCreate(),
    //           transition: Transition.circularReveal,
    //           duration: Duration(milliseconds: 500)));
    //   //   var data=await LatestController().find({'id':'20','type':'cl'});
    //   // Get.to(ClubDetails(data: data, colors: style.cardClubColors));
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MyBounce(
      onTap: onClick,
      child: ShakeWidget(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          shadowColor: style.primaryColor.withOpacity(.3),
          color: style.primaryColor,
          elevation: 20,
          margin: margin,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: borderRadius,
                image: DecorationImage(
                    image: AssetImage("assets/images/$background"),
                    fit: BoxFit.cover)),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(style.cardMargin),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "$icon".startsWith('http')
                              ? MyNetworkImage(
                                  url: "$icon",
                                  fit: BoxFit.contain,
                                  width: style.imageHeight * 2 / 3,
                                  height: style.imageHeight * 2 / 3,
                                )
                              : Image.asset("assets/images/$icon",
                                  width: style.imageHeight * 2 / 3,
                                  height: style.imageHeight * 2 / 3,
                                  fit: BoxFit.contain),
                          Expanded(
                              child: Center(
                                  child: Text(
                            title,
                            style: titleStyle ??
                                style.textBigLightStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: titleColor ?? Colors.white),
                            textAlign: TextAlign.center,
                          ))),
                        ]),
                  ),
                  if (subtitle != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(style.cardMargin / 2),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(style.cardMargin),
                                  topRight: Radius.circular(style.cardMargin))),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            subtitle,
                            style: style.textSmallStyle,
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
