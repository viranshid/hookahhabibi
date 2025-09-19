import 'package:flutter/material.dart';

/// Used by [AppColors] of app and web
class AppColors {
  static const colorTransparent = Color(0x00000000);
  static const colorBlack = Color(0xFF000000);

  // New colors from your palette
  static const color171717 = Color(0xFF171717);
  static const color2B2B2B = Color(0xFF2B2B2B);
  static const color484848 = Color(0xFF484848);
  static const color949494 = Color(0xFF949494);
  static const colorBD7D28 = Color(0xFFBD7D28);
  static const colorB3B3B3 = Color(0xFFB3B3B3);
  static const colorFFFFFF = Color(0xFFFFFFFF); // Already exists as colorWhite

  // Your existing gradients
  static const linearGradientFB9400FFAB38 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB9400), Color(0xFFFFAB38)],
  );

  static const linearGradient5A8D9D265260 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5A8D9D), Color(0xFF265260)],
  );
}