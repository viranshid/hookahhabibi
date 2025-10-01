import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuScreen.dart';
import 'package:hookahhabibi/Screen/Welcom/View/HHWelcomeMenuCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/utils/app_Strings.dart';

class HHWelcome extends StatefulWidget {
  final String locationName;
  final String locationId;

  const HHWelcome({
    Key? key,
    this.locationName = 'Default Location',
    this.locationId = '',
  }): super(key: key);

  @override
  State<HHWelcome> createState() => _HHWelcomeState();
}

class _HHWelcomeState extends State<HHWelcome> {
  HHDishCategoryModel? selectedMenuItem;
  final ScrollController _scrollController = ScrollController();
  final HHAppManager _appManager = HHAppManager();
  bool _isLoading = false;
  List<HHDishCategoryModel> _categories = [];

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
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(APPImages.imgWelcomeBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildLogo(),
              _buildTitle(),
              _buildSubTitle(),
              _buildWelcomeSubImage(),
              _buildMenuScrollView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin70),
      child: Center(
        child: Container(
          width: Dimens.margin450,
          height: Dimens.margin129,
          child: Image.asset(
            APPImages.icLoginLogo,
            width: Dimens.margin450,
            height: Dimens.margin129,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin20),
      child: Center(
        child: Container(
          height: Dimens.margin80,
          child: AppText(
            text: APPStrings.wcTitle,
            appTextStyle: AppTextStyle.oswaldBold54White,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSubTitle() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin15),
      child: Center(
        child: Container(
          width: Dimens.margin500,
          height: Dimens.margin64,
          child: AppText(
            text: APPStrings.wcSubTitle,
            appTextStyle: AppTextStyle.merriweatherItalic22White,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSubImage() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin28),
      child: Center(
        child: Container(
          width: Dimens.margin538,
          height: Dimens.margin118,
          child: Image.asset(
            APPImages.imgWelcomSubimage,
            width: Dimens.margin538,
            height: Dimens.margin118,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: Dimens.margin538,
                height: Dimens.margin118,
                decoration: BoxDecoration(
                  color: AppColors.color949494.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(Dimens.margin10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    color: AppColors.colorECC16E,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuScrollView() {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: Dimens.margin60),
        height: Dimens.margin150,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: Dimens.margin60),
        height: Dimens.margin150,
        child: Center(
          child: AppText(
            text: 'No categories available',
            appTextStyle: AppTextStyle.jostMedium16Gray,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin60,
        left: Dimens.margin140,
        right: Dimens.margin140,
      ),
      height: Dimens.margin150,
      child: Center(
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: Dimens.margin16),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return HHWelcomeMenuCard(
              category: category,
              isSelected: selectedMenuItem?.id == category.id,
              onTap: _handleMenuItemTap,
            );
          },
        ),
      ),
    );
  }

  void _handleMenuItemTap(HHDishCategoryModel category) {
    setState(() {
      selectedMenuItem = selectedMenuItem?.id == category.id ? null : category;
    });

    print('Category selected: ${category.title}');
    print('Category ID: ${category.id}');

    // Navigate to Menu Screen with location and category data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HHMenuScreen(
          locationName: widget.locationName,
          locationId: widget.locationId,
          selectedCategoryId: category.id,
        ),
      ),
    );
  }
}