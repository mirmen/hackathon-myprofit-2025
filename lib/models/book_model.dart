// models/book_model.dart
class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final int totalPages;
  final int currentPage;
  final bool isDemo;
  final bool isPurchased;
  final bool isFavorite;
  final DateTime? addedDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.totalPages,
    required this.currentPage,
    this.isDemo = false,
    this.isPurchased = false,
    this.isFavorite = false,
    this.addedDate,
  });

  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages * 100).clamp(0.0, 100.0);
  }

  String get progressText {
    return '${progressPercentage.toStringAsFixed(1)}%';
  }

  String get subtitle {
    if (isDemo) return 'Демо версия';
    if (isPurchased) return 'Приобретена';
    return 'В избранном';
  }
}
