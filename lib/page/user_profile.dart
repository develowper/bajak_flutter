import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:games/page/transactions.dart';
import 'package:games/widget/AppBar.dart';
import 'package:games/widget/GlassContainer.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/extensions.dart';
import '../helper/helpers.dart';
import '../helper/styles.dart';
import '../model/User.dart';
import '../page/shop.dart';
import '../widget/MyTextField.dart';
import '../widget/blinkanimation.dart';
import '../widget/mini_card.dart';
import '../widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/AnimationController.dart';
import '../controller/UserFilterController.dart';

class UserProfilePage extends StatelessWidget {
  late final UserController userController;
  late final SettingController settingController;

  late final Style style;
  final GlobalKey _key = GlobalKey();
  late Rx<User> user;
  Rx<List<dynamic>> counties = Rx<List<dynamic>>([]);
  late MaterialColor colors;

  late Map<String, dynamic> userInfo;
  late Map<String, dynamic> userRef;
  late TextStyle title1Style;
  late TextStyle title2Style;
  late Helper helper;
  RxBool loading = false.obs;
  RxDouble titleHeight = RxDouble(0.0);
  Rx<Map<String, String>> cacheHeaders = Rx<Map<String, String>>({});

  late Rx<ScrollPhysics> parentScrollPhysics =
      Rx<ScrollPhysics>(const BouncingScrollPhysics());
  late Rx<ScrollPhysics> childScrollPhysics =
      Rx<ScrollPhysics>(const NeverScrollableScrollPhysics());
  RxString statusText = '_'.obs;
  RxInt expireDays = 0.obs;
  RxString statusTextLawyer = '_'.obs;
  RxInt expireDaysLawyer = 0.obs;
  final MyAnimationController animationController =
      Get.find<MyAnimationController>();
  late UserFilterController filterController;

