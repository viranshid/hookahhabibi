import 'package:hookahhabibi/utils/app_images.dart';

/// Dish Category Model
class HHDishCategoryModel {
  final String id;
  final String title;
  final String slugUrl;
  final String image;
  final int displayOrder;
  final String? parentCatId;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  /// Breadcrumb string returned by the get-dishes API on the
  /// `parent_dish_cats` node, e.g. `"Ramadan Package > All Ramadan Packages"`.
  /// Empty for categories returned by get-dish-cats.
  final String fullCategory;
  final List<HHDishCategoryModel> subCategories;
  final List<DishModel> dishes;

  HHDishCategoryModel({
    required this.id,
    required this.title,
    required this.slugUrl,
    required this.image,
    required this.displayOrder,
    this.parentCatId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.fullCategory = '',
    this.subCategories = const [],
    this.dishes = const [],
  });

  factory HHDishCategoryModel.fromJson(
    Map<String, dynamic> json, {
    String inheritedFullCategory = '',
  }) {
    // The parent_dish_cats node provides full_category; sub-cats inherit it.
    final fullCategory = json['full_category']?.toString().trim().isNotEmpty == true
        ? json['full_category'].toString()
        : inheritedFullCategory;

    // Parse sub-categories — propagate fullCategory downward.
    List<HHDishCategoryModel> subCats = [];
    if (json['dish_cats'] != null && json['dish_cats'] is Map) {
      final dishCatsMap = json['dish_cats'] as Map<String, dynamic>;
      subCats = dishCatsMap.values
          .map((cat) => HHDishCategoryModel.fromJson(
                cat as Map<String, dynamic>,
                inheritedFullCategory: fullCategory,
              ))
          .toList();
    }

    // Parse dishes — inject fullCategory so each dish carries the breadcrumb.
    List<DishModel> dishList = [];
    if (json['dishes'] != null && json['dishes'] is Map) {
      final dishesMap = json['dishes'] as Map<String, dynamic>;
      dishList = dishesMap.values
          .map((dish) => DishModel.fromJson(
                dish as Map<String, dynamic>,
                inheritedFullCategory: fullCategory,
              ))
          .toList();
    }

    return HHDishCategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slugUrl: json['slug_url']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      displayOrder: int.tryParse(json['display_order']?.toString() ?? '0') ?? 0,
      parentCatId: json['parent_cat_id']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      fullCategory: fullCategory,
      subCategories: subCats,
      dishes: dishList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug_url': slugUrl,
      'image': image,
      'display_order': displayOrder,
      'parent_cat_id': parentCatId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isActive => status == 'a';
  bool get isParentCategory => parentCatId == null;
  bool get hasSubCategories => subCategories.isNotEmpty;
  bool get hasDishes => dishes.isNotEmpty;

  @override
  String toString() {
    return 'HHDishCategoryModel(id: $id, title: $title, subCats: ${subCategories.length}, dishes: ${dishes.length})';
  }
}

/// Dish Model
class DishModel {
  final String id;
  final String title;
  final String slugUrl;
  final String image;
  final int displayOrder;
  final String description;
  final String dishPrice;
  final String dishType;
  final String spicyType;
  final String status;
  final String dishCatId;
  final String parentDishCatId;
  final String isUnavailable;
  final String isRecommended;
  final String? createdAt;
  final String? updatedAt;

  /// Inherited from the parent category node's `full_category`
  /// (e.g. `"Ramadan Package > All Ramadan Packages"`).
  final String fullCategory;

  DishModel({
    required this.id,
    required this.title,
    required this.slugUrl,
    required this.image,
    required this.displayOrder,
    required this.description,
    required this.dishPrice,
    required this.dishType,
    required this.spicyType,
    required this.status,
    required this.dishCatId,
    required this.parentDishCatId,
    required this.isUnavailable,
    required this.isRecommended,
    this.createdAt,
    this.updatedAt,
    this.fullCategory = '',
  });

  factory DishModel.fromJson(
    Map<String, dynamic> json, {
    String inheritedFullCategory = '',
  }) {
    return DishModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slugUrl: json['slug_url']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      displayOrder: int.tryParse(json['display_order']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      dishPrice: json['dish_price']?.toString() ?? '0',
      dishType: json['dish_type']?.toString() ?? '',
      spicyType: json['spicy_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dishCatId: json['dish_cat_id']?.toString() ?? '',
      parentDishCatId: json['parent_dish_cat_id']?.toString() ?? '',
      isUnavailable: json['is_unavailable']?.toString() ?? 'n',
      isRecommended: json['recommended']?.toString() ?? 'n',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      fullCategory: inheritedFullCategory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug_url': slugUrl,
      'image': image,
      'display_order': displayOrder,
      'description': description,
      'dish_price': dishPrice,
      'dish_type': dishType,
      'spicy_type': spicyType,
      'status': status,
      'dish_cat_id': dishCatId,
      'parent_dish_cat_id': parentDishCatId,
      'is_unavailable': isUnavailable,
      'recommended': isRecommended,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isActive => status == 'a';
  bool get isAvailable => isUnavailable == 'n';
  bool get isSuggested => isRecommended == 'y';
  bool get isVegetarian => dishType == 'v';
  bool get isSpicy => spicyType == 'y';

  String get formattedPrice {
    try {
      final price = double.parse(dishPrice);
      return 'RP. ${price.toStringAsFixed(0)}';
    } catch (e) {
      return 'RP. $dishPrice';
    }
  }

  // -------------------- OPTIONS MAPS --------------------

  static const Map<String, String> _dishTypeImages = {
    'n': '',
    'v': APPImages.icVeg,
    'g': '',
    'm': '',
  };

  static const Map<String, String> _spicyTypeImages = {
    'n': '',
    's': '',
    'm': APPImages.icMediumChilli,
    'f': APPImages.icChilli,
  };


  // -------------------- IMAGE PATH GETTERS --------------------

  String get imgDishType =>
      _dishTypeImages[dishType] ?? '';

  String get imgSpicyType =>
      _spicyTypeImages[spicyType] ?? '';

  @override
  String toString() {
    return 'DishModel(id: $id, title: $title, price: $formattedPrice)';
  }
}