import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHMenuItemCard extends StatelessWidget {
  const HHMenuItemCard({
    Key? key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.vegIconPath,
    this.spicyIconPath,
    this.onTap,
    this.onRightIconTap,
  }) : super(key: key);

  final String title;
  final String price;
  final String? imageUrl;
  final String? vegIconPath;
  final String? spicyIconPath;
  final VoidCallback? onTap;
  final VoidCallback? onRightIconTap;

  static const double _cardHeight = Dimens.margin80;
  static const double _iconSizeSmall = Dimens.margin16;
  static const double _iconSizeLarge = Dimens.margin24;
  static const double _imageSize = Dimens.margin70;
  static const double _imageBorderWidth = Dimens.margin3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimens.margin270,
      height: _cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: Dimens.margin35,
            top: 0,
            bottom: 0,
            child: _buildSubCard(),
          ),
          Positioned(
            left: 0,
            top: (_cardHeight - _imageSize) / 2,
            child: _buildFoodImage(),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    return Container(
      width: _imageSize,
      height: _imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.color004225,
        border: Border.all(
          color: AppColors.color004225,
          width: _imageBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.fill,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSubCard() {
    return Container(
      width: Dimens.margin235,
      height: _cardHeight,
      decoration: BoxDecoration(
        color: AppColors.color0042254D,
        borderRadius: BorderRadius.circular(Dimens.margin5),
        border: Border.all(
          color: AppColors.color0042254D,
          width: Dimens.margin1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 5),
            blurRadius: 30,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Material(
        color: AppColors.colorTransparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimens.margin5),
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: Dimens.margin50),
              SizedBox(width: Dimens.margin145, child: _buildItemDetails()),
              Expanded(child: _buildRightIconBox()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    final hasVeg = vegIconPath != null && vegIconPath!.isNotEmpty;
    final hasSpicy = spicyIconPath != null && spicyIconPath!.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          appTextStyle: AppTextStyle.oswaldMedium18Gold,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          applyTextTransform: false,
        ),
        const SizedBox(height: Dimens.margin6),
        Row(
          children: [
            Expanded(
              child: AppText(
                text: price,
                appTextStyle: AppTextStyle.oswaldRegular14White,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                applyTextTransform: false,
              ),
            ),
            if (hasVeg) _smallIcon(vegIconPath!),
            if (hasVeg && hasSpicy) const SizedBox(width: Dimens.margin5),
            if (hasSpicy) _smallIcon(spicyIconPath!),
            if (hasVeg || hasSpicy) const SizedBox(width: Dimens.margin7),
          ],
        ),
      ],
    );
  }

  Widget _smallIcon(String path) {
    return Image.asset(
      path,
      width: _iconSizeSmall,
      height: _iconSizeSmall,
      errorBuilder: (_, __, ___) =>
          const SizedBox(width: _iconSizeSmall, height: _iconSizeSmall),
    );
  }

  Widget _buildRightIconBox() {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.color00422566,
            width: Dimens.margin1,
          ),
        ),
      ),
      child: Material(
        color: AppColors.colorTransparent,
        child: InkWell(
          onTap: onRightIconTap,
          child: Center(
            child: Image.asset(
              APPImages.icMenuItemCardRight,
              width: _iconSizeLarge,
              height: _iconSizeLarge,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: _iconSizeLarge,
                height: _iconSizeLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
