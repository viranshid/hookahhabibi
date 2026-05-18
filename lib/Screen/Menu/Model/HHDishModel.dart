class HHDishModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final String rawPrice;
  final String imageUrl;
  final String isSpicy;
  final String isVegetarian;
  final bool isAvailable;
  final bool isRecomended;
  final String category;

  /// Breadcrumb path from the get-dishes API (`full_category`),
  /// e.g. `"Ramadan Package > All Ramadan Packages"`.
  final String fullCategory;

  HHDishModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.rawPrice = '',
    required this.imageUrl,
    this.isSpicy = '',
    this.isVegetarian = '',
    this.isAvailable = true,
    this.isRecomended = false,
    required this.category,
    this.fullCategory = '',
  });

  // Factory constructor for JSON parsing
  factory HHDishModel.fromJson(Map<String, dynamic> json) {
    return HHDishModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isSpicy: json['isSpicy']?.toString() ?? '',
      isVegetarian: json['isVegetarian']?.toString() ?? '',
      isAvailable: json['isAvailable'] ?? true,
      isRecomended: json['isRecomended'] ?? true,
      category: json['category']?.toString() ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isSpicy': isSpicy,
      'isVegetarian': isVegetarian,
      'isAvailable': isAvailable,
      'isRecomended': isRecomended,
      'category': category,
    };
  }

  // Copy with method
  HHDishModel copyWith({
    String? id,
    String? name,
    String? description,
    String? price,
    String? imageUrl,
    String? isSpicy,
    String? isVegetarian,
    bool? isAvailable,
    bool? isRecomended,
    String? category,
  }) {
    return HHDishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isSpicy: isSpicy ?? this.isSpicy,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isAvailable: isAvailable ?? this.isAvailable,
      isRecomended: isRecomended ?? this.isRecomended,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HHDishModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HHDishModel(id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl, isSpicy: $isSpicy, isVegetarian: $isVegetarian, isAvailable: $isAvailable, category: $category)';
  }
}