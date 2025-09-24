class Promotion {
  final String id;
  final String title;
  final String subtitle;
  final String? description;
  final String? imageUrl;
  final String? link;
  final String category;
  final DateTime createdAt;

  Promotion({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description,
    this.imageUrl,
    this.link,
    required this.category,
    required this.createdAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      imageUrl: json['image_url'],
      link: json['link'],
      category: json['category'] ?? 'Акции',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'image_url': imageUrl,
      'link': link,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
