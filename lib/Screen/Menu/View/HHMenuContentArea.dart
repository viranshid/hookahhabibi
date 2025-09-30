import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHDishCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHMenuContentArea extends StatefulWidget {
  final bool isMenuOpen;

  const HHMenuContentArea({
    Key? key,
    this.isMenuOpen = true,
  }) : super(key: key);

  @override
  State<HHMenuContentArea> createState() => _HHMenuContentAreaState();
}

class _HHMenuContentAreaState extends State<HHMenuContentArea> {
  final ScrollController _offersScrollController = ScrollController();
  final ScrollController _tagsScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();

  String? selectedTag;

  // Dummy data for special offers
  final List<String> specialOffers = [
    APPImages.temp1,
    APPImages.temp2,
    APPImages.temp3,
    APPImages.temp1,
    APPImages.temp2,
    APPImages.temp1,
    APPImages.temp2,
    APPImages.temp3,
    APPImages.temp1,
    APPImages.temp2,
  ];

  // Dummy data for menu tags
  final List<String> menuTags = [
    'Indian',
    'Chinese',
    'Italian',
    'Mexican',
    'Thai',
    'Japanese',
    'Mediterranean',
  ];

  // Dummy data for dishes
  final List<HHDishModel> dishes = [
    HHDishModel(
      id: '1',
      name: 'Butter Chicken',
      description: 'Tender chicken pieces in a rich, creamy tomato-based curry sauce with aromatic spices',
      price: 'IDR 85,000',
      imageUrl: 'https://example.com/butter-chicken.jpg',
      isSpicy: true,
      isVegetarian: false,
      isAvailable: true,
      category: 'Indian',
    ),
    HHDishModel(
      id: '2',
      name: 'Paneer Tikka Masala',
      description: 'Grilled cottage cheese cubes in a flavorful spiced gravy with bell peppers and onions',
      price: 'IDR 75,000',
      imageUrl: 'https://example.com/paneer-tikka.jpg',
      isSpicy: true,
      isVegetarian: true,
      isAvailable: false,
      category: 'Indian',
    ),
    HHDishModel(
      id: '3',
      name: 'Biryani Special',
      description: 'Fragrant basmati rice layered with tender meat, aromatic spices, and saffron',
      price: 'IDR 95,000',
      imageUrl: 'https://example.com/biryani.jpg',
      isSpicy: false,
      isVegetarian: false,
      isAvailable: true,
      category: 'Indian',
    ),
    HHDishModel(
      id: '4',
      name: 'Dal Makhani',
      description: 'Creamy black lentils slow-cooked with butter, cream, and aromatic spices',
      price: 'IDR 65,000',
      imageUrl: 'https://example.com/dal-makhani.jpg',
      isSpicy: false,
      isVegetarian: true,
      isAvailable: true,
      category: 'Indian',
    ),
    HHDishModel(
      id: '5',
      name: 'Tandoori Chicken',
      description: 'Succulent chicken marinated in yogurt and spices, cooked in a traditional clay oven',
      price: 'IDR 90,000',
      imageUrl: 'https://example.com/tandoori.jpg',
      isSpicy: true,
      isVegetarian: false,
      isAvailable: false,
      category: 'Indian',
    ),
    HHDishModel(
      id: '6',
      name: 'Palak Paneer',
      description: 'Fresh cottage cheese cubes in a smooth spinach gravy with aromatic Indian spices',
      price: 'IDR 70,000',
      imageUrl: 'https://example.com/palak-paneer.jpg',
      isSpicy: false,
      isVegetarian: true,
      isAvailable: true,
      category: 'Indian',
    ),
    HHDishModel(
      id: '7',
      name: 'Garlic Naan',
      description: 'Soft, fluffy bread topped with garlic and butter, baked fresh in tandoor',
      price: 'IDR 25,000',
      imageUrl: 'https://example.com/garlic-naan.jpg',
      isSpicy: false,
      isVegetarian: true,
      isAvailable: true,
      category: 'Indian',
    ),
    HHDishModel(
      id: '8',
      name: 'Chicken Korma',
      description: 'Mild, creamy curry with tender chicken, cashews, and fragrant spices',
      price: 'IDR 85,000',
      imageUrl: 'https://example.com/korma.jpg',
      isSpicy: false,
      isVegetarian: false,
      isAvailable: true,
      category: 'Indian',
    ),
    HHDishModel(
      id: '9',
      name: 'Rogan Josh',
      description: 'Aromatic lamb curry with rich spices and a deep red color from Kashmiri chilies',
      price: 'IDR 110,000',
      imageUrl: 'https://example.com/rogan-josh.jpg',
      isSpicy: true,
      isVegetarian: false,
      isAvailable: true,
      category: 'Indian',
    ),
    HHDishModel(
      id: '10',
      name: 'Malai Kofta',
      description: 'Soft cottage cheese and potato dumplings in a rich, creamy tomato-cashew gravy',
      price: 'IDR 78,000',
      imageUrl: 'https://example.com/malai-kofta.jpg',
      isSpicy: false,
      isVegetarian: true,
      isAvailable: false,
      category: 'Indian',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set first tag as selected by default
    selectedTag = menuTags.first;
  }

  @override
  void dispose() {
    _offersScrollController.dispose();
    _tagsScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  // Get filtered dishes based on selected tag
  List<HHDishModel> get filteredDishes {
    if (selectedTag == null) return dishes;
    return dishes.where((dish) => dish.category == selectedTag).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildMenuTagsSection(),
              _buildSeparatorWithText(),
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
        itemCount: specialOffers.length,
        separatorBuilder: (context, index) => const SizedBox(width: Dimens.margin20),
        itemBuilder: (context, index) {
          return _buildOfferCard(specialOffers[index]);
        },
      ),
    );
  }

  Widget _buildOfferCard(String imagePath) {
    return GestureDetector(
      onTap: () {
        print('Offer tapped: $imagePath');
        // Handle offer tap
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
          child: Image.asset(
            imagePath,
            width: Dimens.margin420,
            height: Dimens.margin160,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: Dimens.margin420,
                height: Dimens.margin160,
                decoration: BoxDecoration(
                  color: AppColors.color949494.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(Dimens.margin10),
                ),
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

  Widget _buildMenuTag(String tag) {
    final isSelected = selectedTag == tag;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTag = tag;
        });
        print('Selected tag: $tag');
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
              : const Color(0x1AD9D9D9), // #D9D9D91A
          borderRadius: BorderRadius.circular(Dimens.margin50),
        ),
        child: Center(
          child: AppText(
            text: tag.toUpperCase(),
            appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
            customColor: isSelected
                ? AppColors.color00541A
                : AppColors.colorD9D9D9,
            customFontSize: Dimens.textSize20,
            textAlign: TextAlign.center,
            applyTextTransform: true,
          ),
        ),
      ),
    );
  }

  Widget _buildSeparatorWithText() {
    return Container(
      margin: const EdgeInsets.only(
        top: Dimens.margin30,
        left: Dimens.margin10,
        right: Dimens.margin30,
      ),
      child: Row(
        children: [
          // Left line
          Expanded(
            child: Container(
              height: Dimens.margin1,
              color: AppColors.color33FFFF,
            ),
          ),
          // Center text with padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.margin20),
            child: AppText(
              text: selectedTag?.toUpperCase() ?? '',
              appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
              customFontSize: Dimens.textSize20,
              customColor: AppColors.colorF4F5F7,
              textAlign: TextAlign.center,
              applyTextTransform: false,
            ),
          ),
          // Right line
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