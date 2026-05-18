import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuContentArea.dart'
    show DashedLinePainter;
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHMenuItemCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHStaffMenuContentArea extends StatefulWidget {
  final String? selectedCategoryId;
  final double contentWidth;
  final ValueChanged<HHDishModel>? onItemSelected;

  const HHStaffMenuContentArea({
    Key? key,
    this.selectedCategoryId,
    required this.contentWidth,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<HHStaffMenuContentArea> createState() =>
      HHStaffMenuContentAreaState();
}

class HHStaffMenuContentAreaState extends State<HHStaffMenuContentArea> {
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _tagsScrollController = ScrollController();
  final HHAppManager _appManager = HHAppManager();

  final Map<String, GlobalKey> _sectionKeys = {};
  final GlobalKey _tagsBarKey = GlobalKey();
  final ValueNotifier<bool> _isStickyNotifier = ValueNotifier(false);
  final ValueNotifier<String?> _selectedTagNotifier = ValueNotifier(null);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _activeFilters = {};

  bool _isLoading = false;
  bool _isScrolling = false;
  bool _isProgrammaticScroll = false;

  double? _cachedStickyThreshold;
  final Map<String, double> _cachedSectionOffsets = {};

  List<HHDishCategoryModel> _cachedSubCategories = [];
  Map<String, List<HHDishModel>> _cachedGroupedDishes = {};

  Timer? _scrollDebouncer;
  String? _lastDetectedTag;

  static const double _stickyHeaderHeight = 70.0;
  static const double _sectionDetectionThreshold = 150.0;

  static const String SHISHA_PARENT_CATEGORY_ID = "35";
  static const String HOOKAH_HOUSE_MIX_ID = "48";
  static const String MAKE_YOUR_OWN_ID = "47";
  static const List<String> SUB_CATEGORY_IDS = ["49", "50", "51", "52", "53"];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _mainScrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(HHStaffMenuContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      _resetState();
      _isLoading = widget.selectedCategoryId != null;
      Future.microtask(() {
        if (mounted) {
          debugPrint(
              '[HHStaffMenuContentArea] Loading dishes for ${widget.selectedCategoryId}');
          _loadDishes();
        }
      });
    } else if (widget.contentWidth != oldWidget.contentWidth) {
      _scheduleOffsetCache();
    }
  }

  @override
  void dispose() {
    _scrollDebouncer?.cancel();
    _mainScrollController.removeListener(_handleScroll);
    _mainScrollController.dispose();
    _tagsScrollController.dispose();
    _isStickyNotifier.dispose();
    _selectedTagNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() => _loadData();

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    if (widget.selectedCategoryId != null) {
      await _loadDishes();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadDishes() async {
    if (widget.selectedCategoryId == null) return;

    setState(() => _isLoading = true);

    await _appManager.menuManager.loadDishes(
      categoryId: widget.selectedCategoryId!,
    );

    _sectionKeys.clear();
    _cachedSectionOffsets.clear();
    _cachedStickyThreshold = null;

    _cachedSubCategories = _computeSubCategories();
    _cachedGroupedDishes = _computeGroupedDishes();

    for (final subCat in _cachedSubCategories) {
      _sectionKeys[subCat.id] = GlobalKey();
    }

    if (_cachedSubCategories.isNotEmpty && mounted) {
      setState(() {
        _selectedTagNotifier.value = _cachedSubCategories.first.id;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }

    if (_mainScrollController.hasClients) {
      _mainScrollController.jumpTo(0);
    }

    _scheduleOffsetCache();
  }

  void _scheduleOffsetCache() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mainScrollController.hasClients) return;

      final scrollOffset = _mainScrollController.offset;

      final tagsRenderBox =
          _tagsBarKey.currentContext?.findRenderObject() as RenderBox?;
      if (tagsRenderBox != null && tagsRenderBox.hasSize) {
        final tagsScreenY = tagsRenderBox.localToGlobal(Offset.zero).dy;
        _cachedStickyThreshold = scrollOffset + tagsScreenY;
      }

      for (final entry in _sectionKeys.entries) {
        final renderBox =
            entry.value.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final screenY = renderBox.localToGlobal(Offset.zero).dy;
          _cachedSectionOffsets[entry.key] = scrollOffset + screenY;
        }
      }
    });
  }

  void _resetState() {
    _selectedTagNotifier.value = null;
    _isStickyNotifier.value = false;
    _lastDetectedTag = null;
    _sectionKeys.clear();
    _cachedSectionOffsets.clear();
    _cachedStickyThreshold = null;
    _cachedSubCategories = [];
    _cachedGroupedDishes = {};
    _isScrolling = false;
    _isProgrammaticScroll = false;
    _scrollDebouncer?.cancel();
  }

  void _handleScroll() {
    if (!mounted || !_mainScrollController.hasClients) return;
    final offset = _mainScrollController.offset;

    if (_cachedStickyThreshold != null) {
      final shouldBeSticky = offset >= _cachedStickyThreshold!;
      if (_isStickyNotifier.value != shouldBeSticky) {
        _isStickyNotifier.value = shouldBeSticky;
      }
    }

    if (!_isProgrammaticScroll && !_isScrolling) {
      _debounceTagUpdate();
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
    if (_cachedSectionOffsets.isEmpty || _cachedSubCategories.isEmpty) return;
    final offset = _mainScrollController.offset;

    String? newActiveTag;
    for (final tag in _cachedSubCategories) {
      final sectionOffset = _cachedSectionOffsets[tag.id];
      if (sectionOffset != null &&
          offset + _sectionDetectionThreshold >= sectionOffset) {
        newActiveTag = tag.id;
      }
    }

    if (newActiveTag != null && newActiveTag != _lastDetectedTag) {
      _lastDetectedTag = newActiveTag;
      if (_selectedTagNotifier.value != newActiveTag) {
        _selectedTagNotifier.value = newActiveTag;
        _scrollTagIntoView(newActiveTag);
      }
    }
  }

  void _scrollTagIntoView(String tagId) {
    if (!_tagsScrollController.hasClients) return;

    final tagIndex = _cachedSubCategories.indexWhere((t) => t.id == tagId);
    if (tagIndex == -1) return;

    final approximateTagPosition = tagIndex * 150.0;
    final scrollPosition =
        approximateTagPosition - (widget.contentWidth / 2) + 75;

    try {
      if (_tagsScrollController.position.hasPixels) {
        _tagsScrollController.animateTo(
          scrollPosition.clamp(
              0.0, _tagsScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (_) {}
  }

  void _scrollToSection(String tagId) {
    if (_isScrolling) return;

    _selectedTagNotifier.value = tagId;
    _lastDetectedTag = tagId;
    _isScrolling = true;
    _isProgrammaticScroll = true;

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
    _isScrolling = false;
    _isProgrammaticScroll = false;
  }

  bool get _isShishaParentCategory =>
      widget.selectedCategoryId == SHISHA_PARENT_CATEGORY_ID;

  List<HHDishCategoryModel> _computeSubCategories() {
    final rawCategories = _appManager.menuManager.getSubCategories();
    if (!_isShishaParentCategory) return rawCategories;

    final hookahHouseMix = rawCategories.firstWhere(
        (cat) => cat.id == HOOKAH_HOUSE_MIX_ID,
        orElse: () => rawCategories.first);

    final makeYourOwn = rawCategories.firstWhere(
        (cat) => cat.id == MAKE_YOUR_OWN_ID,
        orElse: () => rawCategories.last);

    return [hookahHouseMix, makeYourOwn];
  }

  Map<String, List<HHDishModel>> _computeGroupedDishes() {
    final apiDishes = _appManager.menuManager.getDisplayDishes();
    final locationManager = _appManager.locationManager;
    final Map<String, List<HHDishModel>> grouped = {};

    for (final apiDish in apiDishes) {
      if (!locationManager.isDishAvailable(apiDish.id)) continue;

      final dishModel = HHDishModel(
        id: apiDish.id,
        name: apiDish.title,
        description: apiDish.description,
        price: apiDish.formattedPrice,
        rawPrice: apiDish.dishPrice,
        imageUrl: apiDish.image,
        isSpicy: apiDish.imgSpicyType,
        isVegetarian: apiDish.imgDishType,
        isAvailable: apiDish.isAvailable,
        isRecomended: apiDish.isSuggested,
        category: apiDish.dishCatId,
        fullCategory: apiDish.fullCategory,
      );

      if (_isShishaParentCategory) {
        if (SUB_CATEGORY_IDS.contains(apiDish.dishCatId)) {
          grouped.putIfAbsent(MAKE_YOUR_OWN_ID, () => []).add(dishModel);
        } else {
          grouped.putIfAbsent(apiDish.dishCatId, () => []).add(dishModel);
        }
      } else {
        grouped.putIfAbsent(apiDish.dishCatId, () => []).add(dishModel);
      }
    }

    return grouped;
  }

  List<HHDishCategoryModel> _getSubSubCategories() {
    if (!_isShishaParentCategory) return [];
    return _appManager.menuManager
        .getSubCategories()
        .where((cat) => SUB_CATEGORY_IDS.contains(cat.id))
        .toList();
  }

  int get _crossAxisCount {
    final n = (widget.contentWidth / Dimens.margin280).floor();
    return n.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.contentWidth,
      child: Stack(
        children: [
          Positioned(
            top: Dimens.margin50,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBody(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        if (_isLoading) ...[
          Positioned.fill(
            child: Center(child: _buildLoadingIndicator()),
          ),
        ] else if (_cachedSubCategories.isEmpty) ...[
          Positioned.fill(child: _buildEmptyState()),
        ] else ...[
          CustomScrollView(
            controller: _mainScrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildOriginalTagsBar()),
              ..._buildAllDishSlivers(),
              SliverToBoxAdapter(child: SizedBox(height: Dimens.margin100)),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isStickyNotifier,
            builder: (context, isSticky, _) =>
                isSticky ? _buildStickyTagsBar() : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: Dimens.margin50,
      decoration: const BoxDecoration(
        color: AppColors.color01110A,
        border: Border(
          bottom: BorderSide(
            color: AppColors.colorECC16E1A,
            width: Dimens.margin1,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: Dimens.margin206,
            top: 0,
            bottom: 0,
            child: Center(child: _buildSearchBar()),
          ),
          Positioned(
            right: Dimens.margin20,
            top: 0,
            bottom: 0,
            child: Center(child: _buildLegendNotes()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: Dimens.margin240,
      height: Dimens.margin30,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.margin12),
      decoration: BoxDecoration(
        color: AppColors.color171717C9,
        borderRadius: BorderRadius.circular(Dimens.margin60),
        border: Border.all(color: AppColors.color2B2B2B, width: Dimens.margin1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              cursorColor: AppColors.colorECC16E,
              style: AppTextStyle.oswaldRegular14White.style,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search Item',
                hintStyle: AppTextStyle.oswaldRegular14WhiteFaded.style,
              ),
            ),
          ),
          const SizedBox(width: Dimens.margin8),
          const Icon(
            Icons.search,
            color: AppColors.colorB3B3B3,
            size: Dimens.margin18,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendNotes() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendItem(APPImages.icVeg, 'Vegetarian'),
        _legendSeparator(),
        _legendItem(APPImages.icMediumChilli, 'Medium Spicy'),
        _legendSeparator(),
        _legendItem(APPImages.icChilli, 'Extra Spicy'),
      ],
    );
  }

  Widget _legendItem(String iconPath, String label) {
    final bool isActive = _activeFilters.contains(iconPath);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleFilter(iconPath),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _activeFilters.isEmpty || isActive ? 1.0 : 0.4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: Dimens.margin16,
              height: Dimens.margin16,
              errorBuilder: (_, __, ___) => const SizedBox(
                  width: Dimens.margin16, height: Dimens.margin16),
            ),
            const SizedBox(width: Dimens.margin6),
            AppText(
              text: label,
              appTextStyle: AppTextStyle.oswaldRegular14MutedSpaced,
              customColor:
                  isActive ? AppColors.colorECC16E : null,
              applyTextTransform: false,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFilter(String iconPath) {
    setState(() {
      if (_activeFilters.contains(iconPath)) {
        _activeFilters.remove(iconPath);
      } else {
        _activeFilters.add(iconPath);
      }
    });
  }

  bool _matchesFilters(HHDishModel dish) {
    if (_activeFilters.isEmpty) return true;

    final bool vegRequired = _activeFilters.contains(APPImages.icVeg);
    if (vegRequired && dish.isVegetarian != APPImages.icVeg) return false;

    final spicyFilters = _activeFilters
        .where((f) => f != APPImages.icVeg)
        .toSet();
    if (spicyFilters.isNotEmpty && !spicyFilters.contains(dish.isSpicy)) {
      return false;
    }

    return true;
  }

  Widget _legendSeparator() {
    return Container(
      width: Dimens.margin1,
      height: Dimens.margin16,
      margin: const EdgeInsets.symmetric(horizontal: Dimens.margin12),
      color: AppColors.color2B2B2B,
    );
  }

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
        right: Dimens.margin20,
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
              text: "This section doesn't have any sub-categories yet",
              appTextStyle: AppTextStyle.rubikRegular14Light,
              customColor: AppColors.color949494,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDishesState() {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin60,
        left: Dimens.margin20,
        right: Dimens.margin20,
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
              text:
                  'There are no dishes available in this category at the moment',
              appTextStyle: AppTextStyle.rubikRegular14Light,
              customColor: AppColors.color949494,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalTagsBar() {
    return Container(
      key: _tagsBarKey,
      margin: const EdgeInsets.only(
        top: Dimens.margin10,
        left: Dimens.margin10,
        right: Dimens.margin10,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isStickyNotifier,
        builder: (context, isSticky, child) => Visibility(
          visible: !isSticky,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: child!,
        ),
        child: _buildTagsBarContent(isSticky: false),
      ),
    );
  }

  Widget _buildStickyTagsBar() {
    return Positioned(
      top: 0,
      left: 10,
      right: 10,
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
        child: _buildTagsBarContent(isSticky: true),
      ),
    );
  }

  Widget _buildTagsBarContent({required bool isSticky}) {
    return Container(
      height: _stickyHeaderHeight,
      padding: const EdgeInsets.symmetric(vertical: Dimens.margin10),
      decoration: BoxDecoration(
        color: isSticky ? Colors.transparent : const Color(0xFF011109),
      ),
      child: Center(
        child: ValueListenableBuilder<String?>(
          valueListenable: _selectedTagNotifier,
          builder: (context, selectedTag, _) {
            return ListView.separated(
              controller: _tagsScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.margin10),
              itemCount: _cachedSubCategories.length,
              separatorBuilder: (_, __) => SizedBox(width: Dimens.margin8),
              itemBuilder: (context, index) =>
                  _buildTagChip(_cachedSubCategories[index], selectedTag),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTagChip(HHDishCategoryModel tag, String? selectedTag) {
    final isSelected = selectedTag == tag.id;

    return GestureDetector(
      onTap:
          (_isScrolling || _isLoading) ? null : () => _scrollToSection(tag.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: Dimens.margin40,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.margin20),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.colorECC16E : const Color(0x1AD9D9D9),
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
            customColor:
                isSelected ? AppColors.color00541A : AppColors.colorD9D9D9,
            customFontSize: Dimens.textSize20,
            textAlign: TextAlign.center,
            applyTextTransform: false,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAllDishSlivers() {
    if (_cachedGroupedDishes.isEmpty) {
      return [SliverToBoxAdapter(child: _buildNoDishesState())];
    }

    final List<Widget> slivers = [];
    for (final tag in _cachedSubCategories) {
      final dishes = _filterDishes(_cachedGroupedDishes[tag.id] ?? []);
      if (dishes.isEmpty) continue;

      if (_isShishaParentCategory && tag.id == MAKE_YOUR_OWN_ID) {
        slivers.addAll(_buildMakeYourOwnSlivers(tag, dishes));
      } else {
        slivers.addAll(_buildDishSectionSlivers(tag, dishes));
      }
    }
    if (slivers.isEmpty) {
      return [SliverToBoxAdapter(child: _buildNoDishesState())];
    }
    return slivers;
  }

  List<HHDishModel> _filterDishes(List<HHDishModel> dishes) {
    final q = _searchQuery.trim().toLowerCase();
    return dishes.where((d) {
      if (q.isNotEmpty && !d.name.toLowerCase().contains(q)) return false;
      return _matchesFilters(d);
    }).toList();
  }

  List<Widget> _buildDishSectionSlivers(
      HHDishCategoryModel tag, List<HHDishModel> dishes) {
    _sectionKeys[tag.id] ??= GlobalKey();

    return [
      SliverToBoxAdapter(
        child: Container(
          key: _sectionKeys[tag.id],
          child: _buildSeparator(tag.title),
        ),
      ),
      _buildItemCardSliver(dishes),
    ];
  }

  List<Widget> _buildMakeYourOwnSlivers(
      HHDishCategoryModel tag, List<HHDishModel> allDishes) {
    _sectionKeys[tag.id] ??= GlobalKey();

    final List<Widget> slivers = [
      SliverToBoxAdapter(
        child: Container(
          key: _sectionKeys[tag.id],
          child: _buildSeparator(tag.title),
        ),
      ),
    ];

    for (final subCat in _getSubSubCategories()) {
      final subCatDishes =
          allDishes.where((d) => d.category == subCat.id).toList();
      if (subCatDishes.isEmpty) continue;

      slivers
        ..add(SliverToBoxAdapter(child: _buildSubSeparator(subCat.title)))
        ..add(_buildItemCardSliver(subCatDishes))
        ..add(SliverToBoxAdapter(child: SizedBox(height: Dimens.margin20)));
    }

    return slivers;
  }

  Widget _buildItemCardSliver(List<HHDishModel> dishes) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: Dimens.margin20,
        left: Dimens.margin10,
        right: Dimens.margin10,
        bottom: Dimens.margin20,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dish = dishes[index];
            return RepaintBoundary(
              child: HHMenuItemCard(
                key: ValueKey('staff_item_${dish.id}'),
                title: dish.name,
                price: dish.price,
                imageUrl: dish.imageUrl,
                vegIconPath: dish.isVegetarian,
                spicyIconPath: dish.isSpicy,
                onTap: () {
                  debugPrint('Item tapped: ${dish.name}');
                  widget.onItemSelected?.call(dish);
                },
              ),
            );
          },
          childCount: dishes.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
          mainAxisExtent: Dimens.margin80,
          crossAxisSpacing: Dimens.margin10,
          mainAxisSpacing: Dimens.margin10,
        ),
      ),
    );
  }

  Widget _buildSeparator(String title) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: Dimens.margin30,
            left: Dimens.margin20,
            right: Dimens.margin20,
          ),
          child: Row(
            children: [
              Expanded(
                  child: Container(height: 1, color: AppColors.color33FFFF)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimens.margin20),
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
                  child: Container(height: 1, color: AppColors.color33FFFF)),
            ],
          ),
        ),
        if (_isShishaParentCategory) _buildPriceImage(title),
      ],
    );
  }

  Widget _buildPriceImage(String categoryTitle) {
    String? imagePath;

    if (categoryTitle.toLowerCase().contains("hookah habibi house mix")) {
      imagePath = APPImages.imgPricHookahHabibiHouseMix;
    } else if (categoryTitle.toLowerCase().contains("make your own")) {
      imagePath = APPImages.imgPriceMakeYourOwnShisha;
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: Dimens.margin15),
      child: Center(
        child: Image.asset(
          imagePath,
          height: 50,
          width: 620,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSubSeparator(String title) {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin20,
        left: Dimens.margin60,
        right: Dimens.margin60,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              painter: DashedLinePainter(
                  color: AppColors.colorBB7A24.withOpacity(0.5)),
              child: Container(height: 1),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimens.margin15),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w600,
                fontSize: Dimens.textSize20,
                height: 1.0,
                letterSpacing: 0.0,
                color: AppColors.colorBB7A24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: DashedLinePainter(
                  color: AppColors.colorBB7A24.withOpacity(0.5)),
              child: Container(height: 1),
            ),
          ),
        ],
      ),
    );
  }
}
