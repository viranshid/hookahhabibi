import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuItemCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHMenuListCard extends StatefulWidget {
  final bool isMenuOpen;
  final Function(bool)? onMenuToggle;
  final HHDishCategoryModel? selectedMenuItem;
  final Function(HHDishCategoryModel)? onMenuItemSelected;

  const HHMenuListCard({
    Key? key,
    this.isMenuOpen = false,
    this.onMenuToggle,
    this.selectedMenuItem,
    this.onMenuItemSelected,
  }) : super(key: key);

  @override
  State<HHMenuListCard> createState() => _HHMenuListCardState();
}

class _HHMenuListCardState extends State<HHMenuListCard> {
  final ScrollController _scrollController = ScrollController();
  final HHAppManager _appManager = HHAppManager();
  int? _expandedIndex;
  HHDishCategoryModel? _internalSelectedItem;
  List<HHDishCategoryModel> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    await _appManager.menuManager.loadCategories();

    setState(() {
      _categories = _appManager.menuManager.categories;
      // Initialize with the passed selected item or default to first item
      if (_categories.isNotEmpty) {
        _internalSelectedItem = widget.selectedMenuItem ?? _categories.first;
      }
      _isLoading = false;
    });
  }

  @override
  void didUpdateWidget(HHMenuListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state when external state changes
    if (widget.selectedMenuItem != oldWidget.selectedMenuItem) {
      _internalSelectedItem = widget.selectedMenuItem;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isMenuOpen ? Dimens.margin300 : Dimens.margin130,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(Dimens.margin10),
          bottomRight: Radius.circular(Dimens.margin10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoSection(),
          if (widget.isMenuOpen) _buildSeparatorLine(),
          Expanded(child: _buildMenuScrollView()),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: widget.isMenuOpen
            ? _buildExpandedLogo()
            : _buildCollapsedLogo(),
      ),
    );
  }

  Widget _buildExpandedLogo() {
    return Image.asset(
      APPImages.imgHookahMenuLogo,
      key: const ValueKey('expanded'),
      width: Dimens.margin300,
      height: Dimens.margin90,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: Dimens.margin300,
          height: Dimens.margin90,
          child: const Icon(
            Icons.restaurant_menu,
            color: AppColors.colorECC16E,
            size: 30,
          ),
        );
      },
    );
  }

  Widget _buildCollapsedLogo() {
    return Center(
      child: Image.asset(
        APPImages.imgMenuListLogoMin,
        key: const ValueKey('collapsed'),
        width: Dimens.margin90,
        height: Dimens.margin90,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: Dimens.margin90,
            height: Dimens.margin90,
            child: const Icon(
              Icons.restaurant_menu,
              color: AppColors.colorECC16E,
              size: 30,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeparatorLine() {
    return Container(
      width: double.infinity,
      height: Dimens.margin1,
      color: AppColors.color33FFFF,
    );
  }

  Widget _buildMenuScrollView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: AppText(
          text: 'No categories available',
          appTextStyle: AppTextStyle.jostMedium16Gray,
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero, // Remove default padding
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isExpanded = widget.isMenuOpen && _expandedIndex == index;
        final isSelected = _internalSelectedItem?.id == category.id;

        // Set isFirst for the first item in the list
        final isFirst = index == 0;

        // Set isLast for the last item in the list
        final isLast = index == _categories.length - 1;

        bool isGoldenSaprator = false;
        if (_internalSelectedItem != null) {
          final selectedIndex = _categories.indexWhere((c) => c.id == _internalSelectedItem!.id);
          if (index == selectedIndex || index == selectedIndex - 1) {
            isGoldenSaprator = true;
          }
        }

        return HHMenuItemCard(
          title: category.title,
          imagePath: category.image,
          isExpanded: isExpanded,
          isSelected: isSelected,
          isFirst: isFirst,
          isLast: isLast,
          isGoldenSaprator: isGoldenSaprator,
          isMenuOpen: widget.isMenuOpen,
          onTap: () {
            setState(() {
              if (_expandedIndex == index) {
                _expandedIndex = null;
              } else {
                _expandedIndex = index;
              }
              _internalSelectedItem = category;
            });

            widget.onMenuItemSelected?.call(category);
          },
        );
      },
    );
  }
}