import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHWelcomeMenuType.dart';
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
  HHWelcomeMenuType? selectedMenuItem;
  final ScrollController _scrollController = ScrollController();

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
          itemCount: HHWelcomeMenuType.getAllItems().length,
          separatorBuilder: (context, index) => const SizedBox(width: Dimens.margin16),
          itemBuilder: (context, index) {
            final menuItem = HHWelcomeMenuType.getAllItems()[index];
            return HHWelcomeMenuCard(
              menuType: menuItem,
              isSelected: selectedMenuItem == menuItem,
              onTap: _handleMenuItemTap,
            );
          },
        ),
      ),
    );
  }

  void _handleMenuItemTap(HHWelcomeMenuType menuType) {
    setState(() {
      selectedMenuItem = selectedMenuItem == menuType ? null : menuType;
    });

    // Print selected menu item details
    print('Menu item selected: ${menuType.title}');
    print('Menu item type: ${menuType.name}');
    print('Image path: ${menuType.imagePath}');

    // Navigate to Menu Screen with location data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HHMenuScreen(
          locationName: widget.locationName,
          locationId: widget.locationId,
        ),
      ),
    );
  }

  void _onMenuItemSelected(HHWelcomeMenuType menuType) {
    // This method can be used to handle the selection logic
    // You can pass this as a callback to parent widgets if needed

    switch (menuType) {
      case HHWelcomeMenuType.newAddition:
        _handleNewAddition();
        break;
      case HHWelcomeMenuType.exploreMenu:
        _handleExploreMenu();
        break;
      case HHWelcomeMenuType.hotAppetizers:
        _handleHotAppetizers();
        break;
      case HHWelcomeMenuType.starters:
        _handleStarters();
        break;
      case HHWelcomeMenuType.mainCourse:
        _handleMainCourse();
        break;
      case HHWelcomeMenuType.desserts:
        _handleDesserts();
        break;
      case HHWelcomeMenuType.drinks:
        _handleDrinks();
        break;
      case HHWelcomeMenuType.shisha:
        _handleShisha();
        break;
      case HHWelcomeMenuType.tea:
        _handleTea();
        break;
    }
  }

  // Individual handler methods for each menu type
  void _handleNewAddition() {
    print('Handling New Addition selection');
    // Implement specific logic for New Addition
  }

  void _handleExploreMenu() {
    print('Handling Explore Menu selection');
    // Implement specific logic for Explore Menu
  }

  void _handleHotAppetizers() {
    print('Handling Hot Appetizers selection');
    // Implement specific logic for Hot Appetizers
  }

  void _handleStarters() {
    print('Handling Starters selection');
    // Implement specific logic for Starters
  }

  void _handleMainCourse() {
    print('Handling Main Course selection');
    // Implement specific logic for Main Course
  }

  void _handleDesserts() {
    print('Handling Desserts selection');
    // Implement specific logic for Desserts
  }

  void _handleDrinks() {
    print('Handling Drinks selection');
    // Implement specific logic for Drinks
  }

  void _handleShisha() {
    print('Handling Shisha selection');
    // Implement specific logic for Shisha
  }

  void _handleTea() {
    print('Handling Tea selection');
    // Implement specific logic for Tea
  }
}