import 'package:games/controller/UserController.dart';
import 'package:games/helper/extensions.dart';
import 'package:games/page/user_profile.dart';
import 'package:games/widget/AnimatedButton.dart';
import 'package:games/widget/GlassContainer.dart';
import 'package:games/widget/bounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../helper/styles.dart';
import '../model/User.dart';
import 'side_menu.dart';

class MyAppBar extends StatefulWidget {
  late final Style style;
  late final Widget child;
  Widget? header;
  final String? title;
  final Widget? banner;
  late double height;
  final GlobalKey<SideMenuState>? sideMenuKey;

  late MyAnimationController animationController;

  MyAppBar({
    this.sideMenuKey,
    this.title,
    this.header,
    height,
    Key? key,
    required Widget this.child,
    this.banner,
  }) {
    animationController = Get.find<MyAnimationController>();
    style = Get.find<Style>();
    this.height = height ?? style.imageHeight;
  }

  @override
  State<MyAppBar> createState() => _AppBarState();
}

class _AppBarState extends State<MyAppBar>
    with
        TickerProviderStateMixin,
        KeepAliveParentDataMixin,
        AutomaticKeepAliveClientMixin {
  bool isOpen = false;
  late final Style style;

  UserController userController = Get.find<UserController>();

  @override
  void dispose() async {
    // print('dispose');
    super.dispose();
  }

  @override
  void initState() {
    isOpen = false;
    // print('init');
    style = widget.style;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      decoration: BoxDecoration(
        gradient: style.mainGradientBackground,
        image: DecorationImage(
            image: const AssetImage("assets/images/main_back.jpg"),
            repeat: ImageRepeat.noRepeat,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            colorFilter: ColorFilter.mode(
                style.primaryColor.withAlpha(20), BlendMode.screen),
            opacity: .1),
      ),
      child: NestedScrollView(
        physics: BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            // Sets the expansion height
            // leading: IconButton(
            //   icon: Icon(Icons.menu), // Leading icon (Hamburger menu)
            //   onPressed: () {
            //     print("Menu button pressed!");
            //   },
            // ),
            // title: Text("Expandable AppBar"),
            leading: Center(),
            floating: true,
            snap: false,
            elevation: 10,
            // stretch: true,

            expandedHeight: style.tabHeight,
            pinned: false,
            // Keeps the AppBar visible when collapsed
            flexibleSpace: FlexibleSpaceBar(
              background: Card(
                color: style.primaryMaterial[900]!.withAlpha(50),
                margin: EdgeInsets.zero,
                // elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(widget.style.cardBorderRadius)),
                ),
                child: userController.obx(
                  (user) {
                    // print("*****  update user ${user.financial.balance}");

                    return widget.header ??
                        Padding(
                          padding: EdgeInsets.all(style.cardMargin),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedButton(
                                  onTap: () => Get.toNamed('/ProfilePage'),
                                  child: Container(
                                    // margin: EdgeInsets.symmetric(
                                    //   horizontal: style.cardMargin * 4,
                                    //   vertical: style.cardMargin,
                                    // ),
                                    child:
                                        Image.asset("assets/images/menu.png"),
                                  ),
                                ),
                                Text(widget.title??'',style: widget.style.textHeaderLightStyle,),
                                FittedBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // textDirection: TextDirection.ltr,
                                    children: [
                                      AnimatedButton(
                                        onTap: () {
                                          Get.toNamed('/ProfilePage');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: style.cardMargin * 6,
                                            vertical: style.cardMargin,
                                          ),
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/frame_profile.png"),
                                                repeat: ImageRepeat.noRepeat,
                                                fit: BoxFit.fill,
                                                filterQuality:
                                                    FilterQuality.medium,
                                                opacity: 1),
                                          ),
                                          child: Text(
                                            userController.user.username,
                                            style: widget.style.textMediumStyle
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      AnimatedButton(
                                        onTap: () =>
                                            userController.updateBalance(null,reset: true),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: style.cardMargin * 6,
                                            vertical: style.cardMargin,
                                          ),
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/frame_balance.png"),
                                                repeat: ImageRepeat.noRepeat,
                                                fit: BoxFit.fill,
                                                filterQuality:
                                                    FilterQuality.medium,
                                                opacity: 1),
                                          ),
                                          child: Text(
                                            " ${"${user.financial.balance}".asPrice()}",
                                            style: style.textMediumStyle
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                  },
                ),
              ),

              // background: Image.asset(
              //   "images/dialog_3.png", // Background image
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
        ],
        body: widget.child,
      ),
    );

  }

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
