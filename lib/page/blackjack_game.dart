import 'dart:async';
import 'dart:convert';

// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:games/controller/SettingController.dart';
import 'package:games/controller/SocketController.dart';
import 'package:games/controller/UserController.dart';
import 'package:games/helper/extensions.dart';
import 'package:games/helper/helpers.dart';
import 'package:games/model/Daberna.dart';
import 'package:games/widget/AppBar.dart';
import 'package:games/widget/BlinkingSwitch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:games/widget/MyDialog.dart';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

import '../controller/BlackJackController.dart';
import '../controller/DoozController.dart';
import '../helper/styles.dart';
import '../model/Room.dart';
import '../model/User.dart';
import '../widget/AnimatedButton.dart' show AnimatedButton;
import '../widget/CircleTimer.dart';
import '../widget/FadeInOut.dart';
import '../widget/Flipper.dart';
import '../widget/MyNativeAdv.dart';
import '../widget/RowOverlap.dart';
import '../widget/blinkanimation.dart';
import '../widget/bounce.dart';
import '../widget/loader.dart';

enum GAME_STATUS {
  FINDING,
  INGAME,
}

class BlackJackGame extends StatefulWidget {
  late UserController userController;
  late BlackJackController gameController;
  late SocketController socketController;
  late Style style;
  late SettingController setting;

  late Helper helper;
  late User user;
  CountDownController countDownController = CountDownController();

  var timer;

  var nativeAd;
  late Map audioSources;
  final player = AudioPlayer();

  BlackJackGame({super.key}) {
    // _audioPlayer = AudioPlayer();
    userController = Get.find<UserController>();
    gameController = Get.find<BlackJackController>();
    setting = Get.find<SettingController>();
    socketController = Get.find<SocketController>();
    style = Get.find<Style>();

    helper = Get.find<Helper>();
    user = userController.user;
    timer = CircleTimer(
        strokeWidth: style.cardMargin / 2,
        fillColor: Colors.white,
        ringColor: Colors.white,
        textStyle: style.textMediumLightStyle,
        duration: 0,
        initialDuration: 0,
        height: style.buttonHeight * 2 / 3,
        controller: countDownController,
        onComplete: () {
          // if (room.value.startWithMe) {
          //   controller.startGame(params: {
          //     'roomType': room.value.type
          //   });
          // }
        });
    nativeAd = MyNativeAdv(
      type: AdvType.BANNER,
      failWidget: Center(
        child: Container(
          width: style.gridHeight / 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(style.cardMargin)),
            image: DecorationImage(
              image: AssetImage("assets/images/seat.png"),
              repeat: ImageRepeat.noRepeat,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );

    audioSources = {
      'chick': AudioSource.asset("assets/sounds/chick.mp3"),
      'flip': AudioSource.asset("assets/sounds/flip.mp3"),
    };
  }

  @override
  State<BlackJackGame> createState() => _BlackJackGameState();
}

class _BlackJackGameState extends State<BlackJackGame>
    with SingleTickerProviderStateMixin {
  final GlobalKey _tableKey = GlobalKey();

  RxnDouble _tableWidth = RxnDouble();

  RxInt level = RxInt(-1);
  bool backPressed = false;

  Rx<GAME_STATUS> status = Rx(GAME_STATUS.FINDING);

  int winLevel = -1;

  int rowWinLevel = -1;

  RxBool soundOn = RxBool(false);

  late Timer timer;

  bool playing = false;

  // late final AudioPlayer _audioPlayer;
  num winnersPrize = 0;

  num rowWinnersPrize = 0;

  RxDouble cellSize = 50.0.obs;
  RxDouble gridSize = 50.0.obs;

  RxBool gameExists = false.obs;

  Rx game = Rx(null);

  Rx winnerId = Rx(null);
  late AnimationController _animationController;
  late List<Animation<Offset>> _offsetAnimation;
  var meImg, opImg;
  final GlobalKey _gridKey = GlobalKey();

  var state;

  // print(state?['board']);
  var board;

  var move;
  bool isInsideMove = false;

  var cols;

  Rx action = Rx(null);
  RxList prizes = RxList([]);

  var turnId;

  var p1Id;
  var p2Id;
  var p3Id;
  var p4Id;
  Rx meInGame = false.obs;

  Rx p1Info = Rx(null);
  Rx p2Info = Rx(null);
  Rx p3Info = Rx(null);
  Rx p4Info = Rx(null);

  Rx p1Action1 = Rx(null);
  Rx p1Action2 = Rx(null);
  Rx p2Action1 = Rx(null);
  Rx p2Action2 = Rx(null);
  Rx p3Action1 = Rx(null);
  Rx p3Action2 = Rx(null);
  Rx p4Action1 = Rx(null);
  Rx p4Action2 = Rx(null);
  Rx dealerInfo = Rx(null);

  Rx p1Section1Width = Rx(0);
  Rx p1Section2Width = Rx(0);
  RxDouble left1 = RxDouble(0);
  RxDouble left2 = RxDouble(0);

  Rx p1Section1Turn = Rx(false);
  Rx p1Section2Turn = Rx(false);

  var meId;

  var opId;

  var meInfo;

  var opInfo;

  var moveFrom = null;
  bool turnMe = false;
  Rx<List> blinks = Rx([]);
  var asset = List.generate(7, (index) => index + 1)..shuffle(Random());
  Rx actionTitle = Rx('');
  List circles = [];

  double circleSize = 50.0;

  var roomType;
  bool gameConnected = false;
  RxInt meBet1 = 0.obs;
  RxInt meBet2 = 0.obs;
  Rx<int?> secondsRemaining = 0.obs;
  RxMap meCoins1 = RxMap({});
  RxMap meCoins2 = RxMap({});
  Rx gameText = Rx('');

  @override
  void dispose() {
    print("-----dispose blackjack--${roomType}---");
    widget.player.dispose();

    leaveAll();
    // widget.socketController.disconnect();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    soundOn.value =
        true || Helper.localStorage(key: 'settings.sound', def: 'off') == 'on';

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _offsetAnimation = List.generate(
      2,
      (index) => Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: Offset(index == 0 ? 1 : -1, 0.0),
      ).animate(_animationController),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setSocketListeners();
      findGame();
    });
    meId = int.parse('${widget.user.id}');
    print('---------init blackjack State--user ${meId}----');

    super.initState();
  }

