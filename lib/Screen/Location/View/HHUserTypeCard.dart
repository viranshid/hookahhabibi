import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHUserTypeEnum.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHUserTypeCard extends StatelessWidget {
  final HHUserType userType;
  final String label;
  final String assetIcon;
  final bool isSelected;
  final VoidCallback onTap;

  // Constants from design
  static const double _cardHeight = 120;
  static const double _cardBorderRadius = 12;
  static const double _iconSize = 50;
  static const double _radioButtonSize = 20;
  static const double _radioButtonPadding = 15;
  static const double _innerCircleSize = 12;
  static const double _innerCircleBorderRadius = 6;
  static const int _animationDuration = 300;

  // Shadow values
  static const Color _shadowColor = Color(0x1F000000); // #0000001F
  static const double _shadowOffsetY = 5;
  static const double _shadowBlur = 20;
  static const double _shadowSpread = -5;

  static const Color _innerShadowColor = Color(0x0D000000); // #0000000D
  static const double _innerShadowBlur = 10;

  // Typography
  static const double _labelFontSize = 22;
  static const double _labelLineHeight = 20 / 22;

  const HHUserTypeCard({
    Key? key,
    required this.userType,
    required this.label,
    required this.assetIcon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: _animationDuration),
        curve: Curves.easeOut,
        height: _cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          boxShadow: [
            // Main shadow: 0px 5px 20px -5px #0000001F
            BoxShadow(
              color: _shadowColor,
              offset: const Offset(0, _shadowOffsetY),
              blurRadius: _shadowBlur,
              spreadRadius: _shadowSpread,
            ),
            // Inner blur effect: 0px -8px 10px 0px #0000000D
            BoxShadow(
              color: _innerShadowColor,
              offset: const Offset(0, 0),
              blurRadius: _innerShadowBlur,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icon (50x50) - centered horizontally
            Align(
              alignment: const Alignment(0, -0.4),
              child: Image.asset(
                assetIcon,
                width: _iconSize,
                height: _iconSize,
                fit: BoxFit.contain,
              ),
            ),
            // Label (Staff Member / Customer) - centered horizontally, below icon
            Align(
              alignment: const Alignment(0, 0.5),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                  fontSize: _labelFontSize,
                  height: _labelLineHeight,
                  letterSpacing: 0,
                  color: AppColors.color00541A,
                ),
              ),
            ),
            // Radio button (20x20) - top right corner with 15px padding
            Positioned(
              top: _radioButtonPadding,
              right: _radioButtonPadding,
              child: _buildRadioButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton() {
    return SizedBox(
      width: _radioButtonSize,
      height: _radioButtonSize,
      child: Stack(
        children: [
          // Outer circle
          Container(
            width: _radioButtonSize,
            height: _radioButtonSize,
            decoration: BoxDecoration(
              color: AppColors.colorD9D9D9, // Light gray background
              borderRadius: BorderRadius.circular(_radioButtonSize / 2),
              border: Border.all(
                color: AppColors.color00541A80, // Dark green 50% opacity
                width: 1.5,
              ),
            ),
          ),
          // Inner circle (only visible when selected)
          if (isSelected)
            Center(
              child: Container(
                width: _innerCircleSize,
                height: _innerCircleSize,
                decoration: BoxDecoration(
                  color: AppColors.color00541A,
                  borderRadius: BorderRadius.circular(_innerCircleBorderRadius),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
