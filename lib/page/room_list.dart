import 'package:cached_network_image/cached_network_image.dart';
import 'package:games/controller/RoomController.dart';
import 'package:games/helper/variables.dart';
import 'package:games/widget/AnimatedButton.dart';
import 'package:games/widget/AppBar.dart';

import 'package:games/widget/animateheart.dart';
import 'package:games/widget/bounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/styles.dart';
import '../model/Room.dart';
import '../model/Ticket.dart';
import '../widget/MyNetworkImage.dart';
import '../widget/MyRefresh.dart';
import '../widget/loader.dart';
import 'room.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';

class RoomListPage extends StatefulWidget {
  RoomListPage({
    Key? key,
  }) : super(key: key) {}

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  late SettingController setting = Get.find<SettingController>();

  late Style style = Get.find<Style>();

  MyAnimationController animationController = Get.find<MyAnimationController>();

  UserController userController = Get.find<UserController>();

  TextEditingController textController = TextEditingController();

  ScrollController scrollController = ScrollController();

  RoomController controller = Get.find<RoomController>();
  Timer? timer;
  var roomGame;
  var roomName;

  @override
  void initState() {
    if (Get.arguments == null) {
      Future.microtask(() => Get.offAllNamed('/'));
    } else {
      roomGame = Get.arguments['type'];
      roomName = Get.arguments['title'];
    }
    print('*****initState');
    if (setting.roomRefreshTime > 0) {
      timer = Timer.periodic(
          Duration(seconds: setting.roomRefreshTime), (Timer t) => refresh());
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      refresh();
      WakelockPlus.disable();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: MyAppBar(
          title: "${'rooms_list'.tr} ${roomName ?? ''}",
          child: controller.obx((rooms) {
            if (rooms == null) return MyRefresh(text: "", onRefresh: refresh());
            return RefreshIndicator(
              onRefresh: () => refresh(),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: false,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  for (Room room in rooms)
                    GestureDetector(
                        child: Container(
                            height: style.imageHeight,
                            margin: EdgeInsets.all(style.cardMargin),
                            padding: EdgeInsets.all(style.cardMargin * 2),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(style.cardMargin),
                                boxShadow: style.mainShadow,
                                gradient: style.cardGradientBackground),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          room.image != ''
                                              ? SizedBox(
                                                  height: style.imageHeight / 2,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        style.cardMargin),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.contain,
                                                      imageUrl: room.image,
                                                    ),
                                                  ),
                                                )
                                              : Center(),
                                          Text(
                                            room.title,
                                            style: style.textHeaderLightStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  AnimateHeart(
                                    repeat: true,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          room.playerCount,
                                          style:
                                              style.textMediumNumberLightStyle,
                                        ),
                                        Text(
                                          'player'.tr,
                                          style: style.textSmallLightStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        onTap: () async {
                          // final res = Get.toNamed('/RoomPage', arguments: room);
                          // final res = Get.toNamed('/RoomPage/${room.type}',
                          //     arguments: room);
                          timer?.cancel();
                          final res =
                              await Get.toNamed(room.page, arguments: room);

                          if (res != null && res == true) {
                            if (setting.roomRefreshTime > 0) {
                              timer = Timer.periodic(
                                  Duration(seconds: setting.roomRefreshTime),
                                  (Timer t) => refresh());
                            } else {
                              refresh();
                            }
                          }
                          //   userController.updateBalance(null);
                        })
                ],
              ),
            );
          },
              onLoading: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Loader(color: Colors.white)]),
              onEmpty: MyRefresh(
                onRefresh: refresh,
              )),
        ),
      ),
    );
  }

  refresh() async {
    // print("timer $mounted ${setting.roomRefreshTime}");
    if (!mounted && setting.roomRefreshTime > 0) {
      timer?.cancel();
      return;
    }
    var data = await controller.getData(param: {'game': roomGame}) ?? [];
    // Get.to(() => RoomPage(room: data[0]));
    // if (data.length > 0) await Get.toNamed(data[0].page, arguments: data[0]);
  }
}
