import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:games/controller/RoomController.dart';
import 'package:games/controller/SocketController.dart';
import 'package:games/page/blackjack_game.dart';
import 'package:games/page/contact_us.dart';
import 'package:games/page/daberna_game.dart';
import 'package:games/page/room.dart';
import 'package:games/page/shop.dart';
import 'package:games/page/user_profile.dart';
import 'package:games/page/winwheel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:games/widget/MyDialog.dart';
import 'package:games/widget/MyNativeAdv.dart';
import 'package:games/widget/ScrollingText.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import 'controller/APIProvider.dart';
import 'controller/AnimationController.dart';
import 'controller/BlackJackController.dart';
import 'controller/DoozController.dart';
import 'controller/SettingController.dart';
import 'controller/TicketController.dart';
import 'controller/TransactionController.dart';
import 'controller/UserController.dart';
import 'controller/UserController.dart';
import 'helper/helpers.dart';
import 'helper/styles.dart';
import 'helper/translations.dart';
import 'helper/variables.dart';
import 'model/Daberna.dart';
import 'page/dooz_game.dart';
import 'page/menu_drawer.dart';
import 'page/policy.dart';
import 'page/register_login_screen.dart';
import 'page/room_list.dart';
import 'page/splash_screen.dart';
import 'page/transactions.dart';
import 'page/withdraw.dart';
import 'widget/AnimatedButton.dart';
import 'widget/AppBar.dart';
import 'widget/banner_card.dart';
import 'widget/shakeanimation.dart';
import 'widget/side_menu.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'helper/web_stubs.dart' if (dart.library.html) 'package:web/web.dart'
    as web;
import 'helper/web_stubs.dart' if (dart.library.html) 'helper/telegram.dart';

late AppLinks? _appLinks;
Uri? deepLink;
StreamSubscription? _sub;
late Style style;

