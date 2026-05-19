import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuListCard.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHSelectedMealItem.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHKotPanel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHOrderItemNotesCard.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHStaffMenuContentArea.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
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
  static const double _headerWidth = 90;

  HHDishCategoryModel? _selectedCategory;
  final List<HHSelectedMealItem> _selectedMeals = [];

  void _handleItemSelected(HHDishModel dish) {
    setState(() {
      final index = _selectedMeals.indexWhere((m) => m.id == dish.id);
      if (index >= 0) {
        final existing = _selectedMeals[index];
        _selectedMeals[index] =
            existing.copyWith(quantity: existing.quantity + 1);
      } else {
        final priceSource =
            dish.rawPrice.isNotEmpty ? dish.rawPrice : dish.price;
        final breadcrumb = dish.fullCategory.isNotEmpty
            ? dish.fullCategory
            : [_selectedCategory?.title ?? '', dish.category]
                .where((s) => s.isNotEmpty)
                .join(' > ');
        _selectedMeals.add(HHSelectedMealItem(
          id: dish.id,
          title: dish.name,
          unitPrice: HHSelectedMealItem.parsePrice(priceSource),
          imageUrl: dish.imageUrl,
          subtitle: breadcrumb,
        ));
      }
    });
  }

  void _incrementItem(String id) {
    setState(() {
      final index = _selectedMeals.indexWhere((m) => m.id == id);
      if (index < 0) return;
      final item = _selectedMeals[index];
      _selectedMeals[index] = item.copyWith(quantity: item.quantity + 1);
    });
  }

  void _decrementItem(String id) {
    setState(() {
      final index = _selectedMeals.indexWhere((m) => m.id == id);
      if (index < 0) return;
      final item = _selectedMeals[index];
      if (item.quantity <= 1) {
        _selectedMeals.removeAt(index);
      } else {
        _selectedMeals[index] = item.copyWith(quantity: item.quantity - 1);
      }
    });
  }

  void _removeItem(String id) {
    setState(() {
      _selectedMeals.removeWhere((m) => m.id == id);
    });
  }

  Future<void> _handleAddNote(String id) async {
    final index = _selectedMeals.indexWhere((m) => m.id == id);
    if (index < 0) return;
    final item = _selectedMeals[index];
    final note = await HHOrderItemNotesCard.show(
      context,
      dishTitle: item.title,
      dishSubtitle: item.subtitle ?? '',
      imageUrl: item.imageUrl,
      initialNote: item.notes,
    );
    if (note == null) return;
    final latestIndex = _selectedMeals.indexWhere((m) => m.id == id);
    if (latestIndex < 0) return;
    setState(() {
      _selectedMeals[latestIndex] =
          _selectedMeals[latestIndex].copyWith(notes: note);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth =
        screenWidth - Dimens.margin90 - Dimens.margin300;

    return Container(
      color: AppColors.color01110A,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HHMenuListCard(
            isMenuOpen: false,
            collapsedWidth: Dimens.margin105,
            selectedMenuItem: _selectedCategory,
            onMenuItemSelected: (category) {
              setState(() => _selectedCategory = category);
            },
            header: _buildMenuDishesHeader(),
          ),
          Expanded(
            child: HHStaffMenuContentArea(
              selectedCategoryId: _selectedCategory?.id,
              contentWidth: contentWidth > 0 ? contentWidth : screenWidth,
              onItemSelected: _handleItemSelected,
            ),
          ),
          HHKotPanel(
            selectedItems: _selectedMeals,
            onIncrementItem: _incrementItem,
            onDecrementItem: _decrementItem,
            onRemoveItem: _removeItem,
            onAddNote: _handleAddNote,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuDishesHeader() {
    return Container(
      width: _headerWidth,
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
