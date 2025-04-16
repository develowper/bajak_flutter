import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

extension RangeExtension on int {
  List<int> to(int max, {int step = 1}) =>
      [for (int i = this; i <= max; i += step) i];
}

extension StringExtension on String {
  String asPrice() =>
      this.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) {
        return '${m[1]},';
      });

  String toEng() {
    var s = this;
    var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(RegExp(persianNumbers[i]), enNumbers[i]);
    }
    return s;
  }

  String toFa() {
    var s = this;
    var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(RegExp(enNumbers[i]), persianNumbers[i]);
    }
    return s;
  }

  num parseFloat() {
    double tmp = double.tryParse("$this") ?? 0;
    if (tmp % 1 == 0) return tmp.toInt();
    return tmp;
  }

  Color toColor() {
    String hex = this ?? "#000";
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }
}

// extension numberExtension on dynamic {
//   String parseFloat() {
//     double tmp = double.tryParse("$this") ?? 0;
//     if (tmp % 1 == 0) return tmp.toStringAsFixed(0);
//
//     return "$tmp";
//   }
// }
extension numberExtension on dynamic {
  num parseFloat() {
    double tmp = double.tryParse("$this") ?? 0;
    if (tmp % 1 == 0) return tmp.toInt();
    return tmp;
  }

  String toShamsi() {
    var date = this;
    if (date != null && date is String) date = DateTime.tryParse(date);

    if (date != null) {
      JalaliFormatter f = (date is DateTime
              ? Jalali.fromDateTime(date)
              : Jalali.fromDateTime(
                  DateTime.fromMillisecondsSinceEpoch(date * 1000)))
          .formatter;
      return " ${f.d} ${f.mN} | ${"${f.date.hour}".padLeft(2, '0')}:${"${f.date.minute}".padLeft(2, '0')}"
          .toFa();
    }
    return "";
  }
}
