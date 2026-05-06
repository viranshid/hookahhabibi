import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHStaffMenuHeader extends StatelessWidget {
  final Widget? child;
  final double height;

  const HHStaffMenuHeader({
    Key? key,
    this.child,
    this.height = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.color004216,
      ),
      child: Stack(
        children: [
          _buildLogoWidget(),
          if (child != null)
            Positioned.fill(
              child: child!,
            ),
        ],
      ),
    );
  }

  /// Separate widget function for logo
  Widget _buildLogoWidget() {
    return Positioned(
      left: 15,
      top: 0,
      bottom: 0,
      child: Container(
        width: 270,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.colorFFFFFF,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            APPImages.icHeaderLogo,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.color171717,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.color949494,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
