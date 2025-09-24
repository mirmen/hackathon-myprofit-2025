class CartItem {
  final String id;
  final String productId;
  final String title;
  final String author;
  final String type;
  final double price;
  final String imageUrl;
  final String selectedOption;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.author,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.selectedOption,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? title,
    String? author,
    String? type,
    double? price,
    String? imageUrl,
    String? selectedOption,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      author: author ?? this.author,
      type: type ?? this.type,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      selectedOption: selectedOption ?? this.selectedOption,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'author': author,
      'type': type,
      'price': price,
      'image_url': imageUrl,
      'selected_option': selectedOption,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      title: json['title'],
      author: json['author'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
      selectedOption: json['selected_option'],
      quantity: json['quantity'],
    );
  }
}
