import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

class HHLoadingView extends StatelessWidget {
  final String? message;
  final Color? indicatorColor;

  const HHLoadingView({
    Key? key,
    this.message,
    this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              indicatorColor ?? AppColors.colorECC16E,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: Dimens.margin16),
            AppText(
              text: message!,
              appTextStyle: AppTextStyle.rubikRegular14Light,
              customColor: AppColors.color949494,
            ),
          ],
        ],
      ),
    );
  }
}
