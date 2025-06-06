import 'dart:async';
import 'dart:ui';

import 'package:games/page/contact_us.dart';
import 'package:games/widget/GlassContainer.dart';
import 'package:games/widget/MyButton.dart';
import 'package:games/widget/MyDialog.dart';
import 'package:games/widget/MyTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/helpers.dart';
import '../helper/styles.dart';
import '../helper/variables.dart';
import '../widget/loader.dart';

class RegisterLoginScreen extends StatelessWidget {
  final bool isLoading;
  final String? error;
  late final Style style;
  late final SettingController settingController;
  late final UserController userController = Get.find<UserController>();
  late TextEditingController textPhoneController;
  late TextEditingController textVerifyController;
  late TextEditingController textRefController;
  late TextEditingController textPasswordController;
  late TextEditingController textPasswordVerifyController;
  late TextEditingController textFullNameController;
  late TextEditingController textEmailController;
  late TextEditingController textInviterCodeController;
  late TextEditingController textSmsCodeController;
  late TextEditingController textUsernameController;

  late MyAnimationController animationController;

  late RxString show = RxString('LOGIN');
  late RxBool isLawyer = RxBool(false);
  late RxBool isAcceptedPolicy = RxBool(false);
  late Helper helper;
  late RxBool enableButton;
  late Timer _timer;
  RxInt time = 60.obs;

  late AnimationController animationTextPhoneController;
  late ButtonStyle buttonStyle;

  RegisterLoginScreen({Key? key, this.isLoading = false, String? this.error}) {
    // userController = Get.find<UserController>();
    style = Get.find<Style>();
    settingController = Get.find<SettingController>();
    helper = Get.find<Helper>();
    textPhoneController = TextEditingController();

    textVerifyController = TextEditingController();
    textSmsCodeController = TextEditingController();
    textRefController = TextEditingController();
    textPasswordController = TextEditingController();
    textFullNameController = TextEditingController();
    textInviterCodeController = TextEditingController();
    textEmailController = TextEditingController();
    textUsernameController = TextEditingController();
    textPasswordVerifyController = TextEditingController();
    animationController = Get.find<MyAnimationController>();

    buttonStyle = style.buttonStyle(
      padding: EdgeInsets.symmetric(vertical: style.cardMargin),
      backgroundColor: style.primaryColor,
    );

    enableButton = true.obs;
    // if (error != null) show.value = 'LOGIN';
    animationController.showField();

    userController.addListener(() {});

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   textPhoneController.text = '';
    //   textFullNameController.text = 'نام تست';
    // textUsernameController.text = 'mojraj';
    //   textEmailController.text = 'moj2raj2@hotmail.com';
    // textPasswordController.text = '123123';
    // textPasswordVerifyController.text = '123123';
    //   textSmsCodeController.text = '00654';
    //   // loginRegister();
    // });
  }

