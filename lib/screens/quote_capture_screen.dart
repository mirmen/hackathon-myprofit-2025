import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class QuoteCaptureScreen extends StatefulWidget {
  @override
  _QuoteCaptureScreenState createState() => _QuoteCaptureScreenState();
}

class _QuoteCaptureScreenState extends State<QuoteCaptureScreen> {
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
          'Фото цитат',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сохраните любимую цитату из книги',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Добавить цитату',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _quoteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Цитата',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _bookController,
                      decoration: InputDecoration(
                        labelText: 'Название книги',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _authorController,
                      decoration: InputDecoration(
                        labelText: 'Автор',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ваши мысли (опционально)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.camera_alt),
                            label: Text('Сделать фото'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveQuote,
                            child: Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Мои цитаты',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            _buildQuoteCard(
              "Не все те, кто бродят, потерялись",
              "Хоббит",
              "Дж. Р. Р. Толкин",
              "Эта цитата напоминает мне о важности путешествий и открытий",
              "2 часа назад",
            ),
            SizedBox(height: 12),
            _buildQuoteCard(
              "Книга - это машина времени, которая позволяет общаться с умами прошлого",
              "Читай, чтобы быть умным",
              "Артур Шopenhauer",
              "Почему я люблю читать старинные философские труды",
              "Вчера",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(
    String quote,
    String book,
    String author,
    String note,
    String time,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote text
            Text(
              '"$quote"',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            // Book and author
            Text(
              '$book — $author',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            // Personal note
            if (note.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            SizedBox(height: 12),
            // Time and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share, size: 18),
                      onPressed: () {
                        // Share functionality
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18),
                      onPressed: () {
                        // Delete functionality
                      },
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

  void _pickImage() {
    // In a real app, this would open the camera or gallery
    AppUtils.showSuccessSnackBar(context, 'Фото цитаты сохранено!');
  }

  void _saveQuote() {
    if (_quoteController.text.isEmpty ||
        _bookController.text.isEmpty ||
        _authorController.text.isEmpty) {
      AppUtils.showErrorSnackBar(
        context,
        'Пожалуйста, заполните все обязательные поля',
      );
      return;
    }

    // In a real app, this would save to a database
    AppUtils.showSuccessSnackBar(context, 'Цитата сохранена!');

    // Clear fields
    _quoteController.clear();
    _bookController.clear();
    _authorController.clear();
    _noteController.clear();
  }
}