  UserProfilePage({Key? key}) {
    userController = Get.find<UserController>();
    settingController = Get.find<SettingController>();
    helper = Get.find<Helper>();
    style = Get.find<Style>();
    colors = style.primaryMaterial;
    user = Rx<User>(userController.user ?? User.nullUser());
    userInfo = userController.userInfo;
    userRef = userController.userRef ?? {};
    title1Style = style.textBigStyle;
    title2Style = style.textMediumStyle;
    filterController = userController.filterController;

    if (!settingController.appLoaded()) Get.offNamed('/');
    // WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
    //     Duration(seconds: 2),
    //     () => Get.to(MarketingPage(),
    //         transition: Transition.topLevel,
    //         duration: Duration(milliseconds: 100))));

    //         // showEditDialog({'username': user.username}));

    parentScrollPhysics = Rx<ScrollPhysics>(userController.parentScrollPhysics);
    childScrollPhysics = Rx<ScrollPhysics>(userController.childScrollPhysics);

    assign();
    userController.parentScrollController =
        userController.parentScrollController;
    userController.childScrollController = userController.childScrollController;
    userController.childScrollPhysics = userController.childScrollPhysics;
    userController.parentScrollPhysics = userController.parentScrollPhysics;
/*
    userController.parentScrollController.addListener(() {
      if (userController.parentScrollController.offset >
              userController.parentScrollController.position.maxScrollExtent &&
          userController.childScrollController.position.maxScrollExtent > 0 &&
          childScrollPhysics.value is NeverScrollableScrollPhysics &&
          parentScrollPhysics.value is! NeverScrollableScrollPhysics) {
        userController.parentScrollController.animateTo(
            userController.parentScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
        childScrollPhysics.value = BouncingScrollPhysics();
        parentScrollPhysics.value = NeverScrollableScrollPhysics();
        userController.childScrollPhysics = childScrollPhysics.value;
        userController.parentScrollPhysics = parentScrollPhysics.value;
      }
    });
    userController.childScrollController.addListener(() {
      if (userController.childScrollController.offset < 0 &&
          parentScrollPhysics.value is NeverScrollableScrollPhysics &&
          childScrollPhysics.value is! NeverScrollableScrollPhysics) {
        parentScrollPhysics.value = BouncingScrollPhysics();
        childScrollPhysics.value = NeverScrollableScrollPhysics();
        userController.childScrollPhysics = childScrollPhysics.value;
        userController.parentScrollPhysics = parentScrollPhysics.value;
      }
    });
    */
    DateTime now = DateTime.now();
    DateTime expireDaysDateTime =
        user.value?.expiresAt != null && user.value?.expiresAt != ''
            ? DateTime.tryParse(user.value!.expiresAt) ?? now
            : now;

    expireDays.value = expireDaysDateTime.difference(now).inDays;
    statusText.value = !user.value.isActive ? 'blocked'.tr : 'active'.tr;
    // : expireDays.value <  0
    //     ? 'expired'.tr
    //     : 'inactive'.tr;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _getTitleHeight();
    });
  }

  _getTitleHeight() {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    titleHeight.value = renderBox.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: Scaffold(
          body: MyAppBar(
            // header: Center(
            //   child: Text(
            //     'profile'.tr,
            //     style: style.textHeaderLightStyle,
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            child: Stack(
              children: [
                //name status
                Padding(
                  padding: EdgeInsets.all(style.cardMargin),
                  child: Row(
                    key: _key,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //name
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: style.cardMargin / 4),
                        child: TextButton(
                          style: style.buttonStyle(
                            padding: EdgeInsets.all(style.cardMargin * 2),
                            radius: BorderRadius.all(
                              Radius.circular(style.cardMargin),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () => null,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IntrinsicHeight(
                                    child: Row(children: [
                                  if (false)
                                    Icon(
                                      Icons.person,
                                      color: user.value.isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  Text(
                                    'name'.tr,
                                    style: style.textSmallStyle,
                                  ),
                                  VerticalDivider(
                                    color: user.value.isActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  Text(
                                    user.value.fullName != ''
                                        ? user.value.fullName
                                        : '-',
                                    style: style.textSmallStyle,
                                  ),
                                ])),
                                if (false)
                                  IntrinsicHeight(
                                      child: Text(
                                          statusText.value == 'expired'.tr
                                              ? 'click_for_pay'.tr
                                              : '')),
                              ]),
                        ),
                      ),
                      //status
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: style.cardMargin / 4),
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextButton(
                                style: style.buttonStyle(
                                  padding: EdgeInsets.all(style.cardMargin * 2),
                                  radius: BorderRadius.all(
                                    Radius.circular(style.cardMargin),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () => null,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IntrinsicHeight(
                                          child: Row(children: [
                                        Image.asset(
                                          user.value.isActive
                                              ? 'assets/images/ok.png'
                                              : 'assets/images/cancel.png',
                                          height: style.cardMargin * 2,
                                        ),
                                        if (false)
                                          Icon(
                                            Icons.person,
                                            color: user.value.isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        if (false)
                                          Text(
                                            'sub'.tr,
                                            style: style.textMediumStyle,
                                          ),
                                        VerticalDivider(
                                          color: user.value.isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: style.cardMargin / 2),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      style.cardMargin))),
                                          child: Text(statusText.value,
                                              style: style.textSmallStyle
                                                  .copyWith(
                                                      color: user.value.isActive
                                                          ? Colors.green
                                                          : Colors.red)),
                                        ),
                                      ])),
                                      if (false)
                                        IntrinsicHeight(
                                            child: Text(
                                                statusText.value == 'expired'.tr
                                                    ? 'click_for_pay'.tr
                                                    : '')),
                                    ]),
                              ),
                              SizedBox(
                                height: style.cardMargin,
                              ),
                              TextButton.icon(
                                  style: style.buttonStyle(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin * 2,
                                          vertical: style.cardMargin * 1.5),
                                      backgroundColor:
                                          Colors.red.withOpacity(.8),
                                      radius: BorderRadius.all(
                                        Radius.circular(style.cardMargin),
                                      ),
                                      splashColor:
                                          Colors.white.withOpacity(.5)),
                                  onPressed: () => Get.dialog(
                                        Center(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        style.cardBorderRadius),
                                              ),
                                              shadowColor: style.primaryColor
                                                  .withOpacity(.3),
                                              color: Colors.white,
                                              // colors[100]?.withOpacity(.8),
                                              margin: EdgeInsets.all(
                                                  style.cardMargin),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        style.cardMargin * 4,
                                                    horizontal:
                                                        style.cardMargin * 2),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                          style.cardMargin / 2),
                                                      child: Text(
                                                        'sure_to_exit?'.tr,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: style
                                                            .textMediumStyle,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: TextButton(
                                                              style:
                                                                  ButtonStyle(
                                                                      overlayColor:
                                                                          WidgetStateProperty
                                                                              .resolveWith(
                                                                        (states) {
                                                                          return states.contains(WidgetState.pressed)
                                                                              ? style.secondaryColor
                                                                              : null;
                                                                        },
                                                                      ),
                                                                      backgroundColor:
                                                                          WidgetStateProperty.all(colors[
                                                                              50]),
                                                                      shape: WidgetStateProperty
                                                                          .all(
                                                                              RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.horizontal(
                                                                          right:
                                                                              Radius.circular(style.cardBorderRadius / 2),
                                                                          left: Radius.circular(style.cardBorderRadius /
                                                                              4),
                                                                        ),
                                                                      ))),
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child: Text(
                                                                'cancel'.tr,
                                                                style: style
                                                                    .textMediumStyle,
                                                              )),
                                                        ),
                                                        VerticalDivider(
                                                          indent:
                                                              style.cardMargin /
                                                                  2,
                                                          endIndent:
                                                              style.cardMargin /
                                                                  2,
                                                        ),
                                                        Expanded(
                                                          child: TextButton(
                                                              style: style.buttonStyle(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  splashColor: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          .5)),
                                                              onPressed: () {
                                                                Get.back();
                                                                userController
                                                                    .logout();
                                                              },
                                                              child: Text(
                                                                'verify'.tr,
                                                                style: style
                                                                    .textMediumLightStyle,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        barrierDismissible: true,
                                      ),
                                  icon: const Icon(
                                    Icons.power_settings_new_rounded,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'exit'.tr,
                                    style: style.textMediumLightStyle,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(style.cardMargin),
                      padding: EdgeInsets.all(style.cardMargin),
                      margin: EdgeInsets.all(style.cardMargin),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: style.bottomNavigationBarHeight / 2,
                          ),
                          GlassContainer(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(style.cardMargin),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(style.cardMargin),
                                ),
                              ),
                              minVerticalPadding: style.cardMargin * 2,
                              tileColor: Colors.white,
                              leading: Icon(Icons.person_rounded),
                              title: Text(
                                'edit_info'.tr,
                                style: style.textMediumStyle,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: style.cardMargin * 4),
                              onTap: () {
                                assign();
                                Get.dialog(
                                    Center(
                                      child: MiniCard(
                                        scrollable: true,
                                        loading: loading,
                                        shrink: true,
                                        titlePadding:
                                            EdgeInsets.all(style.cardMargin),
                                        title: 'user_info'.tr,
                                        style: style,
                                        desc1: '',
                                        child: Container(
                                          child: Padding(
                                              padding: EdgeInsets.all(
                                                  style.cardMargin / 4),
                                              child: Column(
                                                children: [
                                                  MyTextField(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4),
                                                    icon: Icon(
                                                      Icons.person,
                                                      color: style.primaryColor,
                                                    ),
                                                    textController:
                                                        filterController
                                                            .textNameCtrl,
                                                    labelText:
                                                        "${'name'.tr} ${'family'.tr}",
                                                    textInputType:
                                                        TextInputType.name,
                                                  ),
                                                  MyTextField(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4),
                                                    icon: Icon(
                                                      Icons.account_box_rounded,
                                                      color: style.primaryColor,
                                                    ),
                                                    textController:
                                                        filterController
                                                            .textUsernameCtrl,
                                                    labelText:
                                                        "${'username'.tr}",
                                                    textInputType:
                                                        TextInputType.name,
                                                  ),
                                                  MyTextField(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4),
                                                    icon: Icon(
                                                      Icons
                                                          .phone_android_rounded,
                                                      color: style.primaryColor,
                                                    ),
                                                    textController:
                                                        filterController
                                                            .textPhoneCtrl,
                                                    labelText: "${'phone'.tr}",
                                                    textInputType:
                                                        TextInputType.number,
                                                  ),
                                                  MyTextField(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4),
                                                    icon: Icon(
                                                      Icons.credit_card_rounded,
                                                      color: style.primaryColor,
                                                    ),
                                                    textController:
                                                        filterController
                                                            .textCardCtrl,
                                                    labelText:
                                                        "${'card_number'.tr}",
                                                    textInputType:
                                                        TextInputType.number,
                                                  ),
                                                  MyTextField(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4),
                                                    icon: Icon(
                                                      Icons
                                                          .card_membership_rounded,
                                                      color: style.primaryColor,
                                                    ),
                                                    textController:
                                                        filterController
                                                            .textShebaCtrl,
                                                    labelText:
                                                        "${'sheba_number'.tr}",
                                                    textInputType:
                                                        TextInputType.number,
                                                  ),
                                                  SizedBox(
                                                    height: style.cardMargin,
                                                  ),
                                                  TextButton(
                                                      style: style.buttonStyle(
                                                        backgroundColor: style
                                                                .primaryMaterial[
                                                            500],
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: style
                                                                        .cardMargin *
                                                                    2),
                                                        radius: BorderRadius
                                                            .vertical(
                                                          bottom: Radius.circular(
                                                              style.cardBorderRadius /
                                                                  2),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        edit({}, type: 'user');
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          "${'edit'.tr}",
                                                          style: style
                                                              .textMediumLightStyle
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      )),
                                                ],
                                              )),
                                        ),
                                      ),
                                    ),
                                    barrierDismissible: true);
                              },
                            ),
                          ),

                          GlassContainer(
                            color: Colors.white,
                            child: ListTile(
                              minVerticalPadding: style.cardMargin * 2,
                              leading: Icon(Icons.attach_money_rounded),
                              title: Text(
                                'wallet_charge'.tr,
                                style: style.textMediumStyle,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: style.cardMargin * 4),
                              onTap: () => Get.to(
                                () => ShopPage(),
                              ),
                            ),
                          ),

                          Container(
                            color: Colors.white,
                            child: ListTile(
                              minVerticalPadding: style.cardMargin * 2,
                              leading: Icon(Icons.bar_chart_rounded),
                              title: Text(
                                'transactions'.tr,
                                style: style.textMediumStyle,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: style.cardMargin * 4),
                              onTap: () => Get.to(
                                () => TransactionsPage(),
                              ),
                            ),
                          ),

                          //change password
                          Container(
                            color: Colors.white,
                            child: ListTile(
                              minVerticalPadding: style.cardMargin * 2,
                              leading: Icon(Icons.password_rounded),
                              title: Text(
                                'password_change'.tr,
                                style: style.textMediumStyle,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: style.cardMargin * 4),
                              onTap: () {
                                assign();
                                Get.dialog(
                                    Center(
                                      child: MiniCard(
                                        scrollable: true,
                                        loading: loading,
                                        shrink: true,
                                        titlePadding:
                                            EdgeInsets.all(style.cardMargin),
                                        title: 'password_change'.tr,
                                        style: style,
                                        desc1: '',
                                        child: Container(
                                          child: Padding(
                                              padding: EdgeInsets.all(
                                                  style.cardMargin / 2),
                                              child: Column(
                                                children: [
                                                  if (false)
                                                    MyTextField(
                                                      margin: EdgeInsets.symmetric(
                                                          vertical:
                                                              style.cardMargin /
                                                                  4),
                                                      icon:
                                                          Icon(Icons.password),
                                                      textController:
                                                          filterController
                                                              .textPaswOldCtrl,
                                                      labelText:
                                                          'password_old'.tr,
                                                      textInputType:
                                                          TextInputType.text,
                                                      obscure: true,
                                                    ),
                                                  MyTextField(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4),
                                                    icon: Icon(
                                                      Icons.password_outlined,
                                                      color: style.primaryColor,
                                                    ),
                                                    textController:
                                                        filterController
                                                            .textPaswCtrl,
                                                    labelText:
                                                        "${'password_new'.tr}",
                                                    textInputType:
                                                        TextInputType.text,
                                                    obscure: true,
                                                  ),
                                                  MyTextField(
                                                    margin: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4),
                                                    icon: Icon(
                                                      Icons.password_outlined,
                                                      color: style.primaryColor,
                                                    ),
                                                    textController:
                                                        filterController
                                                            .textPaswConfCtrl,
                                                    labelText:
                                                        "${'password_rep'.tr}",
                                                    textInputType:
                                                        TextInputType.text,
                                                    obscure: true,
                                                  ),
                                                  SizedBox(
                                                    height: style.cardMargin,
                                                  ),
                                                  TextButton(
                                                      style: style.buttonStyle(
                                                        backgroundColor: style
                                                                .primaryMaterial[
                                                            500],
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: style
                                                                        .cardMargin *
                                                                    2),
                                                        radius: BorderRadius
                                                            .vertical(
                                                          bottom: Radius.circular(
                                                              style.cardBorderRadius /
                                                                  2),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        edit({},
                                                            type: 'password');
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          "${'edit'.tr}",
                                                          style: style
                                                              .textMediumLightStyle
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      )),
                                                ],
                                              )),
                                        ),
                                      ),
                                    ),
                                    barrierDismissible: true);
                              },
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(style.cardMargin))),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.link_rounded),
                                      SizedBox(
                                        width: style.cardMargin,
                                      ),
                                      Text(
                                        'telegram_connect'.tr,
                                        style: style.textMediumStyle,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'need_vpn'.tr,
                                    style: style.textSmallStyle.copyWith(
                                        color:
                                            style.primaryColor.withOpacity(.8)),
                                  ),
                                ],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: style.cardMargin * 4),
                              onTap: () =>
                                  userController.getTelegramConnectLink(),
                            ),
                          ),

                          SizedBox(
                            height: style.bottomNavigationBarHeight / 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: loading.value,
                    child: Container(
                      color: style.primaryColor.withOpacity(.7),
                      child: Center(
                        child: ShakeWidget(
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(style.cardMargin))),
                            child: Padding(
                              padding: EdgeInsets.all(style.cardMargin),
                              child: CircularProgressIndicator(
                                  color: style.primaryColor),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  refresh() async {
    loading.value = true;
    await userController.getUser(refresh: true);
    loading.value = false;
  }

  edit(Map<String, dynamic> params, {String? type = 'user'}) async {
    loading.value = true;
    switch (type) {
      case 'password':
        params = {
          'password_old': filterController.textPaswOldCtrl.text,
          'password': filterController.textPaswCtrl.text,
          'password_confirmation': filterController.textPaswConfCtrl.text,
        };
        break;

      case 'user':
        params = {
          'full_name': filterController.textNameCtrl.text,
          'username': filterController.textUsernameCtrl.text,
          'phone': filterController.textPhoneCtrl.text,
          'card': filterController.textCardCtrl.text,
          'sheba': filterController.textShebaCtrl.text,
        };

        break;
    }
    Map res = await userController.edit(params: params, type: type);
    if (res['status'] == 'success') {
      if (params['password_new'] != '') {
        filterController.textPaswOldCtrl.clear();
        filterController.textPaswCtrl.clear();
        filterController.textPaswConfCtrl.clear();
      }

      // Get.back();
      if (res['message'] != null) {
        helper.showToast(msg: res['message'], status: 'success');
      }
      assign(data: res);
    }
    loading.value = false;
    // if (res) Future.delayed(Duration(seconds: 6),()=>Get.back());
  }

  isEditable() {
    return true;
  }

  void assign({Map? data}) {
    if (data != null) {}
    data = data ?? {};
    if (data['user'] != null) {
      if (data['financial'] != null) {
        data['user']['financial'] = data['financial'];
      }
      user.value = User.fromJson(data['user']);
    }
    filterController.textNameCtrl.text = user.value.fullName;
    filterController.textPhoneCtrl.text = user.value.phone;
    filterController.textUsernameCtrl.text = user.value.username;
    filterController.textCardCtrl.text = user.value.financial.card;
    filterController.textShebaCtrl.text = user.value.financial.sheba;
    filterController.textEmailCtrl.text = user.value.email;
    filterController.textPaswOldCtrl.text = '';
    filterController.textPaswCtrl.text = '';
    filterController.textPaswConfCtrl.text = '';
  }
}
