class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final double balance;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.balance,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      balance: (json['balance'] as num).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(),
    };
  }
} 