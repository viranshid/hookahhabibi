import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/ImageCacheManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHDishCard extends StatelessWidget {
  final HHDishModel dish;
  final Function(HHDishModel)? onTap;

  const HHDishCard({
    Key? key,
    required this.dish,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dish.isAvailable ? () => onTap?.call(dish) : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x66000000), // #00000066
          borderRadius: BorderRadius.circular(Dimens.margin10),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0F000000), // #0000000F
              offset: const Offset(0, 5),
              blurRadius: 30,
              spreadRadius: -10,
            ),
            BoxShadow(
              color: const Color(0x12FFFFFF), // #FFFFFF12
              offset: Offset.zero,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDishImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: Dimens.margin20,
                  right: Dimens.margin20,
                  top: Dimens.margin10,
                  bottom: Dimens.margin15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDishName(),
                    SizedBox(height: Dimens.margin8),
                    Expanded(child: _buildDishDescription()),
                    SizedBox(height: Dimens.margin10),
                    _buildBottomRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishImage() {
    return Padding(
      padding: const EdgeInsets.all(Dimens.margin20),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: Dimens.margin150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimens.margin12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.margin12),
              child: ImageCacheManager().getCachedImage(
                imageUrl: dish.imageUrl,
                width: double.infinity,
                height: Dimens.margin150,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(Dimens.margin12),
                placeholder: Container(
                  width: double.infinity,
                  height: Dimens.margin150,
                  decoration: BoxDecoration(
                    color: AppColors.color949494.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(Dimens.margin12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
                    ),
                  ),
                ),
                errorWidget: Container(
                  width: double.infinity,
                  height: Dimens.margin150,
                  decoration: BoxDecoration(
                    color: AppColors.color949494.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(Dimens.margin12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.colorECC16E,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
          // Overlay when dish is not available
          if (!dish.isAvailable) _buildNotAvailableOverlay(),
        ],
      ),
    );
  }

  Widget _buildNotAvailableOverlay() {
    return Container(
      width: double.infinity,
      height: Dimens.margin150,
      decoration: BoxDecoration(
        color: const Color(0xB2FFFFFF), // #FFFFFFB2 with 70% opacity
        borderRadius: BorderRadius.circular(Dimens.margin12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.margin10),
          child: Text(
            'Currently Not\nAvailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w500,
              fontSize: Dimens.textSize26,
              height: 36 / 26, // line-height / font-size
              letterSpacing: 0,
              color: const Color(0xFFCD3030), // #CD3030
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDishName() {
    return AppText(
      text: dish.name.toUpperCase(),
      appTextStyle: AppTextStyle.oswaldBold20Light,
      customColor: AppColors.colorECC16E,
      customFontWeight: FontWeight.w700,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      applyTextTransform: false,
    );
  }

  Widget _buildDishDescription() {
    return AppText(
      text: dish.description,
      appTextStyle: AppTextStyle.rubikRegular14Light,
      customColor: const Color(0xFFAAAAAA),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: _buildPriceLabel()),
        SizedBox(width: Dimens.margin8),
        _buildIconsRow(),
      ],
    );
  }

  Widget _buildPriceLabel() {
    return AppText(
      text: dish.price.toUpperCase(),
      appTextStyle: AppTextStyle.rubikSemiBold18OffWhite,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      applyTextTransform: false,
    );
  }

  Widget _buildIconsRow() {
    // Only show icons if at least one condition is true
    if (!dish.isSpicy && !dish.isVegetarian) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dish.isSpicy) ...[
          _buildSpicyIcon(),
          if (dish.isVegetarian) SizedBox(width: Dimens.margin8),
        ],
        if (dish.isVegetarian) _buildVegetarianIcon(),
      ],
    );
  }

  Widget _buildSpicyIcon() {
    return Container(
      width: Dimens.margin24,
      height: Dimens.margin24,
      child: Image.asset(
        APPImages.icChilli,
        width: Dimens.margin24,
        height: Dimens.margin24,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: Dimens.margin24,
            height: Dimens.margin24,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Dimens.margin4),
            ),
            child: const Icon(
              Icons.whatshot,
              color: Colors.red,
              size: Dimens.margin16,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVegetarianIcon() {
    return Container(
      width: Dimens.margin24,
      height: Dimens.margin24,
      child: Image.asset(
        APPImages.icVeg,
        width: Dimens.margin24,
        height: Dimens.margin24,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: Dimens.margin24,
            height: Dimens.margin24,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Dimens.margin4),
            ),
            child: Center(
              child: Container(
                width: Dimens.margin12,
                height: Dimens.margin12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}