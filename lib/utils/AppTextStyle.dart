import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

/// Enum for all text style types in the app
enum AppTextStyle {
  // Jost Font Styles
  jostSemiBold30Primary,
  jostMedium30Primary,
  jostMedium16Primary,
  jostMedium16Gray,
  jostSemiBold18White,
  jostMedium18Orange,
  jostBold26Heading,
  jostBold36Heading,
  jostBold24Light,

  // Rubik Font Styles
  rubikRegular14Light,
  rubikSemiBold18OffWhite,
  rubikRegular14Muted,
  rubikRegular14Red,

  // Oswald Font Styles
  oswaldBold54White,
  oswaldBold20Light,
  oswaldBold26Light,
  oswaldBold22OffWhite,
  oswaldSemiBold26Light,
  oswaldMedium22OffWhite,
  oswaldRegular16OffWhite,
  oswaldSemiBold20UppercaseLight,
  oswaldLight16Gray,
  oswaldRegular20UppercaseLight,
  oswaldRegular14UppercaseLight,

  // Merriweather Font Styles
  merriweatherItalic22White,
}

/// Text Style Manager class
class AppTextStyleManager {
  static const String _jostFont = 'Jost';
  static const String _rubikFont = 'Rubik';
  static const String _oswaldFont = 'Oswald';
  static const String _merriweatherFont = 'Merriweather';

  /// Get TextStyle based on AppTextStyle enum
  static TextStyle getStyle(AppTextStyle style) {
    switch (style) {
    // Jost Font Styles
      case AppTextStyle.jostSemiBold30Primary:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w600,
          fontSize: 30,
          height: 26 / 30, // line-height / font-size
          letterSpacing: 0,
          color: AppColors.colorBB7A24,
        );

      case AppTextStyle.jostMedium30Primary:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w500,
          fontSize: 30,
          height: 26 / 30,
          letterSpacing: 0,
          color: AppColors.colorBB7A24,
        );

      case AppTextStyle.jostMedium16Primary:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 26 / 16,
          letterSpacing: 0,
          color: AppColors.colorBB7A24,
        );

      case AppTextStyle.jostMedium16Gray:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 20 / 16,
          letterSpacing: 0,
          color: AppColors.color949494,
        );

      case AppTextStyle.jostSemiBold18White:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          height: 20 / 18,
          letterSpacing: 0,
          color: AppColors.colorFFFFFF,
        );

      case AppTextStyle.jostMedium18Orange:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorBD7D28,
        );

      case AppTextStyle.jostBold26Heading:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w700,
          fontSize: 26,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.color30271C,
        );

      case AppTextStyle.jostBold36Heading:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w700,
          fontSize: 36,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.color30271C,
        );

      case AppTextStyle.jostBold24Light:
        return TextStyle(
          fontFamily: _jostFont,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          height: 24 / 24, // 100%
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        );

    // Rubik Font Styles
      case AppTextStyle.rubikRegular14Light:
        return TextStyle(
          fontFamily: _rubikFont,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0,
          color: AppColors.colorEFEFEF,
        );

      case AppTextStyle.rubikSemiBold18OffWhite:
        return TextStyle(
          fontFamily: _rubikFont,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorF4F5F7,
        );

      case AppTextStyle.rubikRegular14Muted:
        return TextStyle(
          fontFamily: _rubikFont,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 18 / 14,
          letterSpacing: 0,
          color: AppColors.color6C757D,
        );

      case AppTextStyle.rubikRegular14Red:
        return TextStyle(
          fontFamily: _rubikFont,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 18 / 14,
          letterSpacing: 0,
          color: AppColors.colorFF928A,
        );

    // Oswald Font Styles
      case AppTextStyle.oswaldBold54White:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w700,
          fontSize: 54,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorFFFFFF,
        );

      case AppTextStyle.oswaldBold20Light:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        );

      case AppTextStyle.oswaldBold26Light:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w700,
          fontSize: 26,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        );

      case AppTextStyle.oswaldBold22OffWhite:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorF4F5F7,
        );

      case AppTextStyle.oswaldRegular14UppercaseLight:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 18 / 14, // line-height / font-size
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        );

      case AppTextStyle.oswaldSemiBold26Light:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w600,
          fontSize: 26,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        );

      case AppTextStyle.oswaldMedium22OffWhite:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w500,
          fontSize: 22,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorF4F5F7,
        );

      case AppTextStyle.oswaldRegular16OffWhite:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 20 / 16,
          letterSpacing: 0,
          color: AppColors.colorF4F5F7,
        );

      case AppTextStyle.oswaldSemiBold20UppercaseLight:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        );

      case AppTextStyle.oswaldLight16Gray:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w300,
          fontSize: 16,
          height: 22 / 16,
          letterSpacing: 0,
          color: AppColors.colorD9D9D9,
        );

      case AppTextStyle.oswaldRegular20UppercaseLight:
        return TextStyle(
          fontFamily: _oswaldFont,
          fontWeight: FontWeight.w400,
          fontSize: 20,
          height: 1.0, // 100%
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        );

    // Merriweather Font Styles
      case AppTextStyle.merriweatherItalic22White:
        return TextStyle(
          fontFamily: _merriweatherFont,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          fontSize: 22,
          height: 32 / 22,
          letterSpacing: 0,
          color: AppColors.colorFFFFFF,
        );

      default:
        return const TextStyle();
    }
  }

  /// Get TextStyle with custom color
  static TextStyle getStyleWithColor(AppTextStyle style, Color color) {
    return getStyle(style).copyWith(color: color);
  }

  /// Get TextStyle with custom font size
  static TextStyle getStyleWithSize(AppTextStyle style, double fontSize) {
    return getStyle(style).copyWith(fontSize: fontSize);
  }

  /// Get TextStyle with custom properties
  static TextStyle getStyleWith({
    required AppTextStyle style,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    TextAlign? textAlign,
  }) {
    return getStyle(style).copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Helper method to apply uppercase transformation for specific styles
  static String applyTextTransform(AppTextStyle style, String text) {
    switch (style) {
      case AppTextStyle.oswaldSemiBold20UppercaseLight:
      case AppTextStyle.oswaldRegular20UppercaseLight:
      case AppTextStyle.rubikSemiBold18OffWhite:
        return text.toUpperCase();
      default:
        return text;
    }
  }
}

/// Extension on AppTextStyle for easy usage
extension AppTextStyleExtension on AppTextStyle {
  TextStyle get style => AppTextStyleManager.getStyle(this);

  TextStyle withColor(Color color) => AppTextStyleManager.getStyleWithColor(this, color);

  TextStyle withSize(double fontSize) => AppTextStyleManager.getStyleWithSize(this, fontSize);

  String transformText(String text) => AppTextStyleManager.applyTextTransform(this, text);
}