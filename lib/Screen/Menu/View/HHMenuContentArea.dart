import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHDishCard.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHOffers.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

// Import the new HHHookahCard
import 'package:hookahhabibi/Screen/Menu/View/HHHookahCard.dart';

class HHMenuContentArea extends StatefulWidget {
  final bool isMenuOpen;
  final String? selectedCategoryId;

  const HHMenuContentArea({
    Key? key,
    this.isMenuOpen = true,
    this.selectedCategoryId,
  }) : super(key: key);

  @override
  State<HHMenuContentArea> createState() => HHMenuContentAreaState();
}

class HHMenuContentAreaState extends State<HHMenuContentArea> {
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _tagsScrollController = ScrollController();
  final HHAppManager _appManager = HHAppManager();

  final Map<String, GlobalKey> _sectionKeys = {};
  final GlobalKey _tagsBarKey = GlobalKey();
  final GlobalKey _offersKey = GlobalKey();

  // Create a global key for the offers widget to ensure it's not recreated
  final GlobalKey _offersWidgetKey = GlobalKey();

  String? _selectedTag;
  bool _isLoading = false;
  bool _isTagsSticky = false;
  bool _isScrolling = false;
  bool _isProgrammaticScroll = false;

  Timer? _scrollDebouncer;
  String? _lastDetectedTag;

  static const double _stickyHeaderHeight = 70.0;
  static const double _scrollOffset = 80.0;
  static const double _sectionDetectionThreshold = 150.0;

  // Constant to identify Shisha parent category ID
  static const String SHISHA_PARENT_CATEGORY_ID = "35"; // Based on the API response

  @override
  void initState() {
    super.initState();
    _initializeData();
    _mainScrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(HHMenuContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      _resetState();
      _loadDishes();
    }
  }

  @override
  void dispose() {
    _scrollDebouncer?.cancel();
    _mainScrollController.removeListener(_handleScroll);
    _mainScrollController.dispose();
    _tagsScrollController.dispose();
    super.dispose();
  }

  // ============= INITIALIZATION =============

