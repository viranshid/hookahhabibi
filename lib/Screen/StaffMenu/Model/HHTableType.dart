import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';

enum HHTableType {
  blank,
  kotRunning,
  running,
  printed;

  static HHTableType fromApi(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'k':
      case 'kot':
      case 'kot_running':
        return HHTableType.kotRunning;
      case 'r':
      case 'running':
        return HHTableType.running;
      case 'p':
      case 'printed':
        return HHTableType.printed;
      case 'a':
      case 'available':
      case 'blank':
      default:
        return HHTableType.blank;
    }
  }

  bool get isBooked => this != HHTableType.blank;

  Color get borderColor {
    switch (this) {
      case HHTableType.blank:
        return AppColors.colorTableBlankBg;
      case HHTableType.kotRunning:
        return AppColors.colorTableKOT;
      case HHTableType.running:
        return AppColors.colorTableRunning;
      case HHTableType.printed:
        return AppColors.colorTablePrinted;
    }
  }

  Color get fillColor {
    switch (this) {
      case HHTableType.blank:
        return AppColors.colorTableBlankBg;
      case HHTableType.kotRunning:
        return AppColors.colorTableKOTFill;
      case HHTableType.running:
        return AppColors.colorTableRunningFill;
      case HHTableType.printed:
        return AppColors.colorTablePrintedFill;
    }
  }

  String? get backgroundImage {
    switch (this) {
      case HHTableType.blank:
        return null;
      case HHTableType.kotRunning:
        return APPImages.icKotRunningTableCard;
      case HHTableType.running:
        return APPImages.icRunningTableCard;
      case HHTableType.printed:
        return APPImages.icPrintedTableCard;
    }
  }

  Color get numberColor {
    switch (this) {
      case HHTableType.blank:
        return AppColors.colorFFFFFF;
      case HHTableType.kotRunning:
        return AppColors.colorTableKOT;
      case HHTableType.running:
        return AppColors.colorTableRunning;
      case HHTableType.printed:
        return AppColors.colorTablePrinted;
    }
  }
}
