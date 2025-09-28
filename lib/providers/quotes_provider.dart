import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import 'package:uuid/uuid.dart';

class QuotesProvider with ChangeNotifier {
  final List<Quote> _quotes = [];

  List<Quote> get quotes => _quotes;

  void addQuote({
    required String text,
    required String book,
    required String author,
    String? note,
  }) {
    final newQuote = Quote(
      id: Uuid().v4(),
      text: text,
      book: book,
      author: author,
      note: note,
      createdAt: DateTime.now(),
    );

    _quotes.add(newQuote);
    // Sort by creation date (newest first)
    _quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  void removeQuote(String id) {
    _quotes.removeWhere((quote) => quote.id == id);
    notifyListeners();
  }

  void clearQuotes() {
    _quotes.clear();
    notifyListeners();
  }
}
