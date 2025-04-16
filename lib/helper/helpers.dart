import 'dart:core';
import 'dart:core';

import 'package:flutter/foundation.dart';

import 'stubs.dart' if (dart.library.ffi) 'android_ios_stubs.dart';

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/APIProvider.dart';
import 'styles.dart';
import 'variables.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;

enum TYPE { BOORS, CRYPTO, FOREX }

class Helper {
  static late GetStorage box;

  late final Style style;
  static late ApiProvider apiProvider;

  static PackageInfo? packageInfo;

  static AndroidDeviceInfo? androidInfo;
  static var deviceInfo;

  Helper() {
    box = GetStorage();

    style = Get.find<Style>();
    apiProvider = ApiProvider();

    getAndroidInfo();
    getPackageInfo();
  }

  static localStorage({required String key, dynamic def, dynamic write}) {
    if (write != null) {
      box.write(key, write);
    } else {
      return box.read(key) ?? def;
    }
  }

  static Future<AndroidDeviceInfo?> getAndroidInfo() async {
    if (!kIsWeb && Platform.isAndroid)
      androidInfo ??= await DeviceInfoPlugin().androidInfo;
    return androidInfo;
  }

  static Future getDeviceInfo() async {
    if (!kIsWeb && Platform.isAndroid)
      deviceInfo ??= await DeviceInfoPlugin().androidInfo;
    if (kIsWeb) deviceInfo ??= await DeviceInfoPlugin().webBrowserInfo;
    return deviceInfo;
  }

  static Future<PackageInfo?> getPackageInfo() async {
    packageInfo ??= await PackageInfo.fromPlatform();
    return packageInfo;
  }

