import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHMenuTabScreen extends StatelessWidget {
  const HHMenuTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.color01110A,
      alignment: Alignment.center,
      child: AppText(
        text: 'Menu',
        appTextStyle: AppTextStyle.jostBold26Heading,
      ),
    );
  }
}
