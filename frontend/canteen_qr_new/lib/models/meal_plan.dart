class MealPlan {
  final int id;
  final int userId;
  final String planType;
  final int mealsRemaining;
  final bool breakfastAllowed;
  final bool lunchAllowed;
  final bool dinnerAllowed;
  final DateTime startDate;
  final DateTime? endDate;

  MealPlan({
    required this.id,
    required this.userId,
    required this.planType,
    required this.mealsRemaining,
    required this.breakfastAllowed,
    required this.lunchAllowed,
    required this.dinnerAllowed,
    required this.startDate,
    this.endDate,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      userId: json['user_id'],
      planType: json['plan_type'],
      mealsRemaining: json['meals_remaining'],
      breakfastAllowed: json['breakfast_allowed'],
      lunchAllowed: json['lunch_allowed'],
      dinnerAllowed: json['dinner_allowed'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_type': planType,
      'meals_remaining': mealsRemaining,
      'breakfast_allowed': breakfastAllowed,
      'lunch_allowed': lunchAllowed,
      'dinner_allowed': dinnerAllowed,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
} 