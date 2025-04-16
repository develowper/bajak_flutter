import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../controller/TransactionController.dart';
import '../helper/styles.dart';
import 'filter_widgets.dart';

class TransactionFilterSection extends StatelessWidget {
  final TransactionController controller;
  late MyTabController tabController;

  final MyAnimationController animationController =
      Get.find<MyAnimationController>();
  final Style style = Get.find<Style>();
  final SettingController settingController = Get.find<SettingController>();

  TransactionFilterSection({required this.controller}) {
    tabController = MyTabController(length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return controller.filterController.obx(
      (data) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: Get.height * 2 / 3),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: style.cardMargin * 2,
                ),
                Center(
                  child: MyToggleButtons(
                    type: 'type',
                    controller: controller.filterController,
                    style: style,
                    children: [
                      Container(
                          padding: EdgeInsets.all(style.cardMargin),
                          child: Text('win'.tr)),
                      Container(
                          padding: EdgeInsets.all(style.cardMargin),
                          child: Text('charge'.tr)),
                      Container(
                          padding: EdgeInsets.all(style.cardMargin),
                          child: Text('withdraw'.tr)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(style.cardMargin),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextButton.icon(
                              style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          vertical: style.cardMargin)),
                                  elevation: WidgetStateProperty.all(10),
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      return states
                                              .contains(WidgetState.pressed)
                                          ? style.secondaryColor
                                          : null;
                                    },
                                  ),
                                  backgroundColor: WidgetStateProperty.all(
                                      style.primaryColor),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(
                                            style.cardBorderRadius * 2)),
                                  ))),
                              onPressed: () {
                                controller.getData(param: {'page': 'clear'});
                              },
                              icon: Padding(
                                padding: EdgeInsets.all(style.cardMargin),
                                child: const Icon(Icons.search,
                                    color: Colors.white),
                              ),
                              label: Text(
                                'search'.tr,
                                style: style.textMediumLightStyle,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton.icon(
                              style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          vertical: style.cardMargin)),
                                  elevation: WidgetStateProperty.all(10),
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      return states
                                              .contains(WidgetState.pressed)
                                          ? style.secondaryColor
                                          : null;
                                    },
                                  ),
                                  backgroundColor: WidgetStateProperty.all(
                                      style.primaryColor),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(
                                            style.cardBorderRadius * 2)),
                                  ))),
                              onPressed: () {
                                animationController.toggleFilterSearch();
                              },
                              icon: Padding(
                                padding: EdgeInsets.all(style.cardMargin),
                                child: const Icon(Icons.arrow_upward,
                                    color: Colors.white),
                              ),
                              label: Text('close'.tr)),
                        ),
                      ],
                    ),
                  ),
                ),
                // TabBar(
                //     indicatorWeight: 2,
                //     unselectedLabelColor: style.primaryColor,
                //     overlayColor:
                //         MaterialStateProperty.all(style.primaryColor),
                //     unselectedLabelStyle: style.textMediumStyle
                //         .copyWith(fontFamily: 'Shabnam'),
                //     labelColor: Colors.white,
                //     indicator: BoxDecoration(color: style.primaryColor),
                //     controller: tabController.controller,
                //     tabs: [
                //       Tab(
                //         child: Text('sex'.tr),
                //       ),
                //       Tab(
                //         child: Text('man'.tr),
                //       ),
                //       Tab(
                //         child: Text('woman'.tr),
                //       ),
                //     ])
              ],
            ),
          ),
        );
      },
      onLoading: const Center(),
    );
  }
}
