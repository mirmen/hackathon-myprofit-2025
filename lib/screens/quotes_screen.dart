import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quotes_provider.dart';
import '../models/quote.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _quoteController.dispose();
    _bookController.dispose();
    _authorController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Мои цитаты',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<QuotesProvider>(
        builder: (context, quotesProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сохраните любимую цитату из книги',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.medium),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Добавить цитату',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _quoteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Цитата',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _bookController,
                          decoration: const InputDecoration(
                            labelText: 'Название книги',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Автор',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Ваши мысли (опционально)',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _simulatePhotoCapture,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Сделать фото'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _saveQuote(quotesProvider),
                                child: const Text('Сохранить'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (quotesProvider.quotes.isEmpty)
                  _buildEmptyState()
                else ...[
                  Text(
                    'Сохраненные цитаты',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...quotesProvider.quotes.map(
                    (quote) => _buildQuoteCard(context, quote, quotesProvider),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'У вас пока нет сохраненных цитат',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте первую цитату из вашей любимой книги',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    Quote quote,
    QuotesProvider quotesProvider,
  ) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote text
            Text(
              '"${quote.text}"',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Book and author
            Text(
              '${quote.book} — ${quote.author}',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Personal note
            if (quote.note != null && quote.note!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quote.note!,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Time and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quote.formattedDate,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, size: 18),
                      onPressed: () => _shareQuote(quote),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => _deleteQuote(quotesProvider, quote.id),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _simulatePhotoCapture() {
    // Simulate photo capture functionality
    AppUtils.showSuccessSnackBar(context, 'Фото цитаты сохранено!');
  }

  void _saveQuote(QuotesProvider quotesProvider) {
    if (_quoteController.text.isEmpty ||
        _bookController.text.isEmpty ||
        _authorController.text.isEmpty) {
      AppUtils.showErrorSnackBar(
        context,
        'Пожалуйста, заполните все обязательные поля',
      );
      return;
    }

    quotesProvider.addQuote(
      text: _quoteController.text,
      book: _bookController.text,
      author: _authorController.text,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    AppUtils.showSuccessSnackBar(context, 'Цитата сохранена!');

    // Clear fields
    _quoteController.clear();
    _bookController.clear();
    _authorController.clear();
    _noteController.clear();
  }

  void _shareQuote(Quote quote) {
    // In a real app, this would share the quote
    AppUtils.showSuccessSnackBar(
      context,
      'Цитата "${quote.text}" отправлена в общий доступ!',
    );
  }

  void _deleteQuote(QuotesProvider quotesProvider, String quoteId) {
    quotesProvider.removeQuote(quoteId);
    AppUtils.showSuccessSnackBar(context, 'Цитата удалена!');
  }
}
