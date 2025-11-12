import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Managers/HHLockManager.dart';
import 'package:hookahhabibi/Screen/Login/HHLogin.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationScreen.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuListCard.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuContentArea.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuUnlockScreen.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuPopover.dart';
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
  final HHLockManager _lockManager = HHLockManager();
  final GlobalKey _userSectionKey = GlobalKey();

  HHDishCategoryModel? selectedMenuItem;

  @override
  void initState() {
    super.initState();
    locationName = widget.locationName;
    _loadInitialData();
    _lockManager.addListener(_onLockStateChanged);
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
      setState(() {});
    }
  }

  void _onCategoryChanged(HHDishCategoryModel category) {
    setState(() {
      selectedMenuItem = category;
      categoryTitle = category.title;
    });
    _appManager.menuManager.selectCategory(category);
    print('Selected menu: ${category.title}');
  }

  void _onLockStateChanged() {
    setState(() {});
  }

  Future<void> _handleLockIconTap() async {
    if (_lockManager.isLocked) {
      print('Lock icon tapped - Opening unlock screen');

      final bool? unlocked = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return HHMenuUnlockScreen(
            onUnlocked: () {
              print('Menu unlocked successfully');
            },
            onCancel: () {
              print('Unlock cancelled');
            },
          );
        },
      );

      if (unlocked == true) {
        print('User successfully unlocked the menu');
      }
    } else {
      _showMenuPopover();
    }
  }

  // NEW: Handle location tap
  void _handleLocationTap() {
    print('\n📍 Location tapped');

    // Only allow navigation if menu is unlocked
    if (_lockManager.isLocked) {
      print('   ⚠️ Menu is locked, ignoring location tap');
      _showSnackBar('Please unlock the menu to change location');
      return;
    }

    print('   ✅ Menu is unlocked, navigating to location screen');
    _navigateToLocationScreen();
  }

  // NEW: Navigate to location screen
  Future<void> _navigateToLocationScreen() async {
    print('   🚀 Navigating to Location Screen');

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.margin10),
        ),
        title: const Text(
          'Change Location',
          style: TextStyle(
            color: AppColors.colorFFFFFF,
            fontFamily: 'Oswald',
            fontSize: 24,
          ),
        ),
        content: const Text(
          'Would you like to change your restaurant location?',
          style: TextStyle(
            color: AppColors.color949494,
            fontFamily: 'Rubik',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.color949494),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Change',
              style: TextStyle(color: AppColors.colorECC16E),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      print('   ✅ User confirmed location change');

      // Navigate to location screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HHLocationScreen(),
        ),
      );
    } else {
      print('   ❌ User cancelled location change');
    }
  }

  void _showMenuPopover() {
    final RenderBox? renderBox = _userSectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 8,
        position.dx + size.width,
        position.dy + size.height + 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.margin8),
      ),
      elevation: 20,
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: HHMenuPopover(
            onActionSelected: _handleMenuAction,
          ),
        ),
      ],
    );
  }

  Future<void> _handleMenuAction(HHMenuAction action) async {
    switch (action) {
      case HHMenuAction.lockScreen:
        await _lockManager.lock();
        _showSnackBar('Menu screen locked');
        print('Menu locked');
        break;

      case HHMenuAction.settingsProfile:
        _showSnackBar('Settings Profile - Coming soon');
        print('Settings Profile tapped');
        break;

      case HHMenuAction.signOut:
        await _handleSignOut();
        break;
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.margin10),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppColors.colorFFFFFF,
            fontFamily: 'Oswald',
            fontSize: 24,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: AppColors.color949494,
            fontFamily: 'Rubik',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.color949494),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.colorFF928A),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _appManager.logout();
      await _lockManager.reset();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HHLogin()),
              (route) => false,
        );
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.colorBD7D28,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(Dimens.margin20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.margin10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lockManager.removeListener(_onLockStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            color: AppColors.color01110A,
        ),
        child: Stack(
          children: [
            // Layer 1: Menu list (bottom)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildMenuList(),
            ),

            // Layer 2: Main content (middle)
            Positioned(
              left: isMenuOpen ? Dimens.margin300 : Dimens.margin100,
              right: 0,
              top: 0,
              bottom: 0,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),

            // Layer 3: Toggle button (top - fully clickable)
            Positioned(
              left: (isMenuOpen ? Dimens.margin300 : Dimens.margin100) - Dimens.margin18,
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
          _buildLocationSection(), // This is now clickable
          SizedBox(width: Dimens.margin20),
          _buildUserSection(),
          SizedBox(width: Dimens.margin15),
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

  Widget _buildUserSection() {
    return GestureDetector(
      key: _userSectionKey,
      onTap: _handleLockIconTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: Dimens.margin93,
          height: Dimens.margin50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.margin25),
            color: AppColors.color00541A,
          ),
          child: Row(
            children: [
              SizedBox(width: Dimens.margin4),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  _lockManager.isLocked ? APPImages.icLock : APPImages.icErrowDown,
                  key: ValueKey(_lockManager.isLocked),
                  width: Dimens.margin26,
                  height: Dimens.margin26,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      _lockManager.isLocked ? Icons.lock : Icons.keyboard_arrow_down,
                      size: Dimens.margin26,
                      color: AppColors.colorECC16E,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: Made location section clickable
  Widget _buildLocationSection() {
    return GestureDetector(
      onTap: _handleLocationTap,
      child: MouseRegion(
        cursor: _lockManager.isLocked
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(Dimens.margin8),
            // Add visual feedback when hoverable
            border: !_lockManager.isLocked
                ? Border.all(
              color: Colors.transparent,
              width: 2,
            )
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.margin8,
            vertical: Dimens.margin4,
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
              // Add chevron icon when unlocked to indicate clickability
              if (!_lockManager.isLocked) ...[
                SizedBox(width: Dimens.margin4),
                Icon(
                  Icons.arrow_drop_down,
                  size: Dimens.margin20,
                  color: AppColors.colorECC16E,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return HHMenuContentArea(
      isMenuOpen: isMenuOpen,
      selectedCategoryId: selectedMenuItem?.id,
    );
  }
}