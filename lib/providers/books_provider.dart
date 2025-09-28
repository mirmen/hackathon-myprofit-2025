// providers/books_provider.dart
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';

class BooksProvider with ChangeNotifier {
  List<Book> _userBooks = [];

  List<Book> get userBooks => _userBooks;

  void loadUserBooks() {
    // Заглушка с примерными данными
    _userBooks = [
      Book(
        id: '1',
        title: 'Мастер и Маргарита',
        author: 'Михаил Булгаков',
        coverUrl: '',
        totalPages: 480,
        currentPage: 150,
        isPurchased: true,
        isDemo: false,
        addedDate: DateTime(2024, 1, 15),
      ),
      Book(
        id: '2',
        title: 'Преступление и наказание',
        author: 'Федор Достоевский',
        coverUrl: '',
        totalPages: 672,
        currentPage: 89,
        isPurchased: false,
        isDemo: true,
        isFavorite: true,
        addedDate: DateTime(2024, 2, 10),
      ),
      Book(
        id: '3',
        title: 'Война и мир',
        author: 'Лев Толстой',
        coverUrl: '',
        totalPages: 1225,
        currentPage: 456,
        isPurchased: true,
        isDemo: false,
        addedDate: DateTime(2024, 1, 5),
      ),
      Book(
        id: '4',
        title: '1984',
        author: 'Джордж Оруэлл',
        coverUrl: '',
        totalPages: 328,
        currentPage: 0,
        isPurchased: false,
        isDemo: true,
        isFavorite: true,
        addedDate: DateTime(2024, 3, 1),
      ),
    ];
    notifyListeners();
  }

  void updateBookProgress(String bookId, int currentPage) {
    final index = _userBooks.indexWhere((book) => book.id == bookId);
    if (index != -1) {
      _userBooks[index] = Book(
        id: _userBooks[index].id,
        title: _userBooks[index].title,
        author: _userBooks[index].author,
        coverUrl: _userBooks[index].coverUrl,
        totalPages: _userBooks[index].totalPages,
        currentPage: currentPage,
        isDemo: _userBooks[index].isDemo,
        isPurchased: _userBooks[index].isPurchased,
        isFavorite: _userBooks[index].isFavorite,
        addedDate: _userBooks[index].addedDate,
      );
      notifyListeners();
    }
  }
}
