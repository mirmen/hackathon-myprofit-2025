import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/product_provider.dart';
import 'providers/promotions_provider.dart';
import 'providers/subscriptions_provider.dart';
import 'providers/clubs_provider.dart';
import 'providers/user_provider.dart';
import 'providers/book_exchange_provider.dart';
import 'providers/reading_challenges_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/events_provider.dart';
import 'providers/books_provider.dart'; // Added BooksProvider import
import 'providers/quotes_provider.dart';
import 'screens/main_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/news_feed_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/book_exchange_screen.dart';
import 'screens/quote_capture_screen.dart';
import 'screens/quotes_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/about_screen.dart';
import 'screens/club_detail_screen.dart';
import 'screens/collection_detail_screen.dart';
import 'screens/reading_challenges_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/admin_products_screen.dart';
import 'screens/admin_promotions_screen.dart';
import 'screens/admin_clubs_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/category_products_screen.dart';
import 'screens/podborka_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загрузка переменных окружения
  await dotenv.load(fileName: "lib/.env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(BookstoreApp());
}

class BookstoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PromotionsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionsProvider()),
        ChangeNotifierProvider(create: (_) => ClubsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookExchangeProvider()),
        ChangeNotifierProvider(create: (_) => ReadingChallengesProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(
          create: (_) => BooksProvider(),
        ), // Added BooksProvider
        ChangeNotifierProvider(create: (_) => QuotesProvider()),
        ChangeNotifierProvider(create: (_) => BookCollectionsProvider()),
      ],
      child: MaterialApp(
        title: 'Уютный Книжный Магазин',
        theme: getAppTheme(),
        home: MainScreen(),
        routes: {
          '/cart': (context) => CartScreen(),
          '/news_feed': (context) => NewsFeedScreen(),
          '/auth': (context) => AuthScreen(),
          '/admin': (context) => AdminScreen(),
          '/admin/products': (context) => AdminProductsScreen(),
          '/admin/promotions': (context) => AdminPromotionsScreen(),
          '/admin/clubs': (context) => AdminClubsScreen(),
          '/admin/users': (context) => AdminUsersScreen(),
          '/book_exchange': (context) => BookExchangeScreen(),
          '/quote_capture': (context) => QuoteCaptureScreen(),
          '/quotes': (context) => QuotesScreen(),
          '/help_support': (context) => HelpSupportScreen(),
          '/about': (context) => AboutScreen(),
          '/reading_challenges': (context) => ReadingChallengesScreen(),
          '/subscriptions': (context) => SubscriptionScreen(),
          '/collections': (context) => BookCollectionsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
