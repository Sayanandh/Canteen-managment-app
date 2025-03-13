class Meal {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // 'breakfast', 'lunch', 'dinner', 'snack'
  final bool isVeg;
  final bool isAvailable;
  final bool isIncludedInMealPlan;
  final String imageUrl;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isVeg,
    required this.isAvailable,
    required this.isIncludedInMealPlan,
    this.imageUrl = '',
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      isVeg: json['isVeg'],
      isAvailable: json['isAvailable'],
      isIncludedInMealPlan: json['isIncludedInMealPlan'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
      'isIncludedInMealPlan': isIncludedInMealPlan,
      'imageUrl': imageUrl,
    };
  }
}

class MealPlan {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> includedMeals; // e.g., ['breakfast', 'lunch', 'dinner']
  final int validityDays;
  final bool isActive;

  MealPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.includedMeals,
    required this.validityDays,
    required this.isActive,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      includedMeals: List<String>.from(json['included_meals']),
      validityDays: json['validity_days'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'included_meals': includedMeals,
      'validity_days': validityDays,
      'is_active': isActive,
    };
  }
} 