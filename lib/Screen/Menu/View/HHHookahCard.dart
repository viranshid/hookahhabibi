import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/ImageCacheManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

class HHHookahModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isAvailable;

  HHHookahModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isAvailable = true,
  });
}

class HHHookahCard extends StatefulWidget {
  final HHHookahModel hookah;
  final Function(HHHookahModel)? onTap;

  const HHHookahCard({
    Key? key,
    required this.hookah,
    this.onTap,
  }) : super(key: key);

  @override
  State<HHHookahCard> createState() => _HHHookahCardState();
}

class _HHHookahCardState extends State<HHHookahCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;
  bool _isPopupShowing = false;

  OverlayEntry? _overlayEntry;

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

  void _showPopup() {
    if (_isPopupShowing) return;

    _removeOverlay();

    setState(() {
      _isPopupShowing = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildPopup(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {
        _isPopupShowing = false;
      });
    }
  }

  Widget _buildPopup() {
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
                                widget.hookah.imageUrl,
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
                          _buildPopupHookahInfo(),
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

  // Similar to _buildPopupDishInfo from HHDishCard
  Widget _buildPopupHookahInfo() {
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
          Text(
            widget.hookah.name.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w700,
              fontSize: Dimens.textSize26,
              color: AppColors.colorECC16E,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Dimens.margin15),
          Text(
            widget.hookah.description,
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
        // FIXED: Now calling _showPopup() and also the onTap callback
        onTap: widget.hookah.isAvailable
            ? () {
          _showPopup(); // First show the popup
          widget.onTap?.call(widget.hookah); // Then call the callback if provided
        }
            : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: Dimens.margin100, // Fixed height as per requirements
                child: Stack(
                  children: [
                    // Main background container
                    Positioned.fill(
                      child: Container(),
                    ),

                    // Second view with background
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: Dimens.margin38, // 38px from leading as per requirements
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x66000000), // #00000066
                          borderRadius: BorderRadius.circular(Dimens.margin10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000), // #0000000F
                              offset: Offset(0, 5),
                              blurRadius: 30,
                              spreadRadius: -10,
                            ),
                            BoxShadow(
                              color: Color(0x12FFFFFF), // #FFFFFF12
                              offset: Offset.zero,
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: Dimens.margin76),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Title
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimens.margin15),
                                child: AppText(
                                  text: widget.hookah.name.toUpperCase(),
                                  appTextStyle: AppTextStyle.oswaldSemiBold20UppercaseLight,
                                  customColor: AppColors.colorECC16E,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  applyTextTransform: false,
                                ),
                              ),
                              SizedBox(height: Dimens.margin5),
                              // Description
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimens.margin15),
                                child: AppText(
                                  text: widget.hookah.description,
                                  appTextStyle: AppTextStyle.rubikRegular14Light,
                                  customColor: const Color(0xFFAAAAAA),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Circular image
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: Dimens.margin76,
                          height: Dimens.margin76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF004225),
                              width: 6,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimens.margin38), // Half of the width/height for circle
                            child: Image.network(
                              widget.hookah.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppColors.colorECC16E),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (!widget.hookah.isAvailable) _buildNotAvailableOverlay(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotAvailableOverlay() {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(left: Dimens.margin38),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xB2FFFFFF),
            borderRadius: BorderRadius.circular(Dimens.margin10),
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
      ),
    );
  }
}