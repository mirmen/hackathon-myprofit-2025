class Product {
  final String id;
  final String title;
  final String author;
  final String type;
  final double price;
  final double rating;
  final String imageUrl;
  final String description;
  final List<String> options;
  final bool isBook;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.author,
    required this.type,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.options,
    required this.isBook,
    required this.createdAt,
  });

  Product copyWith({
    String? id,
    String? title,
    String? author,
    String? type,
    double? price,
    double? rating,
    String? imageUrl,
    String? description,
    List<String>? options,
    bool? isBook,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      type: type ?? this.type,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      options: options ?? this.options,
      isBook: isBook ?? this.isBook,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'type': type,
      'price': price,
      'rating': rating,
      'image_url': imageUrl,
      'description': description,
      'options': options,
      'is_book': isBook,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      isBook: json['is_book'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
