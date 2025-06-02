import 'dart:async';

// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:games/controller/SettingController.dart';
import 'package:games/controller/UserController.dart';
import 'package:games/helper/extensions.dart';
import 'package:games/helper/helpers.dart';
import 'package:games/model/Daberna.dart';
import 'package:games/page/room_list.dart';
import 'package:games/widget/AppBar.dart';
import 'package:games/widget/BlinkingSwitch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:games/widget/GlassContainer.dart';
import 'package:games/widget/animateheart.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

import '../helper/styles.dart';
import '../model/User.dart';
import '../widget/Flipper.dart';
import '../widget/MyCallNumber.dart';

class DabernaGame extends StatelessWidget {
  final GlobalKey _tableKey = GlobalKey();
  Style style = Get.find<Style>();
  SettingController setting = Get.find<SettingController>();
  late Daberna daberna;
  RxnDouble _tableWidth = RxnDouble();
  RxInt level = RxInt(-1);
  int winLevel = -1;
  int rowWinLevel = -1;
  RxBool soundOn = RxBool(false);
  late Timer timer;
  late UserController userController;
  bool playing = false;
  late User user;

  // late final AudioPlayer _audioPlayer;
  num winnersPrize = 0;
  num rowWinnersPrize = 0;

  bool mounted = true;

  RxDouble cellSize = 32.0.obs;
  RxBool gameExists = false.obs;
  final player = AudioPlayer();
  final numberController = NumberController();
  ConfettiController confettiController =
      ConfettiController(duration: const Duration(milliseconds: 500));
  late Timer callTimer;
  int playIndex = 0;

  int numberDelayMilli = 1500;

