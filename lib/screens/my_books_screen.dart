// screens/my_books_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../models/book_model.dart';

class MyBooksScreen extends StatefulWidget {
  @override
  _MyBooksScreenState createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadUserBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          'Мои книги',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E2E2E),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E2E2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: booksProvider.userBooks.isEmpty
          ? _buildEmptyState()
          : _buildBooksList(booksProvider.userBooks),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: const Color(0xFF8C6A4B).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'У вас пока нет книг',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E2E2E).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте книги в избранное или приобретите их',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: const Color(0xFF2E2E2E).withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(book);
      },
    );
  }

  Widget _buildBookCard(Book book) {
    return Card(
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Обложка книги
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF8C6A4B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                image: book.coverUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(book.coverUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.coverUrl.isEmpty
                  ? Icon(
                      Icons.book,
                      size: 32,
                      color: const Color(0xFF8C6A4B).withOpacity(0.5),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Информация о книге
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E2E2E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (book.isDemo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'ДЕМО',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF2E2E2E).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF2E2E2E).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Прогресс чтения
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Прогресс чтения',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2E2E2E).withOpacity(0.8),
                            ),
                          ),
                          Text(
                            book.progressText,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8C6A4B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: book.progressPercentage / 100,
                        backgroundColor: const Color(0xFFE0E0E0),
                        color: const Color(0xFF8C6A4B),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Страница ${book.currentPage} из ${book.totalPages}',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: const Color(0xFF2E2E2E).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
