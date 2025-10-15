import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/ImageCacheManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHDishCard extends StatefulWidget {
  final HHDishModel dish;
  final Function(HHDishModel)? onTap;

  const HHDishCard({
    Key? key,
    required this.dish,
    this.onTap,
  }) : super(key: key);

  @override
  State<HHDishCard> createState() => _HHDishCardState();
}

class _HHDishCardState extends State<HHDishCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;
  bool _isImageHovered = false;
  bool _isPopupShowing = false;

  OverlayEntry? _overlayEntry;

  // Fixed heights for card sections
  static const double titleHeight = 40.0;
  static const double descriptionHeight = 70.0;
  static const double bottomRowHeight = 40.0;
  static const double cardPadding = 20.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleImageHover(bool isHovered) {
    setState(() {
      _isImageHovered = isHovered;
    });

    if (isHovered && !_isPopupShowing) {
      _showImagePopup();
    } else if (!isHovered && _isPopupShowing) {
      _removeOverlay();
    }
  }

  void _handleImageTap() {
    if (_isPopupShowing) {
      _removeOverlay();
    } else {
      _showImagePopup();
    }
  }

  void _showImagePopup() {
    if (_isPopupShowing) return;

    _removeOverlay();

    setState(() {
      _isPopupShowing = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildImagePopup(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {
        _isPopupShowing = false;
        _isImageHovered = false;
      });
    }
  }

  Widget _buildImagePopup() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _removeOverlay,
        child: Material(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: MouseRegion(
                onExit: (_) {
                  _removeOverlay();
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.colorFFFFFF,
                      borderRadius: BorderRadius.circular(Dimens.margin20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.margin20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCloseButton(),
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(Dimens.margin20),
                              child: Image.network(
                                widget.dish.imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                              AppColors.colorECC16E),
                                        ),
                                        SizedBox(height: Dimens.margin10),
                                        Text(
                                          'Loading image...',
                                          style: TextStyle(
                                            color: AppColors.color949494,
                                            fontSize: Dimens.textSize14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(Dimens.margin40),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 80,
                                          color: AppColors.color949494,
                                        ),
                                        SizedBox(height: Dimens.margin20),
                                        Text(
                                          'Image not available',
                                          style: TextStyle(
                                            color: AppColors.color949494,
                                            fontSize: Dimens.textSize16,
                                            fontFamily: 'Rubik',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          _buildPopupDishInfo(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.margin10),
        child: GestureDetector(
          onTap: _removeOverlay,
          child: Container(
            width: Dimens.margin40,
            height: Dimens.margin40,
            decoration: BoxDecoration(
              color: AppColors.colorFF928A,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.colorFFFFFF,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupDishInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.margin20),
      decoration: BoxDecoration(
        color: const Color(0xFF004216),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimens.margin20),
          bottomRight: Radius.circular(Dimens.margin20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.dish.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontWeight: FontWeight.w700,
                    fontSize: Dimens.textSize26,
                    color: AppColors.colorECC16E,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: Dimens.margin10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.dish.isSpicy)
                    Padding(
                      padding: const EdgeInsets.only(right: Dimens.margin8),
                      child: Image.asset(
                        APPImages.icChilli,
                        width: Dimens.margin30,
                        height: Dimens.margin30,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.whatshot,
                            color: Colors.red,
                            size: Dimens.margin30,
                          );
                        },
                      ),
                    ),
                  if (widget.dish.isVegetarian)
                    Image.asset(
                      APPImages.icVeg,
                      width: Dimens.margin30,
                      height: Dimens.margin30,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.eco,
                          color: Colors.green,
                          size: Dimens.margin30,
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: Dimens.margin15),
          Text(
            widget.dish.description,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w400,
              fontSize: Dimens.textSize16,
              color: AppColors.colorF4F5F7,
              height: 1.5,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Dimens.margin15),
          Text(
            widget.dish.price.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w600,
              fontSize: Dimens.textSize24,
              color: AppColors.colorECC16E,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHoverChange(true),
      onExit: (_) => _handleHoverChange(false),
      child: GestureDetector(
        onTap: widget.dish.isAvailable ? () => widget.onTap?.call(widget.dish) : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x66000000),
                  borderRadius: BorderRadius.circular(Dimens.margin10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x0F000000),
                      offset: const Offset(0, 5),
                      blurRadius: 30 + _elevationAnimation.value,
                      spreadRadius: -10,
                    ),
                    BoxShadow(
                      color: const Color(0x12FFFFFF),
                      offset: Offset.zero,
                      blurRadius: 5 + (_elevationAnimation.value / 2),
                      spreadRadius: 1,
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: AppColors.colorECC16E.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available space
              final cardWidth = constraints.maxWidth;
              final cardHeight = constraints.maxHeight;

              // Calculate image size based on available space
              final availableHeightForImage = cardHeight - titleHeight - descriptionHeight - bottomRowHeight - (cardPadding * 2);
              final maxImageWidth = cardWidth - (cardPadding);

              // Use the smaller of width or available height to keep it square
              final imageSize = availableHeightForImage < maxImageWidth
                  ? availableHeightForImage
                  : maxImageWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Square Image Section - Flexible
                  _buildSquareImage(imageSize),

                  // Title Section - Fixed 50px height
                  _buildFixedHeightTitle(),

                  // Description Section - Fixed 70px height
                  _buildFixedHeightDescription(),

                  // Bottom Row Section - Fixed 40px height
                  _buildFixedHeightBottomRow(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSquareImage(double size) {
    return GestureDetector(
      onTap: _handleImageTap,
      child: MouseRegion(
        onEnter: (_) => _handleImageHover(true),
        onExit: (_) => _handleImageHover(false),
        child: Padding(
          padding: const EdgeInsets.all(cardPadding),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.margin12),
                  border: _isImageHovered
                      ? Border.all(
                    color: AppColors.colorECC16E,
                    width: 3,
                  )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.margin12),
                  child: Stack(
                    children: [
                      ImageCacheManager().getCachedImage(
                        imageUrl: widget.dish.imageUrl,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(Dimens.margin12),
                        placeholder: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: AppColors.color949494.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(Dimens.margin12),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.colorECC16E),
                            ),
                          ),
                        ),
                        errorWidget: Container(
                          width: size,
                          height: size,
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
                      if (_isImageHovered)
                        Container(
                          color: Colors.black26,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimens.margin15,
                                vertical: Dimens.margin10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.colorECC16E,
                                borderRadius: BorderRadius.circular(Dimens.margin8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.zoom_in,
                                    color: AppColors.color00541A,
                                    size: Dimens.margin22,
                                  ),
                                  SizedBox(width: Dimens.margin10),
                                  Text(
                                    'View Full Image',
                                    style: TextStyle(
                                      fontFamily: 'Oswald',
                                      fontWeight: FontWeight.w600,
                                      fontSize: Dimens.textSize16,
                                      color: AppColors.color00541A,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!widget.dish.isAvailable) _buildNotAvailableOverlay(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotAvailableOverlay(double size) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 0.9,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xB2FFFFFF),
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
                height: 36 / 26,
                letterSpacing: 0,
                color: const Color(0xFFCD3030),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedHeightTitle() {
    return Container(
      height: titleHeight,
      padding: const EdgeInsets.symmetric(horizontal: cardPadding),
      child: AppText(
        text: widget.dish.name.toUpperCase(),
        appTextStyle: AppTextStyle.oswaldBold20Light,
        customColor: AppColors.colorECC16E,
        customFontWeight: FontWeight.w700,
        maxLines: 2,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.left,
        applyTextTransform: false,
      ),
    );
  }

  Widget _buildFixedHeightDescription() {
    return Container(
      height: descriptionHeight,
      padding: const EdgeInsets.symmetric(horizontal: cardPadding),
      margin: const EdgeInsets.only(top: Dimens.margin8),
      child: AppText(
        text: widget.dish.description,
        appTextStyle: AppTextStyle.rubikRegular14Light,
        customColor: const Color(0xFFAAAAAA),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildFixedHeightBottomRow() {
    return Container(
      height: bottomRowHeight,
      padding: const EdgeInsets.only(
        left: cardPadding,
        right: cardPadding,
        bottom: Dimens.margin15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: _buildPriceLabel()),
          SizedBox(width: Dimens.margin8),
          _buildIconsRow(),
        ],
      ),
    );
  }

  Widget _buildPriceLabel() {
    return AppText(
      text: widget.dish.price.toUpperCase(),
      appTextStyle: AppTextStyle.rubikSemiBold18OffWhite,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      applyTextTransform: false,
    );
  }

  Widget _buildIconsRow() {
    if (!widget.dish.isSpicy && !widget.dish.isVegetarian) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.dish.isSpicy) ...[
          _buildSpicyIcon(),
          if (widget.dish.isVegetarian) SizedBox(width: Dimens.margin8),
        ],
        if (widget.dish.isVegetarian) _buildVegetarianIcon(),
      ],
    );
  }

  Widget _buildSpicyIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: SizedBox(
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
      ),
    );
  }

  Widget _buildVegetarianIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: SizedBox(
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
      ),
    );
  }
}