import 'package:games/helper/extensions.dart';
import 'package:games/widget/GlassContainer.dart';
import 'package:games/widget/MyButton.dart';
import 'package:get_storage/get_storage.dart';
import '../helper/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/styles.dart';
import '../widget/AppBar.dart';
import '../widget/MyTextField.dart';
import '../widget/banner_card.dart';
import '../widget/shakeanimation.dart';
import '../widget/side_menu.dart';
import 'menu_drawer.dart';

class ShopPage extends StatelessWidget {
  late SettingController settingController;
  late UserController userController;
  late Style style;
  late MyAnimationController animationController;
  late Helper helper;
  late TabBar tabBar;

  String? filter;
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');
  final _key = GlobalKey();
  RxInt expireDays = 0.obs;
  RxString statusText = "".obs;
  RxString title = RxString('gateway'.tr);

  TextEditingController amountTextController = TextEditingController();
  TextEditingController cardTextController = TextEditingController();

  ShopPage() {
    settingController = Get.find<SettingController>();
    animationController = Get.find<MyAnimationController>();
    style = Get.find<Style>();
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();

    if (!settingController.appLoaded()) Get.offNamed('/');

    userController.tabControllerShop.index = 0;
    userController.tabControllerShop.addListener(() {
      if (userController.tabControllerShop.indexIsChanging) {
      } else {
        if (userController.tabControllerShop.index == 0) {
          title.value = 'gateway'.tr;
        } else {
          title.value = 'card_to_card'.tr;
        }
        userController.update();
      }
    });
    tabBar = TabBar(
      controller: userController.tabControllerShop,
      // indicatorPadding: EdgeInsets.symmetric(horizontal: style.cardMargin*2),
      // padding: EdgeInsets.symmetric(horizontal: style.cardMargin*2),
      labelPadding: EdgeInsets.symmetric(horizontal: style.cardMargin * 2),

      dividerHeight: 0,

      indicator: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(style.cardMargin),
        // Rounded corners
        border: Border.all(color: Colors.white, width: 1), // White border
      ),
      labelStyle: style.textHeaderLightStyle,
      labelColor: style.secondaryColor,
      unselectedLabelColor: style.secondaryColor,
      tabs: [
        Tab(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: style.cardMargin * 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'gateway'.tr,
                style: style.textHeaderLightStyle,
              ),
            ),
          ),
        ),
        Tab(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: style.cardMargin * 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'card_to_card'.tr,
                style: style.textHeaderLightStyle,
              ),
            ),
          ),
        ),
      ],
    );
    DateTime now = DateTime.now();
    DateTime expireDaysDateTime = userController.user?.expiresAt != null &&
            userController.user?.expiresAt != ''
        ? DateTime.tryParse(userController.user!.expiresAt) ?? now
        : now;

    expireDays.value = expireDaysDateTime.difference(now).inDays;

    statusText.value =
        userController.user?.isActive != null && !userController.user!.isActive
            ? 'blocked'.tr
            : "${expireDays.value > 0 ? expireDays.value : 0} ${'day'.tr}";
    // WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
    //       Duration(seconds: 1),
    //       () => Get.dialog(iAPPurchase.showPlanDialog(
    //         item: iAPPurchase.plans[0],
    //       )),
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: userController.obx(
          (user) => RefreshIndicator(
              onRefresh: () => userController.getUser(refresh: true),
              child: MyAppBar(
                sideMenuKey: _sideMenuKey,
                header: Center(
                  child: Text(
                    title.value,
                    style: style.textHeaderLightStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                child: GlassContainer(
                  margin: EdgeInsets.all(style.cardMargin),
                  padding: EdgeInsets.all(style.cardMargin),
                  borderRadius: BorderRadius.circular(style.cardMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: style.cardMargin,
                      ),
                      tabBar,
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: style.cardMargin),
                          child: TabBarView(
                            controller: userController.tabControllerShop,
                            children: [
                              //charge
                              ListView(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      style.cardMargin * 2,
                                    ),
                                    margin: EdgeInsets.all(
                                      style.cardMargin,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          style.cardMargin),
                                      color: style.primaryColor,
                                      border: Border.all(
                                        color: Colors.transparent,
                                        // Make the border itself transparent
                                        width: 4.0,
                                      ),
                                      boxShadow: style.mainShadow,
                                    ),
                                    child: Text(
                                      settingController.chargeTitle,
                                      style: style.textMediumLightStyle,
                                    ),
                                  ),
                                  SizedBox(
                                    height: style.cardMargin,
                                  ),
                                  MyTextField(
                                    margin: EdgeInsets.symmetric(
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
                                  MyButton(
                                    themeId: 10,
                                    label: 'pay'.tr,
                                    onPressed: () => userController.getPayUrl(
                                        amount: amountTextController.text),
                                  )
                                ],
                              ),
                              //card to card
                              ListView(shrinkWrap: true, children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    style.cardMargin * 2,
                                  ),
                                  margin: EdgeInsets.all(
                                    style.cardMargin,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(style.cardMargin),
                                    color: style.primaryColor,
                                    border: Border.all(
                                      color: Colors.transparent,
                                      // Make the border itself transparent
                                      width: 4.0,
                                    ),
                                    boxShadow:    style.mainShadow,
                                  ),
                                  child: Text(
                                    settingController.cardToCardTitle,
                                    style: style.textMediumLightStyle,
                                  ),
                                ),
                                SizedBox(
                                  height: style.cardMargin,
                                ),
                                Card(
                                  child: Container(
                                    padding: EdgeInsets.all(style.cardMargin),
                                    child: Column(
                                      children: [
                                        Text(
                                          'destination_card_number'.tr,
                                          style: style.textHeaderStyle,
                                        ),
                                        Divider(
                                          color: style.primaryColor
                                              .withOpacity(.5),
                                        ),
                                        GestureDetector(
                                          onTap: () => helper.copyToClipboard(
                                              settingController
                                                      .cardToCard['card'] ??
                                                  ''),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${settingController.cardToCard['card'] ?? 'inactive'.tr}",
                                                style: style.textHeaderStyle,
                                              ),
                                              if (settingController
                                                      .cardToCard['card'] !=
                                                  null)
                                                IconButton(
                                                    onPressed: () =>
                                                        helper.copyToClipboard(
                                                            settingController
                                                                        .cardToCard[
                                                                    'card'] ??
                                                                ''),
                                                    icon: Icon(
                                                      Icons.copy_all_rounded,
                                                      color: style.primaryColor,
                                                    )),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: style.cardMargin,
                                ),
                                MyTextField(
                                  margin: EdgeInsets.symmetric(
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
                                MyTextField(
                                  margin: EdgeInsets.symmetric(
                                      vertical: style.cardMargin / 4),
                                  icon: Icon(
                                    Icons.credit_card_rounded,
                                    color: style.primaryColor,
                                  ),
                                  textController: cardTextController,
                                  labelText: "${'source_card_number'.tr}",
                                  textInputType: TextInputType.number,
                                  obscure: false,
                                ),
                                MyButton(

                                  label: 'register_request'.tr,
                                  onPressed: () async {
                                    Map res = await userController.cardTocard(
                                        amount: amountTextController.text,
                                        card: cardTextController.text);
                                    if (res['status'] == 'success') {
                                      amountTextController.clear();
                                      cardTextController.clear();
                                    }
                                  },
                                )
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ));
  }
}