  DabernaGame({super.key}) {
    // _audioPlayer = AudioPlayer();
    userController = Get.find<UserController>();
    user = userController.user;
    // Helper.sendLog({'message': "game ${daberna.id} - player ${user.username}"});
    if (Get.arguments == null) {
      Future.microtask(() => Get.offAllNamed('/'));
      daberna = Daberna.fromJson({'boards': []});
    } else {
      daberna = Get.arguments as Daberna;
      gameExists.value = true;
    }
    soundOn.value =
        Helper.localStorage(key: 'settings.sound', def: 'off') == 'on';

    //move my cards top
    daberna.boards.sort((a, b) {
      if (a.playerId == user.id && b.playerId != user.id) {
        return -1;
      } else if (a.playerId != user.id && b.playerId == user.id) {
        return 1;
      } else {
        return Random().nextInt(2) * 2 - 1;
      }
    });
    //convert numbers to rx
    daberna.boards.forEach((item) {
      item.card = item.card
          .map((row) =>
              row.map((col) => RxString("$col" == "0" ? '' : "$col")).toList())
          .toList();
    });
    daberna.rowWinners.forEach((item) {
      rowWinLevel = item['level'];
      rowWinnersPrize += item['prize'];
      if ("${item['user_id']}" == user.id) {
        userController.updateBalance(int.parse("${item['prize']}"),
            reset: false);
      }
    });

    daberna.winners.forEach((item) {
      winLevel = item['level'];
      winnersPrize += item['prize'];
      if ("${item['user_id']}" == user.id) {
        userController.updateBalance(int.parse("${item['prize']}"),
            reset: false);
      }
    });
    daberna.numbers.insert(0, ' ');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // mounted = true;
      // for (var i = 0; i < 63; i++) {
      //   daberna.boards.forEach((board) {
      //     board.card.forEach((row) {
      //       row.forEach((col) {
      //         if (col.value == "${daberna.numbers[playIndex]}") {
      //           col.value = '';
      //           col.refresh();
      //         }
      //       });
      //     });
      //   });
      //   level.value++;
      //   playIndex++;
      // }
      startTimer();
    });
  }

  startTimer() {
    callTimer =
        Timer.periodic(Duration(milliseconds: numberDelayMilli), (timer) {
      play(playIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvoked: (didPop) async {
          mounted = false;
          player.stop();
          player.dispose();
          confettiController.dispose();
          callTimer.cancel();
          // _audioPlayer.stop();
          // _audioPlayer.dispose();
          Future.delayed(const Duration(seconds: 2),
              () => userController.updateBalance(null));
          RoomListPage.isMounted = true;
          return Future.value(true);
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          body: !gameExists.value
              ? SizedBox()
              : MyAppBar(
                  height: style.tabHeight,
                  header: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: style.cardMargin,
                        vertical: style.cardMargin / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //cards  players count
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${'card_count'.tr}: ",
                                  style: style.textMediumLightStyle,
                                ),
                                Text(
                                  "${daberna.cardCount}",
                                  style: style.textMediumNumberLightStyle,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${'player_count'.tr}: ",
                                  style: style.textMediumLightStyle,
                                ),
                                Text(
                                  "${daberna.playerCount}",
                                  style: style.textMediumNumberLightStyle,
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(
                          width: style.cardMargin,
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'game'.tr,
                              style: style.textMediumLightStyle,
                            ),
                            Text(
                              "${daberna.id}",
                              style: style.textMediumNumberLightStyle,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: style.cardMargin,
                        ),
                        FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          onPressed: toggleSound,
                          child: Obx(() => Image.asset(
                                soundOn.value
                                    ? "assets/images/button_sound_on.png"
                                    : "assets/images/button_sound_off.png",
                              )),
                        ),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      //tab bottom
                      Container(
                        padding: EdgeInsets.all(
                          style.cardMargin / 2,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: style.cardMargin,
                          vertical: style.cardMargin / 2,
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
                            boxShadow: style.mainShadow),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Obx(
                                        () => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(
                                                  style.cardMargin),
                                              decoration: BoxDecoration(
                                                color: style
                                                    .primaryMaterial[700]!
                                                    .withAlpha(100),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        style.cardMargin),
                                              ),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'row_win'.tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: style
                                                          .textTinyLightStyle,
                                                    ),
                                                    VerticalDivider(
                                                      color: Colors.white
                                                          .withAlpha(50),
                                                    ),
                                                    Text(
                                                      overflow:
                                                          TextOverflow.fade,
                                                      "${"${rowWinnersPrize}".asPrice()} ${'currency'.tr}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: style
                                                          .textTinyLightStyle,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: style.cardMargin,
                                            ),
                                            for (var rWinner
                                                in daberna.rowWinners)
                                              Visibility(
                                                visible:
                                                    level.value >= rowWinLevel,
                                                child: Row(
                                                  children: [
                                                    GlassContainer(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              style.cardMargin /
                                                                  2),
                                                      padding: EdgeInsets.all(
                                                          style.cardMargin / 2),
                                                      // decoration: BoxDecoration(
                                                      //   borderRadius:
                                                      //       BorderRadius
                                                      //           .circular(style
                                                      //               .cardMargin),
                                                      //   color: style
                                                      //       .primaryMaterial[
                                                      //           700]!
                                                      //       .withAlpha(100),
                                                      // ),
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          overflow:
                                                              TextOverflow.fade,
                                                          "${rWinner['username']}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: style
                                                              .textSmallLightStyle,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: style.cardMargin,
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: style.cardMargin / 2,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Obx(
                                        () => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(
                                                  style.cardMargin),
                                              decoration: BoxDecoration(
                                                color: style
                                                    .primaryMaterial[700]!
                                                    .withAlpha(100),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        style.cardMargin),
                                              ),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'all_win'.tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: style
                                                          .textTinyLightStyle,
                                                    ),
                                                    VerticalDivider(
                                                      color: Colors.white
                                                          .withAlpha(50),
                                                    ),
                                                    Text(
                                                      overflow:
                                                          TextOverflow.fade,
                                                      "${"${winnersPrize}".asPrice()} ${'currency'.tr}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: style
                                                          .textTinyLightStyle,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: style.cardMargin,
                                            ),
                                            for (var winner in daberna.winners)
                                              Visibility(
                                                visible:
                                                    level.value >= winLevel,
                                                child: Row(
                                                  children: [
                                                    GlassContainer(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              style.cardMargin /
                                                                  2),
                                                      padding: EdgeInsets.all(
                                                          style.cardMargin / 2),
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          overflow:
                                                              TextOverflow.fade,
                                                          "${winner['username']}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: style
                                                              .textSmallLightStyle,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: style.cardMargin,
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //timer
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: MyCallNumber(
                                      textStyle:
                                          style.textHeaderNumberLightStyle,
                                      numberController: numberController),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //cards
                      Expanded(
                          key: _tableKey,
                          child: LayoutBuilder(builder: (ctx, constraints) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final tableWidth =
                                  _tableKey.currentContext?.size?.width;
                              if (tableWidth != _tableWidth.value) {
                                _tableWidth.value = tableWidth ?? 0;
                              }
                            });
                            int rows = daberna.boards[0].card.length;
                            int columns = daberna.boards[0].card[0].length;
                            cellSize = RxDouble(_tableWidth.value != null
                                ? _tableWidth.value! / (columns + 1)
                                : constraints.maxWidth / (columns + 1));
                            cellSize.value = min(cellSize.value, 32);
                            return Obx(() => Column(children: [
                                  if (level.value > winLevel) WinnersWidget(),
                                  Expanded(child: CardsWidget())
                                ]));
                          }))
                    ],
                  ),
                ),
        ));
  }

  Future playSound(index) async {
    // print("${soundOn.value},${daberna.numbers[index]},${mounted}");
    if (soundOn.value && daberna.numbers[index] != ' ' && mounted) {
      final duration = await player.setAsset(// Load a URL
          "assets/sounds/numbers/${daberna.numbers[index]}.mp3");
      player.play();
      // await _audioPlayer.setSource(
      //     AssetSource("sounds/numbers/${daberna.numbers[index]}.mp3"));
      // await _audioPlayer.resume();

      // if (index == 0) await Future.delayed(const Duration(seconds: 2));
      return true;
      // await soloud.stop(handle);
      // await soloud.disposeSource(source);
    }
  }

  void play(index) async {
    if (index > 0) playSound(index);
    if (daberna.numbers.length > index) {
      numberController.change(
          ("${daberna.numbers[index]}".length == 1 ? ' ' : '') +
              "${daberna.numbers[index]}");
      vibrate(index);

      // print("${level.value} ${winLevel}");
      // print("${level.value} ${rowWinLevel}");

      daberna.boards.forEach((board) {
        board.card.forEach((row) {
          row.forEach((col) {
            if (col.value == "${daberna.numbers[index]}") {
              // col.value = ' ';

              col.refresh();
              Future.delayed(Duration(milliseconds: 500), () {
                col.value = '';
                if (daberna.rowWinners
                        .map((r) => "${r['user_id']}")
                        .contains(board.playerId) &&
                    rowWinLevel == index &&
                    row.every((c) => c == '')) {
                  row.forEach((co) => co.value = ' ');
                }
              });

              // col.update((String? val) {
              //   col.value = '';
              //   return '';
              // });
              // col.update((String? val)=>'' );
            }
          });
        });
      });
      level.value++;
      playIndex++;
    } else {
      Future.delayed(Duration(milliseconds: numberDelayMilli), () {
        level.value++;
      });
      callTimer.cancel();
    }

    if (false && level.value >= winLevel) {
      Future.delayed(
          const Duration(seconds: 1),
          () => Get.dialog(
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          margin: EdgeInsets.all(style.cardMargin / 2),
                          padding: EdgeInsets.all(style.cardMargin * 2),
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                            image: DecorationImage(
                                image: AssetImage("assets/images/dialog_2.png"),
                                repeat: ImageRepeat.noRepeat,
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.medium,
                                opacity: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: style.cardMargin * 2,
                                    horizontal: style.cardMargin * 4,
                                  ),
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/frame_button_8.png"),
                                        repeat: ImageRepeat.noRepeat,
                                        fit: BoxFit.fill,
                                        filterQuality: FilterQuality.medium,
                                        opacity: 1),
                                  ),
                                  child: Text(
                                    'winners'.tr,
                                    textAlign: TextAlign.center,
                                    style: style.textHeaderStyle,
                                  ),
                                ),
                              ),
                              Center(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (var key in [
                                        'username',
                                        'card_number',
                                        'prize'
                                      ])
                                        IntrinsicWidth(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.all(
                                                      style.cardMargin),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: style
                                                              .primaryColor),
                                                      color: Colors.grey[300]),
                                                  child: Text(
                                                    (key == 'username'
                                                            ? 'name'
                                                            : key ==
                                                                    'card_number'
                                                                ? 'card'
                                                                : key)
                                                        .tr,
                                                    textAlign: TextAlign.center,
                                                    style: style.textSmallStyle,
                                                  )),
                                              for (var winner
                                                  in daberna.winners +
                                                      daberna.rowWinners)
                                                Container(
                                                    padding: EdgeInsets.all(
                                                        style.cardMargin),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: style
                                                                .primaryColor),
                                                        color: Colors.white),
                                                    child: Text(
                                                      overflow:
                                                          TextOverflow.fade,
                                                      "${winner[key]}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          style.textSmallStyle,
                                                    )),
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                barrierDismissible: true,
              ));
    }
  }

  toggleSound() {
    soundOn.value = !soundOn.value;

    Helper.localStorage(
        key: 'settings.sound', write: soundOn.value ? 'on' : 'off');
  }

  void vibrate(index) async {
    if (kIsWeb || (index != rowWinLevel && index != winLevel)) return;
    if ((await Vibration.hasCustomVibrationsSupport()) ?? false) {
      Vibration.vibrate(duration: 1000);
    } else {
      Vibration.vibrate();
      await Future.delayed(const Duration(milliseconds: 500));
      Vibration.vibrate();
    }
  }

  Widget BoardCell(col, row) {
    // print("${row},${row.every((i) => i.value == '  ' || i.value=='')}");

    return Stack(
      children: [
        Center(
          child: BlinkingSwitch(
            firstChild: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "${col.value}",
                textAlign: TextAlign.center,
                style:
                    style.textMediumNumberStyle.copyWith(color: Colors.black),
              ),
            ),
            secondChild: Container(color: Colors.transparent),
            changeKey: col,
            blinkCount: 3,
            blinkDuration: const Duration(milliseconds: 300),
            fadeDuration: const Duration(milliseconds: 200),
          ),
        ),
        if (row.every((i) => i.value == ' '))
          Container(color: Colors.cyanAccent)
      ],
    );
  }

  Widget Board(board) {
    RxBool winCell = false.obs;
    return Container(
        constraints: BoxConstraints(
            maxWidth: (cellSize.value * (board.card.first.length + 2))),
        margin: EdgeInsets.all(style.cardMargin / 4),
        padding: EdgeInsets.all(style.cardMargin)
            .copyWith(bottom: style.cardMargin * 2),
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(style.cardMargin),
          border: Border.all(
            color: style.primaryColor,
          ),
          color: Colors.white,
          // image: DecorationImage(
          //     image: AssetImage(
          //         "assets/images/frame_button_13.png"),
          //     //dialog_3
          //     repeat: ImageRepeat.noRepeat,
          //     fit: BoxFit.fill,
          //     filterQuality: FilterQuality.medium,
          //     opacity: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(style.cardMargin / 4),
                  // decoration: BoxDecoration(
                  //   color: Colors.grey[300],
                  //   borderRadius: BorderRadius.circular(style.cardMargin),
                  // ),
                  child: Text(
                    board.username,
                    textAlign: TextAlign.center,
                    style: style.textSmallStyle.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(style.cardMargin / 4),
                  // decoration: BoxDecoration(
                  //   color: Colors.gray[300],
                  //   // borderRadius: BorderRadius.circular(style.cardMargin),
                  // ),
                  child: Text(
                    "${'card'.tr} ${board.cardNumber}",
                    textAlign: TextAlign.center,
                    style: style.textSmallStyle.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
            Container(
                padding: EdgeInsets.all(style.cardMargin / 2),
                decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(style.cardMargin),
                    // border: Border.all(
                    //   color: style.primaryColor,
                    // ),
                    // color: style.primaryColor,
                    ),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: board.card.first.length,
                    // Number of columns
                    childAspectRatio: 1, // Makes it square
                  ),
                  itemCount: board.card.length * board.card.first.length,
                  itemBuilder: (context, index) {
                    final rowCount = board.card.length;
                    final colCount = board.card.first.length;

                    // Calculate actual row/col index (reversed column logic)
                    final rowIndex = index ~/ colCount;
                    final colIndex =
                        colCount - 1 - (index % colCount); // reversed

                    final cell = board.card[rowIndex][colIndex];

                    return Container(
                      // margin: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      width: cellSize.value,
                      height: cellSize.value,
                      decoration: BoxDecoration(
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: style.primaryMaterial[400]!.withAlpha(5),
                        //     blurRadius: 2.0,
                        //     spreadRadius: 2,
                        //   ),
                        // ],
                        color: cell.value == ''
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: BoardCell(cell, board.card[rowIndex]),
                    );
                  },
                )),
          ],
        ));
  }

  Widget WinnersWidget() {
    confettiController.play();
    return Stack(
      children: [
        AnimateHeart(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(style.cardMargin),
                padding: EdgeInsets.symmetric(
                    horizontal: style.cardMargin,
                    vertical: style.cardMargin * 3),
                decoration: BoxDecoration(
                  boxShadow: style.mainShadow,
                  color: style.primaryColor,
                  borderRadius: BorderRadius.circular(style.cardMargin),
                  // image: DecorationImage(
                  //   image: AssetImage(
                  //       "assets/images/frame_button.png"),
                  //   repeat: ImageRepeat.noRepeat,
                  //   fit: BoxFit.fill,
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: style.cardMargin * 1,
                          horizontal: style.cardMargin * 2,
                        ).copyWith(top: style.cardMargin),
                        decoration: const BoxDecoration(),
                        child: Text(
                          'winners'.tr,
                          textAlign: TextAlign.center,
                          style: style.textHeaderLightStyle,
                        ),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var key in [
                              'username',
                              'prize',
                              'card_number'
                            ])
                              IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(
                                            style.cardMargin / 2),
                                        padding:
                                            EdgeInsets.all(style.cardMargin),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              style.cardMargin),
                                          // border: Border.all(
                                          //     color: style
                                          //         .primaryColor),
                                          // color: Colors
                                          //         .grey[
                                          //     300]
                                        ),
                                        child: Text(
                                          (key == 'username'
                                                  ? 'name'
                                                  : key == 'card_number'
                                                      ? 'card'
                                                      : key)
                                              .tr,
                                          textAlign: TextAlign.center,
                                          style: style.textSmallStyle.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    for (var winner
                                        in daberna.winners + daberna.rowWinners)
                                      GlassContainer(
                                        margin: EdgeInsets.all(
                                            style.cardMargin / 2),
                                        borderRadius: BorderRadius.circular(
                                            style.cardMargin),
                                        child: Container(
                                            margin: EdgeInsets.all(
                                                style.cardMargin / 2),
                                            padding: EdgeInsets.all(
                                                style.cardMargin),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      style.cardMargin),
                                              // border: Border.all(
                                              //     color: style
                                              //         .primaryColor),
                                              // color:
                                              // Colors.white.withOpacity(.3)
                                            ),
                                            child: Text(
                                              overflow: TextOverflow.fade,
                                              key == 'prize'
                                                  ? "${"${winner[key]}".asPrice()} ${'currency'.tr}"
                                                  : "${winner[key]}",
                                              textAlign: TextAlign.center,
                                              style: style.textSmallLightStyle,
                                            )),
                                      ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: .05,
            // blastDirection: pi / 2,
            shouldLoop: false,
            createParticlePath: _drawStar,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            maxBlastForce: 60,
            // increase for stronger rain
            minBlastForce: 20,
            emissionFrequency: 0.6,
            numberOfParticles: 100,
            gravity: .9,
          ),
        ),
      ],
    );
  }

  Path _drawStar(Size size) {
    // original: https://github.com/zapps-tech/confetti/blob/master/example/lib/custom_shape.dart
    final Path path = Path();
    final double width = size.width;
    final double halfWidth = width / 2;
    final double externalRadius = halfWidth;
    final double internalRadius = halfWidth / 2.5;
    final angle = (2 * pi) / 5;

    for (int i = 0; i < 5; i++) {
      final x = halfWidth + externalRadius * cos(i * angle);
      final y = halfWidth + externalRadius * sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      final x2 = halfWidth + internalRadius * cos(i * angle + angle / 2);
      final y2 = halfWidth + internalRadius * sin(i * angle + angle / 2);
      path.lineTo(x2, y2);
    }

    path.close();
    return path;
  }

  Widget CardsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // for (DabernaBoard board
        //     in daberna.boards.where((item) =>
        //             item.username ==
        //             user.username) ??
        //         [])
        //   Board(board),
        // Container(
        //   height: style.cardMargin,
        //   color: style.primaryColor,
        // ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (DabernaBoard board in daberna.boards
                        .where((item) => item.username == user.username) ??
                    [])
                  Board(board),
                for (DabernaBoard board in daberna.boards
                    .where((item) => item.username != user.username))
                  Board(board),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
