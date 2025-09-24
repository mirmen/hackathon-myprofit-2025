class SubscriptionPlan {
  final String id;
  final String title;
  final String price;
  final String cups;
  final List<String> includedDrinks;
  final bool isPopular;
  final String? description;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.cups,
    required this.includedDrinks,
    this.description,
    this.isPopular = false,
  });

  SubscriptionPlan copyWith({
    String? id,
    String? title,
    String? price,
    String? cups,
    List<String>? includedDrinks,
    bool? isPopular,
    String? description,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      cups: cups ?? this.cups,
      includedDrinks: includedDrinks ?? this.includedDrinks,
      isPopular: isPopular ?? this.isPopular,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'cups': cups,
      'included_drinks': includedDrinks,
      'is_popular': isPopular,
      'description': description,
    };
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      cups: json['cups'],
      includedDrinks: List<String>.from(json['included_drinks'] ?? []),
      isPopular: json['is_popular'] ?? false,
      description: json['description'],
    );
  }
}

class CollectionBook {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final String imageUrl;
  final double progress;
  final bool isFavorite;

  CollectionBook({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.imageUrl,
    required this.progress,
    this.isFavorite = false,
  });

  CollectionBook copyWith({
    String? id,
    String? title,
    String? author,
    String? publisher,
    String? imageUrl,
    double? progress,
    bool? isFavorite,
  }) {
    return CollectionBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      imageUrl: imageUrl ?? this.imageUrl,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'image_url': imageUrl,
      'progress': progress,
      'is_favorite': isFavorite,
    };
  }

  factory CollectionBook.fromJson(Map<String, dynamic> json) {
    return CollectionBook(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publisher: json['publisher'],
      imageUrl: json['image_url'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