Future<void> initUniLinks() async {
  if (kIsWeb) return;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    _appLinks = AppLinks(); //first run
    _sub = _appLinks?.uriLinkStream.listen((Uri? link) {
      //when run app in background
      // print("deep link resume: $deepLink");

      if (link != null) deepLink = link;
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
    // print("deep link start: $deepLink");

    // Parse the link and warn the user, if it is not correct,
    // but keep in mind it could be `null`.
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
}

void main() async {
  // runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);
  await GetStorage.init();
  await initUniLinks();
  WakelockPlus.disable();
  // setUrlStrategy();
  final apiProvider = Get.put(ApiProvider());
  style = Get.put(Style());
  // TelegramService.init();
  Helper.initPushPole();
  // usePathUrlStrategy();
  runApp(MyApp());
  // }, (error, stackTrace) async {
  //   // print(error);
  //   Helper.sendLog({'message': "$error \n $stackTrace"});
  // });
}

class HasArgumentMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    var params = Get.arguments;
    if (params == null) {
      return const RouteSettings(name: '/'); // Redirect to home
    }
    return null; // Continue to  Page
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    // GetStorage box = GetStorage();
    // final translate = Get.put(MyTranslations());
    // Get.updateLocale(const Locale('fa', 'IR'));
    if (kIsWeb) {
      web.window.onPopState.listen((event) {
        if (Get.currentRoute != '/') {
          Get.back(
            result: true,
          );
        }
      });
    }
    return GetMaterialApp(
        onInit: () {
          style.setTheme();
        },
        onReady: () {
          style.setSize(context.size?.width);
        },
        onDispose: () {},
        navigatorKey: _navKey,
        title: Variable.APP_LABEL,
        color: style.primaryColor,
        unknownRoute: GetPage(name: '/', page: () => MyHomePage()),
        initialRoute: '/',
        opaqueRoute: true,
        defaultTransition: Transition.native,
        // 👈 تغییر پیش‌فرض
        // navigatorObservers: [GetObserver()],
        getPages: [
          GetPage(name: '/', page: () => MyHomePage()),
          GetPage(name: '/:type/RoomList', page: () => RoomListPage()),
          GetPage(name: '/WinWheel', page: () => WinWheelPage()),
          GetPage(name: '/Transactions', page: () => TransactionsPage()),
          GetPage(name: '/WithdrawPage', page: () => WithdrawPage()),
          GetPage(name: '/ShopPage', page: () => ShopPage()),
          GetPage(name: '/ProfilePage', page: () => UserProfilePage()),
          GetPage(
            name: '/RoomPage/:type',
            page: () => RoomPage(),
            middlewares: [HasArgumentMiddleware()],
          ),
          GetPage(name: '/ContactPage', page: () => ContactUsPage()),
          GetPage(name: '/PolicyPage', page: () => PolicyPage()),
          GetPage(
            name: '/DabernaGame',
            page: () => DabernaGame(),
            middlewares: [HasArgumentMiddleware()],
          ),
          GetPage(
            name: '/DoozGame',
            page: () => DoozGame(),
            middlewares: [HasArgumentMiddleware()],
          ),
          GetPage(
            name: '/BlackJackGame',
            page: () => BlackJackGame(),
            middlewares: [HasArgumentMiddleware()],
          ),
        ],
        routingCallback: (routing) {
          if (routing?.current != '/' && routing?.previous == null) {
            // If app is opened from a non-main link, redirect to '/'
            Get.offAllNamed('/');
          }
        },

        // title: 'label'.tr,
        debugShowCheckedModeBanner: false,
        // defaultTransition: Transition.native,
        translations: MyTranslations(),
        locale: const Locale('fa', 'IR'),
        fallbackLocale: const Locale('fa', 'IR'),
        theme: style.theme,
        home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  final style = Get.find<Style>();
  final helper = Get.put(Helper());

  final settingController = Get.put(SettingController());
  final userController = Get.put(UserController());

  final animationController = Get.put(MyAnimationController());
  final ticketController = Get.put(TicketController());
  final transactionController = Get.put(TransactionController());
  final roomController = Get.put(RoomController());
  final socketController = Get.put(SocketController());
  final doozController = Get.put(DoozController());
  final blackjackController = Get.put(BlackJackController());
  static RxBool ticketNotification = false.obs;

  // Get.put(IAPPurchase(
  // keys: settingController.keys,
  // products: settingController.plans,
  // plans: settingController.plans));
  MyHomePage({Key? key, title}) : super(key: key) {
    userController.getUser(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Get.updateLocale(const Locale('fa', 'IR'));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: const AssetImage("assets/images/texture.jpg"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    style.primaryColor.withOpacity(.1), BlendMode.darken),
                opacity: .15),
            // LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: <Color>[
            //     style.primaryMaterial[50]!,
            //     style.primaryMaterial[50]!,
            //     style.primaryMaterial[200]!,
            //   ],
            // ),
          ),
          child: userController.obx((user) {
            return settingController.obx(
              (setting) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  extendBody: true,
                  // appBar: AppBar(title: Text('label'.tr)),

                  body: MainPage(),
                );
              },
              onError: (msg) => RegisterLoginScreen(error: msg),
              onLoading: SplashScreen(
                isLoading: true,
              ),
              onEmpty: SplashScreen(),
            );
          },
              onError: (msg) => RegisterLoginScreen(error: msg),
              onLoading: SplashScreen(
                isLoading: true,
              ),
              onEmpty: SplashScreen())),
    );
  }
}

class MainPage extends StatefulWidget {
  late EdgeInsets marginLeft;
  late EdgeInsets marginRight;
  final style = Get.find<Style>();

  final apiProvider = Get.find<ApiProvider>();

  final userController = Get.find<UserController>();

  final animationController = Get.find<MyAnimationController>();

  final settingController = Get.find<SettingController>();

