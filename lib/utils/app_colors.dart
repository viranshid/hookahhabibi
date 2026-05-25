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
  static const colorECC16E1A = Color(0x1AECC16E); // Primary light 10% opacity
  static const colorEFEFEF = Color(0xFFEFEFEF); // Light gray
  static const colorF4F5F7 = Color(0xFFF4F5F7); // Off white
  static const color6C757D = Color(0xFF6C757D); // Text muted
  static const colorFF928A = Color(0xFFFF928A); // Light red/salmon
  static const colorD9D9D9 = Color(0xFFD9D9D9); // Light gray
  static const color5E0000 = Color(0x5E000000);
  static const color660000 = Color(0x66000000);
  static const color00541A = Color(0xFF00541A);
  static const color00541A80 = Color(0x8000541A); // Dark green 50% opacity
  static const color004216 = Color(0xFF004216);
  static const color33FFFF = Color(0x33FFFFFF);
  static const color01110A = Color(0xFF01110A);
  static const color012012 = Color(0xFF012012);
  static const color003210 = Color(0xFF003210);
  static const color266528 = Color(0xFF266528);
  static const colorKotActionLight = Color(0xFF4D7A38);
  static const colorKotActionDark = Color(0xFF1F5C1E);
  static const color84994F99 = Color(0x9984994F); // Olive @ 60% — inactive KOT tab
  static const color19552D = Color(0xFF19552D);   // Selected KOT tab
  static const colorC4C4C4 = Color(0xFFC4C4C4);   // KOT list header label
  static const color0042254D = Color(0x4D004225);
  static const color00422566 = Color(0x66004225);
  static const color004225 = Color(0xFF004225);
  static const color171717C9 = Color(0xC9171717);

  // Table status border colors
  static const colorTableBlankBorder = Color(0xFF2E7D44);
  static const colorTableRunningBlue = Color(0xFF00A6E0);
  static const colorTablePrintedGreen = Color(0xFF8AB87A);

  // Table card status colors (per backend spec)
  static const colorTableBlankBg = Color(0xFF00541A);
  static const colorTableKOT = Color(0xFFD09843);
  static const colorTableKOTFill = Color(0x4DD09843);
  static const colorTableRunning = Color(0xFF00C0E8);
  static const colorTableRunningFill = Color(0x4D00C0E8);
  static const colorTablePrinted = Color(0xFF84994F);
  static const colorTablePrintedFill = Color(0x4D84994F);

  // Split-bill modal palette
  static const colorD09843 = Color(0xFFD09843); // Checkbox + "Add" pill fill
  static const colorFF5F57 = Color(0xFFFF5F57); // Modal close X (macOS red)
  static const colorF4F7F4 = Color(0xFFF4F7F4); // Card field label
  static const color17171780 = Color(0x80171717); // Input fill (50% dark)
  static const color01110A33 = Color(0x3301110A); // Input border (20%)
  static const colorWhite33 = Color(0x33FFFFFF); // Divider / ghost text
  static const colorBlack33 = Color(0x33000000); // Cancel button bg
  static const colorWhite40 = Color(0x40FFFFFF); // Ghost placeholder text

  static const Color transparentColor = Colors.transparent;
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