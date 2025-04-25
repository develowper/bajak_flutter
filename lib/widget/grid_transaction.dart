import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import '../controller/TransactionController.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/extensions.dart';
import '../helper/helpers.dart';
import '../helper/styles.dart';
import '../helper/variables.dart';
import '../model/Transaction.dart';
import '../model/User.dart';
import '../widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GridTransaction extends StatelessWidget {
  final TransactionController controller;
  final Style style;
  final SettingController settingController;
  late final UserController userController;
  late Rx<Transaction> data;

  MaterialColor colors;

  late TextStyle titleStyle;

  GridTransaction({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.style,
    required this.colors,
  }) {
    titleStyle = style.textMediumStyle/*.copyWith(color: colors[900])*/;
    userController = Get.find<UserController>();
    this.data = Rx<Transaction>(data);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ShakeWidget(
        child: Row(
          children: [
            Expanded(
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(style.cardMargin),
                ),
                shadowColor: colors[500]?.withOpacity(.7),
                margin: EdgeInsets.symmetric(
                    horizontal: style.cardMargin,
                    vertical: style.cardMargin / 4),
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage("assets/images/texture.jpg"),
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        opacity: .3),
                    borderRadius: BorderRadius.circular(style.cardBorderRadius),
                    gradient: style.cardGradientBackgroundReverse,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                              style: style.buttonStyle(
                                  splashColor: colors[100],
                                  radius: BorderRadius.circular(
                                      style.cardBorderRadius),
                                  backgroundColor:
                                      Colors.white.withOpacity(.8)),
                              onPressed: () => null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${data.value.createdAt}",
                                        style: style.textSmallStyle,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(style.cardMargin),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data.value.title,
                                            // overflow: TextOverflow.ellipsis,
                                            // textWidthBasis: TextWidthBasis.longestLine,
                                            style: titleStyle.copyWith(
                                                color: colors[800],
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: style.cardMargin,
                                        vertical: style.cardMargin / 2),
                                    child: Divider(
                                      height: 1,
                                      thickness: 3,
                                      indent: style.cardMargin,
                                      endIndent: style.cardMargin,
                                      color: colors[50],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: style.cardMargin),
                                    child: IntrinsicHeight(
                                      child: Column(
                                        children: [
                                          miniCell(
                                              title: 'amount'.tr,
                                              colors: data.value.amount
                                                      .contains("-")
                                                  ? Colors.red
                                                  : Colors.teal,
                                              child:
                                                  "${data.value.amount.asPrice()} ${'currency'.tr}"),
                                          miniCell(
                                              title: 'trace_code'.tr,
                                              colors: Colors.indigo ,
                                              child: data.value.id),
                                          if (data.value.coupon != '')
                                            miniCell(
                                                title: 'coupon'.tr,
                                                colors: Colors.indigo,
                                                child: data.value.coupon),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        )
                        //text section
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget miniCell(
      {required String title,
      required MaterialColor colors,
      required dynamic child}) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(style.cardMargin)),
        child: TextButton(
            style: style.buttonStyle(
                splashColor: colors[100],
                radius: BorderRadius.circular(style.cardMargin),
                backgroundColor: colors[50]),
            onPressed: () => null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Text(
                    title,
                    style: titleStyle.copyWith(
                        color: colors[800], fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: style.cardMargin,
                      vertical: style.cardMargin / 2),
                  child: Divider(
                    height: 1,
                    thickness: 3,
                    indent: style.cardMargin,
                    endIndent: style.cardMargin,
                    color: colors[100],
                  ),
                ),
                Center(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: style.cardMargin),
                      child: child.runtimeType == String
                          ? Text(
                              child,
                              style: style.textMediumStyle
                                  .copyWith(color: colors[500]),
                            )
                          : child),
                ),
              ],
            )),
      ),
    );
  }
}