  MainPage() {
    marginLeft = EdgeInsets.symmetric(
      horizontal: style.cardMargin / 2,
      vertical: style.cardMargin / 2,
    ).copyWith(right: style.cardMargin / 4, bottom: style.cardMargin);
    marginRight = EdgeInsets.symmetric(
      horizontal: style.cardMargin / 2,
      vertical: style.cardMargin / 2,
    ).copyWith(left: style.cardMargin / 4, bottom: style.cardMargin);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      settingController.resolveDeepLink(deepLink);
      deepLink = null;
      settingController.showUpdateDialogIfRequired();

      //
      // Future.delayed(
      //   const Duration(seconds: 1),
      //   () {
      //     // Get.find<RoomController>()
      //     //     .startGame(daberna: Daberna.fromJson(settingController.game));
      //     final result = Get.toNamed('/daberna/RoomList',
      //         arguments: settingController.games[0]);
      //     // Get.toNamed('/WinWheel');
      //   },
      // );
    });
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   final _state = _sideMenuKey.currentState;
    //   if (_state!.isOpened) {
    //     _state.closeSideMenu();
    //     animationController.closeDrawer();
    //   } else {
    //     _state.openSideMenu();
    //     animationController.openDrawer();
    //     // _animationButtonController.reverse();
    //   }

    // });
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final socketController = Get.find<SocketController>();

  final GlobalKey<SideMenuState> _sideMenuKey =
      Get.put(GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey'));

  @override
  void initState() {
    socketController.init(params: {'user-id': widget.userController.user.id});
    socketController.connect();

    super.initState();
  }

  @override
  void dispose() {
    socketController?.disconnect();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   // gradient: style.mainGradientBackground,
      //   image: DecorationImage(
      //       image: const AssetImage("assets/images/main_back.jpg"),
      //       repeat: ImageRepeat.noRepeat,
      //       fit: BoxFit.cover,
      //       filterQuality: FilterQuality.medium,
      //       colorFilter: ColorFilter.mode(
      //           style.primaryColor , BlendMode.screen),
      //       opacity: .1),
      // ),
      child: MyAppBar(
        title: null,
        sideMenuKey: _sideMenuKey,
        banner: SizedBox(
            height: widget.style.tabHeight,
            child: MyNativeAdv(type: AdvType.BANNER)),
        child: ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            Column(
              children: [
                for (var msg in widget.settingController.headerMessages)
                  Obx(
                    () => Visibility(
                      visible: msg['visible'].value,
                      child: InkWell(
                        onTap: () => Get.dialog(
                          MyDialog(
                            onCancelPressed: () {
                              msg['visible'].value = false;
                              Navigator.of(context, rootNavigator: true).pop();

                              // Get.back(
                              //   canPop: true,
                              // );
                            },
                            widget: Text(
                              msg['msg'],
                              style: widget.style.textMediumStyle,
                            ),
                            message: '',
                          ),
                          barrierDismissible: true,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_rounded,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: ScrollingText(
                                text: msg['msg'],
                                repeat: true,
                                padding:
                                    EdgeInsets.all(widget.style.cardMargin),
                                direction: AxisDirection.left,
                                speed: 40,
                                backgroundColor: Colors.black38,
                                style: widget.style.textSmallLightStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
            for (var game in widget.settingController.games)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedButton(
                  child: Image.asset(
                    "assets/images/menu/${game['type']}.png",
                    fit: BoxFit.fill,
                  ),
                  onTap: () {
                    final result = Get.toNamed('/${game['type']}/RoomList',
                        arguments: game);
                    // final result = Get.to(() => RoomListPage());

                    // userController.updateBalance(null);
                  },
                ),
              ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedButton(
                onTap: () => Get.toNamed('/ShopPage'),
                child: Image.asset(
                  "assets/images/menu/deposit.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedButton(
                onTap: () => Get.toNamed('/WithdrawPage'),
                child: Image.asset(
                  "assets/images/menu/withdraw.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedButton(
                  onTap: () => Get.toNamed('/WinWheel'),
                  child: Image.asset(
                    "assets/images/menu/winwheel.png",
                    fit: BoxFit.fill,
                  )),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedButton(
                  onTap: () => Get.toNamed('/ProfilePage'),
                  child: Image.asset(
                    "assets/images/menu/profile.png",
                    fit: BoxFit.fill,
                  )),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedButton(
                  onTap: () => Get.toNamed('/Transactions'),
                  child: Image.asset(
                    "assets/images/menu/reports.png",
                    fit: BoxFit.fill,
                  )),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedButton(
                  onTap: () => Get.toNamed('/ContactPage'),
                  child: Image.asset(
                    "assets/images/menu/support.png",
                    fit: BoxFit.fill,
                  )),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedButton(
                  onTap: () => Get.toNamed('/PolicyPage'),
                  child: Image.asset(
                    "assets/images/menu/policy.png",
                    fit: BoxFit.fill,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refreshAll() {
    // widget.settingController.refresh();
    // blogController.getData();
    widget.userController.getUser(refresh: true);
    return Future.value(null);
  }
}
