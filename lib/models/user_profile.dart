class UserProfile {
  final String email; // Email is now the primary identifier
  final String name;
  final String passwordHash;
  final DateTime createdAt;

  UserProfile({
    required this.email,
    required this.name,
    required this.passwordHash,
    required this.createdAt,
  });

  // For backward compatibility and display purposes
  String get id => email;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'],
      name: json['name'],
      passwordHash: json['passwordHash'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
