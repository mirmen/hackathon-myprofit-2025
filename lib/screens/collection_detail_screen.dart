import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';
import '../widgets/product_card.dart';

class CollectionDetailScreen extends StatefulWidget {
  final String collectionName;
  final String collectionType; // 'books' or 'coffee'

  const CollectionDetailScreen({
    Key? key,
    required this.collectionName,
    required this.collectionType,
  }) : super(key: key);

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  // Mock data for genre collections
  final Map<String, List<Map<String, dynamic>>> _mockCollections = {
    'Фэнтези': [
      {
        'id': 'fantasy_1',
        'title': 'Властелин колец',
        'author': 'Дж. Р. Р. Толкин',
        'type': 'Книги',
        'price': 1200.0,
        'rating': 4.9,
        'imageUrl': '',
        'description':
            'Эпическая сага о путешествии хоббита Фродо, который должен уничтожить Кольцо Всевластия.',
      },
      {
        'id': 'fantasy_2',
        'title': 'Гарри Поттер и философский камень',
        'author': 'Дж. К. Роулинг',
        'type': 'Книги',
        'price': 850.0,
        'rating': 4.8,
        'imageUrl': '',
        'description':
            'История о юном волшебнике, который узнает о своем призвании в школе чародейства Хогвартс.',
      },
      {
        'id': 'fantasy_3',
        'title': 'Игра престолов',
        'author': 'Джордж Мартин',
        'type': 'Книги',
        'price': 1100.0,
        'rating': 4.7,
        'imageUrl': '',
        'description':
            'Первая книга в серии "Песнь Льда и Огня", полная интриг, битв и предательств.',
      },
      {
        'id': 'fantasy_4',
        'title': 'Хроники Нарнии',
        'author': 'Клайв Льюис',
        'type': 'Книги',
        'price': 950.0,
        'rating': 4.6,
        'imageUrl': '',
        'description':
            'Семь книг о волшебной стране Нарнии и приключениях детей, попавших туда.',
      },
      {
        'id': 'fantasy_5',
        'title': 'Американские боги',
        'author': 'Нил Гейман',
        'type': 'Книги',
        'price': 780.0,
        'rating': 4.5,
        'imageUrl': '',
        'description':
            'Роман о столкновении древних богов со своими современными аналогами.',
      },
      {
        'id': 'fantasy_6',
        'title': 'Ночь дракона',
        'author': 'Маргарет Вейс',
        'type': 'Книги',
        'price': 690.0,
        'rating': 4.4,
        'imageUrl': '',
        'description': 'Первая книга из серии "Хроники Драконьих Яйцекрадов".',
      },
      {
        'id': 'fantasy_7',
        'title': 'Эрагон',
        'author': 'Кристофер Паолини',
        'type': 'Книги',
        'price': 820.0,
        'rating': 4.3,
        'imageUrl': '',
        'description':
            'Первая книга из серии "Наследие", о юном всаднике дракона.',
      },
      {
        'id': 'fantasy_8',
        'title': 'Мастер и Маргарита',
        'author': 'Михаил Булгаков',
        'type': 'Книги',
        'price': 750.0,
        'rating': 4.9,
        'imageUrl': '',
        'description':
            'Роман о дьяволе, который посещает атеистический Советский Союз.',
      },
      {
        'id': 'fantasy_9',
        'title': 'Сияние',
        'author': 'Стивен Кинг',
        'type': 'Книги',
        'price': 900.0,
        'rating': 4.6,
        'imageUrl': '',
        'description':
            'Ужасающая история о писателе, который становится зимним смотрителем отеля.',
      },
      {
        'id': 'fantasy_10',
        'title': 'Ведьмак. Последнее желание',
        'author': 'Анджей Сапковский',
        'type': 'Книги',
        'price': 880.0,
        'rating': 4.7,
        'imageUrl': '',
        'description': 'Первая книга из цикла о ведьмаке Геральте из Ривии.',
      },
    ],
    'Детективы': [
      {
        'id': 'detective_1',
        'title': 'Шерлок Холмс. Полное собрание',
        'author': 'Артур Конан Дойл',
        'type': 'Книги',
        'price': 1500.0,
        'rating': 4.8,
        'imageUrl': '',
        'description':
            'Классические детективы о великом сыщике Шерлоке Холмсе и его верном друге докторе Ватсоне.',
      },
      {
        'id': 'detective_2',
        'title': 'Убийство в Восточном экспрессе',
        'author': 'Агата Кристи',
        'type': 'Книги',
        'price': 650.0,
        'rating': 4.7,
        'imageUrl': '',
        'description':
            'Детектив о загадочном убийстве в поезде, расследование ведет Эркюль Пуаро.',
      },
      {
        'id': 'detective_3',
        'title': 'Девушка с татуировкой дракона',
        'author': 'Стиг Ларссон',
        'type': 'Книги',
        'price': 720.0,
        'rating': 4.5,
        'imageUrl': '',
        'description':
            'Первая книга трилогии Миллениума о журналистке и хакере.',
      },
      {
        'id': 'detective_4',
        'title': 'Десять негритят',
        'author': 'Агата Кристи',
        'type': 'Книги',
        'price': 580.0,
        'rating': 4.6,
        'imageUrl': '',
        'description':
            'Классический детектив о десяти людях, оказавшихся на острове.',
      },
      {
        'id': 'detective_5',
        'title': 'Имя розы',
        'author': 'Умберто Эко',
        'type': 'Книги',
        'price': 890.0,
        'rating': 4.4,
        'imageUrl': '',
        'description':
            'Исторический детектив о монахе-францисканце в итальянском монастыре XIV века.',
      },
      {
        'id': 'detective_6',
        'title': 'Мальтийский сокол',
        'author': 'Дэш Хэммет',
        'type': 'Книги',
        'price': 670.0,
        'rating': 4.3,
        'imageUrl': '',
        'description': 'Классический детектив о частном детективе Сэме Спэйде.',
      },
      {
        'id': 'detective_7',
        'title': 'Убийство по алфавиту',
        'author': 'Агата Кристи',
        'type': 'Книги',
        'price': 710.0,
        'rating': 4.5,
        'imageUrl': '',
        'description': 'Детектив о серии убийств, следующих по алфавиту.',
      },
      {
        'id': 'detective_8',
        'title': 'Благие знамения',
        'author': 'Терри Пратчетт, Нил Гейман',
        'type': 'Книги',
        'price': 790.0,
        'rating': 4.6,
        'imageUrl': '',
        'description':
            'Юмористический детектив о конце света и ангеле с демоном.',
      },
      {
        'id': 'detective_9',
        'title': 'Приключения Шерлока Холмса',
        'author': 'Артур Конан Дойл',
        'type': 'Книги',
        'price': 920.0,
        'rating': 4.7,
        'imageUrl': '',
        'description': 'Сборник классических детективов о великом сыщике.',
      },
      {
        'id': 'detective_10',
        'title': 'Тень ветра',
        'author': 'Карлос Руис Сафон',
        'type': 'Книги',
        'price': 840.0,
        'rating': 4.8,
        'imageUrl': '',
        'description':
            'История о юном человеке, который ищет автора таинственной книги.',
      },
    ],
    'Классика': [
      {
        'id': 'classic_1',
        'title': 'Преступление и наказание',
        'author': 'Федор Достоевский',
        'type': 'Книги',
        'price': 750.0,
        'rating': 4.9,
        'imageUrl': '',
        'description':
            'Роман о молодом студенте Раскольникове, совершившем убийство.',
      },
      {
        'id': 'classic_2',
        'title': 'Война и мир',
        'author': 'Лев Толстой',
        'type': 'Книги',
        'price': 1200.0,
        'rating': 4.8,
        'imageUrl': '',
        'description': 'Эпический роман о России в эпоху Наполеоновских войн.',
      },
      {
        'id': 'classic_3',
        'title': 'Анна Каренина',
        'author': 'Лев Толстой',
        'type': 'Книги',
        'price': 890.0,
        'rating': 4.7,
        'imageUrl': '',
        'description': 'Роман о женщине, которая бросает семью ради любви.',
      },
      {
        'id': 'classic_4',
        'title': 'Мастер и Маргарита',
        'author': 'Михаил Булгаков',
        'type': 'Книги',
        'price': 780.0,
        'rating': 4.9,
        'imageUrl': '',
        'description':
            'Роман о дьяволе, который посещает атеистический Советский Союз.',
      },
      {
        'id': 'classic_5',
        'title': 'Евгений Онегин',
        'author': 'Александр Пушкин',
        'type': 'Книги',
        'price': 560.0,
        'rating': 4.6,
        'imageUrl': '',
        'description':
            'Роман в стихах о молодом дворянине и его любви к Татьяне.',
      },
      {
        'id': 'classic_6',
        'title': 'Отцы и дети',
        'author': 'Иван Тургенев',
        'type': 'Книги',
        'price': 620.0,
        'rating': 4.5,
        'imageUrl': '',
        'description': 'Роман о конфликте между поколениями в России XIX века.',
      },
      {
        'id': 'classic_7',
        'title': 'Обломов',
        'author': 'Иван Гончаров',
        'type': 'Книги',
        'price': 680.0,
        'rating': 4.4,
        'imageUrl': '',
        'description':
            'Роман о дворянине, который не может преодолеть свою лень.',
      },
      {
        'id': 'classic_8',
        'title': 'Мертвые души',
        'author': 'Николай Гоголь',
        'type': 'Книги',
        'price': 710.0,
        'rating': 4.7,
        'imageUrl': '',
        'description': 'Поэма о Чичикове, который покупает "мертвые души".',
      },
      {
        'id': 'classic_9',
        'title': 'Герой нашего времени',
        'author': 'Михаил Лермонтов',
        'type': 'Книги',
        'price': 590.0,
        'rating': 4.5,
        'imageUrl': '',
        'description':
            'Роман о молодом офицере Печорине и его психологическом портрете.',
      },
      {
        'id': 'classic_10',
        'title': 'Тихий Дон',
        'author': 'Михаил Шолохов',
        'type': 'Книги',
        'price': 950.0,
        'rating': 4.6,
        'imageUrl': '',
        'description':
            'Эпический роман о казаках в годы Первой мировой и Гражданской войн.',
      },
    ],
    'Кофе': [
      {
        'id': 'coffee_1',
        'title': 'Эфиопия Иргачиф',
        'author': 'для эспрессо',
        'type': 'Кофе',
        'price': 650.0,
        'rating': 4.7,
        'imageUrl': '',
        'description':
            'Сладкий кофе с нотами тёмных ягод, цитрусов и молочного шоколада.',
      },
      {
        'id': 'coffee_2',
        'title': 'Колумбия Супремо',
        'author': 'для фильтра',
        'type': 'Кофе',
        'price': 720.0,
        'rating': 4.6,
        'imageUrl': '',
        'description':
            'Сбалансированный кофе с нотами орехов, какао и фруктов.',
      },
      {
        'id': 'coffee_3',
        'title': 'Гватемала Антигуа',
        'author': 'для турки',
        'type': 'Кофе',
        'price': 680.0,
        'rating': 4.5,
        'imageUrl': '',
        'description': 'Полный тела кофе с нотами шоколада, специй и цветов.',
      },
      {
        'id': 'coffee_4',
        'title': 'Бразилия Санто-Антонио',
        'author': 'для капучино',
        'type': 'Кофе',
        'price': 590.0,
        'rating': 4.4,
        'imageUrl': '',
        'description': 'Гладкий кофе с нотами орехов, карамели и какао.',
      },
      {
        'id': 'coffee_5',
        'title': 'Кения АА',
        'author': 'для френч-пресса',
        'type': 'Кофе',
        'price': 820.0,
        'rating': 4.8,
        'imageUrl': '',
        'description':
            'Яркий кофе с нотами чёрной смородины, винограда и лимона.',
      },
      {
        'id': 'coffee_6',
        'title': 'Коста-Рика Тарразу',
        'author': 'для мокко',
        'type': 'Кофе',
        'price': 750.0,
        'rating': 4.5,
        'imageUrl': '',
        'description': 'Сладкий кофе с нотами карамели, фруктов и цветов.',
      },
      {
        'id': 'coffee_7',
        'title': 'Йемен Моха',
        'author': 'для турки',
        'type': 'Кофе',
        'price': 890.0,
        'rating': 4.6,
        'imageUrl': '',
        'description': 'Редкий кофе с нотами вина, шоколада и специй.',
      },
      {
        'id': 'coffee_8',
        'title': 'Гондурас Маркаль',
        'author': 'для эспрессо',
        'type': 'Кофе',
        'price': 630.0,
        'rating': 4.3,
        'imageUrl': '',
        'description':
            'Сбалансированный кофе с нотами орехов, какао и фруктов.',
      },
      {
        'id': 'coffee_9',
        'title': 'Перу Чикко',
        'author': 'для фильтра',
        'type': 'Кофе',
        'price': 710.0,
        'rating': 4.4,
        'imageUrl': '',
        'description': 'Яркий кофе с нотами ягод, цитрусов и карамели.',
      },
      {
        'id': 'coffee_10',
        'title': 'Гватемала Файн',
        'author': 'для капучино',
        'type': 'Кофе',
        'price': 780.0,
        'rating': 4.7,
        'imageUrl': '',
        'description': 'Полный тела кофе с нотами шоколада, специй и цветов.',
      },
    ],
  };

