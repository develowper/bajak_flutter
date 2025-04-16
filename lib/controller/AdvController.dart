import 'dart:convert';
import 'dart:io';

import 'package:adivery/adivery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tapsell_plus/NativeAdPayload.dart';
import 'package:tapsell_plus/tapsell_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:adivery/adivery_ads.dart' as Adivery;

import '../helper/helpers.dart';
import '../helper/variables.dart';
import '../model/adv.dart';
import '../widget/MyNetWorkImage.dart';
import 'APIProvider.dart';
import 'SettingController.dart';
import 'UserController.dart';

class AdvController extends GetxController with StateMixin<Map> {
  List<AdvItem> _data = [];
  bool loading = false;

  int maxFailedLoadAttempts = 3;

  int get currentLength => _data.length;

  List<AdvItem> get data => _data;

  set data(List<AdvItem> value) {
    _data = value;
  }

  late ApiProvider apiProvider;
  late SettingController settingController;
  late UserController userController;
  late Helper helper;

  static AdRequest targetInfo = AdRequest(
    keywords: <String>[
      'game',
      'بازی',
      'car',
      'خودرو',
    ],
    // contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  AdiveryNativeAdWidget? nativeAdWidgetAdivery;
  Widget? nativeAdWidgetTapsell;
  AdmobAdWidget? nativeAdWidgetAdmob;
  int _numNativeLoadAttempts = 0;

  late Adivery.NativeAd nativeAdAdivery;
  NativeAd? nativeAdAdmob;

  AdvController() {}
  var cna;

  initialize() {
    MobileAds.instance.initialize();
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();

    initAdvertisers();
    cna = createNativeAdv();
  }

  Widget nativeAdv() {
    return FutureBuilder(
      future: cna,
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        if (!snapshot.hasError && snapshot.hasData) return snapshot.data!;

        return Center();
      },
    );
  }

  Future<Widget?> createNativeAdv() async {
    String type = settingController.adv["types"]['native'] ?? '';
    _numNativeLoadAttempts = 0;
    // try {
    await Helper.getDeviceInfo();

    // type = 'tapsell';
    // type = 'my';
    // type = 'admob';
    print("****type********$type");
    if (Helper.deviceInfo == null || Helper.deviceInfo!.sdkInt < 20)
      return Center();
    if (type == 'tapsell') {
      if (nativeAdWidgetTapsell == null) {
        dynamic responseId = null;
        await TapsellPlus.instance.requestNativeAd(
            /*'5cfaa9deaede570001d5553a'*/
            settingController.adv[type]['native'], onResponse: (res) async {
          responseId = res;
          print("******tapsell onResponse    ${responseId}");
          if (responseId != null && responseId.runtimeType != String)
            responseId = responseId['response_id'];
          // if (responseId != null)

          TapsellPlus.instance.showNativeAd(
            responseId,
            admobFactoryId: 'adFactoryExample',
            onOpened: (nativeAd) {
              // print("******tapsell type   ${nativeAd.runtimeType}");
              // print("******tapsell loaded   ${nativeAd}");
              if (nativeAd is GeneralNativeAdPayload) {
                print(nativeAd.ad.iconUrl);
                nativeAdWidgetTapsell = TapsellNativeAdWidget(
                    responseId: nativeAd.ad.responseId ?? '',
                    title: nativeAd.ad.title ?? '',
                    description: nativeAd.ad.description ?? '',
                    callToAction: nativeAd.ad.callToActionText ?? '',
                    iconUrl: nativeAd.ad.iconUrl ?? '',
                    portraitImageUrl: nativeAd.ad.portraitImageUrl ?? '',
                    landScapeImageUrl: nativeAd.ad.landscapeImageUrl ?? '',
                    onClick: () => Get.back());
              } else if (nativeAd is AdMobNativeAdPayload) {
              } else if (nativeAd is AdMobNativeAdViewPayload) {
                nativeAdWidgetTapsell = AdWidget(ad: nativeAd.nativeAdView!);
              }

              return nativeAdWidgetTapsell;
              // return nativeAdTapsell;
            },
            onError: (map) {
              print('******tapsell Ad error - Error: $map');
            },
          );
        }, onError: (res) {
          print("******tapsell error   ${res}");
        });
        print("******tapsell response    ${responseId}");
      }
      await Future.delayed(Duration(seconds: 5));
      nativeAdWidgetTapsell = nativeAdWidgetTapsell;

      return nativeAdWidgetTapsell;
    } else if (type == 'adivery') {
      if (nativeAdWidgetAdivery == null) {
        nativeAdAdivery = Adivery.NativeAd(
            settingController.adv["$type"]['native'], onAdLoaded: () {
          nativeAdWidgetAdivery =
              AdiveryNativeAdWidget(nativeAd: nativeAdAdivery);
        }, onError: (error) {
          print("****Adivery native ad error $error");
        });
        nativeAdAdivery.loadAd();
      }
      return nativeAdWidgetAdivery;
      //
    } else if (type == 'admob') {
      bool nativeAdLoaded = false;
      nativeAdAdmob ??= NativeAd(
        // adUnitId: 'ca-app-pub-3940256099942544/2247696110',
        adUnitId: settingController.adv["$type"]['native'],
        request: targetInfo,
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            print('******  admob Loaded - $ad');
            if (nativeAdWidgetAdmob == null && nativeAdAdmob != null)
              nativeAdWidgetAdmob = AdmobAdWidget(
                nativeAd: nativeAdAdmob!,
              );
            update();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) async {
            print('******* $ad failedToLoad: $error');
            ad.dispose();
            if (nativeAdWidgetAdmob == null &&
                _numNativeLoadAttempts < maxFailedLoadAttempts) {
              _numNativeLoadAttempts++;
              print('*******attemptAdmob load');
              await Future.delayed(Duration(seconds: 1));
              nativeAdAdmob?.load();
            }
            // settingController.adv.type['native'] = null;
            return Center();
          },
          onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
        ),
      );