  showToast({required String msg, String status = 'info'}) {
    final snackBar = Get.snackbar(
      '',
      '',

      overlayBlur: 0,
      userInputForm: Form(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: style.cardMargin, horizontal: style.cardMargin),
          decoration: BoxDecoration(
            color: status == 'danger'
                ? Colors.red
                : status == 'success'
                    ? Colors.green
                    : style.primaryColor,
            // image: DecorationImage(
            //     image: AssetImage("assets/images/frame_button_6.png"),
            //     repeat: ImageRepeat.noRepeat,
            //     fit: BoxFit.fill,
            //     filterQuality: FilterQuality.medium,
            //     opacity: 1),
            borderRadius: BorderRadius.circular(style.cardMargin),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // status == 'danger'
              //     ? const Icon(
              //         Icons.dangerous_outlined,
              //         color: Colors.white,
              //       )
              //     : status == 'success'
              //         ? const Icon(Icons.done, color: Colors.white)
              //         : const Icon(Icons.info_outline, color: Colors.white),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(style.cardMargin * 2),
                  child: Text(
                    '$msg',
                    style: style.textHeaderLightStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      colorText: Colors.white,
      padding: EdgeInsets.all(style.cardMargin / 2),
      margin: EdgeInsets.all(style.cardMargin / 2),
      onTap: (snack) => Get.closeCurrentSnackbar(),
      shouldIconPulse: true,
      borderRadius: style.cardBorderRadius,
      backgroundColor: Colors.transparent,
      // icon: status == 'danger'
      //     ? const Icon(
      //         Icons.dangerous_outlined,
      //         color: Colors.white,
      //       )
      //     : status == 'success'
      //         ? const Icon(Icons.done, color: Colors.white)
      //         : const Icon(Icons.info_outline, color: Colors.white),
      snackPosition: SnackPosition.bottom,
      snackStyle: SnackStyle.grounded,

// messageText: Center(
//   child: Text(
//     msg,
//     style: TextStyle(color: Colors.white),
//   ),
// ),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 300),
// boxShadows: [
//   BoxShadow(
//     color: Colors.black.withOpacity(0.1),
//     spreadRadius: 5,
//     blurRadius: 20,
//     offset: const Offset(0, 6), // changes position of shadow
//   ),
// ],

// backgroundColor: status == 'success'
//     ? Colors.green
//     : status == 'danger'
//         ? Colors.red
//         : style.primaryColor,
    );
  }

  static String toShamsi(date) {
    if (date != null) {
      JalaliFormatter f =
          Jalali.fromDateTime(DateTime.fromMillisecondsSinceEpoch(date * 1000))
              .formatter;
      return e2f(
          " ${f.d} ${f.mN} | ${"${f.date.hour}".padLeft(2, '0')}:${"${f.date.minute}".padLeft(2, '0')}"); //⏰
// int hours = (DateTime.tryParse(date).toUtc().millisecondsSinceEpoch -
//         DateTime.now().millisecondsSinceEpoch) ~/
//     3600000;
// int hours = DateTime.tryParse(date).difference(DateTime.now()).inHours +
//     (DateTime.now().toLocal().hour - DateTime.now().toUtc().hour);
//
// return (hours > 24
//     ? " ${hours ~/ 24} ${Variable.LANG == 'fa' ? 'روز' : 'Day' + (hours ~/ 24 > 1 ? 's' : '')} "
//     : "$hours ${Variable.LANG == 'fa' ? 'ساعت' : 'Hour' + (hours > 1 ? 's' : '')} ")
//     .toString();
    } else
      return "";
  }

  static void shareFile({path, text}) async {
    String dir = (await getTemporaryDirectory()).path;
    File temp = File('$dir/temp.jpg');
    final ByteData imageData =
        await NetworkAssetBundle(Uri.parse(path)).load('');
    final Uint8List bytes = imageData.buffer.asUint8List();
    await temp.writeAsBytes(bytes);
/*do something with temp file*/

    await Share.shareXFiles(
      [XFile(temp.path)],
      text: text,
      subject: 'label'.tr,
    );
    temp.delete();
  }

  static sendLog(params) async {
    if (params?['message'] == null ||
        "${params?['message']}".contains('play()')) return;

    deviceInfo ??= await getDeviceInfo();

    var release = deviceInfo?.version.release ?? deviceInfo?.browserName;
    var sdkInt = deviceInfo?.version.sdkInt ?? deviceInfo?.appVersion;
    var manufacturer = deviceInfo?.manufacturer ?? deviceInfo?.userAgent;
    var model = deviceInfo?.model ?? deviceInfo?.platform;
    var market = Variable.MARKET;
    packageInfo ??= await PackageInfo.fromPlatform();
    String? buildNumber = packageInfo?.buildNumber;

    params['message'] =
        "${Variable.APP_LABEL} ❎ version:$buildNumber\n$model\n$release\n$sdkInt\n$manufacturer\n$market${params['message']}";

    return await apiProvider.fetch(Variable.LINK_SEND_LOG,
        param: params, method: 'post');
  }

  static Future<bool> initPushPole() async {
    return true;

// if (!await PushPole.isPushPoleInitialized()) await PushPole.initialize();
// PushPole.isPushPoleInitialized().then((initialized) async {
//   if (initialized) {
//     // var id = await PushPole.getId();
//     PushPole.subscribe(Variables.LABEL);
//     return true;
//   }
// });
// return false;
  }

  getPushId() async {
    return null;
// return await PushPole.getId();
  }

  static String e2f(String s) {
    var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(RegExp(enNumbers[i]), persianNumbers[i]);
    }
    return s;
  }

  static String f2e(String s) {
    var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(RegExp(persianNumbers[i]), enNumbers[i]);
    }
    return s;
  }

  copyToClipboard(String text) {
    if (text == '') return;
    Clipboard.setData(ClipboardData(text: text));
    showToast(msg: 'copy_success'.tr, status: 'success');
  }

  String decrypt(str) {
    final decrypted;
    Map sec = getFromC();
    final key = Encrypt.Key.fromUtf8(sec['enc_key']);
    final iv = Encrypt.IV.fromUtf8(sec['enc_iv']);

    final encrypter =
        Encrypt.Encrypter(Encrypt.AES(key, mode: Encrypt.AESMode.cbc));
    decrypted = encrypter.decrypt(Encrypt.Encrypted.fromBase64(str), iv: iv);

    return decrypted;
  }

  String encrypt(str) {
    final res;
    Map sec = getFromC();

    final key = Encrypt.Key.fromUtf8(sec['key']);
    final iv = Encrypt.IV.fromUtf8(sec['iv']);

    final encrypter =
        Encrypt.Encrypter(Encrypt.AES(key, mode: Encrypt.AESMode.cbc));
    res = encrypter.encrypt(str, iv: iv);

    return res;
  }
}
