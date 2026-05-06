import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Managers/HHLockManager.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationScreen.dart';
import 'package:hookahhabibi/Screen/Login/HHLogin.dart';
import 'package:hookahhabibi/Widgets/HHMenuPopover.dart';
import 'package:hookahhabibi/Widgets/HHMenuUnlockScreen.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:provider/provider.dart';

/// Shared header right-side widget: location pill + 20px gap + user pill + 15px trailing gap.
/// Same view & behavior as HHMenuScreen header (lock-aware, popover, location change).
class HHHeaderUserLocation extends StatefulWidget {
  final String locationName;

  const HHHeaderUserLocation({
    Key? key,
    required this.locationName,
  }) : super(key: key);

  @override
  State<HHHeaderUserLocation> createState() => _HHHeaderUserLocationState();
}

class _HHHeaderUserLocationState extends State<HHHeaderUserLocation> {
  final HHAppManager _appManager = HHAppManager();
  final GlobalKey _userSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final lockManager = context.watch<HHLockManager>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLocationSection(lockManager),
        SizedBox(width: Dimens.margin20),
        _buildUserSection(lockManager),
        SizedBox(width: Dimens.margin15),
      ],
    );
  }

  // ────────────────────────── User section ──────────────────────────

  Widget _buildUserSection(HHLockManager lockManager) {
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
                decoration: const BoxDecoration(shape: BoxShape.circle),
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
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Image.asset(
                  lockManager.isLocked ? APPImages.icLock : APPImages.icErrowDown,
                  key: ValueKey(lockManager.isLocked),
                  width: Dimens.margin26,
                  height: Dimens.margin26,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      lockManager.isLocked ? Icons.lock : Icons.keyboard_arrow_down,
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

  // ────────────────────────── Location section ──────────────────────────

  Widget _buildLocationSection(HHLockManager lockManager) {
    return GestureDetector(
      onTap: _handleLocationTap,
      child: MouseRegion(
        cursor: lockManager.isLocked
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(Dimens.margin8),
            border: !lockManager.isLocked
                ? Border.all(color: Colors.transparent, width: 2)
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
                  text: widget.locationName,
                  appTextStyle: AppTextStyle.oswaldRegular16OffWhite,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!lockManager.isLocked) ...[
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

  // ────────────────────────── Handlers ──────────────────────────

  Future<void> _handleLockIconTap() async {
    final lockManager = context.read<HHLockManager>();
    if (lockManager.isLocked) {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return HHMenuUnlockScreen(
            onUnlocked: () {},
            onCancel: () {},
          );
        },
      );
    } else {
      _showMenuPopover();
    }
  }

  void _handleLocationTap() {
    final lockManager = context.read<HHLockManager>();
    if (lockManager.isLocked) {
      _showSnackBar('Please unlock the menu to change location');
      return;
    }
    _navigateToLocationScreen();
  }

  Future<void> _navigateToLocationScreen() async {
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
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.color949494)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change',
                style: TextStyle(color: AppColors.colorECC16E)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HHLocationScreen()),
      );
    }
  }

  void _showMenuPopover() {
    final RenderBox? renderBox =
        _userSectionKey.currentContext?.findRenderObject() as RenderBox?;
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
          child: HHMenuPopover(onActionSelected: _handleMenuAction),
        ),
      ],
    );
  }

  Future<void> _handleMenuAction(HHMenuAction action) async {
    switch (action) {
      case HHMenuAction.lockScreen:
        await context.read<HHLockManager>().lock();
        _showSnackBar('Menu screen locked');
        break;
      case HHMenuAction.settingsProfile:
        _showSnackBar('Settings Profile - Coming soon');
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
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.color949494)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.colorFF928A)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _appManager.logout();
      if (!mounted) return;
      await context.read<HHLockManager>().reset();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HHLogin()),
        (route) => false,
      );
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
}
