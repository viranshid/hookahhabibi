import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_Strings.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';



class HHButton extends StatelessWidget {
  final String text;
  final HHButtonType type;
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? imagePath;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isEnabled;

  const HHButton({
    Key? key,
    required this.text,
    required this.type,
    this.onPressed,
    this.icon,
    this.imagePath,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case HHButtonType.normal:
        return _buildNormalButton();
      case HHButtonType.rounded:
        return _buildRoundedButton();
      case HHButtonType.onlyText:
        return _buildOnlyTextButton();
      case HHButtonType.iconWithText:
        return _buildIconWithTextButton();
    }
  }

  Widget _buildNormalButton() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? Dimens.margin56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.colorBD7D28,
          disabledBackgroundColor: AppColors.color949494,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            fontSize: Dimens.textSize18,
            height: 20 / 18, // line-height / font-size
            letterSpacing: 0,
            color: AppColors.colorFFFFFF,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRoundedButton() {
    return SizedBox(
      width: width ?? Dimens.margin56,
      height: height ?? Dimens.margin56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.colorBD7D28,
          disabledBackgroundColor: AppColors.color949494,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: imagePath != null
            ? Image.asset(
          imagePath!,
          width: Dimens.margin24,
          height: Dimens.margin24,
          fit: BoxFit.contain,
        )
            : icon ??
            const Icon(
              Icons.add,
              color: AppColors.colorFFFFFF,
              size: Dimens.margin24,
            ),
      ),
    );
  }

  Widget _buildOnlyTextButton() {
    return SizedBox(
      height: height ?? Dimens.margin26,
      child: TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Align(
          child: AppText(
            text: APPStrings.loginForgotBtn,
            appTextStyle: AppTextStyle.jostMedium18Orange,
            customColor: AppColors.colorBD7D28,
            textAlign: TextAlign.center,
          ),
        )
      ),
    );
  }

  Widget _buildIconWithTextButton() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? Dimens.margin56,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.colorBD7D28,
          disabledBackgroundColor: AppColors.color949494,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          elevation: 0,
        ),
        icon: imagePath != null
            ? Image.asset(
          imagePath!,
          width: Dimens.margin20,
          height: Dimens.margin20,
          fit: BoxFit.contain,
          color: AppColors.colorFFFFFF,
        )
            : icon ??
            const Icon(
              Icons.add,
              color: AppColors.colorFFFFFF,
              size: Dimens.margin20,
            ),
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            fontSize: Dimens.textSize18,
            height: 20 / 18, // line-height / font-size
            letterSpacing: 0,
            color: AppColors.colorFFFFFF,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}