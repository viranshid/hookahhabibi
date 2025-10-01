import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHDishCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

class HHMenuContentArea extends StatefulWidget {
  final bool isMenuOpen;
  final String? selectedCategoryId;

  const HHMenuContentArea({
    Key? key,
    this.isMenuOpen = true,
    this.selectedCategoryId,
  }) : super(key: key);

  @override
  State<HHMenuContentArea> createState() => _HHMenuContentAreaState();
}

class _HHMenuContentAreaState extends State<HHMenuContentArea> {
  final ScrollController _offersScrollController = ScrollController();
  final ScrollController _tagsScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  final HHAppManager _appManager = HHAppManager();

  String? selectedTag;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(HHMenuContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      // Reset selected tag when category changes
      selectedTag = null;
      _loadDishes();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load offers
    await _appManager.menuManager.loadOffers();

    // Load dishes if category is selected
    if (widget.selectedCategoryId != null) {
      await _loadDishes();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDishes() async {
    if (widget.selectedCategoryId == null) return;

    await _appManager.menuManager.loadDishes(
      categoryId: widget.selectedCategoryId!,
    );

    // Set first subcategory as selected by default
    final subCategories = _appManager.menuManager.getSubCategories();
    if (subCategories.isNotEmpty) {
      setState(() {
        selectedTag = subCategories.first.id;
      });
    } else {
      setState(() {
        selectedTag = null;
      });
    }
  }

  @override
  void dispose() {
    _offersScrollController.dispose();
    _tagsScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  List<HHDishModel> get filteredDishes {
    final apiDishes = _appManager.menuManager.getDisplayDishes();
    final locationManager = _appManager.locationManager;

    // Convert API dishes to UI models and filter by availability
    return apiDishes.where((dish) {
      // Filter by selected subcategory tag
      if (selectedTag != null && dish.dishCatId != selectedTag) {
        return false;
      }

      // Check if dish is available at selected location
      return locationManager.isDishAvailable(dish.id);
    }).map((apiDish) {
      return HHDishModel(
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
    }).toList();
  }

  List<HHDishCategoryModel> get menuTags {
    return _appManager.menuManager.getSubCategories();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
        ),
      );
    }

    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        controller: _mainScrollController,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpecialOffersTitle(),
              _buildSpecialOffersSection(),
              if (menuTags.isNotEmpty) _buildMenuTagsSection(),
              if (menuTags.isNotEmpty) _buildSeparatorWithText(),
              _buildDishesGrid(),
              SizedBox(height: Dimens.margin40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialOffersTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimens.margin10,
        left: Dimens.margin10,
      ),
      child: SizedBox(
        height: Dimens.margin33,
        child: AppText(
          text: 'Special Offers',
          appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildSpecialOffersSection() {
    final offers = _appManager.menuManager.offers;

    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: Dimens.margin160,
      margin: const EdgeInsets.only(
        top: Dimens.margin10,
        left: Dimens.margin10,
      ),
      child: ListView.separated(
        controller: _offersScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: offers.length,
        separatorBuilder: (context, index) => const SizedBox(width: Dimens.margin20),
        itemBuilder: (context, index) {
          return _buildOfferCard(offers[index].image);
        },
      ),
    );
  }

  Widget _buildOfferCard(String imageUrl) {
    return GestureDetector(
      onTap: () {
        print('Offer tapped: $imageUrl');
      },
      child: Container(
        width: Dimens.margin420,
        height: Dimens.margin160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.margin10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.margin10),
          child: Image.network(
            imageUrl,
            width: Dimens.margin420,
            height: Dimens.margin160,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.color949494.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.color949494.withOpacity(0.3),
                child: const Center(
                  child: Icon(
                    Icons.local_offer,
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

  Widget _buildMenuTagsSection() {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin10,
        left: Dimens.margin10,
        right: Dimens.margin30,
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimens.margin10),
      decoration: const BoxDecoration(
        color: Color(0xFF011109),
      ),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: Dimens.margin40,
          child: ListView.separated(
            controller: _tagsScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: Dimens.margin5),
            itemCount: menuTags.length,
            separatorBuilder: (context, index) => const SizedBox(width: Dimens.margin5),
            itemBuilder: (context, index) {
              return _buildMenuTag(menuTags[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTag(HHDishCategoryModel tag) {
    final isSelected = selectedTag == tag.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTag = tag.id;
        });
        print('Selected tag: ${tag.title}');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        height: Dimens.margin40,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.margin20,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.colorECC16E
              : const Color(0x1AD9D9D9),
          borderRadius: BorderRadius.circular(Dimens.margin50),
        ),
        child: Center(
          child: AppText(
            text: tag.title.toUpperCase(),
            appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
            customColor: isSelected
                ? AppColors.color00541A
                : AppColors.colorD9D9D9,
            customFontSize: Dimens.textSize20,
            textAlign: TextAlign.center,
            applyTextTransform: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSeparatorWithText() {
    final selectedTagName = menuTags
        .firstWhere(
          (tag) => tag.id == selectedTag,
      orElse: () => menuTags.first,
    )
        .title;

    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin10,
        right: Dimens.margin30,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: Dimens.margin1,
              color: AppColors.color33FFFF,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.margin20),
            child: AppText(
              text: selectedTagName.toUpperCase(),
              appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
              customFontSize: Dimens.textSize20,
              customColor: AppColors.colorF4F5F7,
              textAlign: TextAlign.center,
              applyTextTransform: false,
            ),
          ),
          Expanded(
            child: Container(
              height: Dimens.margin1,
              color: AppColors.color33FFFF,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishesGrid() {
    if (filteredDishes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Dimens.margin40),
        child: Center(
          child: AppText(
            text: 'No dishes available',
            appTextStyle: AppTextStyle.jostMedium16Gray,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin10,
        right: Dimens.margin30,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.isMenuOpen ? 3 : 4,
          childAspectRatio: widget.isMenuOpen ? 0.75 : 0.7,
          crossAxisSpacing: Dimens.margin20,
          mainAxisSpacing: Dimens.margin20,
        ),
        itemCount: filteredDishes.length,
        itemBuilder: (context, index) {
          return HHDishCard(
            dish: filteredDishes[index],
            onTap: (dish) {
              print('Dish tapped: ${dish.name}');
              print('Price: ${dish.price}');
              print('Category: ${dish.category}');
              print('Available: ${dish.isAvailable}');
              // TODO: Navigate to dish detail or add to cart
            },
          );
        },
      ),
    );
  }
}