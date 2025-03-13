class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'student', 'staff', 'admin'
  final double balance;
  final String profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.balance,
    this.profileImage = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      balance: json['balance'].toDouble(),
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'balance': balance,
      'profileImage': profileImage,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    double? balance,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      profileImage: profileImage ?? this.profileImage,
    );
  }
} 