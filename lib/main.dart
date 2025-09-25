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
import 'screens/main_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/news_feed_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/book_exchange_screen.dart';
import 'screens/quote_capture_screen.dart';
import 'screens/reading_challenges_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
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
      ],
      child: MaterialApp(
        title: 'Уютный Книжный Магазин',
        theme: getAppTheme(),
        home: MainScreen(),
        routes: {
          '/cart': (context) => CartScreen(),
          '/news_feed': (context) => NewsFeedScreen(),
          '/auth': (context) => AuthScreen(),
          '/book_exchange': (context) => BookExchangeScreen(),
          '/quote_capture': (context) => QuoteCaptureScreen(),
          '/reading_challenges': (context) => ReadingChallengesScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
