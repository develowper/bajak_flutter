import 'dart:convert';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:games/controller/RoomController.dart';
import 'package:games/controller/SocketController.dart';
import 'package:games/helper/extensions.dart';
import 'package:games/main.dart';
import 'package:games/widget/AnimatedButton.dart';
import 'package:games/widget/AppBar.dart';
import 'package:games/widget/CircleTimer.dart';
import 'package:games/widget/GlassContainer.dart';
import 'package:games/widget/MyButton.dart';
import 'package:games/widget/MyLoader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:games/widget/animateheart.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/styles.dart';
import '../model/Daberna.dart';
import '../model/Room.dart';
import '../model/Ticket.dart';
import '../widget/MyRefresh.dart';
import '../widget/bounce.dart';
import 'user_profile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class RoomPage extends StatefulWidget {
  late Room room;
  SocketController socket = Get.find<SocketController>();

  RoomPage({
    Key? key,
  }) : super(key: key) {
    WakelockPlus.enable();
    // if (Get.arguments == null) {
    //   Get.toNamed('/');
    //   return;
    // }

    if (Get.arguments == null) {
      Future.microtask(() => Get.offAllNamed('/RoomList'));
      room = Room.fromNull();
    } else {
      room = Get.arguments as Room;
    }
    print("room page ${room?.type}");
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //
    // });
  }

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late SettingController setting = Get.find<SettingController>();

  late Style style = Get.find<Style>();

  MyAnimationController animationController = Get.find<MyAnimationController>();

  UserController userController = Get.find<UserController>();

  TextEditingController textController = TextEditingController();

  ScrollController scrollController = ScrollController();

  RoomController controller = Get.find<RoomController>();

  RxBool loading = RxBool(false);
  RxInt cardCount = RxInt(1);
  RxInt initTimer = RxInt(1);
  RxString userBalance = RxString('0');
  Rx players = Rx([]);

  CountDownController countDownController = CountDownController();
  late Rx room;

  @override
  void initState() {
    print("initState******");
    // if (widget.room == null) {
    //   Get.toNamed('/');
    //   return;
    // }

    room = widget.room.obs;

    initTimer.value = room.value.secondsRemaining;
    userBalance.value = "${userController.user.financial.balance}";
    // print(widget.room.type);
    setSocketListeners();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print("*******didChangeDependencies ${room.value.type}");
    // setSocketListeners();
    refresh();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    leaveRoom();
    // socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, res) async {
        Future.delayed(const Duration(seconds: 2),
            () => userController.updateBalance(null));
        Get.offNamed('/RoomList');
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: MyAppBar(
              title: widget.room?.title ?? '',
              child: Stack(
                children: [
                  Column(
                    children: [
                      GlassContainer(
                        margin: EdgeInsets.all(style.cardMargin),
                        padding: EdgeInsets.all(style.cardMargin),
                        borderRadius: BorderRadius.circular(style.cardMargin),
                        child: Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'buy_card'.tr,
                                      style: style.textHeaderLightStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    Container(
                                      height: style.gridHeight / 2,
                                      padding: EdgeInsets.symmetric(
                                        vertical: style.cardMargin,
                                        horizontal: style.cardMargin * 2,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedButton(
                                            child: Image.asset(
                                                'assets/images/button_right.png'),
                                            onTap: () {
                                              if (cardCount.value <
                                                  (widget.room
                                                          ?.maxUserCardsCount ??
                                                      0)) {
                                                cardCount.value++;
                                              }
                                            },
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: style.cardMargin),
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    style.cardMargin * 4),
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assets/images/frame_cube.png"),
                                                  repeat: ImageRepeat.noRepeat,
                                                  fit: BoxFit.fill,
                                                  filterQuality:
                                                      FilterQuality.medium,
                                                  opacity: 1),
                                            ),
                                            child: Obx(
                                              () => Text(
                                                cardCount.value.toString(),
                                                style:
                                                    style.textHeaderLightStyle,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          AnimatedButton(
                                            child: Image.asset(
                                                'assets/images/button_left.png'),
                                            onTap: () {
                                              if (cardCount.value > 1) {
                                                cardCount.value--;
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyButton(
                                          padding: EdgeInsets.symmetric(
                                            vertical: style.cardMargin * 2,
                                            horizontal: style.cardMargin * 4,
                                          ),
                                          themeId: 10,
                                          label: "pay_*".trParams({
                                            'item':
                                                "${cardCount.value * (widget.room?.cardPrice ?? 0)}"
                                                    .asPrice()
                                          }),
                                          onPressed: () {
                                            payAndJoinRoom();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Obx(() => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin),
                                      child: AnimateHeart(
                                        repeat: true,
                                        child: CircleTimer(
                                            fillColor: Colors.white,
                                            ringColor: Colors.white38,
                                            duration:
                                                room?.value.maxSeconds ?? 0,
                                            initialDuration: initTimer.value,
                                            height: style.tabHeight,
                                            textStyle: style
                                                .textHeaderNumberLightStyle,
                                            controller: countDownController,
                                            onComplete: () {
                                              // if (room.value.startWithMe) {
                                              //   controller.startGame(params: {
                                              //     'roomType': room.value.type
                                              //   });
                                              // }
                                            }),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: style.cardMargin / 2,
                      ),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: style.cardMargin * 2,
                          horizontal: style.cardMargin,
                        ),
                        decoration: BoxDecoration(
                          gradient: style.cardGradientBackgroundReverse,
                          // borderRadius: BorderRadius.vertical(
                          //     top:
                          //         Radius.circular(style.cardBorderRadius * 2))
                          // image: DecorationImage(
                          //     image: AssetImage("assets/images/dialog_2.png"),
                          //     repeat: ImageRepeat.noRepeat,
                          //     fit: BoxFit.fill,
                          //     filterQuality: FilterQuality.medium,
                          //     opacity: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Obx(() => IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "${room?.value.playerCount} ${'player'.tr}",
                                          style: style.textMediumStyle.copyWith(
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        width: style.cardMargin,
                                      ),
                                      VerticalDivider(
                                        color: style.primaryColor.withAlpha(30),
                                      ),
                                      SizedBox(
                                        width: style.cardMargin,
                                      ),
                                      Text(
                                          "${room?.value.cardCount}/${room?.value.maxCardsCount} ${'card'.tr}",
                                          style: style.textMediumStyle.copyWith(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )),
                            Divider(
                              color: style.primaryColor.withAlpha(50),
                            ),
                            if (false)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: style.cardMargin * 2,
                                      horizontal: style.cardMargin * 4,
                                    ),
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/frame_button_1.png"),
                                          repeat: ImageRepeat.noRepeat,
                                          fit: BoxFit.fill,
                                          filterQuality: FilterQuality.medium,
                                          opacity: 1),
                                    ),
                                    child: Text(
                                      'players'.tr,
                                      style: style.textHeaderLightStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            Expanded(
                                child: Obx(
                              () => ListView(
                                children: [
                                  for (RoomPlayer player in room?.value.players)
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(
                                                  style.cardMargin),
                                              margin: EdgeInsets.all(
                                                  style.cardMargin / 3),
                                              decoration: BoxDecoration(
                                                // color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        style.cardBorderRadius),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  if (false)
                                                    Image.asset(
                                                        'assets/images/ok.png',
                                                        height:
                                                            style.cardMargin *
                                                                3),
                                                  SizedBox(
                                                    width: style.cardMargin,
                                                  ),
                                                  Text(
                                                    player.username,
                                                    textAlign: TextAlign.center,
                                                    style: style.textSmallStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  SizedBox(
                                                    width: style.cardMargin,
                                                  ),
                                                  Text(
                                                    '👋🏼',
                                                    style:
                                                        style.textMediumStyle,
                                                  ),
                                                  SizedBox(
                                                    width: style.cardMargin,
                                                  ),
                                                  Text(
                                                      "${player.cardCount} ${'card'.tr}",
                                                      style: style
                                                          .textSmallStyle
                                                          .copyWith(
                                                              color: style
                                                                      .primaryMaterial[
                                                                  400])),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: Get.width / 2,
                                          child: Divider(
                                            color: style.primaryColor
                                                .withAlpha(40),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ))
                          ],
                        ),
                      ))
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }

  setSocketListeners() {
    // socket.init(params: {
    //   "request-room": Get.parameters['type'] ?? room?.value.type,
    //   "user-id": "${userController.user.id}"
    // });
    widget.socket.socket?.clearListeners();
    widget.socket.on('connect', (_) {
      print('connected');
      // socket.emitWithAck("request-room", {'type': widget.room.type}, (data) {
      //   print("ack request room");
      //   print(data);
      // });
    });
    widget.socket.on('error', (_) {
      print('error');
      print(_);
    });

    widget.socket.on('ping', (_) {});
    widget.socket.on('pong', (_) {});
    widget.socket.on('connect_error', (_) {
      print('connect_error');
      print(_);
    });
    widget.socket.on('disconnect', (_) {
      print('disconnect');
      print(_);
    });
    widget.socket.on("request-room-accepted", (_) {
      print("--request-room-accepted ${_}");
    });
    widget.socket.on("user-${userController.user.id}-info", (data) {
      // print("update user info ${data}");
      if (data['user_balance'] != null) {
        userBalance.value = "${data['user_balance']}";
        userController.user.financial.balance =
            int.parse("${data['user_balance']}");
        // userController.refreshUserInfo(
        //     params: {'user_balance': int.parse("${data['user_balance']}")});
      }
    });
    widget.socket.on("room-update", (data) {
      // print("---------room-update ${widget.socket.socket?.id}");
      // print("  ${data}");
      room?.value.players = (jsonDecode(data['players'] ?? '[]'))
          .map<RoomPlayer>((item) => RoomPlayer.fromJson({
                'user_id': item['user_id'],
                'username': item['username'],
                'card_count': item['card_count'],
              }))
          .toList();

      room?.value.playerCount =
          "${data['player_count'] ?? room?.value.playerCount}";
      room?.value.cardCount = "${data['card_count'] ?? room?.value.cardCount}";
      room?.value.userCardCount =
          "${data['user_card_count'] ?? room?.value.userCardCount}";
      room?.value.startWithMe = data['start_with_me'].runtimeType == String
          ? bool.parse(data['start_with_me'])
          : data['start_with_me'];
      room?.refresh();

      data['seconds_remaining'] =
          int.tryParse("${data['seconds_remaining']}") ?? 0;
      if (data['seconds_remaining'] >= 0) {
        if (mounted) {
          // initTimer.value = data['seconds_remaining'];
          countDownController.restart(duration: data['seconds_remaining']);
        }
      }
    });
    widget.socket.on("game-start", (data) {
      // print("---------game-start ${socket.socket}");
      // print("  ${data}");

      controller.startGame(daberna: Daberna.fromJson(data));
    });
  }

  refresh() async {
    // print("*****refresh");
    List<Room> data =
        await controller.find(param: {'id': room?.value.id}) ?? [];

    if (data.length > 0) room?.value = data[0];

    if ((room?.value.secondsRemaining ?? 0) > 0) {
      countDownController.restart(duration: room?.value.secondsRemaining);
    }
    // print("============${userController.user.id}");
    joinRoom();
    // socket.connect();
  }

  leaveRoom() {
    if (widget.room.type != null) {
      widget.socket.emit('leave-room',
          {'type': widget.room.type, 'user_id': userController.user.id});
    }
  }

  joinRoom() {
    if (widget.room.type != null) {
      widget.socket.emit('join-room',
          {'type': widget.room.type, 'user_id': userController.user.id});
    }
  }

  payAndJoinRoom() async {
    loading.value = true;
    var res = await controller.payAndJoinRoom(
        roomType: widget.room?.type ?? '', cardCount: cardCount.value);
    loading.value = false;
    if (res?['user_balance'] != null) {
      userController.updateBalance(int.parse("${res['user_balance']}"),
          reset: true);
      userBalance.value = "${res['user_balance']}";
      userController.user.financial.balance =
          int.parse("${res['user_balance']}");
    }
  }
}
