import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_telegram_web_app/flutter_telegram_web_app.dart' as tg;
import 'package:flutter_telegram_web_app/flutter_telegram_web_app.dart';
import 'package:get/get.dart';

/*
  add this line in web/index.html

<head>
....
<script src="https://telegram.org/js/telegram-web-app.js" defer></script>
</head>
*/
class TelegramService {
  static bool _scriptInjected = false;
  bool isStateStable = true;

  static init() async {
    await tg.ready();

    if (!tg.BackButton.isVisible) await tg.BackButton.show();
    tg.BackButton.onClick(JsVoidCallback(() {
      // we can also use onEvent(TelegramWebEventType.backButtonClicked)
      Get.back();
    }));
  }

  /// Inject Telegram WebApp JS script dynamically
// static Future<void> injectScript() async {
//   if (_scriptInjected) return; // Avoid duplicate injection
//   try {
//     // Load the script content from assets
//     String scriptContent =
//         await rootBundle.loadString('assets/js/telegram-web-app.js');
//
//     // Create a script element
//     final script = ScriptElement();
//     script.text = scriptContent;
//     document.head!.append(script);
//
//     _scriptInjected = true;
//     print("Telegram script injected from assets.");
//   } catch (e) {
//     print("Failed to inject Telegram script: $e");
//   }
// }
//
// /// Show the Telegram Mini App back button
// static showBackButton() async {
//   if (!kIsWeb) return;
//   await injectScript();
//
//   if (js.context.hasProperty('Telegram')) {
//     js.context.callMethod('eval', ['Telegram.WebApp.BackButton.show();']);
//     js.context.callMethod('eval', [
//       'Telegram.WebApp.BackButton.onClick(() => { window.flutter_inappwebview.callHandler("onBackPressed"); });'
//     ]);
//     print("Back button shown.");
//   } else {
//     print("Telegram API is not available.");
//   }
//   // Ensure script is loaded
// }
}
