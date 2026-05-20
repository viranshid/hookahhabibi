import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHOrderStatus.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHOrderStatusHeader extends StatelessWidget {
  final HHOrderStatus? selectedStatus;
  final ValueChanged<HHOrderStatus>? onStatusSelected;
  final VoidCallback? onNewOrderPressed;

  const HHOrderStatusHeader({
    Key? key,
    this.selectedStatus,
    this.onStatusSelected,
    this.onNewOrderPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Stack(
        children: [
          Container(color: AppColors.color01110A),
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < HHOrderStatus.values.length; i++) ...[
                        if (i > 0) const SizedBox(width: 20),
                        _buildTab(HHOrderStatus.values[i]),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: _buildNewOrderButton(),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 1, color: AppColors.colorECC16E1A),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(HHOrderStatus status) {
    final bool isSelected = selectedStatus == status;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStatusSelected == null ? null : () => onStatusSelected!(status),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: status.indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          AppText(
            text: status.label,
            appTextStyle: AppTextStyle.jostSemiBold18White,
            customFontSize: 13,
            customFontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            applyTextTransform: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrderButton() {
    return SizedBox(
      width: 160,
      height: 40,
      child: ElevatedButton(
        onPressed: onNewOrderPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorBD7D28,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const AppText(
          text: 'New Order',
          appTextStyle: AppTextStyle.jostSemiBold18White,
          customFontSize: 16,
          applyTextTransform: false,
        ),
      ),
    );
  }
}
