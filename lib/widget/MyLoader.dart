import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class MyLoader extends StatelessWidget {
  List<String> images = [];
  final currentIndex = 0.obs;

  MyLoader() {
    images = [
      'assets/images/loader/load_0.png',
      'assets/images/loader/load_1.png',
      'assets/images/loader/load_2.png',
      'assets/images/loader/load_3.png',
      'assets/images/loader/load_4.png',
      'assets/images/loader/load_5.png',
    ];
    final binding = WidgetsFlutterBinding.ensureInitialized();

    binding.addPostFrameCallback((_) async {
      BuildContext context = binding.rootElement as BuildContext;
      if (context != null) {
        for (var asset in images) {
          precacheImage(AssetImage(asset), context);
        }
      }
    });
    startTimer();
  }

  startTimer() async {
    // await Future.delayed(const Duration(milliseconds: 500));
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      currentIndex.value = (currentIndex.value + 1) % images.length;
    });
  }

  // Reactive variable to hold current index

  // List of image paths

  // Timer to change the image periodically

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        return Image.asset(images[currentIndex.value]);
      }),
    );
  }
}
