import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/ImageCacheManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHWelcomeMenuCard extends StatelessWidget {
  final HHDishCategoryModel category;
  final Function(HHDishCategoryModel)? onTap;
  final bool isSelected;

  const HHWelcomeMenuCard({
    Key? key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(category),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.margin10),
            child: Image.asset(
              APPImages.icMenuBg,
              width: Dimens.margin70,
              height: Dimens.margin70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: Dimens.margin70,
                  height: Dimens.margin70,
                  decoration: BoxDecoration(
                    color: AppColors.color949494.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(Dimens.margin10),
                  ),
                );
              },
            ),
          ),
          // Category icon from API (42x42)
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.margin8),
            child: ImageCacheManager().getCachedImage(
              imageUrl: category.image,
              width: Dimens.margin42,
              height: Dimens.margin42,
              fit: BoxFit.contain,
              placeholder: Container(
                width: Dimens.margin42,
                height: Dimens.margin42,
                color: Colors.transparent,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
                  ),
                ),
              ),
              errorWidget: Container(
                width: Dimens.margin42,
                height: Dimens.margin42,
                color: Colors.transparent,
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.colorECC16E,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return SizedBox(
      width: Dimens.margin70,
      height: Dimens.margin64,
      child: AppText(
        text: category.title,
        appTextStyle: AppTextStyle.oswaldRegular14UppercaseLight,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}