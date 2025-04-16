import 'package:games/widget/AnimatedButton.dart';

import 'package:games/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class MyButton extends StatelessWidget {
  Style style = Get<Style>();

  String label;
  Color? labelColor;
  TextStyle? labelStyle;
  Color? backgroundColor;
  Function? onPressed;
  ButtonStyle? buttonStyle;
  RxBool isLoading = false.obs;
  bool isSecondary = false;
  int? themeId;

  EdgeInsets? padding;

  MyButton(
      {super.key,
      required this.label,
      this.labelColor,
      this.labelStyle,
      this.backgroundColor,
      this.onPressed,
      themeId,
      this.padding,
      this.isSecondary = false,
      this.buttonStyle}) {
    this.themeId;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      child: Container(
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: style.cardMargin,
              horizontal: style.cardMargin,
            ),
        decoration: BoxDecoration(
          image: themeId != null
              ? DecorationImage(
                  image:
                      AssetImage("assets/images/frame_button_${themeId}.png"),
                  repeat: ImageRepeat.noRepeat,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                  opacity: 1)
              : null,
        ),
        child: Obx(
          () => isLoading.value
              ? Loader(
                  color: Colors.white,
                )
              : Text(
                  label,
                  style: style.textMediumLightStyle
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
      onTap: () async {
        if (onPressed == null) return;
        isLoading.value = true;
        await onPressed!();
        isLoading.value = false;
      },
      buttonStyle: style.buttonStyle(),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: style.cardMargin),
      child: TextButton(
          style: buttonStyle ??
              style.buttonStyle(
                backgroundColor: backgroundColor ??
                    (isSecondary ? Colors.white : style.primaryColor),
                radius: BorderRadius.all(
                  Radius.circular(style.buttonBorderRadius),
                ),
              ),
          onPressed: () async {
            if (onPressed == null) return;
            isLoading.value = true;
            await onPressed!();
            isLoading.value = false;
          },
          child: Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(vertical: style.cardMargin),
              child: isLoading.value
                  ? Loader(
                      color: labelColor ??
                          (isSecondary ? style.primaryColor : Colors.white),
                    )
                  : Text(
                      label,
                      style: (labelStyle ??
                              (labelColor != null
                                  ? style.textHeaderStyle
                                      .copyWith(color: labelColor)
                                  : isSecondary
                                      ? style.textHeaderStyle
                                      : style.textHeaderLightStyle))
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
            ),
          )),
    );
  }
}
