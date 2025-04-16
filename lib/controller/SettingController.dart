import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:games/page/shop.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/APIProvider.dart';
import '../controller/UserController.dart';
import '../helper/helpers.dart';
import '../helper/styles.dart';
import '../helper/variables.dart';
import '../model/App.dart';
import '../page/contact_us.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'APIController.dart';
import 'AnimationController.dart';

class SettingController extends APIController<Map<String, dynamic>>
    with GetSingleTickerProviderStateMixin {
  var game = null;

  Map adv = {};
  List blackjackHelp = [];
  List games = [];
  List rooms = [];
  List coins = [];
  List ticketStatuses = [];
  String chargeTitle = '';
  String cardToCardTitle = '';
  Map cardToCard = {};
  Map winwheel = {'active': 0, 'limit_hour': 0, 'labels': []};
  String withdrawTitle = '';
  String policy = '';
  int callSpeed = 1000;
  int roomRefreshTime = 0;
  late Map<String, dynamic> _keys;
  String? payment;
  Map marketing = {};
  late Map<String, dynamic> cropRatio = {'profile': 1.0, 'document': null};
  late Map<String, dynamic> _limits;
  late String _chatScript;

  String get chatScript => _chatScript;

  set chatScript(String value) {
    _chatScript = value;
  }

  Map<String, dynamic> get limits => {'club': 1};

  set limits(Map<String, dynamic> value) {
    _limits = value;
  }

  Helper helper = Get.find<Helper>();

  bool _isVisibleBottomNavigationBar = true;

  set isVisibleBottomNavigationBar(bool value) {
    _isVisibleBottomNavigationBar = value;
  }

  get isVisible => _isVisibleBottomNavigationBar;

  Map<String, dynamic> get keys => _keys;

  set keys(Map<String, dynamic> value) {
    _keys = value;
  }

  late List<dynamic> categories;
  late Map<String, dynamic> types;

  App? appInfo;
  Map<String, dynamic> _data = {};
  late String _storageLink;

  int get currentLength => _data.length;

  Map<String, dynamic> get blogs => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(Map<String, dynamic> value) {
    _data = value;
  }

  late ApiProvider apiProvider;
  late UserController userController;
  late Style style;

  int _currentPageIndex = 2;

  int get currentPageIndex => _currentPageIndex;

  set currentPageIndex(int value) {
    _currentPageIndex = value;
    update();
  }

  late TabController bottomSheetController;

  SettingController() {
    apiProvider = Get.find<ApiProvider>();

    style = Get.find<Style>();

    bottomSheetController =
        TabController(length: 5, initialIndex: currentPageIndex, vsync: this);
    bottomSheetController.addListener(() {
      // settingController.currentPageIndex =bottomSheetController.index;
    });
  }

  @override
  onInit() async {
    // await getData();
    super.onInit();
  }

  Future<Map<String, dynamic>?> getData(
      {Map<String, dynamic> params = const {}}) async {
    await Helper.getPackageInfo();
    userController = Get.find<UserController>();

    params = {
      ...params,
      ...{
        'market': Variable.MARKET,
        'package': Helper.packageInfo?.packageName,
        'version': Helper.packageInfo?.buildNumber,
      }
    };

    change(GetStatus.loading());

    final parsedJson = await apiProvider.fetch(Variable.LINK_GET_SETTINGS,
        param: params,
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        tryReminded: ApiProvider.maxRetry);
    // print(parsedJson);
    if (parsedJson == null || parsedJson['error'] != null) {
      change(GetStatus.empty());
      return null;
    } else {
      data = parsedJson;
      game = _data['game'];
      blackjackHelp = _data['blackjack_help'] ?? [];
      adv = _data['ad'] ?? {};
      rooms = _data['rooms'] ?? [];
      games = _data['games'] ?? [];
      coins = _data['coins'] ?? [];
      coins.sort((b, a) => a.compareTo(b));
      ticketStatuses = _data['ticket_statuses'];
      chargeTitle = "${_data['charge_title']}";
      cardToCardTitle = _data['card_to_card_title'] ?? {};
      withdrawTitle = _data['withdraw_title'] ?? {};
      cardToCard = _data['card_to_card'] ?? {};
      winwheel = _data['winwheel'] ?? {};
      policy = _data['policy'] ?? '';
      callSpeed = _data['call_speed'] ?? 1000;
      roomRefreshTime = _data['room_refresh_time'] ?? 0;
      appInfo = App.fromJson(_data ?? {}, await PackageInfo.fromPlatform());
      Variable.LINK_SEND_LOG = appInfo!.logLink ?? Variable.LINK_SEND_LOG;
      change(GetStatus.success(_data));
      return _data;
    }
  }

  void goTo(String s, {scheme}) async {
    if (scheme == null) {
      if (s.contains('sms:')) {
        scheme = 'sms';
      } else if (s.contains('mailto:')) {
        scheme = 'email';
      } else if (s.contains('//wa.me')) {
        scheme = 'whatsapp';
      } else if (s.contains('//t.me')) {
        scheme = 'telegram';
      }
    }

    switch (scheme) {
      case 'your_comments':
        if (await canLaunchUrlString(appInfo!.marketLink)) {
          launchUrlString(appInfo!.marketLink,
              mode: LaunchMode.externalApplication);
        }
        break;
      case 'site':
        if (await canLaunchUrl(Uri.parse(appInfo!.siteLink))) {
          launchUrl(Uri.parse(appInfo!.siteLink),
              mode: LaunchMode.externalApplication);
        }
        break;
      case 'privacy':
        if (await canLaunchUrlString(appInfo!.policyLink)) {
          launchUrlString(appInfo!.policyLink!,
              mode: LaunchMode.externalApplication);
        }
        break;
      case 'email':
        final Uri uri = Uri(
          scheme: 'mailto',
          path: s,
          query:
              'subject=${'message'.tr} ${'from'.tr} ${'user'.tr} ${Get.find<UserController>().user?.phone}&body=', //add subject and body here
        );
        if (await canLaunchUrl(uri)) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'telegram':
        if (await canLaunchUrlString(s)) {
          launchUrlString(s, mode: LaunchMode.externalApplication);
        }
        break;
      case 'instagram':
        if (await canLaunchUrlString(s)) {
          launchUrlString(s, mode: LaunchMode.externalApplication);
        }
        break;
      case 'whatsapp':
        final Uri uri;
        String phone = appInfo!.phone.startsWith('0')
            ? appInfo!.phone.replaceFirst('0', '98')
            : appInfo!.phone;

        if (Platform.isAndroid) {
          uri = Uri.parse("https://wa.me/${phone}"); // new line
        } else {
          uri = Uri.parse(
              "https://api.whatsapp.com/send?phone=${phone}"); // &text=${'message'.tr} ${'from'.tr} ${'user'.tr} ${userController.user?.phone}
        }

        if (await canLaunchUrl(uri)) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'update':
        if (!showUpdateDialogIfRequired()) {
          helper.showToast(msg: 'app_is_updated'.tr, status: 'success');
        }
        break;
      case 'contact_us':
        Get.dialog(ContactUsPage(), barrierDismissible: true);
        break;
      case 'policy':
        final parsedJson = await apiProvider.fetch(
          Variable.LINK_POLICY,
        );
        if (parsedJson?['data'] != null) {
          Get.to(() => Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(style.cardMargin * 2),
                    margin: EdgeInsets.all(style.cardMargin),
                    decoration: BoxDecoration(
                        color: style.secondaryColor,
                        borderRadius:
                            BorderRadius.circular(style.cardBorderRadius)),
                    child: Text(
                      parsedJson?['data'] ?? '',
                      style: style.textMediumStyle,
                    ),
                  ),
                ),
              ));
        }
        break;
      default:
        if (await canLaunchUrlString(s)) {
          launchUrlString(s, mode: LaunchMode.externalApplication);
        }
        break;
    }
  }

  String getDocType(type) {
    return "";
  }

  String? getDocId(List<dynamic>? docs, String type) {
    var t = getDocType(type);

    final Map<String, dynamic>? doc =
        docs?.firstWhereOrNull((el) => el['type_id'] == t);
    if (doc != null) return "${doc['id']}";
    return null;
  }

  String province(dynamic province_id) {
    return '';
  }

  String county(dynamic county_id) {
    return '';
  }

  String expireDays(int timestamp) {
    if (timestamp == -1) {
      return '0';
    } else {
      DateTime currentDate = DateTime.now();
      int milli = timestamp * 1000 - currentDate.millisecondsSinceEpoch;

      if (milli > 0) {
        return ((((milli / 1000) / 60) / 60) / 24).toStringAsFixed(0);
      } else {
        return '0';
      }
    }
  }

  Future<String?> pickAndCrop(
      {required ratio, required MaterialColor colors}) async {
    final ImagePicker _picker = ImagePicker();

    XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      CroppedFile? cp = await ImageCropper().cropImage(
        sourcePath: imageFile.path,

        aspectRatio: ratio != null
            ? CropAspectRatio(ratioX: ratio.toDouble(), ratioY: 1)
            : null,
        // CropAspectRatio(ratioX:ratio cropRatio['profile'].toDouble(), ratioY: 1),
        // aspectRatioPresets: [
        // settingController.getAspectRatio('profile'),

        // ],

        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'select_crop_section'.tr,
              toolbarColor: colors[500],
              toolbarWidgetColor: Colors.white,
              hideBottomControls: false,
              statusBarColor: colors[500],
              initAspectRatio: ratio != null
                  ? CropAspectRatioPreset.square
                  : CropAspectRatioPreset.original,

              // initAspectRatio: settingController
              //     .getAspectRatio('profile'),
              lockAspectRatio: ratio != null),
          IOSUiSettings(
            title: 'select_crop_section'.tr,
          ),
        ],
      );

      if (cp != null) {
        File f = File(cp.path);
        return cp.path;
        return "image/${cp.path.split('.').last};base64," +
            base64.encode(await f.readAsBytes());
      }
    }
    return null;
  }

  bool showUpdateDialogIfRequired() {
    if (!(appInfo?.needUpdate ?? false)) {
      return false;
    } else {
      Get.dialog(
          Center(
            child: Material(
              color: Colors.transparent,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(style.cardBorderRadius))),
                child: Padding(
                  padding: EdgeInsets.all(style.cardMargin),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(style.cardMargin),
                        child: Text(
                          'new_version_exists'.tr,
                          style: style.textBigStyle.copyWith(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(style.cardMargin / 2)),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) {
                                      return states
                                              .contains(MaterialState.pressed)
                                          ? style.secondaryColor
                                          : null;
                                    },
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          style.cardBorderRadius / 2),
                                    ),
                                  ))),
                              onPressed: () async {
                                if (await canLaunchUrl(
                                    Uri.parse(appInfo!.marketLink))) {
                                  launchUrl((Uri.parse(appInfo!.marketLink)),
                                      mode: LaunchMode.externalApplication);
                                }
                                Get.back();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, color: Colors.white),
                                  Text(
                                    'download'.tr,
                                    style: style.textMediumStyle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          barrierDismissible: true);
      return true;
    }
  }

  void resolveDeepLink(Uri? deepLink) async {
    if (deepLink == null) return;

    List<String>? path = deepLink.pathSegments;
    if (path.length == 0) return;
    if (path.length == 1) {
      var model = path[0];
      switch (model) {
        case 'shop':
          Get.to(() => ShopPage());
          break;
      }
    } else if (path.length >= 2) {
      var model = path[0];
      var id = path[1];

      if (path.length == 4 && path.contains('panel') && path.contains('edit')) {
        model = path[1];
        id = path[3];
      }
      switch (model) {
        case 'shop':
          break;
      }
    }
  }

  Future<dynamic> clearImageCache({required String url}) async {
    // apiProvider.fetch(url, method: 'get', headers: {
    //   'Pragma': 'no-cache',
    //   // 'Cache-Control': 'no-cache, no-store',
    //   'X-LiteSpeed-Purge': url,
    //   'Cache-Control': 'max-age=0, no-cache, no-store',
    // });
    return await CachedNetworkImage.evictFromCache(url);
  }

  String category(category_id) {
    var t = categories
        .firstWhereOrNull((element) => "${element['id']}" == "$category_id");
    return t == null ? '' : t['title'];
  }

  copyToClipboard(String text) {
    if (text == '') return;
    Clipboard.setData(ClipboardData(text: text));
    helper.showToast(msg: 'copy_success'.tr, status: 'success');
  }

  @override
  Map<String, dynamic> filters = {};

  bool appLoaded() {
    return appInfo != null;
  }
}
