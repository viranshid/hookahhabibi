class HHDishModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final bool isSpicy;
  final bool isVegetarian;
  final bool isAvailable;
  final String category;

  HHDishModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isSpicy = false,
    this.isVegetarian = false,
    this.isAvailable = true,
    required this.category,
  });

  // Factory constructor for JSON parsing
  factory HHDishModel.fromJson(Map<String, dynamic> json) {
    return HHDishModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isSpicy: json['isSpicy'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
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
    bool? isSpicy,
    bool? isVegetarian,
    bool? isAvailable,
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