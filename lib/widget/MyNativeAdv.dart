import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:games/controller/UserController.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controller/APIProvider.dart';
import '../controller/SettingController.dart';
import '../helper/styles.dart';
import '../helper/variables.dart';

enum AdvType { BANNER }

class MyNativeAdv extends StatelessWidget {
  late SettingController setting;
  late UserController userController;
  late Style style;
  late final apiProvider;
  final AdvType type;
  final failWidget;

  MyNativeAdv({super.key, required AdvType this.type, this.failWidget}) {
    setting = Get.find<SettingController>();
    style = Get.find<Style>();
    apiProvider = Get.find<ApiProvider>();
    userController = Get.find<UserController>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: createNativeAdv(),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        if (!snapshot.hasError && snapshot.hasData) return snapshot.data!;

        return failWidget ?? Center();
      },
    );
  }

  Future<Widget?> createNativeAdv() async {
    var type = setting.adv['types']?['native'] ?? {};

    // try {

    // print("****adv********$type");
    var adv = await getAdvItem();
    // print(adv);

    if (type == 'my') {
      if (adv['banner_link'] == null) return null;
      return Container(
        decoration: BoxDecoration(

        ),
        child: GestureDetector(
          child: Image.network(
            adv['banner_link'],
            fit: BoxFit.fill,
            repeat: ImageRepeat.noRepeat,
          ),
          onTap: () => launchUrl(adv),
        ),
      );
    } else
      return null;
  }

  Future getAdvItem({Map<String, dynamic>? param}) async {
    var parsedJson = await apiProvider.fetch(
      Variable.LINK_GET_ADV,
      param: {'cmnd': 'random'},
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
    );

    return parsedJson;
  }

  void launchUrl(advItem) async {
    if (await canLaunchUrlString(advItem['click_link'])) {
      advClicked(advItem['id']);
      launchUrlString(advItem['click_link'],
          mode: LaunchMode.externalApplication);
    }
  }

  void advClicked(  id) async {
    var parsedJson = await apiProvider.fetch(
      Variable.LINK_ADV_CLICK,
      param: {'id': id},
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      method: 'post',
    );
    // print(parsedJson);
  }
}
