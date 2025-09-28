import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Модель данных для подборки книг
class BookCollection {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final int booksCount;
  final String curator;
  final double rating;
  final int savesCount;
  final String type;
  final DateTime createdAt;
  final List<String> tags;

  BookCollection({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.booksCount,
    required this.curator,
    required this.rating,
    required this.savesCount,
    required this.type,
    required this.createdAt,
    this.tags = const [],
  });
}

// Провайдер для управления подборками книг
class BookCollectionsProvider with ChangeNotifier {
  List<BookCollection> _collections = [];
  List<BookCollection> _savedCollections = [];
  bool _isLoading = false;
  String _selectedType = 'all';
  String _searchQuery = '';
  String _sortBy = 'newest';

  List<BookCollection> get collections => _getFilteredAndSortedCollections();
  List<BookCollection> get savedCollections => _savedCollections;
  bool get isLoading => _isLoading;
  String get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  List<BookCollection> _getFilteredAndSortedCollections() {
    List<BookCollection> filtered = _collections;

    // Фильтрация по типу
    if (_selectedType != 'all') {
      filtered = filtered
          .where((collection) => collection.type == _selectedType)
          .toList();
    }

    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (collection) =>
                collection.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                collection.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                collection.curator.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                collection.tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(_searchQuery.toLowerCase()),
                ),
          )
          .toList();
    }

    // Сортировка
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'saves':
        filtered.sort((a, b) => b.savesCount.compareTo(a.savesCount));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'books':
        filtered.sort((a, b) => b.booksCount.compareTo(a.booksCount));
        break;
    }

    return filtered;
  }

  Future<void> loadCollections() async {
    _isLoading = true;
    notifyListeners();

    // Имитация загрузки данных
    await Future.delayed(Duration(seconds: 2));

    _collections = [
      BookCollection(
        id: '1',
        title: 'Лучшие книги 2024 года',
        description:
            'Подборка самых обсуждаемых и рейтинговых книг этого года от ведущих критиков и издателей',
        imageUrl: 'https://example.com/collections/best2024.jpg',
        booksCount: 25,
        curator: 'Команда BookClub',
        rating: 4.8,
        savesCount: 243,
        type: 'featured',
        createdAt: DateTime(2024, 1, 15),
        tags: ['новинки', 'бестселлеры', '2024'],
      ),
      BookCollection(
        id: '2',
        title: 'Классика мировой литературы',
        description:
            'Вечные произведения, которые должен прочитать каждый образованный человек',
        booksCount: 50,
        curator: 'Профессор Иванов',
        rating: 4.9,
        savesCount: 567,
        type: 'popular',
        createdAt: DateTime(2023, 11, 20),
        tags: ['классика', 'литература', 'образование'],
      ),
      BookCollection(
        id: '3',
        title: 'Современная проза',
        description:
            'Актуальные романы и рассказы современных авторов, отражающие дух времени',
        imageUrl: 'https://example.com/collections/modern.jpg',
        booksCount: 18,
        curator: 'Литературный критик',
        rating: 4.5,
        savesCount: 89,
        type: 'new',
        createdAt: DateTime(2024, 2, 10),
        tags: ['проза', 'современность', 'романы'],
      ),
      BookCollection(
        id: '4',
        title: 'Научная фантастика',
        description:
            'Лучшие произведения в жанре научной фантастики от основоположников до современных авторов',
        booksCount: 32,
        curator: 'Клуб Sci-Fi',
        rating: 4.7,
        savesCount: 321,
        type: 'thematic',
        createdAt: DateTime(2023, 12, 5),
        tags: ['фантастика', 'наука', 'будущее'],
      ),
      BookCollection(
        id: '5',
        title: 'Бизнес и саморазвитие',
        description:
            'Книги по личностному росту, предпринимательству и управлению временем',
        booksCount: 22,
        curator: 'Бизнес-тренер Петров',
        rating: 4.6,
        savesCount: 154,
        type: 'popular',
        createdAt: DateTime(2024, 1, 30),
        tags: ['бизнес', 'саморазвитие', 'успех'],
      ),
      BookCollection(
        id: '6',
        title: 'Детективы и триллеры',
        description:
            'Захватывающие истории с интригующим сюжетом и неожиданной развязкой',
        booksCount: 28,
        curator: 'Криминальный обозреватель',
        rating: 4.4,
        savesCount: 198,
        type: 'thematic',
        createdAt: DateTime(2024, 3, 5),
        tags: ['детектив', 'триллер', 'криминал'],
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  Future<bool> isCollectionSaved(String collectionId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _savedCollections.any((collection) => collection.id == collectionId);
  }

  Future<bool> saveCollection(String collectionId) async {
    await Future.delayed(Duration(milliseconds: 500));

    final collection = _collections.firstWhere((c) => c.id == collectionId);
    if (!_savedCollections.contains(collection)) {
      _savedCollections.add(collection);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> unsaveCollection(String collectionId) async {
    await Future.delayed(Duration(milliseconds: 500));

    _savedCollections.removeWhere(
      (collection) => collection.id == collectionId,
    );
    notifyListeners();
    return true;
  }
}

// Цвета темы
class AppColors {
  static const Color primary = Color(0xFF8C6A4B);
  static const Color secondary = Color(0xFFCD9F68);
  static const Color background = Color(0xFFF8F5F1);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF2E2E2E);
  static const Color accent = Color(0xFF005230);
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color textLight = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}

// Утилиты для показа уведомлений
class AppUtils {
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// Виджет для загрузки изображений
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CachedImageWidget({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.collections_bookmark_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }
}

// Основной экран подборок книг
class BookCollectionsScreen extends StatefulWidget {
  @override
  _BookCollectionsScreenState createState() => _BookCollectionsScreenState();
}

class _BookCollectionsScreenState extends State<BookCollectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookCollectionsProvider>().loadCollections();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Подборка книг',
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
          // Кнопка поиска
          IconButton(
            icon: Icon(Icons.search, color: AppColors.onSurface),
            onPressed: _showSearchDialog,
          ),
          // Кнопка сортировки
          IconButton(
            icon: Icon(Icons.sort, color: AppColors.onSurface),
            onPressed: _showSortDialog,
          ),
          // Меню дополнительных опций
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'saved') {
                _showSavedCollections();
              } else if (value == 'refresh') {
                context.read<BookCollectionsProvider>().loadCollections();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'saved',
                child: Row(
                  children: [
                    Icon(Icons.bookmark, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Сохраненные подборки'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Обновить данные'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<BookCollectionsProvider>(
        builder: (context, collectionsProvider, child) {
          if (collectionsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Column(
            children: [
              // Показать поисковый запрос если он есть
              if (collectionsProvider.searchQuery.isNotEmpty)
                _buildSearchHeader(collectionsProvider),

              // Секция фильтров
              _buildFilterSection(collectionsProvider),

              // Информация о результатах
              _buildResultsInfo(collectionsProvider),

              // Список подборок
              Expanded(
                child: collectionsProvider.collections.isEmpty
                    ? _buildEmptyState(collectionsProvider)
                    : _buildCollectionsList(collectionsProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader(BookCollectionsProvider collectionsProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.primary.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Результаты поиска: "${collectionsProvider.searchQuery}"',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18),
            onPressed: () {
              collectionsProvider.clearSearch();
              _searchController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BookCollectionsProvider collectionsProvider) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', 'Все', collectionsProvider),
          _buildFilterChip('featured', 'Рекомендуемые', collectionsProvider),
          _buildFilterChip('popular', 'Популярные', collectionsProvider),
          _buildFilterChip('new', 'Новинки', collectionsProvider),
          _buildFilterChip('thematic', 'Тематические', collectionsProvider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String type,
    String label,
    BookCollectionsProvider collectionsProvider,
  ) {
    final isSelected = collectionsProvider.selectedType == type;

    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForType(type),
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textLight,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => collectionsProvider.setType(type),
        selectedColor: AppColors.primary.withOpacity(0.15),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildResultsInfo(BookCollectionsProvider collectionsProvider) {
    final count = collectionsProvider.collections.length;
    final total = collectionsProvider._collections.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Найдено: $count из $total',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
          Text(
            _getSortLabel(collectionsProvider.sortBy),
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList(BookCollectionsProvider collectionsProvider) {
    return RefreshIndicator(
      onRefresh: () => collectionsProvider.loadCollections(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: collectionsProvider.collections.length,
        itemBuilder: (context, index) {
          final collection = collectionsProvider.collections[index];
          return BookCollectionCard(collection: collection);
        },
      ),
    );
  }

  Widget _buildEmptyState(BookCollectionsProvider collectionsProvider) {
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
            child: Icon(
              collectionsProvider.searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.collections_bookmark_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            collectionsProvider.searchQuery.isNotEmpty
                ? 'По запросу ничего не найдено'
                : 'Подборки не найдены',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Text(
            collectionsProvider.searchQuery.isNotEmpty
                ? 'Попробуйте изменить поисковый запрос'
                : 'Попробуйте изменить фильтры поиска',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              collectionsProvider.setType('all');
              collectionsProvider.clearSearch();
            },
            child: Text('Показать все подборки'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Поиск подборок'),
        content: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Введите название, автора или тег...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            context.read<BookCollectionsProvider>().setSearchQuery(value);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                context.read<BookCollectionsProvider>().setSearchQuery(query);
              }
              Navigator.of(context).pop();
            },
            child: Text('Найти'),
          ),
        ],
      ),
    ).then((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        _searchFocusNode.requestFocus();
      });
    });
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Сортировка подборок',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            _buildSortOption('newest', 'Сначала новые', Icons.new_releases),
            _buildSortOption('rating', 'По рейтингу', Icons.star),
            _buildSortOption('saves', 'По сохранениям', Icons.favorite),
            _buildSortOption(
              'books',
              'По количеству книг',
              Icons.library_books,
            ),
            _buildSortOption('title', 'По названию', Icons.sort_by_alpha),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String title, IconData icon) {
    return Consumer<BookCollectionsProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.sortBy == value;
        return ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textLight,
          ),
          title: Text(
            title,
            style: GoogleFonts.montserrat(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.onSurface,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check, color: AppColors.primary)
              : null,
          onTap: () {
            provider.setSortBy(value);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showSavedCollections() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Сохраненные подборки',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Consumer<BookCollectionsProvider>(
                builder: (context, provider, child) {
                  if (provider.savedCollections.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Нет сохраненных подборок',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Сохраняйте понравившиеся подборки,\nчтобы вернуться к ним позже',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.savedCollections.length,
                    itemBuilder: (context, index) {
                      final collection = provider.savedCollections[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.collections_bookmark,
                            color: AppColors.primary,
                          ),
                          title: Text(collection.title),
                          subtitle: Text(
                            '${collection.booksCount} книг • ${collection.curator}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _unsaveCollection(collection.id),
                          ),
                          onTap: () {
                            // Навигация к деталям подборки
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unsaveCollection(String collectionId) async {
    final provider = context.read<BookCollectionsProvider>();
    final success = await provider.unsaveCollection(collectionId);

    if (success) {
      AppUtils.showSuccessSnackBar(context, 'Подборка удалена из сохраненных');
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'featured':
        return Icons.star_rounded;
      case 'popular':
        return Icons.trending_up_rounded;
      case 'new':
        return Icons.new_releases_rounded;
      case 'thematic':
        return Icons.category_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'rating':
        return 'По рейтингу';
      case 'saves':
        return 'По сохранениям';
      case 'newest':
        return 'Сначала новые';
      case 'books':
        return 'По количеству книг';
      case 'title':
        return 'По названию';
      default:
        return 'Сортировка';
    }
  }
}

// Карточка подборки книг
class BookCollectionCard extends StatefulWidget {
  final BookCollection collection;

  const BookCollectionCard({Key? key, required this.collection})
    : super(key: key);

  @override
  State<BookCollectionCard> createState() => _BookCollectionCardState();
}

class _BookCollectionCardState extends State<BookCollectionCard> {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final collectionsProvider = context.read<BookCollectionsProvider>();
    final isSaved = await collectionsProvider.isCollectionSaved(
      widget.collection.id,
    );
    if (mounted) {
      setState(() {
        _isSaved = isSaved;
      });
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final collectionsProvider = context.read<BookCollectionsProvider>();
    bool success;

    if (_isSaved) {
      success = await collectionsProvider.unsaveCollection(
        widget.collection.id,
      );
    } else {
      success = await collectionsProvider.saveCollection(widget.collection.id);
    }

    if (mounted) {
      if (success) {
        setState(() {
          _isSaved = !_isSaved;
        });

        AppUtils.showSuccessSnackBar(
          context,
          _isSaved
              ? 'Подборка "${widget.collection.title}" добавлена в избранное'
              : 'Подборка "${widget.collection.title}" удалена из избранного',
        );
      } else {
        AppUtils.showErrorSnackBar(
          context,
          'Ошибка при ${_isSaved ? 'удалении' : 'добавлении'} подборки',
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12),
          _buildDescription(),
          SizedBox(height: 16),
          _buildStatsRow(),
          SizedBox(height: 16),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение подборки
          if (widget.collection.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedImageWidget(
                imageUrl: widget.collection.imageUrl!,
                width: 70,
                height: 70,
              ),
            )
          else
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getCollectionTypeColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForCollectionType(),
                color: _getCollectionTypeColor(),
                size: 32,
              ),
            ),
          SizedBox(width: 16),

          // Информация о подборке
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название подборки
                Text(
                  widget.collection.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),

                // Количество книг и куратор
                Row(
                  children: [
                    Icon(
                      Icons.book_rounded,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${widget.collection.booksCount} книг',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.collection.curator,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.collection.description,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Бейдж типа подборки
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getCollectionTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForCollectionType(),
                  size: 12,
                  color: _getCollectionTypeColor(),
                ),
                SizedBox(width: 4),
                Text(
                  _getTypeLabel(widget.collection.type),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getCollectionTypeColor(),
                  ),
                ),
              ],
            ),
          ),

          // Рейтинг и количество сохранений
          Row(
            children: [
              Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
              SizedBox(width: 4),
              Text(
                widget.collection.rating.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.favorite_rounded, size: 14, color: Colors.red[300]),
              SizedBox(width: 4),
              Text(
                '${widget.collection.savesCount}',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[300],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 48, // чуть больше, чтобы текст не резался
        child: _isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: _toggleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved
                      ? AppColors.textLight
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      // исправление тут
                      child: Text(
                        _isSaved ? 'В избранном' : 'Сохранить подборку',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // на всякий случай
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Color _getCollectionTypeColor() {
    switch (widget.collection.type) {
      case 'featured':
        return AppColors.warning;
      case 'popular':
        return AppColors.success;
      case 'new':
        return AppColors.accent;
      case 'thematic':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForCollectionType() {
    switch (widget.collection.type) {
      case 'featured':
        return Icons.star_rounded;
      case 'popular':
        return Icons.trending_up_rounded;
      case 'new':
        return Icons.new_releases_rounded;
      case 'thematic':
        return Icons.category_rounded;
      default:
        return Icons.collections_bookmark_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'featured':
        return 'Рекомендуемая';
      case 'popular':
        return 'Популярная';
      case 'new':
        return 'Новинки';
      case 'thematic':
        return 'Тематическая';
      default:
        return 'Подборка';
    }
  }
}

// Пример использования в main.dart:
/*
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookCollectionsProvider()),
      ],
      child: MaterialApp(
        title: 'Book Collections',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: BookCollectionsScreen(),
      ),
    ),
  );
}
*/
