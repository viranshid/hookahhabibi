import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/StaffMenuTab.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHStaffMenuTabItem extends StatelessWidget {
  static const double boxWidth = 100;
  static const double boxHeight = 80;
  static const double arrowHeight = 11.13;
  static const double totalHeight = boxHeight + arrowHeight;

  final StaffMenuTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const HHStaffMenuTabItem({
    Key? key,
    required this.tab,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: boxWidth,
        height: totalHeight,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          child: isSelected
              ? CustomPaint(
                  key: const ValueKey('selected'),
                  size: const Size(boxWidth, totalHeight),
                  painter: _SelectedTabPainter(),
                  child: _buildContent(),
                )
              : SizedBox(
                  key: const ValueKey('unselected'),
                  width: boxWidth,
                  height: totalHeight,
                  child: _buildContent(),
                ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(tab.icon, width: 36, height: 36),
          ),
        ),
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 22,
            child: Center(
              child: AppText(
                text: tab.label,
                appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedTabPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.color00541A
      ..style = PaintingStyle.fill;

    final boxBottom = HHStaffMenuTabItem.boxHeight;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, boxBottom)
      ..lineTo(62, boxBottom)
      ..lineTo(size.width / 2 + 0.5, size.height - 1)
      ..arcToPoint(
        Offset(size.width / 2 - 0.5, size.height - 1),
        radius: const Radius.circular(1),
      )
      ..lineTo(39.37, boxBottom)
      ..lineTo(0, boxBottom)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SelectedTabPainter oldDelegate) => false;
}
