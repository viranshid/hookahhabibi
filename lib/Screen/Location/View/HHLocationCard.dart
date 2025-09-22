import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Location/Model/HHLocationCardModel.dart';
import 'package:hookahhabibi/utils/ImageCacheManager.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

class HHLocationCard extends StatelessWidget {
  final HHLocationCardModel location;
  final Function(HHLocationCardModel)? onTap;
  final Function(HHLocationCardModel, bool)? onSelectionChanged;

  const HHLocationCard({
    Key? key,
    required this.location,
    this.onTap,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call(location);
        onSelectionChanged?.call(location, !location.isSelected);
      },
      child: Container(
        width: Dimens.margin512,
        height: Dimens.margin130,
        clipBehavior: Clip.hardEdge, // This will hide the outside shadow
        decoration: BoxDecoration(
          color: const Color(0xFF00541A), // Secondary color
          borderRadius: BorderRadius.circular(Dimens.margin18),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000), // #0000001A
              offset: const Offset(0, 5),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildImageSection(),
            _buildContentSection(),
            _buildCheckboxSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Positioned(
      left: -10,
      top: (130 - 100) / 2, // Center vertically in the card
      child: Container(
        width: Dimens.margin100,
        height: Dimens.margin100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.margin50),
          border: Border.all(
            color: AppColors.colorECC16E, // Primary light
            width: Dimens.margin2,
          ),
          boxShadow: [
            // Multiple box shadows as specified
            BoxShadow(
              color: const Color(0x14FFFFFF), // #FFFFFF14
              offset: Offset.zero,
              blurRadius: 0,
              spreadRadius: 30,
            ),
            BoxShadow(
              color: const Color(0x1A000000), // #0000001A
              offset: Offset.zero,
              blurRadius: 0,
              spreadRadius: 20,
            ),
            BoxShadow(
              color: const Color(0x1A000000), // #0000001A
              offset: Offset.zero,
              blurRadius: 0,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.margin50),
          child: ImageCacheManager().getCachedImage(
            imageUrl: location.imageUrl,
            width: Dimens.margin100,
            height: Dimens.margin100,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(Dimens.margin50),
            placeholder: Container(
              width: Dimens.margin100,
              height: Dimens.margin100,
              decoration: BoxDecoration(
                color: AppColors.color949494.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Dimens.margin50),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
                ),
              ),
            ),
            errorWidget: Container(
              width: Dimens.margin100,
              height: Dimens.margin100,
              decoration: BoxDecoration(
                color: AppColors.color949494.withOpacity(0.5),
                borderRadius: BorderRadius.circular(Dimens.margin50),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.colorECC16E,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Positioned(
      top: Dimens.margin18,
      left: Dimens.margin100 - 10 + Dimens.margin25, // Image width + left offset + margin
      right: Dimens.margin10 + Dimens.margin20 + Dimens.margin18, // Checkbox area + margins
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          SizedBox(height: Dimens.margin12),
          _buildSubtitle(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return SizedBox(
      height: Dimens.margin24,
      child: AppText(
        text: location.title,
        appTextStyle: AppTextStyle.jostBold24Light,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubtitle() {
    return SizedBox(
      height: Dimens.margin59,
      child: AppText(
        text: location.subtitle,
        appTextStyle: AppTextStyle.rubikRegular14Light,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCheckboxSection() {
    return Positioned(
      top: Dimens.margin18,
      right: Dimens.margin18,
      child: _buildCustomCheckbox(),
    );
  }

  Widget _buildCustomCheckbox() {
    return SizedBox(
      width: Dimens.margin20,
      height: Dimens.margin20,
      child: Stack(
        children: [
          // Outer circle
          Container(
            width: Dimens.margin20,
            height: Dimens.margin20,
            decoration: BoxDecoration(
              color: const Color(0x00D9D9D9), // Transparent background #D9D9D900
              borderRadius: BorderRadius.circular(Dimens.margin10),
              border: Border.all(
                color: location.isSelected
                    ? const Color(0xFFD09843) // Primary color when selected
                    : const Color(0x80FFFFFF), // White with 50% opacity when unselected #FFFFFF80
                width: Dimens.margin1,
              ),
            ),
          ),
          // Inner circle (only visible when selected)
          if (location.isSelected)
            Center(
              child: Container(
                width: Dimens.margin12,
                height: Dimens.margin12,
                decoration: BoxDecoration(
                  color: AppColors.colorECC16E, // #ECC16E
                  borderRadius: BorderRadius.circular(Dimens.margin6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}