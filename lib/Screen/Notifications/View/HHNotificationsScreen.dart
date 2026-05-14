import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHNotificationsScreen extends StatelessWidget {
  const HHNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color171717,
      body: Center(
        child: AppText(
          text: 'Notifications — Coming Soon',
          appTextStyle: AppTextStyle.oswaldSemiBold26Light,
          customColor: AppColors.color949494,
        ),
      ),
    );
  }
}
