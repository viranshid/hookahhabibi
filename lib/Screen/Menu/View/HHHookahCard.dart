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
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

  void _handleCardTap() {
    if (widget.hookah.isAvailable) {
      _showPopup();
      widget.onTap?.call(widget.hookah);
    }
  }

  Widget _buildPopup() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _removeOverlay,
        child: Material(
          color: Colors.black54,
          child: Center(
            child: _buildPopupContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupContent() {
    return GestureDetector(
      onTap: () {},
      child: MouseRegion(
        onExit: (_) {
          _removeOverlay();
        },
        child: _buildAnimatedPopupContainer(),
      ),
    );
  }

  Widget _buildAnimatedPopupContainer() {
    return TweenAnimationBuilder<double>(
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
      child: _buildPopupContainerWithConstraints(),
    );
  }

  Widget _buildPopupContainerWithConstraints() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: _buildPopupDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimens.margin20),
        child: _buildPopupInnerContent(),
      ),
    );
  }

  BoxDecoration _buildPopupDecoration() {
    return BoxDecoration(
      color: AppColors.colorFFFFFF,
      borderRadius: BorderRadius.circular(Dimens.margin20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 30,
          spreadRadius: 5,
        ),
      ],
    );
  }

  Widget _buildPopupInnerContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCloseButton(),
        Flexible(
          child: _buildPopupImage(),
        ),
        _buildPopupHookahInfo(),
      ],
    );
  }

  Widget _buildPopupImage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.margin20),
      child: ImageCacheManager.getNetworkImage(
        url: widget.hookah.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        placeholder: _buildImageLoadingPlaceholder(),
        errorWidget: _buildImageErrorWidget(),
      ),
    );
  }

  Widget _buildImageLoadingPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
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
  }

  Widget _buildImageErrorWidget() {
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
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.margin10),
        child: GestureDetector(
          onTap: _removeOverlay,
          child: _buildCloseButtonContainer(),
        ),
      ),
    );
  }

  Widget _buildCloseButtonContainer() {
    return Container(
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
    );
  }

  Widget _buildPopupHookahInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.margin20),
      decoration: _buildPopupInfoDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPopupTitle(),
          SizedBox(height: Dimens.margin15),
          _buildPopupDescription(),
        ],
      ),
    );
  }

  BoxDecoration _buildPopupInfoDecoration() {
    return BoxDecoration(
      color: const Color(0xFF004216),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(Dimens.margin20),
        bottomRight: Radius.circular(Dimens.margin20),
      ),
    );
  }

  Widget _buildPopupTitle() {
    return Text(
      widget.hookah.name.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w700,
        fontSize: Dimens.textSize26,
        color: AppColors.colorECC16E,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPopupDescription() {
    return Text(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHoverChange(true),
      onExit: (_) => _handleHoverChange(false),
      child: GestureDetector(
        onTap: _handleCardTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildCardContainer(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardContainer() {
    return Container(
      height: Dimens.margin100,
      child: Stack(
        children: [
          _buildMainBackground(),
          _buildCardContent(),
          _buildCircularImage(),
          if (!widget.hookah.isAvailable) _buildNotAvailableOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainBackground() {
    return Positioned.fill(
      child: Container(),
    );
  }

  Widget _buildCardContent() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      left: Dimens.margin38,
      child: Container(
        decoration: _buildCardContentDecoration(),
        child: Padding(
          padding: const EdgeInsets.only(left: Dimens.margin38),
          child: _buildCardTextContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildCardContentDecoration() {
    return BoxDecoration(
      color: const Color(0x66000000),
      borderRadius: BorderRadius.circular(Dimens.margin10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          offset: Offset(0, 5),
          blurRadius: 30,
          spreadRadius: -10,
        ),
        BoxShadow(
          color: Color(0x12FFFFFF),
          offset: Offset.zero,
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _buildCardTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCardTitle(),
        SizedBox(height: Dimens.margin5),
        _buildCardDescription(),
      ],
    );
  }

  Widget _buildCardTitle() {
    return Padding(
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
    );
  }

  Widget _buildCardDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.margin15),
      child: AppText(
        text: widget.hookah.description,
        appTextStyle: AppTextStyle.rubikRegular14Light,
        customColor: const Color(0xFFAAAAAA),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCircularImage() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: _buildImageContainer(),
      ),
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: Dimens.margin76,
      height: Dimens.margin76,
      decoration: _buildImageBorderDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimens.margin38),
        child: _buildCachedNetworkImage(),
      ),
    );
  }

  BoxDecoration _buildImageBorderDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFF004225),
        width: 4,
      ),
    );
  }

  Widget _buildCachedNetworkImage() {
    return ImageCacheManager.getNetworkImage(
      url: widget.hookah.imageUrl,
      width: Dimens.margin76,
      height: Dimens.margin76,
      fit: BoxFit.cover,
      placeholder: _buildCircularImageLoading(),
      errorWidget: _buildCircularImageError(),
      borderRadius: BorderRadius.circular(Dimens.margin38),
    );
  }

  Widget _buildCircularImageLoading() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.colorECC16E),
      ),
    );
  }

  Widget _buildCircularImageError() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
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
            child: _buildNotAvailableText(),
          ),
        ),
      ),
    );
  }

  Widget _buildNotAvailableText() {
    return Padding(
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
    );
  }
}