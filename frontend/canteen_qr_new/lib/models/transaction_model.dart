import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final String type;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'amount': amount,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isCredit => amount > 0;

  String get formattedAmount {
    final prefix = isCredit ? '+' : '';
    return '$prefix₹${amount.abs().toStringAsFixed(2)}';
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(timestamp);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(timestamp);
  }
} 