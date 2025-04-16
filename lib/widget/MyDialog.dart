import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';
import '../helper/variables.dart';

class MyDialog extends StatefulWidget {
  final BuildContext context;
  final String message;

//  final String okText;
//  final EnumProperty type;
  final String? okText;
  final VoidCallback? onOkPressed;
  final VoidCallback onCancelPressed;
  final StatefulWidget? widget;

//  final Function(int) onOkPressed;

  MyDialog(
      {required this.context,
      required this.message,
      this.widget,
      this.onOkPressed,
      required this.onCancelPressed,
      String? this.okText});

  @override
  State<StatefulWidget> createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  late final Style style;

  @override
  void initState() {
    super.initState();
    style = Get.find<Style>();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(style.isBigSize ? 42 : 16),
          margin: EdgeInsets.symmetric(horizontal: style.isBigSize ? 32 : 16),
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: widget.widget,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  widget.message,
                  textDirection: Variable.LANG == 'fa'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: style.textMediumStyle,
                ),
              ),
              Row(
                textDirection: Variable.LANG == 'fa'
                    ? TextDirection.ltr
                    : TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //cancel button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(widget.context);
                        widget.onCancelPressed();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.hovered) ||
                              states.contains(WidgetState.pressed)) {
                            return Colors.white70;
                          } else {
                            return widget.onOkPressed != null
                                ? Colors.grey
                                : style.primaryColor;
                          }
                        }),

                        shadowColor:
                            const WidgetStatePropertyAll(Colors.black54),
                        elevation: const WidgetStatePropertyAll(3),
                        padding:
                            const WidgetStatePropertyAll(EdgeInsets.all(4)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: const Radius.circular(10.0),
                                right: Radius.circular(
                                    widget.onOkPressed == null ? 10.0 : 0)))),
                        // minimumSize: Size(100, 40), //////// HERE
                      ),
                      icon: Icon(
                        widget.onOkPressed == null ? Icons.check : Icons.clear,
                        color: Colors.white,
                        textDirection: TextDirection.rtl,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.onOkPressed != null ? 'cancel'.tr : 'ok'.tr,
                          style: style.textMediumLightStyle,
                        ),
                      ),
                    ),
                  ),
                  if (widget.onOkPressed != null)
                    const SizedBox(
                      height: 4,
                    ),
                  //accept button
                  widget.onOkPressed != null
                      ? Expanded(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              overlayColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.hovered) ||
                                    states.contains(WidgetState.pressed)) {
                                  return style.secondaryColor;
                                } else {
                                  return style.primaryColor;
                                }
                              }),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.hovered) ||
                                    states.contains(WidgetState.pressed)) {
                                  return style.secondaryColor;
                                } else {
                                  return style.primaryColor;
                                }
                              }),
                              shadowColor:
                                  const WidgetStatePropertyAll(Colors.black54),
                              elevation: const WidgetStatePropertyAll(3),
                              padding: const WidgetStatePropertyAll(
                                  EdgeInsets.all(4)),
                              shape: const WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(10.0)))),
                              // minimumSize: Size(100, 40), //////// HERE
                            ),
                            onPressed: () async {
                              widget.onOkPressed!();
                            },
                            icon: const Icon(
                              Icons.check,
                              color: Colors.white,
                              textDirection: TextDirection.rtl,
                            ),
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.okText ?? 'OK',
                                style: style.textMediumLightStyle,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
