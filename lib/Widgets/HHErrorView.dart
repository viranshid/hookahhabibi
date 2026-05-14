import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/Widgets/HHButton.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

class HHErrorView extends StatelessWidget {
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const HHErrorView({
    Key? key,
    required this.message,
    this.retryLabel,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.margin40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.colorFF928A,
            ),
            SizedBox(height: Dimens.margin20),
            AppText(
              text: message,
              appTextStyle: AppTextStyle.rubikRegular14Light,
              customColor: AppColors.color949494,
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
            if (onRetry != null) ...[
              SizedBox(height: Dimens.margin30),
              SizedBox(
                width: Dimens.margin200,
                child: HHButton(
                  text: retryLabel ?? 'Retry',
                  type: HHButtonType.normal,
                  onPressed: onRetry!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
