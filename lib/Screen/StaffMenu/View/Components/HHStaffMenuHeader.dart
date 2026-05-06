import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/StaffMenuTab.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHStaffMenuTabItem.dart';
import 'package:hookahhabibi/Widgets/HHHeaderUserLocation.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHStaffMenuHeader extends StatelessWidget {
  final StaffMenuTab selectedTab;
  final ValueChanged<StaffMenuTab> onTabSelected;
  final String locationName;
  final double height;

  static const double _logoLeft = 15;
  static const double _logoWidth = 270;
  static const double _logoHeight = 100;
  static const double _tabsLeftGap = 25;
  static const double _tabSpacing = 0;

  const HHStaffMenuHeader({
    Key? key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.locationName,
    this.height = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.color004216,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: _logoLeft,
            top: 0,
            child: _buildLogoImage(),
          ),
          Positioned(
            left: _logoLeft + _logoWidth + _tabsLeftGap,
            top: 0,
            child: _buildTabsRow(),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: HHHeaderUserLocation(locationName: locationName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage() {
    return SizedBox(
      width: _logoWidth,
      height: _logoHeight,
      child: Image.asset(
        APPImages.logoMember,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTabsRow() {
    final tabs = StaffMenuTab.values;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: _tabSpacing),
          HHStaffMenuTabItem(
            tab: tabs[i],
            isSelected: tabs[i] == selectedTab,
            onTap: () => onTabSelected(tabs[i]),
          ),
        ],
      ],
    );
  }
}