  List<Product> _getCollectionProducts() {
    final collectionData = _mockCollections[widget.collectionName] ?? [];

    return collectionData.map((item) {
      return Product(
        id: item['id'],
        title: item['title'],
        author: item['author'],
        type: item['type'],
        price: item['price'],
        rating: item['rating'],
        imageUrl: item['imageUrl'],
        description: item['description'],
        options: item['options'] ?? ['Стандарт (250г)', 'Большой (500г)'],
        isBook: item['type'] == 'Книги',
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _getCollectionProducts();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                  AppSpacing.responsive(context, AppSpacing.large),
                ),
                child: Text(
                  'Топ-10 ${widget.collectionType == 'books' ? 'книг' : 'сортов кофе'} в жанре "${widget.collectionName}"',
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.widthPercentage(context, 5),
              ),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getProductColumnCount(),
                  crossAxisSpacing: ResponsiveUtils.widthPercentage(context, 4),
                  mainAxisSpacing: ResponsiveUtils.heightPercentage(context, 2),
                  childAspectRatio:
                      0.83, // Адаптивное соотношение для гибких карточек
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: ResponsiveUtils.getAppBarHeight(context),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.onSurface,
          size: ResponsiveUtils.responsiveIconSize(context, 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: Padding(
        padding: ResponsiveUtils.getResponsivePadding(
          context,
          horizontal: AppSpacing.responsive(context, AppSpacing.medium),
          vertical: ResponsiveUtils.heightPercentage(context, 2),
        ),
        child: Row(
          children: [
            // Add spacing to account for the back button
            SizedBox(width: ResponsiveUtils.responsiveIconSize(context, 30)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.collectionName,
                    style: GoogleFonts.montserrat(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.heightPercentage(context, 1),
                  ),
                  Text(
                    'Подборка топ-10',
                    style: GoogleFonts.montserrat(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getProductColumnCount() {
    final mediaQuery = MediaQuery.of(context);
    final deviceWidth = mediaQuery.size.width;

    if (deviceWidth < 360) {
      return 1; // Very small screens
    } else if (deviceWidth < 600) {
      return 2; // Small to medium screens
    } else if (deviceWidth < 900) {
      return 3; // Tablets
    } else {
      return 4; // Large screens
    }
  }
}
