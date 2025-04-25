import 'package:games/widget/AppBar.dart';

import 'package:games/widget/MyRefresh.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../controller/TransactionController.dart';
import '../helper/helpers.dart';
import '../helper/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/filter_transaction.dart';
import '../widget/grid_transaction.dart';
import '../widget/loader.dart';
import '../widget/search_section.dart';

class TransactionsPage extends StatelessWidget {
  late TransactionController controller;
  late MyAnimationController animationController;
  late Style style;
  late SettingController settingController;
  ScrollController scrollController = ScrollController();
  late MaterialColor colors;

  TransactionsPage({Key? key, MaterialColor? colors}) {
    controller = Get.find<TransactionController>();
    settingController = Get.find<SettingController>();
    style = Get.find<Style>();
    this.colors = colors ?? style.primaryMaterial;
    animationController = Get.find<MyAnimationController>();
    scrollController.addListener(() {
      if (scrollController.position.pixels + 50 >
          scrollController.position.maxScrollExtent) {
        if (!controller.loading) {
          controller.getData();
        }
      }
    });
    if (!settingController.appLoaded()) Get.offNamed('/');
    refresh();

    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   Future.delayed(Duration(seconds: 3), () {
    //     Get.to(
    //         ClubDetails(
    //             data: controller.data[0],
    //             controller: controller,
    //             settingController: settingController,
    //             style: style,
    //             colors: colors),
    //         transition: Transition.circularReveal,
    //         duration: Duration(milliseconds: 400));
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// appBar: AppBar(actions: [
//   IconButton(onPressed:()=> showSearch(context: context, delegate: SearchBar()), icon: Icon(Icons.search))
// ]),

      backgroundColor: Colors.transparent,
      body: MyAppBar(
        title: 'transactions'.tr,
        // child:
        // RefreshIndicator(
        //   onRefresh: () => controller.getData(param: {'page': 'clear'}),
        child: SafeArea(
          child: Column(
            children: [
              SearchSection(
                filterSection: TransactionFilterSection(
                  controller: controller,
                ),
                controller: controller,
                hintText: controller.filterController.searchHintText,
              ),
              Expanded(
                child: controller.obx((data) {
                  if (style.gridLength < 2) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            controller: scrollController,
                            padding: EdgeInsets.zero,
                            shrinkWrap: false,
                            itemCount: data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GridTransaction(
                                data: data[index],
                                controller: controller,
                                settingController: settingController,
                                style: style,
                                colors: colors,
                              );
                            },
                          ),
                        ),
                        controller.loading ? Loader() : Center()
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: false,
                            controller: scrollController,
                            itemCount: data!.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: style.gridLength,
                                    childAspectRatio: 1.5),
                            itemBuilder: (BuildContext context, int index) {
                              return GridTransaction(
                                data: data[index],
                                controller: controller,
                                settingController: settingController,
                                style: style,
                                colors: colors,
                              );
                            },
                          ),
                        ),
                        controller.loading ? Loader() : Center()
                      ],
                    );
                  }
                },
                    onEmpty: MyRefresh(
                      onRefresh: refresh,
                    ),
                    onLoading: Loader(
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
        // ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: style.primaryColor,
      //   child: Icon(Icons.add),
      // ),
    );
  }

  void refresh() {
    controller.filterController.set({});
    controller.getData(param: {
      'page': 'clear',
    });
    controller.filterController.change(GetStatus.success(true));
  }
}
