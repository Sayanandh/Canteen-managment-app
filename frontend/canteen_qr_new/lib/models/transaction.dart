class Transaction {
  final int id;
  final int userId;
  final double amount;
  final String transactionType;
  final String? description;
  final DateTime timestamp;
  final String? mealType;
  final String status;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.transactionType,
    this.description,
    required this.timestamp,
    this.mealType,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      transactionType: json['transaction_type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      mealType: json['meal_type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'transaction_type': transactionType,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'meal_type': mealType,
      'status': status,
    };
  }
} 