import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

/// Used by [AppFont] of app and web
class AppFont {
  static const regular = TextStyle(fontWeight: FontWeight.w400);
  static const bold = TextStyle(fontWeight: FontWeight.w700);
  static const highBold = TextStyle(fontWeight: FontWeight.w800);
  static const semiBold = TextStyle(fontWeight: FontWeight.w600);
  static const mediumBold = TextStyle(fontWeight: FontWeight.w500);
  static const highLevelBold= TextStyle(fontWeight: FontWeight.w900);

  ///-------regular-----------

  static final regularColorBlack =
      regular.copyWith(color: AppColors.colorBlack);

}

