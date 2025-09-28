import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'clubs_screen.dart';
// import 'news_feed_screen.dart'; // Removed as we're removing the feed tab
import 'profile_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'auth_screen.dart';
import '../utils/app_utils.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Updated screens list without NewsFeedScreen
  final List<Widget> _screens = [
    HomeScreen(),
    ClubsScreen(),
    // NewsFeedScreen(), // Removed
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
      ).then((value) {
        // Принудительная перестройка для обновления UI в зависимости от статуса авторизации
        setState(() {});
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceWidth = mediaQuery.size.width;
    final deviceHeight = mediaQuery.size.height;

    // Calculate responsive bottom nav height
    final bottomNavHeight = ResponsiveUtils.getBottomNavHeight(context);
    final iconSize = ResponsiveUtils.responsiveIconSize(context, 24);
    final labelSize = ResponsiveUtils.responsiveFontSize(context, 12);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: bottomNavHeight,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: deviceWidth * 0.01, // 1% of screen width
              offset: Offset(
                0,
                deviceHeight * -0.005,
              ), // -0.5% of screen height
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: iconSize),
              activeIcon: Icon(Icons.home, size: iconSize),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined, size: iconSize),
              activeIcon: Icon(Icons.auto_stories, size: iconSize),
              label: 'Клубы',
            ),
            // Removed the feed item
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: iconSize),
              activeIcon: Icon(Icons.person, size: iconSize),
              label: 'Профиль',
            ),
          ],
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedFontSize: labelSize,
          unselectedFontSize: labelSize,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF8C6A4B),
          unselectedItemColor: Colors.grey[600],
        ),
      ),
    );
  }
}
