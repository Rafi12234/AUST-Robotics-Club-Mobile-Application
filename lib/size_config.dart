import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    // optional "block" units for convenience (like 1% of screen)
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }
}
