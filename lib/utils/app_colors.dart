import 'package:flutter/material.dart';

/// Used by [AppColors] of app and web
class AppColors {
  static const colorTransparent = Color(0x00000000);
  static const colorBlack = Color(0xFF000000);

  // Existing colors from your palette
  static const color171717 = Color(0xFF171717);
  static const color2B2B2B = Color(0xFF2B2B2B);
  static const color484848 = Color(0xFF484848);
  static const color949494 = Color(0xFF949494);
  static const colorBD7D28 = Color(0xFFBD7D28);
  static const colorB3B3B3 = Color(0xFFB3B3B3);
  static const colorFFFFFF = Color(0xFFFFFFFF); // White

  // New colors found in font specifications
  static const colorBB7A24 = Color(0xFFBB7A24); // Primary dark
  static const color30271C = Color(0xFF30271C); // Heading color
  static const colorECC16E = Color(0xFFECC16E); // Primary light
  static const colorEFEFEF = Color(0xFFEFEFEF); // Light gray
  static const colorF4F5F7 = Color(0xFFF4F5F7); // Off white
  static const color6C757D = Color(0xFF6C757D); // Text muted
  static const colorFF928A = Color(0xFFFF928A); // Light red/salmon
  static const colorD9D9D9 = Color(0xFFD9D9D9); // Light gray
  static const color5E0000 = Color(0x5E000000);
  static const color660000 = Color(0x66000000);

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

  // Additional gradient variations you might need
  static const linearGradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [colorBB7A24, colorECC16E],
  );
}