  @override
  Widget build(BuildContext context) {
    //error sms verify

    if (error != null) {
      return Obx(
        () => Material(
          child: Container(
            decoration: BoxDecoration(
              gradient: style.mainGradientBackground,
              image: DecorationImage(
                  image: const AssetImage("assets/images/main_back.jpg"),
                  // repeat: ImageRepeat.repeat,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                  colorFilter: ColorFilter.mode(
                      style.primaryColor.withOpacity(1), BlendMode.colorBurn),
                  opacity: .1),
            ),
            // width: Get.width,
            padding: EdgeInsets.all(style.cardMargin),
            child: FadeTransition(
              opacity: animationController.showFieldController,
              child: Center(
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(style.cardMargin),
                  child: Padding(
                    padding: EdgeInsets.all(style.cardMargin),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Image.asset('assets/images/icon.png',
                            height: style.gridHeight),

                        //fullname field
                        if (false && show.value == 'REGISTER')
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  style.cardBorderRadius * 2),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ListTile(
                                  leading: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person),
                                      VerticalDivider(),
                                    ],
                                  ),
                                  title: TextField(
                                    controller: textFullNameController,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.done,
                                    enableSuggestions: true,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        hintText: 'fullname'.tr,
                                        border: InputBorder.none),
                                    onSubmitted: (str) {},
                                    // onEditingComplete: () {
                                    //   controller.getData(param: {'page': 'clear'});
                                    // },
                                    onChanged: (str) {
                                      animationController
                                          .toggleClearFullNameIcon(str.length);
                                    },
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FadeTransition(
                                        opacity: animationController
                                            .fadeShowClearFullNameIconController,
                                        child: IconButton(
                                          splashColor: style.secondaryColor,
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            textFullNameController.clear();
                                            animationController
                                                .toggleClearFullNameIcon(0);
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ), //inviter code field
                        //username field
                        if (['REGISTER', 'LOGIN'].contains(show.value))
                          MyTextField(
                            textController: textUsernameController,
                            icon: Icon(
                              Icons.person,
                              color: style.primaryColor,
                            ),
                            textInputType: TextInputType.emailAddress,
                            labelText: "username".tr,
                          ),

                        //phone field
                        if (show.value == 'PHONE' || show.value == 'REGISTER')
                          MyTextField(
                            textController: textPhoneController,
                            icon: Icon(
                              Icons.phone,
                              color: style.primaryColor,
                            ),
                            textInputType: TextInputType.phone,
                            labelText: "phone".tr,
                          ),

                        //email field
                        if (false && show.value == 'REGISTER')
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  style.cardBorderRadius * 2),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ListTile(
                                  leading: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.email),
                                      VerticalDivider(),
                                    ],
                                  ),
                                  title: TextField(
                                    controller: textEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    enableSuggestions: true,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        hintText: 'email'.tr,
                                        border: InputBorder.none),
                                    onSubmitted: (str) {},
                                    // onEditingComplete: () {
                                    //   controller.getData(param: {'page': 'clear'});
                                    // },
                                    onChanged: (str) {
                                      animationController
                                          .toggleClearEmailIcon(str.length);
                                    },
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FadeTransition(
                                        opacity: animationController
                                            .fadeShowClearEmailIconController,
                                        child: IconButton(
                                          splashColor: style.secondaryColor,
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            textEmailController.clear();
                                            animationController
                                                .toggleClearEmailIcon(0);
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        //password field
                        if (['REGISTER', 'LOGIN'].contains(show.value))
                          MyTextField(
                            textController: textPasswordController,
                            icon: Icon(
                              Icons.password_rounded,
                              color: style.primaryColor,
                            ),
                            textInputType: TextInputType.text,
                            obscure: true,
                            onAction: (str) {
                              print(str);
                              show.value == 'LOGIN' ? loginRegister() : null;
                            },
                            labelText: "password".tr,
                          ),
                        //password verify field
                        if (show.value == 'REGISTER')
                          MyTextField(
                            textController: textPasswordVerifyController,
                            icon: Icon(
                              Icons.password_rounded,
                              color: style.primaryColor,
                            ),
                            obscure: true,
                            textInputType: TextInputType.text,
                            labelText: "password_verify".tr,
                            onAction: (str) => show.value == 'REGISTER'
                                ? loginRegister()
                                : null,
                          ),
                        //sms code field
                        if (false && show.value == 'REGISTER')
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  style.cardBorderRadius * 2),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ListTile(
                                  leading: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.sms),
                                      VerticalDivider(),
                                    ],
                                  ),
                                  title: TextField(
                                    controller: textSmsCodeController,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        hintText: 'sms_code'.tr,
                                        border: InputBorder.none),
                                    onSubmitted: (str) {},
                                    // onEditingComplete: () {
                                    //   controller.getData(param: {'page': 'clear'});
                                    // },
                                    onChanged: (str) {
                                      animationController
                                          .toggleClearSmsCodeIcon(str.length);
                                    },
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FadeTransition(
                                        opacity: animationController
                                            .fadeShowClearSmsCodeIconController,
                                        child: IconButton(
                                          splashColor: style.secondaryColor,
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            textSmsCodeController.clear();
                                            animationController
                                                .toggleClearSmsCodeIcon(0);
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        //inviter code field
                        if (false && show.value == 'REGISTER')
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  style.cardBorderRadius * 2),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ListTile(
                                  leading: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_add_alt_1),
                                      VerticalDivider(),
                                    ],
                                  ),
                                  title: TextField(
                                    controller: textInviterCodeController,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        hintText: 'inviter_code'.tr,
                                        border: InputBorder.none),
                                    onSubmitted: (str) {},
                                    // onEditingComplete: () {
                                    //   controller.getData(param: {'page': 'clear'});
                                    // },
                                    onChanged: (str) {
                                      animationController
                                          .toggleClearInviterCodeIcon(
                                              str.length);
                                    },
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FadeTransition(
                                        opacity: animationController
                                            .fadeShowClearInviterCodeIconController,
                                        child: IconButton(
                                          splashColor: style.secondaryColor,
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            textInviterCodeController.clear();
                                            animationController
                                                .toggleClearInviterCodeIcon(0);
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),

                        if (false && show.value == 'REGISTER')
                          InkWell(
                            onTap: () {
                              isAcceptedPolicy.value = !isAcceptedPolicy.value;
                            },
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'i_accept_policy'.tr,
                                    style: style.textMediumLightStyle
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  CupertinoSwitch(
                                    activeColor: style.primaryColor,
                                    trackColor:
                                        style.secondaryColor.withOpacity(.3),
                                    value: isAcceptedPolicy.value,
                                    onChanged: (value) {
                                      isAcceptedPolicy.value = value;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (['LOGIN'].contains(show.value))
                          Row(
                            children: [
                              //login
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: style.cardMargin / 2),
                                  child: MyButton(
                                    label: 'login'.tr,
                                    onPressed: () {
                                      loginRegister();
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: style.cardMargin / 2),
                                  child: MyButton(
                                    label: 'register'.tr,
                                    onPressed: () {
                                      show.value = "REGISTER";
                                    },
                                  ),
                                ),
                              ),
                              //register
                            ],
                          ),

                        //telegram
                        if (show.value == 'LOGIN')
                          Container(
                            padding: EdgeInsets.all(
                              style.cardMargin,
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: style.cardMargin,
                              horizontal: style.cardMargin / 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(style.cardMargin),
                              color: style.primaryColor,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  userController.recoverPassword();
                                },
                                child: Text(
                                  'password_recover_(telegram)'.tr,
                                  textAlign: TextAlign.center,
                                  style: style.textMediumLightStyle.copyWith(
                                    color: style.secondaryColor,
                                    // shadows: [
                                    //   Shadow(
                                    //       color: Colors.black45,
                                    //       offset: Offset(0, 2)),
                                    // ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // register  button
                        if (['REGISTER'].contains(show.value))
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: style.cardMargin / 2),
                            child: MyButton(
                              label: 'register'.tr,
                              onPressed: () {
                                loginRegister();
                              },
                            ),
                          ),

                        if (show.value == 'VERIFY')
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  style.cardBorderRadius * 2),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: ListTile(
                                  leading: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.group),
                                      VerticalDivider(),
                                    ],
                                  ),
                                  title: TextField(
                                    controller: textRefController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                        hintText:
                                            "${'ref_code'.tr} (${'optional'.tr})",
                                        border: InputBorder.none),
                                    onSubmitted: (str) {},
                                    // onEditingComplete: () {
                                    //   controller.getData(param: {'page': 'clear'});
                                    // },
                                    onChanged: (str) {},
                                  ),
                                  trailing: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [],
                                  )),
                            ),
                          ),
                        if (show.value == 'VERIFY')
                          TextButton(
                              style: buttonStyle.copyWith(
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(style.cardBorderRadius),
                                ),
                              ))),
                              onPressed: () {
                                show.value = 'PHONE';
                                animationController.showField();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: style.cardMargin),
                                child: Text(
                                  'edit_phone'.tr,
                                  style: style.textMediumLightStyle,
                                ),
                              )),

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              settingController.goTo('', scheme: 'policy');
                            },
                            child: Container(
                              padding: EdgeInsets.all(style.cardMargin),
                              child: Text(
                                'policy'.tr,
                                textAlign: TextAlign.center,
                                style: style.textMediumLightStyle.copyWith(
                                  color: style.secondaryColor,
                                  // shadows: [
                                  //   Shadow(
                                  //       color: Colors.black45,
                                  //       offset: Offset(0, 2)),
                                  // ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (show.value == 'REGISTER')
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                show.value = 'LOGIN';
                              },
                              child: Container(
                                margin: EdgeInsets.all(style.cardMargin),
                                child: Text(
                                  'return'.tr,
                                  textAlign: TextAlign.center,
                                  style: style.textMediumLightStyle.copyWith(
                                    color: style.secondaryColor,
                                    // shadows: [
                                    //   Shadow(
                                    //       color: Colors.black45,
                                    //       offset: Offset(0, 2)),
                                    // ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (show.value == 'LOADING')
                          Loader(
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const Center();
  }

  void toggleEnableButton(String str) {
    if (str.length >= 9 && time.value == 60) {
      enableButton.value = true;
    } else
      enableButton.value = false;
  }

  void preAuth() async {
    show.value = "LOADING";
    String p = getTruePhone();

    final res = await userController.preAuth(
      phone: p,
    );
    // Map<String, dynamic> res = {
    //   "status": "go_register",
    //   "message":
    //       "\u06a9\u0627\u0631\u0628\u0631 \u06af\u0631\u0627\u0645\u06cc \u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0628\u0627\u0644\u0627 \u0631\u0627 \u062a\u06a9\u0645\u06cc\u0644 \u06a9\u0646\u06cc\u062f",
    //   "code": "4472"
    // };
    // print(res);

    if (res == null || res['status'] != null && res['status'] == 'error') {
      helper.showToast(
          msg: res == null || res['message'] == null
              ? 'check_network'.tr
              : res['message'] ?? 'check_network'.tr,
          status: 'danger');
      show.value = "PHONE";
      return;
    }
    switch (res["status"]) {
      case "go_login":
        helper.showToast(msg: res["message"]);
        show.value = "LOGIN";
        break;
      case "go_register":
        helper.showToast(msg: res["message"]);
        show.value = "REGISTER";
        break;
      case "success": //user info
        helper.showToast(msg: res["message"], status: 'success');
        show.value = "REGISTER";
        userController.ACCESS_TOKEN = res["auth_header"];

        userController.getUser(refresh: true);
        // userController.user = User(
        //   id: res["user_id"],
        //   mobile: p,
        //   fullName: res["fullname"],
        //   email: res["email"],
        //   tel: res["tel"],
        //   categories: res["categories"],
        //   isLawyer: res["is_lawyer"] != null ? res["is_lawyer"] == 1 : false,
        //   wallet: res["wallet"],
        //   avatar: res["avatar"],
        //   isLogin: true,
        //   expiredAt: res["expired_at"],
        //   dateNow: res["date_now"],
        //   token: res["auth_header"],
        //   lawyerNumber: res["lawyer_number"],
        //   lawyerMelicard: res["lawyer_melicard"],
        //   lawyerBirthday: res["lawyer_birthday"],
        //   lawyerAddress: res["lawyer_address"],
        //   lawyerSex: res["lawyer_sex"],
        //   lawyerDocument: res["lawyer_document"],
        //   cv: res["cv"],
        //   isExpert: res["is_expert"] != null ? res["is_expert"] == 1 : false,
        //   isShowLawyer: res["is_show_lawyer"] != null
        //       ? res["is_show_lawyer"] == 1
        //       : false,
        //   isVerify: res["is_verify"] != null ? res["is_verify"] == 1 : false,
        //   isBlock: res["is_block"] != null ? res["is_block"] == 1 : false,
        //   lawyerExpiredAt: res["lawyer_expired_at"],
        //   loginAt: res["login_at"],
        //   marketerCode: res["marketer_code"],
        //   cityId: res["cityId"],
        // );
        break;
    }
  }

  // void sendActivationCode() async {
  //   show.value = "LOADING";
  //   String p = getTruePhone();
  //   bool res = await settingController.sendActivationCode(
  //     phone: p,
  //   );
  //   // print("sendActivationCode $p");
  //   // print(res);
  //   if (res == true) {
  //     enableButton.value = false;
  //     startTimer();
  //     show.value = 'VERIFY';
  //     animationController.toggleCloseSearchIcon(0);
  //   } else
  //     show.value = "PHONE";
  //   animationController.showField();
  // }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (time.value <= 0) {
        timer.cancel();
        enableButton.value = true;
        time.value = 60;
      } else {
        time.value--;
      }
    });
  }

  void loginRegister() async {
    String p = getTruePhone();
    // print("loginRegister $p");
    String back = show.value;
    if (show.value == 'PHONE')
      preAuth();
    else if (show.value == 'LOGIN') {
      // show.value = "LOADING";
      final res = await userController.login(
        // phone: "$p",
        username: textUsernameController.text,
        password: textPasswordController.text,
        passwordVerify: textPasswordVerifyController.text,
      );

      // show.value = back;
    } else if (show.value == 'REGISTER') {
      // if (!isAcceptedPolicy.value) {
      //   helper.showToast(msg: 'please_accept_policy'.tr, status: 'danger');
      //   return;
      // }
      // show.value = "LOADING";
      final res = await userController.register(
        phone: "$p",
        // code: textSmsCodeController.text,
        username: textUsernameController.text,
        // email: textEmailController.text,
        // fullname: textFullNameController.text,
        password: textPasswordController.text,
        passwordVerify: textPasswordVerifyController.text,
        // inviter: textInviterCodeController.text,
      );
      // print(res);
      // show.value = back;
    }
    // show.value = 'VERIFY';
    // print(res);
  }

  void recoverPassword() async {
    var before = show.value;
    show.value = "LOADING";
    final res = await userController.recoverPassword(
      phone: getTruePhone(),
    );
    if (res["status"] == 'success') {
      helper.showToast(msg: res["message"], status: 'success');
      startTimer();
    } else if (res["message"] != null)
      helper.showToast(msg: res["message"], status: 'danger');
    show.value = before;
  }

  String getTruePhone() {
    String p = textPhoneController.text;
    if (p.length == 10)
      p = "0$p";
    else if (p.length == 9) p = "09$p";
    return p;
  }
}
