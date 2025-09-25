import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/book_exchange_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book_exchange.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class BookExchangeScreen extends StatefulWidget {
  @override
  _BookExchangeScreenState createState() => _BookExchangeScreenState();
}

class _BookExchangeScreenState extends State<BookExchangeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExchanges();
    });
  }

  Future<void> _loadExchanges() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await context.read<BookExchangeProvider>().loadExchanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Книгообмен',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddBookDialog,
          ),
        ],
      ),
      body: Consumer<BookExchangeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.exchanges.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => _loadExchanges(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: provider.exchanges.length,
              itemBuilder: (context, index) {
                final exchange = provider.exchanges[index];
                return _buildExchangeCard(exchange);
              },
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
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.book, size: 64, color: AppColors.primary),
          ),
          SizedBox(height: 24),
          Text(
            'Нет доступных книг для обмена',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Будьте первым, кто добавит книгу для обмена!',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showAddBookDialog,
            child: Text('Добавить книгу'),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(BookExchange exchange) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book info
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book image placeholder
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exchange.bookTitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        exchange.bookAuthor,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(
                            exchange.condition,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          BookCondition.getLabel(exchange.condition),
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getConditionColor(exchange.condition),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bonus points and action
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: AppConstants.goldColor, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+${exchange.bonusPoints} баллов',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.goldColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _requestExchange(exchange),
                  child: Text('Запросить обмен'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case BookCondition.excellent:
        return Colors.green;
      case BookCondition.good:
        return Colors.blue;
      case BookCondition.fair:
        return Colors.orange;
      case BookCondition.poor:
        return Colors.red;
      default:
        return AppColors.textLight;
    }
  }

  void _showAddBookDialog() {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String author = '';
    String condition = BookCondition.good;
    int bonusPoints = 50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Добавить книгу для обмена',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Название книги',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название книги';
                    }
                    return null;
                  },
                  onSaved: (value) => title = value!,
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Автор',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите автора';
                    }
                    return null;
                  },
                  onSaved: (value) => author = value!,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Состояние книги',
                    border: OutlineInputBorder(),
                  ),
                  value: condition,
                  items: BookCondition.getAllConditions().map((cond) {
                    return DropdownMenuItem(
                      value: cond['value'],
                      child: Text(cond['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        condition = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Бонусные баллы за обмен',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: bonusPoints.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите количество баллов';
                    }
                    final points = int.tryParse(value);
                    if (points == null || points <= 0) {
                      return 'Введите корректное число баллов';
                    }
                    return null;
                  },
                  onSaved: (value) => bonusPoints = int.parse(value!),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Отмена'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _addBookForExchange(
                            title,
                            author,
                            condition,
                            bonusPoints,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Добавить'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addBookForExchange(
    String title,
    String author,
    String condition,
    int bonusPoints,
  ) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final success = await context.read<BookExchangeProvider>().addBookExchange(
      userId: authProvider.currentUser!.id,
      bookTitle: title,
      bookAuthor: author,
      condition: condition,
      bonusPoints: bonusPoints,
    );

    if (success) {
      AppUtils.showSuccessSnackBar(context, 'Книга добавлена для обмена!');
      _loadExchanges();
    } else {
      AppUtils.showErrorSnackBar(context, 'Ошибка при добавлении книги');
    }
  }

  void _requestExchange(BookExchange exchange) {
    // In a real app, this would show a confirmation dialog and process the exchange
    AppUtils.showSuccessSnackBar(
      context,
      'Запрос на обмен отправлен! После подтверждения вы получите ${exchange.bonusPoints} баллов.',
    );
  }
}
