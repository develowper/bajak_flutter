import 'dart:ui';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Style {
  late ThemeData themeData;
  static String fontFamily = 'Yekan' ?? 'Shabnam' ?? 'Tanha';
  static String fontFamilyHeader = 'Two';
  static String fontFamilyNumbers = 'Carre';
  late bool isBigSize;
  late Function(
      {Color? backgroundColor,
      EdgeInsets? padding,
      double? elevation,
      OutlinedBorder? shape,
      BorderRadius? radius,
      Color? splashColor}) buttonStyle;

  setTheme() {
    themeData = Get.isDarkMode ? ThemeData.dark() : themeData;
    themeData.copyWith(
      primaryColor: primaryColor,
    );
  }

  Style() {
    isBigSize = false;
    themeData = ThemeData(
      primarySwatch: primaryMaterial,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primaryContainer: primaryColor,
        primary: primaryColor,
        onPrimary: primaryMaterial[500]!,
        secondary: secondaryColor,
        secondaryContainer: secondaryColor,
        onTertiary: primaryColor,
        onSecondary: Colors.white,
        error: const Color(0xFFF32424),
        onError: const Color(0xFFF32424),
        background: const Color(0xFFF1F2F3),
        onBackground: Colors.white,
        surface: Colors.white,
        onSurface: primaryColor,
        surfaceTint: Colors.white,
      ),
      splashColor: secondaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: fontFamily,
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true, // this will remove the default content padding
        // now you can customize it here or add padding widget
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
            fontSize: 20.0,
            color: Colors.black87,
            // fontWeight: FontWeight.bold,
            fontFamily: fontFamily),
        titleLarge: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily),
        bodyMedium: TextStyle(
            fontSize: 14.0, color: Colors.black87, fontFamily: fontFamily),
      ),
    );

    buttonStyle = (
        {Color? backgroundColor,
        EdgeInsets? padding,
        double? elevation,
        OutlinedBorder? shape,
        BorderRadius? radius,
        Color? splashColor}) {
      backgroundColor = backgroundColor ?? primaryColor;
      return ButtonStyle(
          elevation: WidgetStatePropertyAll(elevation ?? 2),
          shadowColor: WidgetStatePropertyAll(backgroundColor?.withOpacity(.5)),
          padding:
              WidgetStatePropertyAll(padding ?? EdgeInsets.all(cardMargin)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? backgroundColor?.withOpacity(.6)
                : backgroundColor;
          }),
          overlayColor: WidgetStateProperty.resolveWith(
            (states) {
              return states.contains(WidgetState.pressed)
                  ? (splashColor ?? secondaryColor.withOpacity(.2))
                  : null;
            },
          ),
          shape: WidgetStatePropertyAll(shape ??
              RoundedRectangleBorder(
                side: BorderSide(color: backgroundColor ?? primaryColor),
                borderRadius: radius ??
                    BorderRadius.all(
                      Radius.circular(cardMargin),
                    ),
              )));
    };
  }

  get linksGridCount => isBigSize ? 3 : 2;

  get linksRatio => isBigSize ? 2 : 2.8;

  void setSize(width) {
    isBigSize = width != null && width > 500;
  }

  Color get primaryColor => primaryMaterial[500]!;

  Color get secondaryColor => const Color(0xFFfbe9d7);

  Color get theme1 => const Color(0xff84ffc9);

  Color get theme2 => const Color(0xffaab2ff);

  Color get theme3 => const Color(0xffeca0ff);

  Color get theme4 => const Color(0xfff9c58d);

  Color get theme5 => const Color(0xfff492f0);

  Color get theme6 => const Color(0xFFf6d5f7);

  Color get theme7 => const Color(0xFFfbe9d7);

  Color get theme8 => const Color(0xFF2feaa8);

  Color get theme9 => const Color(0xFF028cf3);

  MaterialColor primaryMaterial = Colors.teal ??
      const MaterialColor(
        0xFF640B1E,
        <int, Color>{
          50: Color(0xFFF4D6DC), // 10% lighter
          100: Color(0xFFEAB0BA), // 20% lighter
          200: Color(0xFFDF8A98), // 30% lighter
          300: Color(0xFFD46476), // 40% lighter
          400: Color(0xFFCA3E54), // 50% lighter
          500: Color(0xFFC01832), // Base color - 60%
          600: Color(0xFFA8142C), // 70% darker
          700: Color(0xFF640B1E), // Base color - Index 700
          800: Color(0xFF590A1B), // 90% darker
          900: Color(0xFF4E0818), // 100% darker
        },
      );

  get mainShadow => [
        BoxShadow(
          color: primaryMaterial[100]!.withOpacity(0.8),
          blurRadius: 8.0,
          spreadRadius: 2,
        ),
      ];

  get theme => themeData;

  double get tabHeight => isBigSize ? 128.0 : 96.0;

  double get cardMargin => isBigSize ? 12.0 : 8.0;

  get cardColor => Colors.white.withOpacity(1);

  get iconHeight => 50.0;

  get topOffset => Get.height / 4;

  get cardBorderRadius => 20.0;

  get buttonBorderRadius => 8.0;

  get cardVitrinHeight => 200.0;

  get imageHeight => isBigSize ? 160.0 : 140.0;

  double get gridHeight => isBigSize ? 164.0 : 148.0;

  double get buttonHeight => isBigSize ? 72.0 : 64.0;

  TextStyle get textBigLightStyle => TextStyle(
      color: secondaryColor,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamilyHeader);

  TextStyle get textBigStyle => TextStyle(
      color: primaryMaterial[500],
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamilyHeader);

  TextStyle get textHeaderLightStyle => TextStyle(
      color: secondaryColor,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamilyHeader);

  TextStyle get textHeaderStyle => TextStyle(
      color: primaryColor,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamilyHeader);

  TextStyle get textHeaderNumberStyle => TextStyle(
      color: primaryColor,
      fontSize: 48,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamilyNumbers);

  TextStyle get textMediumNumberStyle => TextStyle(
      color: primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyNumbers);

  TextStyle get textMediumNumberLightStyle => TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyNumbers);

  TextStyle get textHeaderNumberLightStyle => TextStyle(
      color: Colors.white,
      fontSize: 48,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamilyNumbers);

  TextStyle get textTinyLightStyle =>
      TextStyle(color: secondaryColor, fontSize: 10);

  TextStyle get textTinyStyle => TextStyle(color: primaryColor, fontSize: 10);

  TextStyle get textSmallStyle => TextStyle(
        color: primaryMaterial[800],
        fontSize: 14,
      );

  TextStyle get textSmallLightStyle => const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );

  TextStyle get textMediumLightStyle =>
      TextStyle(color: Colors.white, fontSize: 18, fontFamily: fontFamily);

  TextStyle get textMediumStyle =>
      TextStyle(color: primaryColor, fontSize: 18, fontFamily: fontFamily);

  LinearGradient get splashBackground => LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [theme1, theme2, theme3]);

  LinearGradient get splashBackgroundReverse => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryMaterial[900]!,
            primaryMaterial[700]!,
            secondaryColor,
          ]);

  // ButtonStyle get buttonStyle =>
  //     ButtonStyle(backgroundColor:  WidgetStatePropertyAll(primaryColor));

  LinearGradient get mainGradientBackground => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primaryColor, primaryMaterial[200]!, primaryMaterial[900]!]);

  LinearGradient get cardGradientBackground => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryMaterial[400]!,
            primaryMaterial[600]!,
          ]);

  LinearGradient get cardGradientBackgroundReverse => LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.white,
            theme7,
          ]);

  double get bottomNavigationBarHeight => 70.0;

  MaterialColor get boorsMaterial => primaryMaterial;

  MaterialColor get cardNewsColors => primaryMaterial;

  MaterialColor get cardContentColors => Colors.blueGrey;

  MaterialColor get cardLawyerColors => Colors.indigo;

  MaterialColor get cardLocationColors => Colors.teal;

  MaterialColor get cardLegalColors => Colors.brown;

  MaterialColor get cardVotesColors => Colors.indigo;

  MaterialColor get cardOpinionsColors => Colors.teal;

  MaterialColor get cardConventionsColors => Colors.brown;

  MaterialColor get cardPlayerColors => Colors.blueGrey;

  MaterialColor get cardLinkColors => Colors.pink;

  MaterialColor get cardClubColors => Colors.indigo;

  MaterialColor get cardShopColors => Colors.brown;

  MaterialColor get cardProductColors => Colors.purple;

  MaterialColor get cardTournamentColors => Colors.orange;

  int get gridLength => 1;
}
