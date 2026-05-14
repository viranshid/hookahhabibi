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
import 'package:hookahhabibi/utils/routes_generator.dart';

class HHWelcome extends StatefulWidget {
  final String locationName;
  final String locationId;

  const HHWelcome({
    Key? key,
    this.locationName = 'Default Location',
    this.locationId = '',
  }) : super(key: key);

  @override
  State<HHWelcome> createState() => _HHWelcomeState();
}

class _HHWelcomeState extends State<HHWelcome>
    with TickerProviderStateMixin {
  HHDishCategoryModel? selectedMenuItem;
  final ScrollController _scrollController = ScrollController();
  final HHAppManager _appManager = HHAppManager();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;

  List<HHDishCategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    // Load categories from API if not already loaded
    if (_appManager.menuManager.categories.isEmpty) {
      await _appManager.menuManager.loadCategories();
    }

    setState(() {
      _categories = _appManager.menuManager.categories;
      _isLoading = false;
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildLogo(),
                _buildTitle(),
                _buildSubTitle(),
                _buildWelcomeSubImage(),
                _isLoading ? _buildLoadingIndicator() : _buildMenuScrollView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin70),
      child: Center(
        child: SlideTransition(
          position: _logoSlideAnimation,
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('logo_scale'),
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              final clampedValue = value.clamp(0.8, 1.0);
              return Transform.scale(
                scale: clampedValue,
                child: child,
              );
            },
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
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin20),
      child: Center(
        child: SlideTransition(
          position: _contentSlideAnimation,
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('title_fade'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              final clampedValue = value.clamp(0.0, 1.0);
              return Opacity(
                opacity: clampedValue,
                child: child,
              );
            },
            child: Container(
              height: Dimens.margin80,
              child: AppText(
                text: APPStrings.wcTitle,
                appTextStyle: AppTextStyle.oswaldBold54White,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTitle() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin15),
      child: Center(
        child: SlideTransition(
          position: _contentSlideAnimation,
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('subtitle_fade'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              final clampedValue = value.clamp(0.0, 1.0);
              return Opacity(
                opacity: clampedValue,
                child: child,
              );
            },
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
        ),
      ),
    );
  }

  Widget _buildWelcomeSubImage() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin28),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            width: Dimens.margin538,
            height: Dimens.margin95,
            child: Image.asset(
              APPImages.imgWelcomSubimage,
              width: Dimens.margin538,
              height: Dimens.margin95,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: Dimens.margin538,
                  height: Dimens.margin95,
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
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin60,
      ),
      height: Dimens.margin150,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
        ),
      ),
    );
  }

  Widget _buildMenuScrollView() {
    if (_categories.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(
          top: Dimens.margin60,
        ),
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
          separatorBuilder: (context, index) =>
          const SizedBox(width: Dimens.margin16),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return TweenAnimationBuilder<double>(
              key: ValueKey('welcome_menu_${category.id}'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1200 + (index * 100)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                final clampedValue = value.clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(0, 30 * (1 - clampedValue)),
                  child: Opacity(
                    opacity: clampedValue,
                    child: child,
                  ),
                );
              },
              child: HHWelcomeMenuCard(
                category: category,
                isSelected: selectedMenuItem?.id == category.id,
                onTap: (selectedCategory) => _handleMenuItemTap(selectedCategory),
              ),
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

    print('Menu item selected: ${category.title}');
    print('Menu item ID: ${category.id}');
    print('Image URL: ${category.image}');

    // Navigate to Menu Screen with animation and selected category
    RouteGenerator.navigateAndReplaceWithAnimation(
      context,
      HHMenuScreen(
        locationName: widget.locationName,
        locationId: widget.locationId,
        selectedCategoryId: category.id, // Pass selected category
      ),
      animationType: AnimationType.fade,
    );
  }
}