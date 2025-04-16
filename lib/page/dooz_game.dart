import 'dart:async';
import 'dart:convert';

// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:audioplayers/audioplayers.dart';
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

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

import '../controller/DoozController.dart';
import '../helper/styles.dart';
import '../model/Room.dart';
import '../model/User.dart';
import '../widget/AnimatedButton.dart' show AnimatedButton;
import '../widget/FadeInOut.dart';
import '../widget/Flipper.dart';
import '../widget/blinkanimation.dart';
import '../widget/loader.dart';

enum GAME_STATUS {
  FINDING,
  INGAME,
}

class DoozGame extends StatefulWidget {
  late UserController userController;
  late DoozController gameController;
  late SocketController socketController;
  late Helper helper;
  late User user;

  DoozGame({super.key}) {
    // _audioPlayer = AudioPlayer();
    userController = Get.find<UserController>();
    gameController = Get.find<DoozController>();
    socketController = Get.find<SocketController>();
    helper = Get.find<Helper>();
    user = userController.user;
  }

  @override
  State<DoozGame> createState() => _DoozGameState();
}

class _DoozGameState extends State<DoozGame>
    with SingleTickerProviderStateMixin {
  final GlobalKey _tableKey = GlobalKey();

  Style style = Get.find<Style>();

  SettingController setting = Get.find<SettingController>();

  RxnDouble _tableWidth = RxnDouble();

  RxInt level = RxInt(-1);
  bool mounted = false;

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

  final player = AudioPlayer();

  Rx game = Rx(null);

  RxString meCount = RxString('0');

  RxString meInCount = RxString('0');
  RxString meStartCount = RxString('0');

  RxString opCount = RxString('0');

  RxString opInCount = RxString('0');
  RxString opStartCount = RxString('0');

  RxString meUsername = RxString('0');

  RxString opUsername = RxString('0');

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

  var action;

  var turnId;

  var p1Id;

  var p2Id;

  var p1Info;

  var p2Info;

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

  @override
  void dispose() {
    print("-----dispose dooz-----");
    player.dispose();
    leaveAll();
    // widget.socketController.disconnect();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    soundOn.value =
        Helper.localStorage(key: 'settings.sound', def: 'off') == 'on';
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
      mounted = true;
      setSocketListeners();
      findGame();
    });
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
          mounted = false;
          player.stop();
          player.dispose();
          Future.delayed(const Duration(seconds: 2),
              () => widget.userController.updateBalance(null));

          return Future.value(true);
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          body: MyAppBar(
            // height: style.tabHeight,
            header: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: style.cardMargin, vertical: style.cardMargin / 2),
              child: Obx(
                () => IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //cards circle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: style.cardMargin * 2),
                                  height: style.imageHeight / 2,
                                  width: style.imageHeight / 2,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/frame_cube.png"),
                                      repeat: ImageRepeat.noRepeat,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${meInCount.value}/${meCount.value}",
                                      style: style.textMediumLightStyle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    right: 0,
                                    left: 0,
                                    top: style.cardMargin * 2,
                                    child: Text(
                                      'piece'.tr,
                                      textAlign: TextAlign.center,
                                      style: style.textTinyLightStyle.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ))
                              ],
                            ),
                            Text(
                              "${meInfo?['username'] ?? ''}",
                              textAlign: TextAlign.center,
                              style: style.textSmallLightStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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

                      SizedBox(
                        width: style.cardMargin,
                      ),

                      //players circle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: style.cardMargin * 2),
                                  height: style.imageHeight / 2,
                                  width: style.imageHeight / 2,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/frame_cube.png"),
                                      repeat: ImageRepeat.noRepeat,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${opInCount.value}/${opCount.value}",
                                      style: style.textMediumLightStyle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    right: 0,
                                    left: 0,
                                    top: style.cardMargin * 2,
                                    child: Text(
                                      'piece'.tr,
                                      textAlign: TextAlign.center,
                                      style: style.textTinyLightStyle.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ))
                              ],
                            ),
                            Text(
                              "${opInfo?['username'] ?? ''}",
                              textAlign: TextAlign.center,
                              style: style.textSmallLightStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child:
                Obx(() => game.value != null ? GameBoard() : FindGameWidget()),
          ),
        ));
  }

  Future playSound(sound) async {
    if (soundOn.value && mounted) {
      final duration = await player.setAsset(// Load a URL
          "assets/sounds/$sound.mp3");
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

  void play({move}) async {
    if (winnerId.value != null) return;

    print('play ${move}');
    await animateCell(move);

    playSound('chick');
    var res = await widget.gameController
        .play(params: {'game_id': game.value['id'], 'move': move});
    // if (res?['game'] != null) {
    //   game.value = res?['game'];
    //   initGame();
    // }
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
    //   //   circles[move[0]]['top'] = fromRow * cellSize.value + style.cardMargin;
    //   //   circles[move[0]]['left'] = fromCol * cellSize.value + style.cardMargin;
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

  void initGame() async {
    state = game.value?['state'];
    // print(state?['board']);
    board = state?['board'] ?? [];
    move = state?['move'] ?? [-1, -1];
    isInsideMove =
        ![-1, null].contains(move[0]) && ![-1, null].contains(move[1]);
    print("move $move");

    cols = state['col'];
    action = game.value?['action'];
    turnId = game.value?['turnId'];
    p1Id = game.value?['p1Id'];
    p2Id = game.value?['p2Id'];
    winnerId.value = game.value?['winnerId'];
    p1Info = state[p1Id];
    p2Info = state[p2Id];
    meId = widget.user.id == "$p1Id" ? p1Id : p2Id;
    opId = widget.user.id != "$p1Id" ? p1Id : p2Id;
    meInfo = state["$meId"];
    opInfo = state["$opId"];
    meCount.value = "${meInfo['start'] + meInfo['in']}";
    meInCount.value = "${meInfo['in']}";
    meStartCount.value = "${meInfo['start']}";
    opCount.value = "${opInfo['start'] + opInfo['in']}";
    opInCount.value = "${opInfo['in']}";
    opStartCount.value = "${opInfo['start']}";

    moveFrom = meInfo['start'] > 0 ? -1 : null;
    turnMe = widget.user.id == "$turnId";
    blinks = Rx((meInfo['start'] > 0 || action == 'kick') && turnMe
        ? meInfo['allowed']
        : []);
    asset = List.generate(7, (index) => index + 1)..shuffle(Random());
    meImg = meImg ?? "assets/images/players/p${1 ?? asset[0]}.png";
    opImg = opImg ?? "assets/images/players/p${2 ?? asset[1]}.png";
    actionTitle = Rx(winnerId.value == meId
        ? 'you_win'.tr
        : winnerId.value == opId
            ? '*_win'.trParams({'item': opInfo['username']})
            : action == 'kick'
                ? turnMe
                    ? 'kick_opponent'.tr
                    : 'kicking_you'.tr
                : turnMe
                    ? 'your_turn'.tr
                    : 'opponent_turn'.tr);

    // print(turnMe);
    // if (circles.length == 0 && !turnMe)
    await animateCell(move);
    // if (winnerId.value != null) leaveGame(game.value?['id']);
    circles = board.asMap().entries.map((entry) {
      int index = entry.key;
      var el = entry.value;
      var row = index ~/ cols;
      var col = index % cols;
      // print("$row $col ${el['owner']}");
      // var notUpdate =
      //     move.contains(index) && circles.isNotEmpty && isInsideMove;
      // print("${index} ${notUpdate}");
      // if (notUpdate) {
      //   print("notUpdate ${index} ${circles[index]['row']} $row");
      // }
      return {
        'owner': Rx(el['owner']),
        'row': Rx(row),
        'col': Rx(col),
      };
    }).toList();
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
    widget.socketController.on('joined-dooz', (data) {
      gameConnected = true;
      print('+++joined dooz+++');
      // print(data);
      game.value = data;
      status.value = GAME_STATUS.INGAME;
      initGame();
      // print(game.value);
    });
    widget.socketController.on('left-dooz', (data) {
      print('left dooz');
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
    widget.socketController.on('dooz-update', (data) {
      print('---dooz-update---${data?['game']?['id']}');
      if (data?['game'] != null) {
        game.value = data?['game'];
        initGame();
      }
    });
  }

  void findGame() async {
    roomType = Get.arguments?.type;
    print('**dooz finding** ${roomType}');
    game.value = null;
    if (roomType == null) {
      Get.offNamed('/');
      return;
    }
    // leaveAll();
    // status.value = GAME_STATUS.FINDING;
    // print(res);

    var res = await widget.gameController.find(params: {'room_type': roomType});
    print(res);
    print(res?['status']);
    if (res == null || res['status'] == 'waiting') {
      joinRoom();
    } else if (res != null && res['status'] == 'before_game') {
      // game.value = res['game'];
      joinGame(res['game']['id']);
      leaveRoom();
    } else if (res != null && res['status'] == 'low_balance') {
      leaveRoom();
      // game.value = res['game'];
      Future.delayed(const Duration(seconds: 1),
          () => widget.helper.showToast(msg: res['message'], status: 'danger'));
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
          .emit('join-dooz', {'id': gameId, 'user-id': widget.user.id});
    }
  }

  leaveGame(gameId) {
    if (gameId != null) {
      print("**********leaving game ${gameId}");
      widget.socketController.emit('leave-dooz', {'id': gameId});
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
    leaveRoom();
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
          style: style.textHeaderLightStyle,
        ),
        AnimatedButton(
          child: Container(
            width: Get.width / 2,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: style.cardMargin),
            padding: EdgeInsets.all(style.cardMargin),
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
              style: style.textHeaderStyle,
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

    // if (winnerId.value == meId) {
    //   actionTitle.value =;
    // }
    //
    // if (winnerId.value == opId) {
    //   actionTitle.value = '*_win'.trParams({'item': opInfo['username']});
    // }
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(style.cardMargin),
            margin: EdgeInsets.symmetric(horizontal: style.cardMargin),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/frame_wood.png"),
                repeat: ImageRepeat.noRepeat,
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          int.parse(meStartCount.value),
                          (i) => Container(
                            width: style.cardMargin * 2,
                            height: style.cardMargin * 2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(meImg),
                                repeat: ImageRepeat.noRepeat,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: style.cardMargin,
                    ),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          int.parse(opStartCount.value),
                          (i) => Container(
                            width: style.cardMargin * 2,
                            height: style.cardMargin * 2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(opImg),
                                repeat: ImageRepeat.noRepeat,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          actionTitle.value,
                          style: style.textHeaderLightStyle,
                        ),
                      ),
                    )
                  ],
                ),
                if (winnerId.value != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedButton(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: style.cardMargin),
                          padding: EdgeInsets.symmetric(
                              horizontal: style.cardMargin * 4),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/frame_button_5.png"),
                                repeat: ImageRepeat.noRepeat,
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.medium,
                                opacity: 1),
                          ),
                          child: Text(
                            'new_game'.tr,
                            style: style.textHeaderLightStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          // leaveAll();
                          findGame();
                        },
                      ),
                      AnimatedButton(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: style.cardMargin),
                          padding: EdgeInsets.symmetric(
                              horizontal: style.cardMargin * 4),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/frame_button_4.png"),
                                repeat: ImageRepeat.noRepeat,
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.medium,
                                opacity: 1),
                          ),
                          child: Text(
                            'return'.tr,
                            style: style.textHeaderStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          leaveAll();
                          Get.back();
                        },
                      ),
                    ],
                  )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(style.cardMargin),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                      color: Colors.black.withAlpha(100))
                ],
                image: const DecorationImage(
                  image: AssetImage("assets/images/dooz_board.jpg"),
                  repeat: ImageRepeat.noRepeat,
                  fit: BoxFit.fill,
                ),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  gridSize.value =
                      (_gridKey.currentContext?.size?.width ?? cellSize.value);
                  cellSize.value = gridSize.value / cols;
                  // print("grid size ${gridSize.value}");
                  // print("cell size ${cellSize.value}");
                });
                return Obx(
                  () => Stack(
                    children: [
                      ...circles.map((circle) {
                        if (circle['owner'].value == -1) return Center();

                        var left =
                            (cols - 1 - circle['col'].value) * cellSize.value;
                        var top = circle['row'].value * cellSize.value;
                        // print("update ${circle['col']} $left $top");
                        return Visibility(
                          visible: circle['owner'].value != null ||
                              meInfo['start'] > 0 ||
                              opInfo['start'] > 0,
                          child: AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            left: circle['owner'].value == null
                                ? gridSize / 2 - (circleSize / 2)
                                : left,
                            top: circle['owner'].value == null
                                ? gridSize / 2 - (circleSize / 2)
                                : top,
                            width: cellSize.value,
                            height: cellSize.value,
                            child: Container(
                              decoration: BoxDecoration(
                                image:
                                    [p1Id, p2Id].contains(circle['owner'].value)
                                        ? DecorationImage(
                                            image: AssetImage(
                                                circle['owner'].value == meId
                                                    ? meImg
                                                    : opImg),
                                            repeat: ImageRepeat.noRepeat,
                                            fit: BoxFit.fill,
                                          )
                                        : null,
                                shape: BoxShape.circle,
                                color: circle['owner'].value == null
                                    ? Colors.transparent
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                      GridView.builder(
                        key: _gridKey,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols ?? 0,
                          childAspectRatio: 1, // Makes square items
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                        ),
                        itemCount: board.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Center() ??
                                  Container(
                                    color: Colors.transparent,
                                    child: Container(
                                      margin: EdgeInsets.all(style.cardMargin),
                                      decoration: BoxDecoration(
                                        image: [p1Id, p2Id]
                                                .contains(board[index]['owner'])
                                            ? DecorationImage(
                                                image: AssetImage(board[index]
                                                            ['owner'] ==
                                                        p1Id
                                                    ? meImg
                                                    : opImg),
                                                repeat: ImageRepeat.noRepeat,
                                                fit: BoxFit.fill,
                                              )
                                            : null,
                                        shape: BoxShape.circle,
                                        color: /* board[index]['owner'] == p1Id
                                            ? Colors.blue
                                            : board[index]['owner'] == p2Id
                                                ? Colors.red
                                                : */
                                            board[index]['owner'] == null
                                                ? Colors.transparent
                                                : Colors.transparent,
                                      ),
                                    ),
                                  ),
                              Obx(
                                () => Container(
                                  margin: EdgeInsets.all(style.cardMargin / 2),
                                  child: blinks.value.contains(index)
                                      ? InkWell(
                                          onTap: () {
                                            play(move: [moveFrom, index]);
                                          },
                                          child: FadeInOut(
                                            duration: const Duration(
                                                milliseconds: 1500),
                                            repeat: true,
                                            child: Container(
                                                decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withAlpha(150),
                                              shape: BoxShape.circle,
                                            )),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            print(index);
                                            if (meInfo['start'] > 0 ||
                                                winnerId.value != null ||
                                                board[index]['owner'] != meId) {
                                              return;
                                            }
                                            moveFrom = index;

                                            blinks.value =
                                                board[index]['allowed'];
                                          },
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      // Moving Circles
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
