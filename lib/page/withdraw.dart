import 'package:games/widget/AppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/styles.dart';
import '../widget/MyButton.dart';

import '../widget/MyTextField.dart';
import '../widget/loader.dart';

class WithdrawPage extends StatelessWidget {
  WithdrawPage({super.key}) {
    if (!settingController.appLoaded()) Get.offNamed('/');
  }

  SettingController settingController = Get.find<SettingController>();
  Style style = Get.find<Style>();
  UserController userController = Get.find<UserController>();
  TextEditingController amountTextController = TextEditingController();
  RxBool loading = RxBool(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MyAppBar(
      title: 'withdraw'.tr,
      child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            Container(
              padding: EdgeInsets.all(
                style.cardMargin * 2,
              ),
              margin: EdgeInsets.all(
                style.cardMargin,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(style.cardMargin),
                  color: style.primaryColor,
                  border: Border.all(
                    color: Colors.transparent,
                    // Make the border itself transparent
                    width: 4.0,
                  ),
                  boxShadow: style.mainShadow
                  // image: DecorationImage(
                  //     image: AssetImage("assets/images/frame_button_6.png"),
                  //     repeat: ImageRepeat.noRepeat,
                  //     fit: BoxFit.fill,
                  //     filterQuality: FilterQuality.medium,
                  //     opacity: 1),
                  ),
              child: Text(
                settingController.withdrawTitle,
                style: style.textSmallLightStyle,
              ),
            ),
            SizedBox(
              height: style.cardMargin,
            ),
            MyTextField(
              margin: EdgeInsets.symmetric(
                  horizontal: style.cardMargin / 2,
                  vertical: style.cardMargin / 4),
              icon: Icon(
                Icons.account_balance_wallet_rounded,
                color: style.primaryColor,
              ),
              textController: amountTextController,
              labelText: "${'amount'.tr}",
              textInputType: TextInputType.number,
              obscure: false,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(
                      style.cardMargin,
                    ),
                    padding: EdgeInsets.all(
                      style.cardMargin * 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(style.cardMargin),
                      color: style.primaryColor,
                      border: Border.all(
                        color: Colors.transparent,
                        // Make the border itself transparent
                        width: 4.0,
                      ),
                      boxShadow: style.mainShadow,
                      // image: DecorationImage(
                      //     image: AssetImage("assets/images/frame_button_6.png"),
                      //     repeat: ImageRepeat.noRepeat,
                      //     fit: BoxFit.fill,
                      //     filterQuality: FilterQuality.medium,
                      //     opacity: 1),
                    ),
                    child: Text(
                      "${'card'.tr}: ${userController.user.financial.card} \n ${'name'.tr}: ${userController.user.fullName}",
                      style: style.textHeaderLightStyle,
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => loading.value
                  ? Loader(
                      color: Colors.white,
                    )
                  : MyButton(
                      themeId: 10,
                      label: 'register_request'.tr,
                      onPressed: () async {
                        loading.value = true;
                        Map res = await userController.withdraw(
                            amount: amountTextController.text);
                        loading.value = false;
                        if (res['status'] == 'success') {
                          amountTextController.clear();
                        }
                      }),
            )
          ])),
    ));
  }
}
