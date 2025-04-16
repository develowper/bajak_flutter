import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../helper/styles.dart';
import 'loader.dart';

class MyTextField extends StatelessWidget {
  final Style style = Get.find<Style>();
  final SettingController setting = Get.find<SettingController>();
  final TextFieldAnimationController animationController =
      TextFieldAnimationController();

  late final Icon icon;
  late final TextEditingController textController;
  Function(String str)? onAction;
  late RxBool loading;
  late EdgeInsets contentPadding;
  late EdgeInsets margin;
  int? minLines;
  int? maxLines;
  late String labelText;
  RxnBool obscure = RxnBool(null);

  late TextInputAction textInputAction;
  late TextInputType textInputType;

  Function? onChanged;

  MyTextField(
      {Icon? icon,
      Function(String str)? onAction,
      TextEditingController? textController,
      this.minLines,
      this.maxLines,
      this.onChanged,
      TextInputAction? textInputAction,
      TextInputType? textInputType,
      EdgeInsets? contentPadding,
      EdgeInsets? margin,
      String? labelText,
      bool? obscure,
      RxBool? loading})
      : super() {
    this.icon = icon ?? const Icon(Icons.search);
    this.textController = textController ?? TextEditingController();
    this.loading = loading ?? RxBool(false);
    this.textInputAction = textInputAction ?? TextInputAction.search;
    this.textInputType = textInputType ?? TextInputType.text;
    this.contentPadding = contentPadding ?? EdgeInsets.all(style.cardMargin);
    this.margin =
        margin ?? EdgeInsets.symmetric(vertical: style.cardMargin / 2);
    this.labelText = labelText ?? '';
    this.obscure = RxnBool(obscure);
    animationController.toggleCloseIcon(this.textController.text.length);

    this.textController.addListener(() {
      animationController.toggleCloseIcon(this.textController.text.length);
      if (onChanged != null) onChanged!(this.textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: margin,
        child: Card(
          color: Colors.white?? style.primaryMaterial[50]! ,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(style.cardMargin ),
              side:   BorderSide(color: style.primaryMaterial[200]!)),
          child: IntrinsicHeight(
            child: Row(children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        if (onAction != null) {
                          onAction!(textController.text);
                        } else if (obscure.value != null) {
                          obscure.value = !obscure.value!;
                        }
                      },
                      icon: icon),
                  VerticalDivider(
                    color: style.primaryMaterial[50],
                    indent: style.cardMargin / 2,
                    endIndent: style.cardMargin / 2,
                  ),
                ],
              ),
              Expanded(
                child: loading.value
                    ? Loader(
                        color: style.primaryColor,
                      )
                    : Obx(
                        () => TextField(
                          obscureText:
                              obscure.value == null || obscure.value == false
                                  ? false
                                  : true,
                          controller: textController,
                          minLines: minLines ?? 1,
                          maxLines: (minLines ?? 0) > 0 ? maxLines : 1,
                          textInputAction: textInputAction,
                          keyboardType: textInputType,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 16),
                          decoration: InputDecoration(
                              labelText: labelText,
                              labelStyle: const TextStyle(
                                  color: Colors.black38, fontSize: 16),
                              isDense: false,
                              contentPadding: contentPadding,
                              hintText: '',
                              border: InputBorder.none),
                          onSubmitted: (str) =>
                              onAction != null ? onAction!(str) : null,
                          // onEditingComplete: () {
                          //   controller.getData(param: {'page': 'clear'});
                          // },
                          // onChanged: (str) {
                          //   animationController.toggleCloseIcon(str.length);
                          //   if (onChanged != null) onChanged!(str);
                          // },
                        ),
                      ),
              ),
              FadeTransition(
                opacity: animationController._fadeShowClearController,
                child: IconButton(
                  splashColor: style.secondaryColor,
                  icon: Icon(Icons.close, color: style.primaryColor),
                  onPressed: () {
                    textController.clear();
                    if (onAction != null) onAction!(textController.text);
                    if (onChanged != null) onChanged!(textController.text);

                    animationController.toggleCloseIcon(0);
                    // textController.getData(params: {'page': '1'});
                    // onSearchTextChanged('');
                  },
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class TextFieldAnimationController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  late AnimationController _fadeShowClearController;

  TextFieldAnimationController() {
    initAnimation();
  }

  @override
  void onInit() {
    super.onInit();
  }

  toggleCloseIcon(int length) {
    if (length > 0) {
      _fadeShowClearController.forward();
    } else if (length == 0) _fadeShowClearController.reverse();
  }

  void initAnimation() {
    _fadeShowClearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }
}
