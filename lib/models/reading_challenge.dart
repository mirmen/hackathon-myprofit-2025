class ReadingChallenge {
  final String id;
  final String title;
  final String description;
  final List<String> bookIds;
  final int targetBooks;
  final int bonusPoints;
  final DateTime createdAt;
  final DateTime? endDate;
  final List<String> participants;
  final Map<String, int> userProgress; // userId -> books read

  ReadingChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.bookIds,
    required this.targetBooks,
    required this.bonusPoints,
    required this.createdAt,
    this.endDate,
    required this.participants,
    required this.userProgress,
  });

  ReadingChallenge copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? bookIds,
    int? targetBooks,
    int? bonusPoints,
    DateTime? createdAt,
    DateTime? endDate,
    List<String>? participants,
    Map<String, int>? userProgress,
  }) {
    return ReadingChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bookIds: bookIds ?? this.bookIds,
      targetBooks: targetBooks ?? this.targetBooks,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
      participants: participants ?? this.participants,
      userProgress: userProgress ?? this.userProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'book_ids': bookIds,
      'target_books': targetBooks,
      'bonus_points': bonusPoints,
      'created_at': createdAt.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'participants': participants,
      'user_progress': userProgress,
    };
  }

  factory ReadingChallenge.fromJson(Map<String, dynamic> json) {
    return ReadingChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      bookIds: List<String>.from(json['book_ids'] ?? []),
      targetBooks: json['target_books'] ?? 0,
      bonusPoints: json['bonus_points'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      participants: List<String>.from(json['participants'] ?? []),
      userProgress: Map<String, int>.from(json['user_progress'] ?? {}),
    );
  }

  int getUserProgress(String userId) {
    return userProgress[userId] ?? 0;
  }

  double getProgressPercentage(String userId) {
    final progress = getUserProgress(userId);
    return targetBooks > 0 ? progress / targetBooks : 0;
  }

  bool get isCompleted {
    return endDate != null && DateTime.now().isAfter(endDate!);
  }

  bool isUserParticipating(String userId) {
    return participants.contains(userId);
  }
}

class UserChallengeProgress {
  final String userId;
  final String challengeId;
  final int booksRead;
  final List<String> booksCompleted;
  final DateTime lastUpdated;

  UserChallengeProgress({
    required this.userId,
    required this.challengeId,
    required this.booksRead,
    required this.booksCompleted,
    required this.lastUpdated,
  });

  UserChallengeProgress copyWith({
    String? userId,
    String? challengeId,
    int? booksRead,
    List<String>? booksCompleted,
    DateTime? lastUpdated,
  }) {
    return UserChallengeProgress(
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      booksRead: booksRead ?? this.booksRead,
      booksCompleted: booksCompleted ?? this.booksCompleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'challenge_id': challengeId,
      'books_read': booksRead,
      'books_completed': booksCompleted,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory UserChallengeProgress.fromJson(Map<String, dynamic> json) {
    return UserChallengeProgress(
      userId: json['user_id'],
      challengeId: json['challenge_id'],
      booksRead: json['books_read'] ?? 0,
      booksCompleted: List<String>.from(json['books_completed'] ?? []),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}
