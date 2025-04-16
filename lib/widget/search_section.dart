import 'package:games/controller/TransactionController.dart';

import '../controller/AnimationController.dart';
import '../helper/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchSection extends StatelessWidget {
  TextEditingController textController = TextEditingController();
  dynamic controller;

  MyAnimationController animationController = Get.find<MyAnimationController>();
  Style style = Get.find<Style>();

  Widget filterSection;
  String hintText;

  SearchSection({
    Key? key,
    required this.filterSection,
    required this.controller,
    required this.hintText,
  }) {
    controller.filterController.filters['search'] = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Stack(
          children: [
            //filters section
            Card(
              margin: EdgeInsets.only(
                top: style.cardMargin * 2,
                left: style.cardMargin / 2,
                right: style.cardMargin / 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(style.cardBorderRadius/2),
              ),
              color: Colors.white.withOpacity(.95),
              child: SizeTransition(
                sizeFactor: animationController.animation_height_filter,
                child: Container(
                  padding: EdgeInsets.only(top: style.buttonHeight),
                  child: filterSection,
                ),
              ),
            ),
            //main section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(style.cardBorderRadius/2),
              ),
              child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton.icon(
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.resolveWith(
                                (states) {
                                  return states.contains(MaterialState.pressed)
                                      ? style.secondaryColor
                                      : null;
                                },
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(style.primaryColor),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                    right:
                                        Radius.circular(style.cardMargin )),
                              ))),
                          onPressed: () {
                            animationController.toggleFilterSearch();
                          },
                          icon: Icon(Icons.filter_alt, color: Colors.white),
                          label: Text(
                            'filter'.tr,
                            style: style.textMediumLightStyle,
                          )),
                      VerticalDivider(
                        indent: style.cardMargin / 2,
                        endIndent: style.cardMargin / 2,
                      ),
                      IconButton(
                          onPressed: () =>
                              controller.getData(param: {'page': 'clear'}),
                          icon: Icon(Icons.search,color: style.primaryColor,)),
                    ],
                  ),
                  title: TextField(
                    controller: textController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        hintText: hintText, border: InputBorder.none),
                    onSubmitted: (str) {
                      controller.getData(param: {'page': 'clear'});
                    },
                    // onEditingComplete: () {
                    //   controller.getData(param: {'page': 'clear'});
                    // },

                    onChanged: (str) {
                      controller.filterController.filters['search'] = str;
                      controller.filterController.filters['page'] = '1';
                      animationController.toggleCloseSearchIcon(str.length);
                    },
                  ),
                  trailing: FadeTransition(
                    opacity: animationController.fadeShowController,
                    child: IconButton(
                      splashColor: style.secondaryColor,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        textController.clear();
                        controller.filterController.filters['search'] = '';
                        animationController.toggleCloseSearchIcon(0);

                        controller.getData(param: {'page': 'clear'});
                        // animationController
                        //     .toggleCloseSearchIcon(0);
                        // controller.getData(params: {'page': '1'});
                        // onSearchTextChanged('');
                      },
                    ),
                  )),
            ),
          ],
        ),
        SelectedFiltersSection(
            controller: controller,
            animationController: animationController,
            style: style),
      ],
    ));
  }
}

class SelectedFiltersSection extends StatelessWidget {
  final controller;

  late dynamic filters;
  Style style;
  MyAnimationController animationController;

  SelectedFiltersSection(
      {required this.controller,
      required this.style,
      required this.animationController}) {
    animationController.toggleFilterSearch(open: false);
  }

  @override
  Widget build(BuildContext context) {
    if (controller is TransactionController) {
      return Get.find<TransactionController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                // type != 'type' &&
                type != 'panel' &&
                type != 'category' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList()
            .reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: style.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });
    }
    return Center();
  }

  Widget makeWidget(String type) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: style.cardMargin / 4, vertical: style.cardMargin / 4),
      padding: EdgeInsets.symmetric(horizontal: style.cardMargin / 2),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(.95),
          borderRadius:
              BorderRadius.all(Radius.circular(style.cardBorderRadius/2 / 4))),
      child: Row(
        children: [
          Text(
            type.tr + ' | ' + controller.filterController.getFilterName(type),
            style: style.textSmallStyle.copyWith(
                color: style.primaryColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Shabnam'),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
                onPressed: () {
                  controller.filterController.toggleFilter(type);
                },
                icon: Icon(
                  Icons.clear_rounded,
                  color: style.primaryColor,
                )),
          )
        ],
      ),
    );
  }
}
