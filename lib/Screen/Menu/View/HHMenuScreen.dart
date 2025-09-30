import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHWelcomeMenuType.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuListCard.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuContentArea.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHMenuScreen extends StatefulWidget {
  final String locationName;
  final String locationId;

  const HHMenuScreen({
    Key? key,
    required this.locationName,
    required this.locationId,
  }) : super(key: key);

  @override
  State<HHMenuScreen> createState() => _HHMenuScreenState();
}

class _HHMenuScreenState extends State<HHMenuScreen> {
  bool isMenuOpen = true;
  String locationName = 'Karet Kuningan, Jakarta 12940';
  String categoryTitle = 'Cool Appetizer and Salad';

  // Add proper state management for selected menu item
  HHWelcomeMenuType? selectedMenuItem;

  @override
  void initState() {
    super.initState();
    // Initialize with first menu item
    selectedMenuItem = HHWelcomeMenuType.getAllItems().first;
    categoryTitle = selectedMenuItem?.title ?? 'Cool Appetizer and Salad';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(APPImages.imgMenuBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            _buildMenuList(),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isMenuOpen ? Dimens.margin300 : Dimens.margin100,
      child: HHMenuListCard(
        isMenuOpen: isMenuOpen,
        selectedMenuItem: selectedMenuItem,
        onMenuToggle: (value) {
          setState(() {
            isMenuOpen = value;
          });
        },
        onMenuItemSelected: (menuType) {
          setState(() {
            selectedMenuItem = menuType;
            categoryTitle = menuType.title;
          });
          print('Selected menu: ${menuType.title}');
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: Dimens.margin80,
          decoration: BoxDecoration(
            color: const Color(0xFF004216),
            border: const Border(
              bottom: BorderSide(
                color: Color(0x1AFFFFFF), // #FFFFFF1A
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
              _buildLocationSection(),
              SizedBox(width: Dimens.margin20),
              _buildUserSection(),
              SizedBox(width: Dimens.margin15),
            ],
          ),
        ),
        // Position the toggle button half outside
        Positioned(
          left: -Dimens.margin18, // Half of 36 (button width) outside
          top: (Dimens.margin80 - Dimens.margin36) / 2, // Center vertically
          child: _buildMenuToggleButton(),
        ),
      ],
    );
  }

  Widget _buildMenuToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      },
      child: Container(
        width: Dimens.margin36,
        height: Dimens.margin36,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(APPImages.imgMenuBtnMinimizeBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            isMenuOpen ? APPImages.icErrorBack : APPImages.icErrorForword,
            width: Dimens.margin20,
            height: Dimens.margin20,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTitle() {
    return AppText(
      text: categoryTitle,
      appTextStyle: AppTextStyle.oswaldSemiBold26Light,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildUserSection() {
    return Container(
      width: Dimens.margin93,
      height: Dimens.margin50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.margin25),
        color: AppColors.color00541A,
      ),
      child: Row(
        children: [
          SizedBox(width: Dimens.margin4),
          // Avatar
          Container(
            width: Dimens.margin42,
            height: Dimens.margin42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                APPImages.icAvatar,
                width: Dimens.margin42,
                height: Dimens.margin42,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: Dimens.margin42,
                    height: Dimens.margin42,
                    decoration: BoxDecoration(
                      color: AppColors.color949494.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.colorECC16E,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: Dimens.margin12),
          // Lock Icon
          Image.asset(
            APPImages.icLock,
            width: Dimens.margin26,
            height: Dimens.margin26,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.lock,
                size: Dimens.margin26,
                color: AppColors.colorECC16E,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            APPImages.icMapPin,
            width: Dimens.margin28,
            height: Dimens.margin28,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.location_on,
                size: Dimens.margin28,
                color: AppColors.colorECC16E,
              );
            },
          ),
          SizedBox(width: Dimens.margin8),
          Flexible(
            child: AppText(
              text: locationName,
              appTextStyle: AppTextStyle.oswaldRegular16OffWhite,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return HHMenuContentArea(
      isMenuOpen: isMenuOpen,
    );
  }
}