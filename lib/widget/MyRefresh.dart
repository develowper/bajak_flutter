import 'package:games/helper/styles.dart';
import 'package:games/widget/AnimatedButton.dart';
import 'package:games/widget/MyButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyRefresh extends StatelessWidget {
  final String? text;
  final Color? textColor;
  final Function? onRefresh;
  Style style = Get.find<Style>();

  MyRefresh({super.key, this.text, this.onRefresh, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedButton(
          buttonStyle:
              style.buttonStyle(padding: EdgeInsets.all(style.cardMargin * 2)),
          onTap: onRefresh,
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: style.cardMargin * 2,
                  color: textColor != null ? textColor : Colors.white,
                ),
                SizedBox(width: style.cardMargin),
                Text(text ?? "no_result".tr,
                    style: textColor != null
                        ? style.textMediumLightStyle.copyWith(color: textColor)
                        : style.textMediumLightStyle),
              ],
            ),
          ),
        )
      ],
    );
  }
}