  void _animate() {
    _animationController.status == AnimationStatus.completed
        ? _animationController.reverse()
        : _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, dynamic) async {
          backPressed = true;
          widget.player.stop();
          widget.player.dispose();

          Future.delayed(const Duration(seconds: 2),
              () => widget.userController.updateBalance(null));

          return Future.value(true);
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          body: MyAppBar(
            // height: widget.style.tabHeight,
            header: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    // textDirection: TextDirection.ltr,
                    children: [
                      Text(
                        widget.user.username,
                        style: widget.style.textHeaderLightStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: widget.style.iconHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.style.cardMargin * 4,
                                vertical: widget.style.cardMargin,
                              ),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/frame_button_9.png"),
                                    repeat: ImageRepeat.noRepeat,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.medium,
                                    opacity: 1),
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    widget.userController.updateBalance(null),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(
                                      () => Text(
                                        meInGame.value
                                            ? "${p1Info.value?['balance']}"
                                                .asPrice()
                                            : "${"${widget.user.financial.balance}".asPrice()}",
                                        style: widget.style.textMediumLightStyle
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: widget.style.cardMargin,
                                    ),
                                    Image.asset('assets/images/money.png'),
                                  ],
                                ),
                              ),
                            ),
                            // Image.asset('assets/images/money.png'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                //game id circle
                Expanded(
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          margin:
                              EdgeInsets.only(top: widget.style.cardMargin / 2),
                          height: widget.style.imageHeight / 2,
                          width: widget.style.imageHeight / 2,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/frame_cube.png"),
                              repeat: ImageRepeat.noRepeat,
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: widget.style.cardMargin / 2),
                            child: Text(
                              'id'.tr,
                              textAlign: TextAlign.center,
                              style: widget.style.textTinyLightStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Obx(
                              () => Text(
                                "${game.value?['id'] ?? ''}",
                                style: widget.style.textMediumLightStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            child:
                Obx(() => game.value != null ? GameBoard() : FindGameWidget()),
          ),
        ));
  }

  Future playSound(sound) async {
    if (!kIsWeb && soundOn.value && !backPressed && mounted) {
      // final duration = await player.setAsset(// Load a URL
      //     "assets/sounds/$sound.mp3");
      widget.player.setAudioSource(widget.audioSources[sound]);
      widget.player.play();
      // print('----');
      // widget.players[sound]?.play();
      // await _audioPlayer.setSource(
      //     AssetSource("sounds/numbers/${daberna.numbers[index]}.mp3"));
      // await _audioPlayer.resume();

      // if (index == 0) await Future.delayed(const Duration(seconds: 2));
      return true;
      // await soloud.stop(handle);
      // await soloud.disposeSource(source);
    }
  }

  void play(params) async {
    if (winnerId.value != null) return;
    playSound('flip');
    print('play ${params}');
    // await animateCell(move);

    var res = await widget.gameController
        .play(params: {'game_id': game.value['id'], ...params ?? {}});

    if (res?['message'] != null)
      widget.helper.showToast(msg: res?['message'], status: res?['status']);
    if (res?['game'] != null) {
      game.value = res?['game'];
      initGame();
    }
    // print(res);

// vibrate(index);
// level.value++;
// print("${level.value} ${winLevel}");
// print("${level.value} ${rowWinLevel}");
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

  Future animateCell(move) async {
    print("animate $move");
    if (move == null || move == [-1, -1]) return;
    var fromRow = move[0] ?? 0 ~/ cols;
    var fromCol = (move[0] ?? 0 % cols);
    var toRow = (move[1] ?? 0) ~/ cols;
    var toCol = (move[1] ?? 0) % cols;
    // print("$toRow,$toCol");
    if (![null, -1].contains(move[0]) &&
        ![null, -1].contains(move[1]) &&
        !circles.isEmpty) {
      circles[move[0]]['row'].value = toRow;
      circles[move[0]]['col'].value = toCol;
      // circles[move[1]] = circles[move[0]];
      await Future.delayed(Duration(milliseconds: 500));
      // print(
      //     "${circles[move[0]]['row'].value},${circles[move[0]]['col'].value}");
    }
    // if (![null, -1].contains(move[1])) {
    //   // if (move[0] != -1) {
    //   //   circles[move[0]]['top'] = fromRow * cellSize.value + widget.style.cardMargin;
    //   //   circles[move[0]]['left'] = fromCol * cellSize.value + widget.style.cardMargin;
    //   // }
    //   //move from out
    //   circles[move[1]]['row'].value = toRow;
    //   circles[move[1]]['col'].value = toCol;
    //   circles[move[1]]['col'].refresh();
    //   print(
    //       "${circles[move[1]]['row'].value},${circles[move[1]]['col'].value}");
    // }
    // print("$fromRow,$fromCol $toRow,$toCol");
  }

  void setSocketListeners() {
    widget.socketController.on('connect', (data) {
      print('###onConnect ${data}');
      print('is coneected ${widget.socketController.connected()}');
      // print(' connect game ${game.value?['id']}');

      if (widget.socketController.connected()) {
        if (game.value == null) findGame();
      }
      // leaveGame(game.value?['id']);
      // joinGame(game.value?['id']);
    });

    widget.socketController.onReconnect((data) {
      print('@@@@reconnect game ${game.value?['id']}');
// joinGame(gameId);
//       if (game.value == null) findGame();
    });
    widget.socketController.onDisconnect((data) {
      print('----disconnected game ${game.value?['id']}');
      gameConnected = false;
      game.value = null;
    });
    widget.socketController.on('joined-room', (data) {
      print('>>>joined room<<<');
      // print(data);
      // socketController.emitWithAck('leave-room', data, (data) {});
    });
    widget.socketController.on('left-room', (data) {
      print('<<<left room>>>');
      print(data);
    });
    widget.socketController.on('joined-blackjack', (data) {
      if (data == null) return;
      gameConnected = true;
      print('+++joined blackjack+++');
      print(data);
      game.value = data;
      status.value = GAME_STATUS.INGAME;
      initGame();
      // print(game.value);
    });
    widget.socketController.on('left-blackjack', (data) {
      print('left blackjack');
      gameConnected = false;
      print(data);
    });
    widget.socketController.on('game-start', (data) {
      if ('${data['p1']}' == widget.user.id ||
          '${data['p2']}' == widget.user.id) {
        print('---game start---');
        joinGame(data['id']);
      }
    });
    widget.socketController.on('blackjack-update', (data) {
      print('---blackjack-update---${data?['game']?['id']}');

      if (data?['game'] != null) {
        game.value = data?['game'];

        initGame();
      }
    });
  }

  void findGame({params}) async {
    roomType = Get.arguments?.type;
    print('**blackjack finding** ${roomType}');
    game.value = null;
    if (roomType == null) {
      Get.offNamed('/');
      return;
    }
    // leaveAll();
    // status.value = GAME_STATUS.FINDING;

    if (game.value != null) return;
    var res = await widget.gameController
        .find(params: {'room_type': roomType, ...params ?? {}});
    print(res);
    // print(res?['status']);
    if (res?['game'] != null && res?['status'] == 'success') {
      game.value = res?['game'];
      joinGame(res?['game']['id']);

      initGame();
    } else if (res?['message'] != null) {
      // game.value = res['game'];
      Future.delayed(
          const Duration(seconds: 1),
          () =>
              widget.helper.showToast(msg: res?['message'], status: 'danger'));
      Get.back();
    }
  }

  joinRoom() {
    if (roomType != null) {
      print("**********joining room ${roomType}");
      widget.socketController
          .emit('join-room', {'type': roomType, 'user-id': widget.user.id});
    }
  }

  joinGame(gameId) {
    if (gameId != null) {
      print("**********joining game ${gameId}");
      widget.socketController
          .emit('join-blackjack', {'id': gameId, 'user-id': widget.user.id});
    }
  }

  leaveGame(gameId) {
    if (gameId != null) {
      print("**********leaving game ${gameId}");
      widget.socketController.emit('leave-blackjack', {'id': gameId});
    }
  }

  leaveRoom() {
    if (roomType != null) {
      widget.socketController
          .emit('leave-room', {'type': roomType, 'user_id': widget.user.id});
    }
  }

  leaveAll() {
    print("------leave all---");
    widget.socketController.socket?.clearListeners();
    // widget.socketController.socket?.offAny((_, __) {
    //   print("off");
    //   print(_);
    //   print(__);
    // });
    // leaveRoom();
    leaveGame(game.value?['id']);
  }

  Widget FindGameWidget({error}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: Get.width / 2, child: Loader(color: Colors.white)),
        Text(
          'finding_game'.tr,
          style: widget.style.textHeaderLightStyle,
        ),
        AnimatedButton(
          child: Container(
            width: Get.width / 2,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: widget.style.cardMargin),
            padding: EdgeInsets.all(widget.style.cardMargin),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/frame_button_4.png"),
                  repeat: ImageRepeat.noRepeat,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                  opacity: 1),
            ),
            child: Text(
              'return'.tr,
              style: widget.style.textHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            leaveAll();
            Get.back();
          },
        ),
      ],
    );
  }

  Widget GameBoard() {
    print("-----GameBoard-------");

    return Obx(
      () => Column(
        children: [
          Expanded(
              child: Stack(fit: StackFit.expand, children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/blackjack_table.png"),
                  repeat: ImageRepeat.noRepeat,
                  fit: BoxFit.fill,
                ),
              ),
            ),

            Positioned(
              top: Get.height / 20,
              // bottom:  Get.height / 4,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //dealer
                  Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (game.value['id'] == null)
                                AnimatedButton(
                                  child: Container(
                                    width: widget.style.gridHeight / 3,
                                    height: widget.style.gridHeight / 3,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: widget.style.cardMargin),
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/button_question.png"),
                                        repeat: ImageRepeat.noRepeat,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    showHelpDialog();
                                  },
                                ),
                              CircleAvatar(
                                radius: widget.style.gridHeight / 6,
                                backgroundImage:
                                    AssetImage("assets/images/dealer.png"),
                              ),
                              if (secondsRemaining.value != null)
                                Padding(
                                  padding:
                                      EdgeInsets.all(widget.style.cardMargin),
                                  child: widget.timer,
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var card in dealerInfo.value?['cards'] ?? [])
                                Container(
                                  margin: EdgeInsets.all(
                                      widget.style.cardMargin / 4),
                                  height: widget.style.gridHeight / 2,
                                  width: widget.style.gridHeight / 3,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: card == ''
                                        ? Border.all(
                                            width: 1.0,
                                            color: Colors.white,
                                          )
                                        : null,
                                    boxShadow: card == ''
                                        ? null
                                        : const [
                                            BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 2,
                                              color: Colors.black12,
                                            ),
                                          ],
                                    borderRadius: BorderRadius.circular(
                                        widget.style.cardMargin / 2),
                                    image: card == ''
                                        ? null
                                        : DecorationImage(
                                            image: AssetImage(
                                                "assets/images/cards/${card}.png"),
                                            repeat: ImageRepeat.noRepeat,
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var sum in dealerInfo.value?['sum'] ?? [])
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: widget.style.cardMargin / 2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black38,
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Text(
                                    "$sum",
                                    style: widget.style.textSmallLightStyle,
                                  ),
                                ),
                            ],
                          ),
                          //join game button
                          if (!meInGame.value && action.value == null ||
                              action.value == 'done')
                            AnimatedButton(
                              child: IntrinsicWidth(
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: widget.style.cardMargin),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: widget.style.cardMargin * 2,
                                      vertical: widget.style.cardMargin),
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/frame_button_10.png"),
                                      repeat: ImageRepeat.noRepeat,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Text(
                                    'new_game'.tr,
                                    style: widget.style.textHeaderLightStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              onTap: () {
                                findGame(params: {'cmnd': 'join'});
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (action.value == 'done') WinnersBoard(),
                  if (action.value == 'sparing_cards')
                    Text(
                      'sparing_cards'.tr,
                      style: widget.style.textHeaderLightStyle,
                      textAlign: TextAlign.center,
                    ),
                  if (meInGame.value)
                    if ((action.value == 'user_decision' &&
                            (p1Action1.value == 'decision' ||
                                p1Action2.value == 'decision')) ||
                        (action.value == 'bet' && p1Info.value['bet1'] == 0))
                      IntrinsicWidth(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: widget.style.cardMargin),
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.style.cardMargin * 2,
                              vertical: widget.style.cardMargin),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/frame_button_6.png"),
                              repeat: ImageRepeat.noRepeat,
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (gameText.value != '')
                                Text(
                                  gameText.value,
                                  style: widget.style.textMediumLightStyle,
                                  textAlign: TextAlign.center,
                                ),
                              if (p1Section1Turn.value || p1Section2Turn.value)
                                Column(
                                  children: [
                                    Text(
                                      'select_action'.tr,
                                      style: widget.style.textHeaderLightStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      spacing: widget.style.cardMargin / 2,
                                      children: [
                                        if (p1Section1Turn.value)
                                          for (var action
                                              in p1Info.value['allowed1'] ?? [])
                                            AnimatedButton(
                                              onTap: () =>
                                                  play({'cmnd': "${action}1"}),
                                              child: Container(
                                                height: widget.style.iconHeight,
                                                width: widget.style.iconHeight,
                                                decoration: BoxDecoration(
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      spreadRadius: 2,
                                                      blurRadius: 2,
                                                      color: Colors.black12,
                                                    ),
                                                  ],
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/actions/${action}.png"),
                                                    repeat:
                                                        ImageRepeat.noRepeat,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        if (p1Section2Turn.value)
                                          for (var action
                                              in p1Info.value['allowed2'] ?? [])
                                            AnimatedButton(
                                              onTap: () =>
                                                  play({'cmnd': "${action}2"}),
                                              child: Container(
                                                height: widget.style.iconHeight,
                                                width: widget.style.iconHeight,
                                                decoration: BoxDecoration(
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      spreadRadius: 2,
                                                      blurRadius: 2,
                                                      color: Colors.black12,
                                                    ),
                                                  ],
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/actions/${action}.png"),
                                                    repeat:
                                                        ImageRepeat.noRepeat,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              if (action == 'bet' && p1Info.value['bet1'] == 0)
                                //select coins
                                Column(
                                  children: [
                                    Text(
                                      'select_bet_amount'.tr,
                                      style: widget.style.textHeaderLightStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: widget.style.cardMargin,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      spacing: widget.style.cardMargin,
                                      children: [
                                        for (var coin in widget.setting.coins)
                                          AnimatedButton(
                                            child: Container(
                                              height: widget.style.iconHeight,
                                              width: widget.style.iconHeight,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "assets/images/coins/${coin}.png"),
                                                  repeat: ImageRepeat.noRepeat,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            onTap: () => setBet(coin),
                                          ),
                                        AnimatedButton(
                                          child: Container(
                                            height: widget.style.iconHeight,
                                            width: widget.style.iconHeight,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/button_cancel.png"),
                                                repeat: ImageRepeat.noRepeat,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          onTap: () => setBet(0),
                                        ),
                                        AnimatedButton(
                                          child: Container(
                                            height: widget.style.iconHeight,
                                            width: widget.style.iconHeight,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/button_ok.png"),
                                                repeat: ImageRepeat.noRepeat,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          onTap: () => play({
                                            'cmnd': 'bet',
                                            'amount': meBet1.value
                                          }),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
            //player1 (me)
            Positioned(
              bottom: widget.style.cardMargin,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //player1   section 1
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: widget.style.cardMargin),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IntrinsicWidth(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // player1 coins 1
                                        if (meCoins1.value.length > 0)
                                          Container(
                                            // width: p1Section1Width.value,
                                            margin: EdgeInsets.symmetric(
                                                vertical:
                                                    widget.style.cardMargin /
                                                        4),
                                            constraints: BoxConstraints(
                                                minHeight:
                                                    widget.style.gridHeight /
                                                        3),
                                            padding: EdgeInsets.all(
                                                widget.style.cardMargin / 4),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1.0,
                                                color: Colors.white,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      widget.style.cardMargin /
                                                          2),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  children: [
                                                    for (var coin
                                                        in meCoins1.value.keys)
                                                      Column(
                                                        children: [
                                                          Text(
                                                            "${meCoins1.value[coin]}",
                                                            style: widget.style
                                                                .textTinyLightStyle,
                                                          ),
                                                          Container(
                                                            height: widget.style
                                                                    .iconHeight /
                                                                2,
                                                            width: widget.style
                                                                    .iconHeight /
                                                                2,
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: AssetImage(
                                                                    "assets/images/coins/${coin}.png"),
                                                                repeat:
                                                                    ImageRepeat
                                                                        .noRepeat,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                                Text(
                                                  "${meBet1.value}".asPrice(),
                                                  style: widget.style
                                                      .textSmallLightStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        // player1 cards 1
                                        Column(children: [
                                          SizedBox(
                                            height: widget.style.gridHeight / 2,
                                            width: p1Section1Width.value,
                                            child: RowOverlap(
                                              maxSpacing:
                                                  widget.style.gridHeight / 3,
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        (p1Info.value?[
                                                                    'cards1'] ??
                                                                [])
                                                            .length;
                                                    i++)
                                                  Container(
                                                    height: widget
                                                            .style.gridHeight /
                                                        2,
                                                    width: widget
                                                            .style.gridHeight /
                                                        3,
                                                    decoration: BoxDecoration(
                                                      border: p1Info.value?[
                                                                      'cards1']
                                                                  [i] ==
                                                              ''
                                                          ? Border.all(
                                                              width: 1.0,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          : null,
                                                      boxShadow: p1Info.value?[
                                                                      'cards1']
                                                                  [i] ==
                                                              ''
                                                          ? null
                                                          : const [
                                                              BoxShadow(
                                                                spreadRadius: 2,
                                                                blurRadius: 2,
                                                                color: Colors
                                                                    .black12,
                                                              ),
                                                            ],
                                                      borderRadius: BorderRadius
                                                          .circular(widget.style
                                                                  .cardMargin /
                                                              2),
                                                      image: p1Info.value?[
                                                                      'cards1']
                                                                  [i] ==
                                                              ''
                                                          ? null
                                                          : DecorationImage(
                                                              image: AssetImage(
                                                                  "assets/images/cards/${p1Info.value?['cards1'][i]}.png"),
                                                              repeat:
                                                                  ImageRepeat
                                                                      .noRepeat,
                                                              fit: BoxFit.fill,
                                                            ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  widget.style.cardMargin / 2),
                                          //sum 1
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              for (var sum
                                                  in p1Info.value?['sum1'] ??
                                                      [])
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: widget.style
                                                              .cardMargin /
                                                          2),
                                                  margin: EdgeInsets.all(
                                                      widget.style.cardMargin /
                                                          4),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.black38,
                                                    border: Border.all(
                                                      width: 1.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "$sum",
                                                    style: widget.style
                                                        .textSmallLightStyle,
                                                  ),
                                                ),
                                            ],
                                          )
                                        ])
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (p1Section1Turn.value)
                              FadeInOut(
                                child: Container(
                                  // width: widget.style.gridHeight,
                                  height: widget.style.gridHeight,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: widget.style.cardMargin),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.white.withAlpha(150),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        widget.style.cardMargin / 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      //player1 section2
                      if ((p1Info.value?['cards2'] ?? []).length > 0)
                        Expanded(
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: widget.style.cardMargin),
                                child: Row(
                                  children: [
                                    IntrinsicWidth(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // player1 coins 2
                                          if (meCoins2.value.length > 0)
                                            Container(
                                              // width: p1Section2Width.value,
                                              margin: EdgeInsets.symmetric(
                                                  vertical:
                                                      widget.style.cardMargin /
                                                          4),
                                              constraints: BoxConstraints(
                                                  minHeight:
                                                      widget.style.gridHeight /
                                                          3),
                                              padding: EdgeInsets.all(
                                                  widget.style.cardMargin / 4),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1.0,
                                                  color: Colors.white,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(widget
                                                            .style.cardMargin /
                                                        2),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: [
                                                      for (var coin in meCoins2
                                                          .value.keys)
                                                        Column(
                                                          children: [
                                                            Text(
                                                              "${meCoins2.value[coin]}",
                                                              style: widget
                                                                  .style
                                                                  .textTinyLightStyle,
                                                            ),
                                                            Container(
                                                              height: widget
                                                                      .style
                                                                      .iconHeight /
                                                                  2,
                                                              width: widget
                                                                      .style
                                                                      .iconHeight /
                                                                  2,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      "assets/images/coins/${coin}.png"),
                                                                  repeat: ImageRepeat
                                                                      .noRepeat,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "${meBet2.value}".asPrice(),
                                                    style: widget.style
                                                        .textSmallLightStyle,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          //player1 cards 2
                                          Column(children: [
                                            SizedBox(
                                              height:
                                                  widget.style.gridHeight / 2,
                                              width: p1Section2Width.value,
                                              child: RowOverlap(
                                                maxSpacing:
                                                    widget.style.gridHeight / 3,
                                                children: [
                                                  for (int i = 0;
                                                      i <
                                                          (p1Info.value?[
                                                                      'cards2'] ??
                                                                  [])
                                                              .length;
                                                      i++)
                                                    Container(
                                                      height: widget.style
                                                              .gridHeight /
                                                          2,
                                                      width: widget.style
                                                              .gridHeight /
                                                          3,
                                                      decoration: BoxDecoration(
                                                        border: p1Info.value?[
                                                                        'cards2']
                                                                    [i] ==
                                                                ''
                                                            ? Border.all(
                                                                width: 1.0,
                                                                color: Colors
                                                                    .white,
                                                              )
                                                            : null,
                                                        boxShadow: p1Info.value?[
                                                                        'cards2']
                                                                    [i] ==
                                                                ''
                                                            ? null
                                                            : const [
                                                                BoxShadow(
                                                                  spreadRadius:
                                                                      2,
                                                                  blurRadius: 2,
                                                                  color: Colors
                                                                      .black12,
                                                                ),
                                                              ],
                                                        borderRadius: BorderRadius
                                                            .circular(widget
                                                                    .style
                                                                    .cardMargin /
                                                                2),
                                                        image: p1Info.value?[
                                                                        'cards2']
                                                                    [i] ==
                                                                ''
                                                            ? null
                                                            : DecorationImage(
                                                                image: AssetImage(
                                                                    "assets/images/cards/${p1Info.value?['cards2'][i]}.png"),
                                                                repeat:
                                                                    ImageRepeat
                                                                        .noRepeat,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    widget.style.cardMargin /
                                                        2),
                                            //sum 2
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                for (var sum
                                                    in p1Info.value?['sum2'] ??
                                                        [])
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: widget
                                                                    .style
                                                                    .cardMargin /
                                                                2),
                                                    margin: EdgeInsets.all(
                                                        widget.style
                                                                .cardMargin /
                                                            4),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.black38,
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "$sum",
                                                      style: widget.style
                                                          .textSmallLightStyle,
                                                    ),
                                                  ),
                                              ],
                                            )
                                          ])
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (p1Section2Turn.value)
                                FadeInOut(
                                  child: Container(
                                    // width: widget.style.gridHeight,
                                    height: widget.style.gridHeight,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: widget.style.cardMargin),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.white.withAlpha(150),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          widget.style.cardMargin / 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Container(
                    child: Text(
                      p1Info.value?['username'] ?? '',
                      style: widget.style.textMediumLightStyle,
                    ),
                  ),
                  // if (meInGame.value)
                  //   Container(
                  //     child: Text(
                  //       "${p1Info.value?['balance']}".asPrice(),
                  //       style: widget.style.textMediumLightStyle,
                  //     ),
                  //   )
                ],
              ),
            ),
          ])),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: widget.style.gridHeight / 2,
                  child: widget.nativeAd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget WinnersBoard() {
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(widget.style.cardMargin / 2),
            padding: EdgeInsets.symmetric(
                horizontal: widget.style.cardMargin,
                vertical: widget.style.cardMargin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.style.cardMargin),
              color: widget.style.primaryColor,
              border: Border.all(
                color: Colors.transparent,
                // Make the border itself transparent
                width: 4.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.shade700.withOpacity(0.8),
                  blurRadius: 8.0,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var key in ['username', 'prize'])
                          IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.all(
                                        widget.style.cardMargin / 2),
                                    padding: EdgeInsets.all(
                                        widget.style.cardMargin / 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          widget.style.cardMargin),
                                      // border: Border.all(
                                      //     color: style
                                      //         .primaryColor),
                                      // color: Colors
                                      //         .grey[
                                      //     300]
                                    ),
                                    child: Text(
                                      (key == 'username' ? 'name' : key).tr,
                                      textAlign: TextAlign.center,
                                      style: widget.style.textSmallStyle
                                          .copyWith(
                                              color: Colors.yellow,
                                              fontWeight: FontWeight.bold),
                                    )),
                                for (var winner in prizes.value)
                                  Container(
                                      margin: EdgeInsets.all(
                                          widget.style.cardMargin / 2),
                                      padding: EdgeInsets.all(
                                          widget.style.cardMargin),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              widget.style.cardMargin),
                                          // border: Border.all(
                                          //     color: style
                                          //         .primaryColor),
                                          color: Colors.white.withOpacity(.3)),
                                      child: Text(
                                        overflow: TextOverflow.fade,
                                        "${winner[key]}",
                                        textAlign: TextAlign.center,
                                        style: widget.style.textSmallLightStyle,
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
        ],
      ),
    );
  }

  void initGame() async {
    if (game.value == null) return;
    state = game.value?['state'] ?? {};
    if (widget.user.id != '') meId = int.parse(widget.user.id);
    gameText.value = state['gameText'] ?? '';
    if (game.value?['action'] == 'done') {
      leaveGame(game.value?['id']);

      prizes.value = [];
      for (var idx in [1, 2, 3, 4]) {
        if (game.value?['p${idx}Id'] != null) {
          prizes.value.add({
            'username': state['${game.value?['p${idx}Id']}']?['username'] ?? '',
            'prize': "${game.value['p${idx}Prize']}".asPrice()
          });
        }
      }
    }
    action.value = game.value?['action'];
    print("action ${action.value}");
    if (action.value == 'dealer_decision') playSound('flip');
    turnId = game.value?['turnId'];
    secondsRemaining.value = game.value?['secondsRemaining'];
    // print(game.value);
    // canJoinGame= [p1Id, p2Id, p3Id, p4Id].where((i)=>i!=null).length;

    //move me id to p1

    var tmp;
    for (var idx in [2, 3, 4])
      if (game.value?['p${idx}Id'] == meId) {
        tmp = game.value?['p${idx}Id'];
        game.value?['p${idx}Id'] = game.value?['p1Id'];
        game.value?['p1Id'] = tmp;
        tmp = game.value?['p${idx}Prize'];
        game.value?['p${idx}Prize'] = game.value?['p1Prize'];
        game.value?['p1Prize'] = tmp;
        tmp = game.value?['p${idx}Action1'];
        game.value?['p${idx}Action1'] = game.value?['p1Action1'];
        game.value?['p1Action1'] = tmp;
        tmp = game.value?['p${idx}Action2'];
        game.value?['p${idx}Action2'] = game.value?['p1Action2'];
        game.value?['p1Action2'] = tmp;
      }
    p1Id = game.value?['p1Id'];
    p2Id = game.value?['p2Id'];
    p3Id = game.value?['p3Id'];
    p4Id = game.value?['p4Id'];

    p1Action1.value = game.value?['p1Action1'];
    p1Action2.value = game.value?['p1Action2'];
    p2Action1.value = game.value?['p2Action1'];
    p2Action2.value = game.value?['p2Action2'];
    p3Action1.value = game.value?['p3Action1'];
    p3Action2.value = game.value?['p3Action2'];
    p4Action1.value = game.value?['p4Action1'];
    p4Action2.value = game.value?['p4Action2'];
    meInGame.value = [p1Id, p2Id, p3Id, p4Id].contains(meId);
    winnerId.value = game.value?['winnerId'];

    p1Info.value = state["$p1Id"] ??
        {
          'cards1': [''],
          'cards2': [],
          'username': 'empty_table'.tr,
          'balance': 0,
          'bet1': 0,
        };
    if (!meInGame.value) {
      p1Info.value['balance'] = 0;
    } else {
      widget.user.financial.balance = p1Info.value['balance'];
    }
    // meInGame.value ? widget.user.financial.balance : 0;
    // print("balance ${p1Info.value['balance']}");
    meBet1.value = int.parse("${p1Info.value['bet1'] ?? 0}");
    meBet2.value = int.parse("${p1Info.value['bet2'] ?? 0}");
    setCoins();
    p2Info.value = state["$p2Id"] ??
        {
          'cards1': ['', ''],
          'cards2': [],
          'username': 'empty_table'.tr,
          'balance': 0,
          'bet1': 0,
        };
    p3Info.value = state["$p3Id"] ??
        {
          'cards1': ['', ''],
          'cards2': [],
          'username': 'empty_table'.tr,
          'balance': 0,
          'bet1': 0,
        };
    p4Info.value = state["$p4Id"] ??
        {
          'cards1': ['', ''],
          'cards2': [],
          'username': 'empty_table'.tr,
          'balance': 0,
          'bet1': 0,
        };

    dealerInfo.value = state['dealer'] ??
        {
          'cards': ['', ''],
          'username': 'Dealer'
        };

    p1Section1Width.value = Get.width / 3 ??
        (p1Info.value?['cards1'] ?? []).length * widget.style.gridHeight / 6;
    p1Section2Width.value = Get.width / 3 ??
        (p1Info.value?['cards2'] ?? []).length * widget.style.gridHeight / 6;
    left1.value = widget.style.gridHeight / 12;

    p1Section1Turn.value = (p1Info.value?['allowed1'] ?? []).length > 0;
    p1Section2Turn.value =
        !p1Section1Turn.value && (p1Info.value?['allowed2'] ?? []).length > 0;
    // print(p1Info.value['allowed2']);
    meImg = meImg ?? "assets/images/players/p${1 ?? asset[0]}.png";
    opImg = opImg ?? "assets/images/players/p${2 ?? asset[1]}.png";
    actionTitle = Rx('');

    // print(turnMe);
    // if (circles.length == 0 && !turnMe)
    // await animateCell(move);

    // if (winnerId.value != null) leaveGame(game.value?['id']);
    Future.delayed(Duration(seconds: 1), () {
      widget.countDownController.restart(duration: secondsRemaining.value);
    });
  }

  setBet(int coin) {
    playSound('chick');
    if (coin == 0) {
      p1Info.value['balance'] += meBet1.value;
      p1Info.refresh();
      meBet1.value = 0;
      meCoins1.value = {};
      return;
    }
    meBet1.value += (coin);
    p1Info.value['balance'] -= (coin);
    p1Info.refresh();
    setCoins();
  }

  setCoins() {
    meCoins1.value = {};
    meCoins2.value = {};
    var tmpList = [];
    var tmpList2 = [];
    num tmp = meBet1.value;
    num tmp2 = meBet2.value;
    for (var coin in widget.setting.coins) {
      if ((tmp ~/ (coin)) * (coin) > 0) {
        tmpList.addAll(List.filled(tmp ~/ (coin), (coin)).where((i) => i > 0));
        tmp -= (tmp ~/ (coin)) * (coin);
      }
      if ((tmp2 ~/ (coin)) * (coin) > 0) {
        tmpList2
            .addAll(List.filled(tmp2 ~/ (coin), (coin)).where((i) => i > 0));
        tmp2 -= (tmp2 ~/ (coin)) * (coin);
      }
      //
    }
    for (var coin in tmpList) {
      meCoins1.value[coin] = (meCoins1.value[coin] ?? 0) + 1;
    }
    for (var coin in tmpList2) {
      meCoins2.value[coin] = (meCoins2.value[coin] ?? 0) + 1;
    }
  }

  void showHelpDialog() {
    Get.dialog(MyDialog(
      okText: 'accept'.tr,
      widget: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            for (var row in widget.setting.blackjackHelp)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (row['icon'] != '')
                    Padding(
                      padding: EdgeInsets.all(widget.style.cardMargin / 2),
                      child: Image.asset(
                        "assets/images/actions/${row['icon']}.png",
                        width: widget.style.buttonHeight / 2,
                      ),
                    ),
                  if (row['text'] != null)
                    Expanded(
                      child: Text(
                        row['text'],
                        softWrap: true,
                        style: widget.style.textSmallStyle,
                      ),
                    ),
                ],
              )
          ],
        ),
      ),
      message: '',
      onCancelPressed: () {},
    ));
  }
}
