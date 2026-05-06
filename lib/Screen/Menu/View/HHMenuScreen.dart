import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Service/HHMenuLegendModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuLegend.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuListCard.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuContentArea.dart';
import 'package:hookahhabibi/Widgets/HHHeaderUserLocation.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHMenuScreen extends StatefulWidget {
  final String locationName;
  final String locationId;
  final String? selectedCategoryId;

  const HHMenuScreen({
    Key? key,
    required this.locationName,
    required this.locationId,
    this.selectedCategoryId,
  }) : super(key: key);

  @override
  State<HHMenuScreen> createState() => _HHMenuScreenState();
}

class _HHMenuScreenState extends State<HHMenuScreen> {
  bool isMenuOpen = true;
  String locationName = '';
  String categoryTitle = '';
  final HHAppManager _appManager = HHAppManager();

  HHDishCategoryModel? selectedMenuItem;

  @override
  void initState() {
    super.initState();
    locationName = widget.locationName;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_appManager.menuManager.categories.isEmpty) {
      await _appManager.menuManager.loadCategories();
    }

    if (widget.selectedCategoryId != null) {
      selectedMenuItem = _appManager.menuManager.categories.firstWhere(
        (cat) => cat.id == widget.selectedCategoryId,
        orElse: () => _appManager.menuManager.categories.first,
      );
    } else if (_appManager.menuManager.categories.isNotEmpty) {
      selectedMenuItem = _appManager.menuManager.categories.first;
    }

    if (selectedMenuItem != null) {
      categoryTitle = selectedMenuItem!.title;
      _appManager.menuManager.selectCategory(selectedMenuItem!);
      if (mounted) setState(() {});
    }
  }

  void _onCategoryChanged(HHDishCategoryModel category) {
    setState(() {
      selectedMenuItem = category;
      categoryTitle = category.title;
    });
    _appManager.menuManager.selectCategory(category);
  }

  final List<HHMenuLegendModel> _legends = [
    HHMenuLegendModel(iconString: APPImages.icVeg, title: 'Vegetarian Friendly'),
    HHMenuLegendModel(iconString: APPImages.icMediumChilli, title: 'Medium Spicy'),
    HHMenuLegendModel(iconString: APPImages.icChilli, title: 'Extra Spicy'),
    HHMenuLegendModel(iconString: APPImages.icThumbUp, title: 'Recommended'),
    HHMenuLegendModel(title: 'All prices are exclusive of applicable taxes.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.color01110A),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildMenuList(),
            ),
            Positioned(
              left: isMenuOpen ? Dimens.margin300 : Dimens.margin100,
              right: 0,
              top: 0,
              bottom: 0,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildContent()),
                  HHMenuLegend(legends: _legends),
                ],
              ),
            ),
            Positioned(
              left: (isMenuOpen ? Dimens.margin300 : Dimens.margin100) -
                  Dimens.margin18,
              top: Dimens.margin22,
              child: _buildMenuToggleButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: isMenuOpen ? Dimens.margin300 : Dimens.margin100,
      child: HHMenuListCard(
        isMenuOpen: isMenuOpen,
        selectedMenuItem: selectedMenuItem,
        onMenuToggle: (value) {
          setState(() {
            isMenuOpen = value;
          });
        },
        onMenuItemSelected: _onCategoryChanged,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: Dimens.margin80,
      decoration: BoxDecoration(
        color: const Color(0xFF004216),
        border: const Border(
          bottom: BorderSide(
            color: Color(0x1AFFFFFF),
            width: Dimens.margin2,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(Dimens.margin40),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: Dimens.margin30),
          _buildCategoryTitle(),
          const Spacer(),
          HHHeaderUserLocation(locationName: locationName),
        ],
      ),
    );
  }

  Widget _buildMenuToggleButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: Dimens.margin36,
        height: Dimens.margin36,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(APPImages.imgMenuBtnMinimizeBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedRotation(
            turns: isMenuOpen ? 0 : 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Image.asset(
              APPImages.icErrorBack,
              width: Dimens.margin20,
              height: Dimens.margin20,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTitle() {
    return AppText(
      key: ValueKey(categoryTitle),
      text: categoryTitle,
      appTextStyle: AppTextStyle.oswaldSemiBold26Light,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildContent() {
    return HHMenuContentArea(
      isMenuOpen: isMenuOpen,
      selectedCategoryId: selectedMenuItem?.id,
    );
  }
}
