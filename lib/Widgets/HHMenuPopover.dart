import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

enum HHMenuAction {
  lockScreen,
  settingsProfile,
  signOut,
}

class HHMenuPopover extends StatelessWidget {
  final Function(HHMenuAction)? onActionSelected;

  const HHMenuPopover({
    Key? key,
    this.onActionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: Dimens.margin220,
        decoration: BoxDecoration(
          color: AppColors.colorFFFFFF,
          borderRadius: BorderRadius.circular(Dimens.margin8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              icon: APPImages.icLock,
              text: 'Lock Screen',
              textColor: const Color(0xFF6C757D),
              iconColor: const Color(0xFF6C757D),
              onTap: () {
                Navigator.pop(context);
                onActionSelected?.call(HHMenuAction.lockScreen);
              },
            ),
            _buildDashedDivider(),
            _buildMenuItem(
              icon: APPImages.icProfile,
              text: 'Settings Profile',
              textColor: const Color(0xFF6C757D),
              iconColor: const Color(0xFF6C757D),
              onTap: () {
                Navigator.pop(context);
                onActionSelected?.call(HHMenuAction.settingsProfile);
              },
            ),
            _buildDashedDivider(),
            _buildMenuItem(
              icon: APPImages.icLogout,
              text: 'Sign Out',
              textColor: AppColors.colorFF928A,
              iconColor: AppColors.colorFF928A,
              onTap: () {
                Navigator.pop(context);
                onActionSelected?.call(HHMenuAction.signOut);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String text,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.margin16,
          vertical: Dimens.margin12,
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: Dimens.margin18,
              height: Dimens.margin18,
              color: iconColor,
              errorBuilder: (context, error, stackTrace) {
                IconData iconData = Icons.lock;
                if (icon.contains('profile')) {
                  iconData = Icons.person;
                } else if (icon.contains('logout')) {
                  iconData = Icons.logout;
                }
                return Icon(
                  iconData,
                  size: Dimens.margin18,
                  color: iconColor,
                );
              },
            ),
            SizedBox(width: Dimens.margin12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w400,
                  fontSize: Dimens.textSize14,
                  height: 18 / 14,
                  letterSpacing: 0,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Container(
      height: Dimens.margin1,
      margin: const EdgeInsets.symmetric(horizontal: Dimens.margin16),
      child: CustomPaint(
        painter: DashedLinePainter(
          color: const Color(0xFFE5E5E5),
          strokeWidth: 1.0,
          dashLength: 2.0,
          gapLength: 2.0,
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedLinePainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 2.0,
    this.gapLength = 2.0,
  });

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