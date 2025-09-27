class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime memberSince;
  final int bonusPoints;
  final int bonusPointsGoal;
  final List<String> activeSubscriptions;
  final String status;
  final String role;
  final int currentStreak;
  final int longestStreak;
  final int quotesCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.memberSince,
    required this.bonusPoints,
    required this.bonusPointsGoal,
    required this.activeSubscriptions,
    required this.status,
    required this.role,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.quotesCount = 0,
  });

  double get bonusProgress => bonusPoints / bonusPointsGoal;
  int get bonusPointsLeft => bonusPointsGoal - bonusPoints;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? memberSince,
    int? bonusPoints,
    int? bonusPointsGoal,
    List<String>? activeSubscriptions,
    String? status,
    String? role,
    int? currentStreak,
    int? longestStreak,
    int? quotesCount,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberSince: memberSince ?? this.memberSince,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      bonusPointsGoal: bonusPointsGoal ?? this.bonusPointsGoal,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      status: status ?? this.status,
      role: role ?? this.role,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      quotesCount: quotesCount ?? this.quotesCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'member_since': memberSince.toIso8601String(),
      'bonus_points': bonusPoints,
      'bonus_points_goal': bonusPointsGoal,
      'active_subscriptions': activeSubscriptions,
      'status': status,
      'role': role,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'quotes_count': quotesCount,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      memberSince: DateTime.parse(json['member_since']),
      bonusPoints: json['bonus_points'] ?? 0,
      bonusPointsGoal: json['bonus_points_goal'] ?? 1000,
      activeSubscriptions: List<String>.from(
        json['active_subscriptions'] ?? [],
      ),
      status: json['status'],
      role: json['role'] ?? 'user',
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      quotesCount: json['quotes_count'] ?? 0,
    );
  }
}
