import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:games/helper/variables.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class MyDialog extends StatelessWidget {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  Style style = Get.find<Style>();

  final String message;
  final String? okText;
  final VoidCallback? onOkPressed;
  final VoidCallback? onCancelPressed;

  Widget? widget;

  String type;
  late Color color;

//  final Function(int) onOkPressed;

  MyDialog(
      {required this.message,
      this.widget,
      this.onOkPressed,
      this.onCancelPressed,
      this.type = 'info',
      String? this.okText}) {
    color = style.primaryColor;
    if (this.type == 'danger') {
      color = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: style.cardMargin),
                    child: widget,
                  ),
                if (widget == null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: style.cardMargin),
                    child: Text(
                      message,
                      style: style.textBigStyle.copyWith(color: color),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: Variable.LANG == 'fa'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: <Widget>[
                    //cancel button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Get.until((route) => Get.currentRoute == '/');
                          Get.back();
                          onCancelPressed != null ? onCancelPressed!() : null;
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered) ||
                                states.contains(MaterialState.pressed)) {
                              return Colors.white70;
                            } else {
                              return onOkPressed != null ? Colors.white : color;
                            }
                          }),

                          shadowColor:
                              MaterialStateProperty.all(Colors.black54),
                          elevation: MaterialStateProperty.all(3),
                          padding: MaterialStateProperty.all(EdgeInsets.all(4)),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                            Radius.circular(style.cardMargin),
                          ))),
                          // minimumSize: Size(100, 40), //////// HERE
                        ),
                        icon: Icon(
                          onOkPressed == null ? Icons.check : Icons.clear,
                          color: onOkPressed != null
                              ? Colors.black54
                              : Colors.white,
                          textDirection: TextDirection.rtl,
                        ),
                        label: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            onOkPressed != null ? 'cancel'.tr : 'ok'.tr,
                            style: style.textMediumStyle.copyWith(
                                color: onOkPressed != null
                                    ? Colors.black54
                                    : Colors.white),
                          ),
                        ),
                      ),
                    ),
                    if (onOkPressed != null)
                      SizedBox(
                        width: 4,
                      ),
                    //accept button
                    if (onOkPressed != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered) ||
                                  states.contains(MaterialState.pressed)) {
                                return Colors.white38;
                              } else {
                                return color;
                              }
                            }),

                            shadowColor:
                                MaterialStateProperty.all(Colors.black54),
                            elevation: MaterialStateProperty.all(3),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(4)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(style.cardMargin)))),
                            // minimumSize: Size(100, 40), //////// HERE
                          ),
                          onPressed: () async {
                            onOkPressed!();
                          },
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                            textDirection: TextDirection.rtl,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              okText ?? 'ok'.tr,
                              style: style.textMediumStyle
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