      print(
          '*******attemptAdmob $_numNativeLoadAttempts < $maxFailedLoadAttempts');
      nativeAdAdmob?.load();
      await Future.delayed(Duration(seconds: 5));

      // print('*******nativeAdWidgetAdmobLoaded $nativeAdLoaded');
      // await Future.delayed(Duration(seconds: 5));

      // if (nativeAdWidgetAdmob == null &&
      //     _numNativeLoadAttempts < maxFailedLoadAttempts) {
      //   print('*******attemptAdmob load');
      //
      //
      // }
      // _numNativeLoadAttempts++;

      return nativeAdWidgetAdmob;
    } else if (type == 'my') {
      var adv = await getAdvItem();
      if (adv['banner_link'] == null) return null;
      return Container(
        decoration: BoxDecoration(),
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
      return Center();
    // } on MissingPluginException catch (error) {
    //   print('******  Error native ad - $error');
    //   return MyAdv();
    //   // Helper.settings['native_adv_provider'] = 'tapsell';
    // } catch (error) {
    //   print('******  catch native ad - $error');
    //   // Helper.settings['native_adv_provider'] = 'tapsell';
    //   return MyAdv();
    // }
  }

  createInterstitial() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? settingController.adv['admob']['interstitial']
            : 'ca-app-pub-3940256099942544/4411468910',
        request: targetInfo,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitial();
            }
          },
        ));
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitial();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitial();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void createRewarded({onError, onLoaded, onRewarded, type, attempts}) {
    type = type ?? settingController.adv["types"]['rewarded'] ?? '';
    _numRewardedLoadAttempts = attempts ?? 0;
    // type = 'tapsell';
    if (type == 'admob') {
      print('*********************create rewarded');

      RewardedAd.load(
          adUnitId: Platform.isAndroid
              ? settingController.adv['admob']['rewarded'] ??
                  'ca-app-pub-3940256099942544/5224354917'
              : 'ca-app-pub-3940256099942544/1712485313',
          request: targetInfo,
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              print('$ad loaded.');
              _rewardedAd = ad;
              _numRewardedLoadAttempts = 0;
              //
              _rewardedAd?.fullScreenContentCallback =
                  FullScreenContentCallback(
                onAdShowedFullScreenContent: (RewardedAd ad) =>
                    print('--------ad onAdShowedFullScreenContent.'),
                onAdDismissedFullScreenContent: (RewardedAd ad) {
                  print('---------$ad onAdDismissedFullScreenContent.');
                  ad.dispose();
                  // createRewarded();
                },
                onAdFailedToShowFullScreenContent:
                    (RewardedAd ad, AdError error) {
                  print(
                      '--------$ad onAdFailedToShowFullScreenContent: $error');
                  ad.dispose();
                  // createRewarded();
                },
              );

              _rewardedAd?.setImmersiveMode(true);
              _rewardedAd?.show(
                  onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                print(
                    '----------$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
                onRewarded(reward);
              });
              _rewardedAd = null;
              onLoaded();
            },
            onAdFailedToLoad: (LoadAdError error) {
              print(
                  '---------RewardedAd failed to load: $error try $_numRewardedLoadAttempts');
              _rewardedAd = null;
              _numRewardedLoadAttempts += 1;
              if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
                createRewarded(
                    onLoaded: onLoaded,
                    onError: onError,
                    type: 'admob',
                    attempts: _numRewardedLoadAttempts);
              } else {
                _numRewardedLoadAttempts = 3;
                createRewarded(
                    onLoaded: onLoaded, onError: onError, type: 'tapsell');
                // onError(error.message);
              }
              // onError(error.message);
            },
          ));
    } else if (type == 'tapsell') {
      TapsellPlus.instance
          .requestRewardedVideoAd(settingController.adv['tapsell']['rewarded'])
          .then((value) {
        if (value.isNotEmpty) {
          TapsellPlus.instance.showRewardedVideoAd(value, onOpened: (map) {
            print("-------------tapsell onLoaded");
            onLoaded();
          }, onError: (map) {
            onError(map);
          }, onRewarded: (map) {
            print("-------------tapsell onRewarded");
            onRewarded(map);
          });
        }
      });
    }
  }

  void showRewarded(RewardedAd rewardedAd,
      {required Function(dynamic reward) onReward}) {
    // if (_rewardedAd == null) {
    //   print('Warning: attempt to show rewarded before loaded.');
    //   return;
    // }
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createRewarded();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewarded();
      },
    );

    rewardedAd!.setImmersiveMode(true);
    rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onReward(reward);
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
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

  void advClicked(id) async {
    var parsedJson = await apiProvider.fetch(
      Variable.LINK_ADV_CLICK,
      param: {'id': id},
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      method: 'post',
    );
    // print(parsedJson);
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/5354046379'
            : 'ca-app-pub-3940256099942544/6978759866',
        request: targetInfo,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

  void showRewardedInterstitial() {
    if (_rewardedInterstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedInterstitialAd = null;
  }

  Future getData({Map<String, dynamic>? param}) async {
    loading = true;
    // settingController.adv.nativeWidget = await createNativeAdv();

    change(GetStatus.success(settingController.adv));
    loading = false;
    update();
  }

  initAdvertisers() async {
    if (kIsWeb) return;
    initAdmob();
    // initAdivery();
    initTapsell();
  }

  initAdmob() async {
    MobileAds.instance.initialize();
  }

  initAdivery() async {
    AdiveryPlugin.initialize(settingController.adv['adivery']['key']);
  }

  initTapsell() async {
    await TapsellPlus.instance
        .initialize(settingController.adv['tapsell']['key']);
  }

  @override
  onInit() {
    // getData();

    super.onInit();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    super.dispose();
  }
}

class TapsellNativeAdWidget extends StatelessWidget {
  final String responseId;
  final String title;
  final String description;
  final String callToAction;
  final String iconUrl;
  final String portraitImageUrl;
  final String landScapeImageUrl;
  final Function onClick;

  TapsellNativeAdWidget(
      {required this.responseId,
      required this.title,
      required this.description,
      required this.callToAction,
      required this.iconUrl,
      required this.portraitImageUrl,
      required this.landScapeImageUrl,
      required this.onClick}) {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        TapsellPlus.instance.nativeBannerAdClicked(responseId);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        //
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: CachedNetworkImage(
          imageUrl: landScapeImageUrl.replaceFirst('https:', 'http:'),
          fit: BoxFit.fill,
          errorWidget: (BuildContext context, object, dynamic stacktrace) =>
              Center(
            child: Center(),
          ),
        ),
      ),
    );
  }
}

class AdiveryNativeAdWidget extends StatelessWidget {
  final Adivery.NativeAd nativeAd;

  AdiveryNativeAdWidget({
    required this.nativeAd,
  });

  @override
  Widget build(BuildContext context) {
    // if (nativeAd != null && nativeAd.isLoaded) {
    return InkWell(
      splashColor: Colors.white70,
      onTap: () async {
        nativeAd.recordClick();
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: nativeAd.image,
      ),
    );
    // } else {
    //   return MyAdv();
    // }
  }
}

class AdmobAdWidget extends StatelessWidget {
  final AdWithView nativeAd;

  AdmobAdWidget({
    required this.nativeAd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // clipBehavior: Clip.antiAlias,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: AdWidget(
        ad: nativeAd,
      ),
    );
  }
}
