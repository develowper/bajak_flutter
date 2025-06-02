import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helper/variables.dart';

class App {
  final String phone;
  final String versionName;
  int? versionUpdate;
  final String appLink;
  final String? logLink;
  final String commentsLink;
  final String telegramLink;
  final String instagramLink;
  final String siteLink;
  final String emailLink;
  final String eitaaLink;
  final String marketLink;
  final String policyLink;
  final String updateMessage;
  final String updateLink;
  final List questions;
  String whatsappLink;
  String? appName;
  String? packageName;
  String? buildNumber;
  bool needUpdate;
  final List supportLinks;

  String? socketLink;

  App({
    this.phone = '',
    this.versionName = '1.0.0',
    this.appLink = '',
    this.logLink,
    this.commentsLink = '',
    this.telegramLink = '',
    this.instagramLink = '',
    this.siteLink = '',
    this.emailLink = '',
    this.eitaaLink = '',
    this.whatsappLink = '',
    this.marketLink = '',
    this.policyLink = '',
    this.updateMessage = '',
    this.updateLink = '',
    this.versionUpdate,
    this.questions = const [],
    this.supportLinks = const [],
    this.appName,
    this.packageName,
    this.buildNumber,
    this.needUpdate = false,
    this.socketLink,
  });

  factory App.fromJson(Map<String, dynamic> json, PackageInfo packageInfo) {
    // print(packageInfo.version); //1.0.0
    // print(packageInfo.appName); // دبل اسپورت
    // print(packageInfo.packageName); //com.varta.hamsignal
    // print( json['links']?['market']); //
    // print('**********************');
    // print(json['support_links']);

    return App(
        socketLink: json['links']?['socket'] ?? Variable.DOMAIN,
        needUpdate: int.tryParse("${json['app_info']?['version']}") == null
            ? false
            : int.tryParse(packageInfo.buildNumber) == null
                ? false
                : int.parse(packageInfo.buildNumber) <
                        int.parse("${json['app_info']?['version']}")
                    ? true
                    : false,
        versionName: packageInfo.version,
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        buildNumber: packageInfo.buildNumber,
        phone: json['phone'] ?? '',
        updateMessage:
            json['app_info']?['update_message'] ?? 'new_version_exists'.tr,
        updateLink: json['app_info']?['update_link'] ?? '',
        versionUpdate: json['version'] ?? null,
        supportLinks: json['support_links'] ?? [],
        policyLink: json['links']?['policy'] ?? '',
        emailLink: json['links']?['email'] ?? '',
        appLink: json['links']?['app'] ?? '',
        logLink: json['links']?['log'],
        siteLink: json['links']?['site'] ?? '',
        eitaaLink: json['links']?['eitaa'] ?? '',
        commentsLink: json['links']?['comment'] ?? '',
        telegramLink: json['links']?['telegram'] ?? '',
        instagramLink: json['links']?['instagram'] ?? '',
        marketLink: json['links']?['market']?[Variable.MARKET] ?? '',
        questions: (json['questions'] ?? []).map((e) {
          e['visible'] = false.obs;
          return e;
        }).toList());
  }
}