  void _initializeData() {
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load dishes for selected category
    if (widget.selectedCategoryId != null) {
      await _loadDishes();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadDishes() async {
    if (widget.selectedCategoryId == null) return;

    // Set loading state
    setState(() => _isLoading = true);

    print('🍽️ Loading dishes for category: ${widget.selectedCategoryId}');

    await _appManager.menuManager.loadDishes(
      categoryId: widget.selectedCategoryId!,
    );

    final subCategories = _getSubCategories();

    _sectionKeys.clear();
    for (var subCat in subCategories) {
      _sectionKeys[subCat.id] = GlobalKey();
    }

    if (subCategories.isNotEmpty && mounted) {
      setState(() {
        _selectedTag = subCategories.first.id;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }

    print('✅ Dishes loaded successfully');
    print('📋 Section keys created: ${_sectionKeys.length}');

    // Scroll to top after loading
    if (_mainScrollController.hasClients) {
      _mainScrollController.jumpTo(0);
    }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _resetState() {
    _selectedTag = null;
    _lastDetectedTag = null;
    _sectionKeys.clear();
    _isTagsSticky = false;
    _isScrolling = false;
    _isProgrammaticScroll = false;
    _scrollDebouncer?.cancel();
  }

  // ============= SCROLL HANDLING =============

  void _handleScroll() {
    if (!mounted) return;

    // Update sticky state immediately
    _updateStickyState();

    // Debounce tag updates to prevent flickering
    if (!_isProgrammaticScroll && !_isScrolling) {
      _debounceTagUpdate();
    }
  }

  void _updateStickyState() {
    final renderBox = _tagsBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final shouldBeSticky = position.dy <= 0;

    if (_isTagsSticky != shouldBeSticky) {
      setState(() => _isTagsSticky = shouldBeSticky);
    }
  }

  void _debounceTagUpdate() {
    _scrollDebouncer?.cancel();
    _scrollDebouncer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && !_isProgrammaticScroll && !_isScrolling) {
        _updateActiveTagOnScroll();
      }
    });
  }

  void _updateActiveTagOnScroll() {
    final tags = _getSubCategories();
    if (tags.isEmpty) return;

    String? newActiveTag;
    double closestDistance = double.infinity;

    for (var tag in tags) {
      final key = _sectionKeys[tag.id];
      if (key?.currentContext == null) continue;

      final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      final position = renderBox.localToGlobal(Offset.zero);
      final distanceFromThreshold = (position.dy - _sectionDetectionThreshold).abs();

      if (position.dy <= _sectionDetectionThreshold && distanceFromThreshold < closestDistance) {
        closestDistance = distanceFromThreshold;
        newActiveTag = tag.id;
      }
    }

    if (newActiveTag == null) {
      for (var tag in tags) {
        final key = _sectionKeys[tag.id];
        if (key?.currentContext == null) continue;

        final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.hasSize) continue;

        final position = renderBox.localToGlobal(Offset.zero);

        if (position.dy > 0 && position.dy < MediaQuery.of(context).size.height) {
          newActiveTag = tag.id;
          break;
        }
      }
    }

    if (newActiveTag != null && newActiveTag != _lastDetectedTag) {
      _lastDetectedTag = newActiveTag;

      if (mounted && _selectedTag != newActiveTag) {
        setState(() => _selectedTag = newActiveTag);
        _scrollTagIntoView(newActiveTag!);
      }
    }
  }

  void _scrollTagIntoView(String tagId) {
    if (!_tagsScrollController.hasClients) {
      print('⚠️ Tags scroll controller not attached yet');
      return;
    }

    final tags = _getSubCategories();
    final tagIndex = tags.indexWhere((t) => t.id == tagId);
    if (tagIndex == -1) return;

    final approximateTagPosition = tagIndex * 150.0;
    final scrollPosition = approximateTagPosition - (MediaQuery.of(context).size.width / 2) + 75;

    try {
      if (_tagsScrollController.position.hasPixels) {
        _tagsScrollController.animateTo(
          scrollPosition.clamp(0.0, _tagsScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      print('⚠️ Error scrolling tag into view: $e');
    }
  }

  void _scrollToSection(String tagId) {
    if (_isScrolling) return;

    setState(() {
      _selectedTag = tagId;
      _lastDetectedTag = tagId;
      _isScrolling = true;
      _isProgrammaticScroll = true;
    });

    final key = _sectionKeys[tagId];
    if (key == null || key.currentContext == null) {
      _resetScrolling();
      return;
    }

    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
    ).then((_) => _resetScrolling());
  }

  void _resetScrolling() {
    if (mounted) {
      setState(() {
        _isScrolling = false;
        _isProgrammaticScroll = false;
      });
    }
  }

  // ============= DATA HELPERS =============

  // Check if current category is the Shisha parent category
  bool get _isShishaParentCategory {
    return widget.selectedCategoryId == SHISHA_PARENT_CATEGORY_ID;
  }

  // Use the existing getSubCategories method
  List<HHDishCategoryModel> _getSubCategories() {
    return _appManager.menuManager.getSubCategories();
  }

  // Use the existing getGroupedDishes but modified to match the shisha identification
  Map<String, List<HHDishModel>> _getGroupedDishes() {
    final apiDishes = _appManager.menuManager.getDisplayDishes();
    final locationManager = _appManager.locationManager;
    final Map<String, List<HHDishModel>> grouped = {};

    for (var apiDish in apiDishes) {
      if (!locationManager.isDishAvailable(apiDish.id)) continue;

      final dishModel = HHDishModel(
        id: apiDish.id,
        name: apiDish.title,
        description: apiDish.description,
        price: apiDish.formattedPrice,
        imageUrl: apiDish.image,
        isSpicy: apiDish.isSpicy,
        isVegetarian: apiDish.isVegetarian,
        isAvailable: apiDish.isAvailable,
        category: apiDish.dishCatId,
      );

      grouped.putIfAbsent(apiDish.dishCatId, () => []).add(dishModel);
    }

    return grouped;
  }

  // ============= BUILD METHODS =============

  @override
  Widget build(BuildContext context) {
    final contentWidth = widget.isMenuOpen
        ? MediaQuery.of(context).size.width - 300
        : MediaQuery.of(context).size.width - 100;

    return SizedBox(
      width: contentWidth,
      child: Stack(
        children: [
          if (_isLoading) ...[
            // Show offers section even during loading
            _buildPersistentOffersSection(),

            // Show loading indicator below the offers section
            Positioned(
              top: 240, // Below the offers section
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(child: _buildLoadingIndicator()),
            ),
          ] else if (_getSubCategories().isEmpty) ...[
            // No categories found - still show offers
            _buildPersistentOffersSection(),

            // Show empty state below offers
            Positioned(
              top: 240, // Below the offers section
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildEmptyState(),
            ),
          ] else ...[
            // Categories and dishes found, build normal content
            CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Offers section with persistent state
                SliverToBoxAdapter(
                  child: _buildPersistentOffersSection(),
                ),
                SliverToBoxAdapter(
                  child: _buildOriginalTagsBar(),
                ),
                SliverToBoxAdapter(
                  child: _buildAllDishSections(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: Dimens.margin100),
                ),
              ],
            ),
            if (_isTagsSticky) _buildStickyTagsBar(),
          ],
        ],
      ),
    );
  }

  // New method to keep the offers section persistent with a global key
  Widget _buildPersistentOffersSection() {
    return Container(
      key: _offersKey,
      margin: const EdgeInsets.only(
        top: Dimens.margin20,
        left: Dimens.margin20,
        right: Dimens.margin30,
        bottom: Dimens.margin10,
      ),
      height: 220,
      child: HHOffers(
        key: _offersWidgetKey, // Use a persistent global key
      ),
    );
  }

  // ============= SECTIONS BUILD =============

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
          ),
          SizedBox(height: Dimens.margin20),
          AppText(
            text: 'Loading...',
            appTextStyle: AppTextStyle.rubikRegular14Light,
            customColor: AppColors.colorF4F5F7,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin60,
        left: Dimens.margin20,
        right: Dimens.margin40,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 100,
              color: AppColors.color949494.withOpacity(0.5),
            ),
            SizedBox(height: Dimens.margin30),
            AppText(
              text: 'No Categories Available',
              appTextStyle: AppTextStyle.oswaldSemiBold26Light,
              customColor: AppColors.colorF4F5F7,
            ),
            SizedBox(height: Dimens.margin15),
            AppText(
              text: 'This section doesn\'t have any sub-categories yet',
              appTextStyle: AppTextStyle.rubikRegular14Light,
              customColor: AppColors.color949494,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Empty state when tags exist but no dishes
  Widget _buildNoDishesState() {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin60,
        left: Dimens.margin20,
        right: Dimens.margin40,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: AppColors.color949494.withOpacity(0.5),
            ),
            SizedBox(height: Dimens.margin30),
            AppText(
              text: 'No Dishes Available',
              appTextStyle: AppTextStyle.oswaldSemiBold26Light,
              customColor: AppColors.colorF4F5F7,
            ),
            SizedBox(height: Dimens.margin15),
            AppText(
              text: 'There are no dishes available in this category at the moment',
              appTextStyle: AppTextStyle.rubikRegular14Light,
              customColor: AppColors.color949494,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============= TAGS BAR =============

  Widget _buildOriginalTagsBar() {
    return Container(
      key: _tagsBarKey,
      margin: const EdgeInsets.only(
        top: Dimens.margin10,
        left: Dimens.margin10,
        right: Dimens.margin30,
      ),
      child: Visibility(
        visible: !_isTagsSticky,
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        child: _buildTagsBarContent(),
      ),
    );
  }

  Widget _buildStickyTagsBar() {
    return Positioned(
      top: 0,
      left: 10,
      right: 30,
      child: Container(
        height: _stickyHeaderHeight,
        margin: const EdgeInsets.only(left: Dimens.margin10),
        decoration: BoxDecoration(
          color: const Color(0xFF011109),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildTagsBarContent(),
      ),
    );
  }

  Widget _buildTagsBarContent() {
    final tags = _getSubCategories();

    return Container(
      height: _stickyHeaderHeight,
      padding: const EdgeInsets.symmetric(vertical: Dimens.margin10),
      decoration: BoxDecoration(
        color: _isTagsSticky ? Colors.transparent : const Color(0xFF011109),
      ),
      child: Center(
        child: ListView.separated(
          controller: _tagsScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: Dimens.margin10),
          itemCount: tags.length,
          separatorBuilder: (_, __) => SizedBox(width: Dimens.margin8),
          itemBuilder: (context, index) => _buildTagChip(tags[index]),
        ),
      ),
    );
  }

  Widget _buildTagChip(HHDishCategoryModel tag) {
    final isSelected = _selectedTag == tag.id;

    return GestureDetector(
      onTap: (_isScrolling || _isLoading) ? null : () {
        print('🏷️ Tag clicked: ${tag.title} (${tag.id})');
        _scrollToSection(tag.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: Dimens.margin40,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.margin20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.colorECC16E : const Color(0x1AD9D9D9),
          borderRadius: BorderRadius.circular(Dimens.margin50),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.colorECC16E.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Center(
          child: AppText(
            text: tag.title.toUpperCase(),
            appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
            customColor: isSelected ? AppColors.color00541A : AppColors.colorD9D9D9,
            customFontSize: Dimens.textSize20,
            textAlign: TextAlign.center,
            applyTextTransform: false,
          ),
        ),
      ),
    );
  }

  // ============= DISH SECTIONS =============

  Widget _buildAllDishSections() {
    final grouped = _getGroupedDishes();
    final tags = _getSubCategories();

    if (grouped.isEmpty) {
      return _buildNoDishesState();
    }

    print('🔨 Building ${tags.length} dish sections');
    tags.forEach((tag) {
      print('  - ${tag.title}: ${grouped[tag.id]?.length ?? 0} dishes');
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tags.map((tag) {
        final dishes = grouped[tag.id] ?? [];
        if (dishes.isEmpty) return const SizedBox.shrink();
        return _buildDishSection(tag, dishes);
      }).toList(),
    );
  }

  Widget _buildDishSection(HHDishCategoryModel tag, List<HHDishModel> dishes) {
    print('🗿️ Building section for: ${tag.title} (${tag.id}) with key: ${_sectionKeys[tag.id]}');

    return Container(
      key: _sectionKeys[tag.id] ??= GlobalKey(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeparator(tag.title),
          // Check if we're in shisha category and use the appropriate card layout
          _isShishaParentCategory
              ? _buildHookahGrid(dishes)
              : _buildDishGrid(dishes),
        ],
      ),
    );
  }

  Widget _buildSeparator(String title) {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin20,
        right: Dimens.margin40,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: AppColors.color33FFFF),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.margin20),
            child: AppText(
              text: title.toUpperCase(),
              appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
              customFontSize: Dimens.textSize20,
              customColor: AppColors.colorF4F5F7,
              textAlign: TextAlign.center,
              applyTextTransform: false,
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.color33FFFF),
          ),
        ],
      ),
    );
  }

  // Original dish grid for regular menu items
  Widget _buildDishGrid(List<HHDishModel> dishes) {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin20,
        right: Dimens.margin40,
        bottom: Dimens.margin20,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.isMenuOpen ? 3 : 4,
          childAspectRatio: widget.isMenuOpen ? 0.65 : 0.60,
          crossAxisSpacing: Dimens.margin20,
          mainAxisSpacing: Dimens.margin20,
        ),
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final dish = dishes[index];
          return HHDishCard(
            key: ValueKey('dish_${dish.id}'),
            dish: dish,
            onTap: (d) => debugPrint('Dish tapped: ${d.name}'),
          );
        },
      ),
    );
  }

  // Hookah grid for shisha menu items using HHHookahCard in a grid layout
  Widget _buildHookahGrid(List<HHDishModel> dishes) {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin20,
        right: Dimens.margin40,
        bottom: Dimens.margin20,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.isMenuOpen ? 3 : 4, // Same as dish grid
          childAspectRatio: 3.2, // Aspect ratio for the hookah card (width ÷ height)
          crossAxisSpacing: Dimens.margin20,
          mainAxisSpacing: Dimens.margin20,
        ),
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final dish = dishes[index];

          // Convert HHDishModel to HHHookahModel
          final hookah = HHHookahModel(
            id: dish.id,
            name: dish.name,
            description: dish.description,
            imageUrl: dish.imageUrl,
            isAvailable: dish.isAvailable,
          );

          return HHHookahCard(
            key: ValueKey('hookah_${hookah.id}'),
            hookah: hookah,
            onTap: (h) => debugPrint('Hookah tapped: ${h.name}'),
          );
        },
      ),
    );
  }
}