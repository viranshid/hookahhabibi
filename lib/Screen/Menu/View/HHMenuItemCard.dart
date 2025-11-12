import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/ImageCacheManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHMenuItemCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final bool isExpanded;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final bool isMenuOpen;
  final bool isGoldenSaprator;
  final VoidCallback? onTap;

  const HHMenuItemCard({
    Key? key,
    required this.title,
    required this.imagePath,
    this.isExpanded = false,
    this.isSelected = false,
    this.isFirst = false,
    this.isLast = false,
    this.isMenuOpen = true,
    this.isGoldenSaprator = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<HHMenuItemCard> createState() => _HHMenuItemCardState();
}

class _HHMenuItemCardState extends State<HHMenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(HHMenuItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when selection changes
    if (oldWidget.isSelected != widget.isSelected) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get isSelected => widget.isSelected;
  bool get isFirst => widget.isFirst;
  bool get isLast => widget.isLast;
  bool get isMenuOpen => widget.isMenuOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 0,
                  right: Dimens.margin15,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? AppColors.color004216
                            : Colors.transparent,
                        border: _buildCustomBorder(),
                      ),
                      child: widget.isMenuOpen
                          ? _buildExpandedContent()
                          : _buildCollapsedContent(),
                    ),
                    if (widget.isSelected)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        right: -15.0,
                        top: widget.isMenuOpen ? 0 : -30,
                        bottom: 0,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: 1.0,
                            child: CustomPaint(
                              size: const Size(15.0, 30.0),
                              painter: TrianglePainter(color: AppColors.color004216),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Border _buildCustomBorder() {
    const borderColor = AppColors.colorECC16E;
    const transparentColor = Colors.transparent;
    const borderWidth = 1.0;
    const selectedBorderWidth = 2.0;

    // All items have all 4 borders defined
    // Only show colors where needed, rest are transparent

    if (isSelected) {
      // Selected: Show top and bottom borders (2px), hide left and right
      return Border(
        top: BorderSide(
          color: borderColor,
          width: selectedBorderWidth,
        ),
        bottom: BorderSide(
          color: borderColor,
          width: selectedBorderWidth,
        ),
        left: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
        right: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
      );
    } else if (isFirst) {
      // First item: Show bottom and right borders, hide top and left
      return const Border(
        top: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
        bottom: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
        left: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
        right: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      );
    } else if (isLast) {
      // Last item: Show top and right borders, hide bottom and left
      return const Border(
        top: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
        bottom: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
        left: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
        right: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      );
    } else {
      // Regular items: Show bottom and right borders, hide top and left
      return const Border(
        top: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
        bottom: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
        left: BorderSide(
          color: transparentColor,
          width: borderWidth,
        ),
        right: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      );
    }
  }

  Widget _buildExpandedContent() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.margin10,
        vertical: Dimens.margin10,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 100) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImage(),
                const SizedBox(height: Dimens.margin8),
                _buildCollapsedText(),
              ],
            );
          }

          return Row(
            children: [
              _buildImage(),
              const SizedBox(width: Dimens.margin10),
              Expanded(
                child: _buildText(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.margin5,
        vertical: Dimens.margin10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImage(),
          const SizedBox(height: Dimens.margin8),
          _buildCollapsedText(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final isUrl = widget.imagePath.startsWith('http://') || widget.imagePath.startsWith('https://');

    return RepaintBoundary(
      key: ValueKey('image_${widget.imagePath}'),
      child: Container(
        width: Dimens.margin70,
        height: Dimens.margin70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.margin8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.margin8),
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
                      borderRadius: BorderRadius.circular(Dimens.margin8),
                    ),
                  );
                },
              ),
            ),
            // Foreground icon/image
            if (isUrl)
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.margin6),
                child: Image.network(
                  widget.imagePath,
                  key: ValueKey('network_${widget.imagePath}'),
                  width: Dimens.margin40,
                  height: Dimens.margin40,
                  fit: BoxFit.contain,
                  cacheWidth: 120,
                  cacheHeight: 120,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: Dimens.margin40,
                      height: Dimens.margin40,
                      color: Colors.transparent,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: Dimens.margin40,
                      height: Dimens.margin40,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.restaurant_menu,
                        color: widget.isSelected
                            ? AppColors.colorFFFFFF
                            : AppColors.colorECC16E,
                        size: 20,
                      ),
                    );
                  },
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.margin6),
                child: Image.asset(
                  widget.imagePath,
                  key: ValueKey('asset_${widget.imagePath}'),
                  width: Dimens.margin40,
                  height: Dimens.margin40,
                  fit: BoxFit.contain,
                  color: widget.isSelected ? null : AppColors.colorFFFFFF.withOpacity(0.7),
                  colorBlendMode: widget.isSelected ? null : BlendMode.modulate,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: Dimens.margin40,
                      height: Dimens.margin40,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.restaurant_menu,
                        color: widget.isSelected
                            ? AppColors.colorFFFFFF
                            : AppColors.colorECC16E,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildText() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      style: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w400,
        fontSize: Dimens.textSize20,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.colorECC16E,
      ),
      child: Text(
        widget.title.toUpperCase(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCollapsedText() {
    return SizedBox(
      width: Dimens.margin80,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        style: TextStyle(
          fontFamily: 'Oswald',
          fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w400,
          fontSize: Dimens.textSize14,
          height: 18 / 14,
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        ),
        child: Text(
          widget.title.toUpperCase(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTriangleIndicator() {
    double rightPosition = -15.0;
    double triangleWidth = 15.0;
    double triangleHeight = 30.0;
    double topPosition = widget.isMenuOpen ? 0 : -30;

    return Positioned(
      right: rightPosition,
      top: topPosition,
      bottom: 0,
      child: Center(
        child: CustomPaint(
          size: Size(triangleWidth, triangleHeight),
          painter: TrianglePainter(color: AppColors.color004216),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}