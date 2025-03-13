class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final bool isAvailable;
  final String? imageUrl;
  final String mealType;
  final bool isVeg;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
    required this.mealType,
    required this.isVeg,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      isAvailable: json['is_available'],
      imageUrl: json['image_url'],
      mealType: json['meal_type'] ?? 'breakfast',
      isVeg: json['is_veg'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'is_available': isAvailable,
      'image_url': imageUrl,
      'meal_type': mealType,
      'is_veg': isVeg,
    };
  }
} 