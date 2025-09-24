// models/club.dart
class Club {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final int membersCount;
  final int onlineCount;
  final String type; // 'book' or 'coffee'
  final DateTime createdAt;

  Club({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.membersCount,
    required this.onlineCount,
    required this.type,
    required this.createdAt,
  });

  Club copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? membersCount,
    int? onlineCount,
    String? type,
    DateTime? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      membersCount: membersCount ?? this.membersCount,
      onlineCount: onlineCount ?? this.onlineCount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'members_count': membersCount,
      'online_count': onlineCount,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      membersCount: json['members_count'] ?? 0,
      onlineCount: json['online_count'] ?? 0,
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
