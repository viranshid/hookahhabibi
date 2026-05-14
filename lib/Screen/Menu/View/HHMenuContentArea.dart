import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHDishCard.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHOffers.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
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
  final ValueKey _offersWidgetKey = const ValueKey('offers_widget');

  // ValueNotifiers — only their subtrees rebuild on change, not the whole tree
  final ValueNotifier<bool> _isStickyNotifier = ValueNotifier(false);
  final ValueNotifier<String?> _selectedTagNotifier = ValueNotifier(null);

  bool _isLoading = false;
  bool _isScrolling = false;
  bool _isProgrammaticScroll = false;

  // Cached scroll offsets — computed once per data load via post-frame callback.
  // The scroll listener uses pure arithmetic against these; no findRenderObject per frame.
  double? _cachedStickyThreshold;
  final Map<String, double> _cachedSectionOffsets = {};

  // Memoized data — computed once when data loads, not re-computed on every build().
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
  void didUpdateWidget(HHMenuContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      _resetState();
      _loadDishes();
    } else if (widget.isMenuOpen != oldWidget.isMenuOpen) {
      // Grid column count changes on sidebar toggle → recache offsets
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
    super.dispose();
  }

  // ============= INITIALIZATION =============

  void _initializeData() {
    _loadData();
  }

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

    // Memoize — these methods loop over data; computing once prevents
    // re-running on every build() triggered by scroll listener updates.
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

  // Reads RenderObject positions exactly once (post-frame) and stores them as
  // scroll offsets. The scroll listener then does pure arithmetic — no layout
  // tree walks at 60fps.
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

  // ============= SCROLL HANDLING =============

  void _handleScroll() {
    if (!mounted || !_mainScrollController.hasClients) return;

    final offset = _mainScrollController.offset;

    // Sticky check — O(1) arithmetic, no findRenderObject
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

    // Walk sections in order; last one whose cached offset ≤ scroll + threshold wins.
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
        approximateTagPosition - (MediaQuery.of(context).size.width / 2) + 75;

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

    // Update notifier directly — no setState, no full-tree rebuild
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

  // ============= DATA HELPERS =============

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
        imageUrl: apiDish.image,
        isSpicy: apiDish.imgSpicyType,
        isVegetarian: apiDish.imgDishType,
        isAvailable: apiDish.isAvailable,
        isRecomended: apiDish.isSuggested,
        category: apiDish.dishCatId,
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

  // ============= BUILD =============

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
            _buildPersistentOffersSection(),
            Positioned(
              top: 240,
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(child: _buildLoadingIndicator()),
            ),
          ] else if (_cachedSubCategories.isEmpty) ...[
            _buildPersistentOffersSection(),
            Positioned(
              top: 240,
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildEmptyState(),
            ),
          ] else ...[
            CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildPersistentOffersSection()),
                SliverToBoxAdapter(child: _buildOriginalTagsBar()),
                ..._buildAllDishSlivers(),
                SliverToBoxAdapter(child: SizedBox(height: Dimens.margin100)),
              ],
            ),
            // Only this small subtree rebuilds on sticky state change
            ValueListenableBuilder<bool>(
              valueListenable: _isStickyNotifier,
              builder: (context, isSticky, _) =>
                  isSticky ? _buildStickyTagsBar() : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  // ============= OFFERS =============

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
      child: HHOffers(key: _offersWidgetKey),
    );
  }

  // ============= LOADING / EMPTY =============

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

  // ============= TAGS BAR =============

  Widget _buildOriginalTagsBar() {
    return Container(
      key: _tagsBarKey,
      margin: const EdgeInsets.only(
        top: Dimens.margin10,
        left: Dimens.margin10,
        right: Dimens.margin30,
      ),
      // child is built once and reused; only the Visibility wrapper rebuilds on sticky change
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
        // Only the ListView (tag chips) rebuilds when selected tag changes
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
      onTap: (_isScrolling || _isLoading)
          ? null
          : () => _scrollToSection(tag.id),
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

  // ============= DISH SLIVERS =============
  // Replaced Column + shrinkWrap GridViews with proper SliverGrid so Flutter
  // only builds cards that are visible in the viewport (true lazy rendering).

  List<Widget> _buildAllDishSlivers() {
    if (_cachedGroupedDishes.isEmpty) {
      return [SliverToBoxAdapter(child: _buildNoDishesState())];
    }

    final List<Widget> slivers = [];
    for (final tag in _cachedSubCategories) {
      final dishes = _cachedGroupedDishes[tag.id] ?? [];
      if (dishes.isEmpty) continue;

      if (_isShishaParentCategory && tag.id == MAKE_YOUR_OWN_ID) {
        slivers.addAll(_buildMakeYourOwnSlivers(tag, dishes));
      } else {
        slivers.addAll(_buildDishSectionSlivers(tag, dishes));
      }
    }
    return slivers;
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
      _isShishaParentCategory
          ? _buildHookahSliver(dishes)
          : _buildDishSliver(dishes),
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
        ..add(_buildHookahSliver(subCatDishes))
        ..add(SliverToBoxAdapter(child: SizedBox(height: Dimens.margin20)));
    }

    return slivers;
  }

  Widget _buildDishSliver(List<HHDishModel> dishes) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin20,
        right: Dimens.margin40,
        bottom: Dimens.margin20,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => RepaintBoundary(
            child: HHDishCard(
              key: ValueKey('dish_${dishes[index].id}'),
              dish: dishes[index],
              onTap: (d) => debugPrint('Dish tapped: ${d.name}'),
            ),
          ),
          childCount: dishes.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.isMenuOpen ? 3 : 4,
          childAspectRatio: widget.isMenuOpen ? 0.65 : 0.60,
          crossAxisSpacing: Dimens.margin20,
          mainAxisSpacing: Dimens.margin20,
        ),
      ),
    );
  }

  Widget _buildHookahSliver(List<HHDishModel> dishes) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin20,
        right: Dimens.margin40,
        bottom: Dimens.margin20,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dish = dishes[index];
            final hookah = HHHookahModel(
              id: dish.id,
              name: dish.name,
              description: dish.description,
              imageUrl: dish.imageUrl,
              isAvailable: dish.isAvailable,
            );
            return RepaintBoundary(
              child: HHHookahCard(
                key: ValueKey('hookah_${hookah.id}'),
                hookah: hookah,
                onTap: (h) => _showPopup(h),
              ),
            );
          },
          childCount: dishes.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.isMenuOpen ? 3 : 4,
          childAspectRatio: 3.2,
          crossAxisSpacing: Dimens.margin20,
          mainAxisSpacing: Dimens.margin20,
        ),
      ),
    );
  }

  void _showPopup(HHHookahModel hookah) {
    debugPrint('Showing popup for: ${hookah.name}');
  }

  // ============= SEPARATORS =============

  Widget _buildSeparator(String title) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: Dimens.margin30,
            left: Dimens.margin20,
            right: Dimens.margin40,
          ),
          child: Row(
            children: [
              Expanded(
                  child: Container(height: 1, color: AppColors.color33FFFF)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.margin20),
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
        left: Dimens.margin200,
        right: Dimens.margin200,
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

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({this.color = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 3;
    double currentX = 0;

    while (currentX < size.width) {
      canvas.drawLine(
          Offset(currentX, size.height / 2),
          Offset(currentX + dashWidth, size.height / 2),
          paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
