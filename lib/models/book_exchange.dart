class BookExchange {
  final String id;
  final String userId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookImageUrl;
  final String condition;
  final DateTime createdAt;
  final DateTime? exchangedAt;
  final String status; // available, requested, exchanged, completed
  final int bonusPoints;

  BookExchange({
    required this.id,
    required this.userId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookImageUrl,
    required this.condition,
    required this.createdAt,
    this.exchangedAt,
    required this.status,
    required this.bonusPoints,
  });

  BookExchange copyWith({
    String? id,
    String? userId,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    String? condition,
    DateTime? createdAt,
    DateTime? exchangedAt,
    String? status,
    int? bonusPoints,
  }) {
    return BookExchange(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      exchangedAt: exchangedAt ?? this.exchangedAt,
      status: status ?? this.status,
      bonusPoints: bonusPoints ?? this.bonusPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_title': bookTitle,
      'book_author': bookAuthor,
      'book_image_url': bookImageUrl,
      'condition': condition,
      'created_at': createdAt.toIso8601String(),
      'exchanged_at': exchangedAt?.toIso8601String(),
      'status': status,
      'bonus_points': bonusPoints,
    };
  }

  factory BookExchange.fromJson(Map<String, dynamic> json) {
    return BookExchange(
      id: json['id'],
      userId: json['user_id'],
      bookTitle: json['book_title'],
      bookAuthor: json['book_author'],
      bookImageUrl: json['book_image_url'],
      condition: json['condition'],
      createdAt: DateTime.parse(json['created_at']),
      exchangedAt: json['exchanged_at'] != null
          ? DateTime.parse(json['exchanged_at'])
          : null,
      status: json['status'],
      bonusPoints: json['bonus_points'],
    );
  }
}

class BookCondition {
  static const String excellent = 'excellent';
  static const String good = 'good';
  static const String fair = 'fair';
  static const String poor = 'poor';

  static String getLabel(String condition) {
    switch (condition) {
      case excellent:
        return 'Отличное';
      case good:
        return 'Хорошее';
      case fair:
        return 'Удовлетворительное';
      case poor:
        return 'Плохое';
      default:
        return 'Неизвестное';
    }
  }

  static List<Map<String, String>> getAllConditions() {
    return [
      {'value': excellent, 'label': 'Отличное'},
      {'value': good, 'label': 'Хорошее'},
      {'value': fair, 'label': 'Удовлетворительное'},
      {'value': poor, 'label': 'Плохое'},
    ];
  }
}
