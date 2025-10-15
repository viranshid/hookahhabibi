import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/ImageCacheManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHMenuItemCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isExpanded;
  final bool isSelected;
  final bool isMenuOpen;
  final bool isGoldenSaprator;
  final VoidCallback? onTap;

  const HHMenuItemCard({
    Key? key,
    required this.title,
    required this.imagePath,
    this.isExpanded = false,
    this.isSelected = false,
    this.isMenuOpen = true,
    this.isGoldenSaprator = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 0,
              right: Dimens.margin15,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.color00541A
                        : Colors.transparent,
                  ),
                  child: isMenuOpen
                      ? _buildExpandedContent()
                      : _buildCollapsedContent(),
                ),
                if (isSelected) _buildTriangleIndicator(),
              ],
            ),
          ),
          _buildSeparator(),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
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
    return Padding(
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
    final isUrl = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return RepaintBoundary(
      child: Container(
        width: Dimens.margin70,
        height: Dimens.margin70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.margin8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
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
            if (isUrl)
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.margin6),
                child: Image.network(
                  imagePath,
                  key: ValueKey(imagePath),
                  width: Dimens.margin40,
                  height: Dimens.margin40,
                  fit: BoxFit.contain,
                  cacheWidth: 40,
                  cacheHeight: 40,
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
                        color: isSelected
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
                  imagePath,
                  key: ValueKey(imagePath),
                  width: Dimens.margin40,
                  height: Dimens.margin40,
                  fit: BoxFit.contain,
                  color: isSelected ? null : AppColors.colorFFFFFF.withOpacity(0.7),
                  colorBlendMode: isSelected ? null : BlendMode.modulate,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: Dimens.margin40,
                      height: Dimens.margin40,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.restaurant_menu,
                        color: isSelected
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
    // Use bold font weight when selected
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, // Bold when selected
        fontSize: Dimens.textSize20,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.colorECC16E,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildCollapsedText() {
    return SizedBox(
      width: Dimens.margin80,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Oswald',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, // Bold when selected
          fontSize: Dimens.textSize14,
          height: 18 / 14,
          letterSpacing: 0,
          color: AppColors.colorECC16E,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: double.infinity,
      height: Dimens.margin1,
      margin: const EdgeInsets.only(
        left: 0,
        right: Dimens.margin15 + Dimens.margin10,
      ),
      child: CustomPaint(
        painter: DashedLinePainter(
          color: isGoldenSaprator ? AppColors.colorBD7D28 : AppColors.color33FFFF,
          strokeWidth: 1.0,
          dashLength: 3.0,
          gapLength: 3.0,
        ),
      ),
    );
  }

  Widget _buildTriangleIndicator() {
    double rightPosition = -15.0;
    double triangleWidth = 15.0;
    double triangleHeight = 30.0;
    double topPosition = isMenuOpen ? 0 : -30;

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

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedLinePainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 3.0,
    this.gapLength = 3.0,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      final endX = (startX + dashLength).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}