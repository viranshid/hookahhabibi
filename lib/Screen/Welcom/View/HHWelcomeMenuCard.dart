import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHWelcomeMenuType.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

class HHWelcomeMenuCard extends StatelessWidget {
  final HHWelcomeMenuType menuType;
  final Function(HHWelcomeMenuType)? onTap;
  final bool isSelected;

  const HHWelcomeMenuCard({
    Key? key,
    required this.menuType,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(menuType),
      child: Container(
        width: Dimens.margin70,
        height: Dimens.margin150,
        child: Column(
          children: [
            _buildImage(),
            SizedBox(height: Dimens.margin8),
            _buildTitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: Dimens.margin70,
      height: Dimens.margin70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.margin10),
        border: isSelected
            ? Border.all(
          color: AppColors.colorECC16E,
          width: Dimens.margin2,
        )
            : null,
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppColors.colorECC16E.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimens.margin10),
        child: Image.asset(
          menuType.imagePath,
          width: Dimens.margin70,
          height: Dimens.margin70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: Dimens.margin70,
              height: Dimens.margin70,
              decoration: BoxDecoration(
                color: AppColors.color949494.withOpacity(0.5),
                borderRadius: BorderRadius.circular(Dimens.margin10),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: AppColors.colorECC16E,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return SizedBox(
      width: Dimens.margin70,
      height: Dimens.margin64, // Approximate height for 3-4 lines
      child: AppText(
        text: menuType.title,
        appTextStyle: AppTextStyle.oswaldRegular14UppercaseLight,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}