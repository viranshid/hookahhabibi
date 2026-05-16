import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuListCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHMenuTabScreen extends StatefulWidget {
  const HHMenuTabScreen({Key? key}) : super(key: key);

  @override
  State<HHMenuTabScreen> createState() => _HHMenuTabScreenState();
}

class _HHMenuTabScreenState extends State<HHMenuTabScreen> {
  static const Color _headerColor = Color(0xFFD09843);
  static const double _headerHeight = 50;
  static const double _headerTextBottomPadding = 9;

  HHDishCategoryModel? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.color01110A,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HHMenuListCard(
            isMenuOpen: false,
            selectedMenuItem: _selectedCategory,
            onMenuItemSelected: (category) {
              setState(() => _selectedCategory = category);
            },
            header: _buildMenuDishesHeader(),
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildMenuDishesHeader() {
    return Container(
      width: double.infinity,
      height: _headerHeight,
      color: _headerColor,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: _headerTextBottomPadding),
      child: AppText(
        text: 'MENU DISHES',
        appTextStyle: AppTextStyle.oswaldRegular14UppercaseLight,
        customColor: AppColors.colorFFFFFF,
        textAlign: TextAlign.center,
      ),
    );
  }
}
