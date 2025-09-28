import 'package:coffeebook/screens/my_books_screen.dart';
import 'package:coffeebook/screens/quotes_screen.dart';
import 'package:coffeebook/screens/help_support_screen.dart';
import 'package:coffeebook/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  TextEditingController _statusController = TextEditingController();
  bool _isEditingStatus = false;
  String _userStatus = 'Люблю книги и кофе';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<UserProvider>().loadUserProfile();
      }
    });
    _statusController.text = _userStatus;
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  String? _avatarUrlFor(dynamic user) {
    try {
      final avatar = user.avatarUrl;
      if (avatar != null && avatar.toString().isNotEmpty)
        return avatar.toString();
      final email = (user.email ?? '').toString().trim().toLowerCase();
      if (email.isEmpty) return null;
      final bytes = utf8.encode(email);
      final hash = md5.convert(bytes).toString();
      return 'https://www.gravatar.com/avatar/$hash?s=200&d=identicon';
    } catch (e) {
      return null;
    }
  }

  void _saveStatus() {
    setState(() {
      _userStatus = _statusController.text.isNotEmpty
          ? _statusController.text
          : 'Люблю книги и кофе';
      _isEditingStatus = false;
    });
  }

  void _cancelEditing() {
    setState(() {
      _statusController.text = _userStatus;
      _isEditingStatus = false;
    });
  }

  int _getBestStreak(dynamic user) {
    try {
      if (user.bestStreak != null) return user.bestStreak;
      final currentStreak = user.currentStreak ?? 0;
      return currentStreak + 5;
    } catch (e) {
      return 12;
    }
  }

  // Адаптивный размер QR-кода
  double _getQrSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 350 ? 140 : 180;
  }

  // Адаптивный отступ
  double _getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 350 ? 12 : 16;
  }

  // Адаптивный размер шрифта для баллов
  double _getBonusPointsFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 350 ? 56 : 72;
  }

  void _showBonusCardDialog(
    BuildContext context,
    String email,
    int bonusPoints,
    String name,
    DateTime memberSince,
  ) {
    final width = MediaQuery.of(context).size.width; // Добавьте эту строку
    final qrSize = _getQrSize(context);
    final padding = _getPadding(context);
    final isSmallScreen = width < 350; // Добавьте эту строку

    final userData = {
      'user_email': email,
      'user_name': name,
      'bonus_points': bonusPoints,
      'member_since': memberSince.toIso8601String(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'app': 'BookApp',
    };
    final jsonData = json.encode(userData);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(padding),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              AppSpacing.responsive(context, AppSpacing.large),
            ),
          ),
          padding: EdgeInsets.all(padding * 1.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ваш QR-код',
                style: GoogleFonts.manrope(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    isSmallScreen ? 18 : 20,
                  ), // Используем isSmallScreen
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: padding),

              Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(
                    AppSpacing.responsive(context, AppSpacing.medium),
                  ),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: SizedBox(
                  width: qrSize,
                  height: qrSize,
                  child: PrettyQrView.data(
                    data: jsonData,
                    decoration: PrettyQrDecoration(
                      shape: PrettyQrSmoothSymbol(color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              SizedBox(height: padding),
              Text(
                '$bonusPoints бонусных баллов',
                style: GoogleFonts.manrope(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    isSmallScreen ? 14 : 16,
                  ), // Используем isSmallScreen
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padding / 2),
              Text(
                name,
                style: GoogleFonts.manrope(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    isSmallScreen ? 12 : 14,
                  ), // Используем isSmallScreen
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                email,
                style: GoogleFonts.manrope(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    isSmallScreen ? 10 : 12,
                  ), // Используем isSmallScreen
                  color: AppColors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'Участник с ${_formatDate(memberSince)}',
                style: GoogleFonts.manrope(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    isSmallScreen ? 9 : 11,
                  ), // Используем isSmallScreen
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padding * 1.25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(
                      ResponsiveUtils.getButtonHeight(context, size: 'medium'),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.responsive(context, AppSpacing.small),
                      ),
                    ),
                  ),
                  child: Text(
                    'Закрыть',
                    style: GoogleFonts.manrope(
                      fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        isSmallScreen ? 14 : 16,
                      ), // Используем isSmallScreen
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final width = MediaQuery.of(context).size.width;
    final padding = _getPadding(context);
    final isSmallScreen = width < 350;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          'Профиль',
          style: GoogleFonts.manrope(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              isSmallScreen ? 16 : 18,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Ошибка загрузки профиля'));
          }

          final bestStreak = _getBestStreak(user);
          final currentStreak = user.currentStreak ?? 0;
          final bonusPoints = user.bonusPoints ?? 0;
          final bonusPointsGoal = user.bonusPointsGoal ?? 100;
          final bonusProgress = user.bonusProgress ?? 0.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600, // Максимальная ширина контента
                ),
                child: Column(
                  children: [
                    // Профиль с аватаркой слева
                    Card(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.responsive(context, AppSpacing.medium),
                        ),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: EdgeInsets.all(
                          isSmallScreen
                              ? AppSpacing.responsive(
                                  context,
                                  AppSpacing.medium,
                                )
                              : AppSpacing.responsive(
                                  context,
                                  AppSpacing.large,
                                ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Аватарка
                            Builder(
                              builder: (_) {
                                final avatarUrl = _avatarUrlFor(user);
                                return CircleAvatar(
                                  radius: isSmallScreen ? 32 : 40,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.1),
                                  backgroundImage: avatarUrl != null
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  child: avatarUrl == null
                                      ? Text(
                                          user.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : 'U',
                                          style: GoogleFonts.manrope(
                                            fontSize:
                                                ResponsiveUtils.responsiveFontSize(
                                                  context,
                                                  isSmallScreen ? 20 : 28,
                                                ),
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                            SizedBox(
                              width: isSmallScreen
                                  ? AppSpacing.responsive(
                                      context,
                                      AppSpacing.small,
                                    )
                                  : AppSpacing.responsive(
                                      context,
                                      AppSpacing.medium,
                                    ),
                            ),

                            // Информация о пользователе
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: GoogleFonts.manrope(
                                      fontSize:
                                          ResponsiveUtils.responsiveFontSize(
                                            context,
                                            isSmallScreen ? 16 : 20,
                                          ),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: GoogleFonts.manrope(
                                      fontSize:
                                          ResponsiveUtils.responsiveFontSize(
                                            context,
                                            isSmallScreen ? 12 : 14,
                                          ),
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.onSurface.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),

                                  // Статус пользователя
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingStatus = true;
                                      });
                                    },
                                    child: _isEditingStatus
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextField(
                                                controller: _statusController,
                                                style: GoogleFonts.manrope(
                                                  fontSize:
                                                      ResponsiveUtils.responsiveFontSize(
                                                        context,
                                                        isSmallScreen ? 12 : 14,
                                                      ),
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.primary,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Напишите свой статус...',
                                                  hintStyle: GoogleFonts.manrope(
                                                    fontSize:
                                                        ResponsiveUtils.responsiveFontSize(
                                                          context,
                                                          isSmallScreen
                                                              ? 12
                                                              : 14,
                                                        ),
                                                    color: AppColors.onSurface
                                                        .withOpacity(0.5),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppSpacing.responsive(
                                                            context,
                                                            AppSpacing.small,
                                                          ),
                                                        ),
                                                    borderSide:
                                                        const BorderSide(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppSpacing.responsive(
                                                            context,
                                                            AppSpacing.small,
                                                          ),
                                                        ),
                                                    borderSide:
                                                        const BorderSide(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                ),
                                                maxLength: 50,
                                              ),
                                              SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: _saveStatus,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            isSmallScreen
                                                            ? AppSpacing.responsive(
                                                                context,
                                                                AppSpacing
                                                                    .small,
                                                              )
                                                            : AppSpacing.responsive(
                                                                context,
                                                                AppSpacing
                                                                    .medium,
                                                              ),
                                                        vertical:
                                                            AppSpacing.responsive(
                                                              context,
                                                              AppSpacing
                                                                  .extraSmall,
                                                            ),
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppSpacing.responsive(
                                                                context,
                                                                AppSpacing
                                                                    .small,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Сохранить',
                                                      style: GoogleFonts.manrope(
                                                        fontSize:
                                                            ResponsiveUtils.responsiveFontSize(
                                                              context,
                                                              isSmallScreen
                                                                  ? 10
                                                                  : 12,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  TextButton(
                                                    onPressed: _cancelEditing,
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            isSmallScreen
                                                            ? AppSpacing.responsive(
                                                                context,
                                                                AppSpacing
                                                                    .small,
                                                              )
                                                            : AppSpacing.responsive(
                                                                context,
                                                                AppSpacing
                                                                    .medium,
                                                              ),
                                                        vertical:
                                                            AppSpacing.responsive(
                                                              context,
                                                              AppSpacing
                                                                  .extraSmall,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Отмена',
                                                      style: GoogleFonts.manrope(
                                                        fontSize:
                                                            ResponsiveUtils.responsiveFontSize(
                                                              context,
                                                              isSmallScreen
                                                                  ? 10
                                                                  : 12,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .onSurface
                                                            .withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _userStatus,
                                                  style: GoogleFonts.manrope(
                                                    fontSize:
                                                        ResponsiveUtils.responsiveFontSize(
                                                          context,
                                                          isSmallScreen
                                                              ? 12
                                                              : 14,
                                                        ),
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.primary,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons.edit,
                                                size:
                                                    ResponsiveUtils.responsiveIconSize(
                                                      context,
                                                      isSmallScreen ? 14 : 16,
                                                    ),
                                                color: AppColors.onSurface
                                                    .withOpacity(0.5),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: padding),

                    // Кредитная карточка с баллами
                    GestureDetector(
                      onTap: () => _showBonusCardDialog(
                        context,
                        user.email,
                        bonusPoints,
                        user.name,
                        user.memberSince,
                      ),
                      child: Container(
                        height: isSmallScreen ? 160 : 190,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.responsive(context, AppSpacing.medium),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Декоративные элементы
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -30,
                              left: -30,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                            // Контент карточки
                            Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen
                                    ? AppSpacing.responsive(
                                        context,
                                        AppSpacing.medium,
                                      )
                                    : AppSpacing.responsive(
                                        context,
                                        AppSpacing.large,
                                      ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Бонусная карта',
                                        style: GoogleFonts.manrope(
                                          fontSize:
                                              ResponsiveUtils.responsiveFontSize(
                                                context,
                                                isSmallScreen ? 12 : 14,
                                              ),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        Icons.qr_code,
                                        color: Colors.white.withOpacity(0.8),
                                        size:
                                            ResponsiveUtils.responsiveIconSize(
                                              context,
                                              isSmallScreen ? 18 : 20,
                                            ),
                                      ),
                                    ],
                                  ),

                                  // Основной контент с баллами
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              '$bonusPoints',
                                              style: GoogleFonts.manrope(
                                                fontSize:
                                                    _getBonusPointsFontSize(
                                                      context,
                                                    ),
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                height: 0.8,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 0),
                                          Text(
                                            'баллов',
                                            style: GoogleFonts.manrope(
                                              fontSize:
                                                  ResponsiveUtils.responsiveFontSize(
                                                    context,
                                                    isSmallScreen ? 12 : 14,
                                                  ),
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Прогресс-бар и информация об участнике
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 4,
                                        child: LinearProgressIndicator(
                                          value: bonusProgress,
                                          backgroundColor: Colors.white
                                              .withOpacity(0.3),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'До уровня: ${bonusPointsGoal - bonusPoints} баллов',
                                        style: GoogleFonts.manrope(
                                          fontSize:
                                              ResponsiveUtils.responsiveFontSize(
                                                context,
                                                isSmallScreen ? 8 : 10,
                                              ),
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Участник с ${_formatDate(user.memberSince)}',
                                        style: GoogleFonts.manrope(
                                          fontSize:
                                              ResponsiveUtils.responsiveFontSize(
                                                context,
                                                isSmallScreen ? 8 : 10,
                                              ),
                                          color: Colors.white.withOpacity(0.7),
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
                    ),

                    SizedBox(height: padding),

                    // Статистика серий
                    Card(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.responsive(context, AppSpacing.medium),
                        ),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen
                              ? AppSpacing.responsive(context, AppSpacing.small)
                              : AppSpacing.responsive(
                                  context,
                                  AppSpacing.medium,
                                ),
                          horizontal: AppSpacing.responsive(
                            context,
                            AppSpacing.small,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              value: '$currentStreak',
                              title: 'Текущая серия',
                              color: AppColors.primary,
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildStatItem(
                              value: '$bestStreak',
                              title: 'Лучшая серия',
                              color: AppColors.warning,
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: padding),

                    // Меню настроек
                    Card(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.responsive(context, AppSpacing.medium),
                        ),
                      ),
                      elevation: 1,
                      child: Column(
                        children: [
                          _buildAdaptiveListTile(
                            icon: Icons.book,
                            title: 'Мои книги',
                            isSmallScreen: isSmallScreen,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyBooksScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildAdaptiveListTile(
                            icon: Icons.camera_alt,
                            title: 'Фото цитат',
                            isSmallScreen: isSmallScreen,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuotesScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: AppColors.primary,
                              size: ResponsiveUtils.responsiveIconSize(
                                context,
                                isSmallScreen ? 20 : 24,
                              ),
                            ),
                            title: Text(
                              'Уведомления',
                              style: GoogleFonts.manrope(
                                fontSize: ResponsiveUtils.responsiveFontSize(
                                  context,
                                  isSmallScreen ? 14 : 16,
                                ),
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface,
                              ),
                            ),
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildAdaptiveListTile(
                            icon: Icons.help,
                            title: 'Помощь и поддержка',
                            isSmallScreen: isSmallScreen,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HelpSupportScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildAdaptiveListTile(
                            icon: Icons.info,
                            title: 'О приложении',
                            isSmallScreen: isSmallScreen,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AboutScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: padding),

                    // Кнопка выхода
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await context.read<AuthProvider>().signOut();
                          context.read<UserProvider>().clearUser();
                          context.read<CartProvider>().loadCart();
                          context.read<FavoritesProvider>().loadFavorites();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: Size.fromHeight(
                            isSmallScreen
                                ? ResponsiveUtils.getButtonHeight(
                                    context,
                                    size: 'small',
                                  )
                                : ResponsiveUtils.getButtonHeight(
                                    context,
                                    size: 'medium',
                                  ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.responsive(context, AppSpacing.small),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen
                                ? AppSpacing.responsive(
                                    context,
                                    AppSpacing.small,
                                  )
                                : AppSpacing.responsive(
                                    context,
                                    AppSpacing.medium,
                                  ),
                            vertical: isSmallScreen
                                ? AppSpacing.responsive(
                                    context,
                                    AppSpacing.small,
                                  )
                                : AppSpacing.responsive(
                                    context,
                                    AppSpacing.small,
                                  ),
                          ),
                        ),
                        icon: Icon(
                          Icons.logout,
                          size: ResponsiveUtils.responsiveIconSize(
                            context,
                            isSmallScreen ? 18 : 20,
                          ),
                        ),
                        label: Text(
                          'Выйти',
                          style: GoogleFonts.manrope(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              isSmallScreen ? 14 : 16,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: padding / 2),

                    TextButton(
                      onPressed: () => _showLogoutDialog(context),
                      child: Text(
                        'Дополнительные настройки',
                        style: GoogleFonts.manrope(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            isSmallScreen ? 12 : 14,
                          ),
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdaptiveListTile({
    required IconData icon,
    required String title,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: ResponsiveUtils.responsiveIconSize(
          context,
          isSmallScreen ? 20 : 24,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: ResponsiveUtils.responsiveFontSize(
            context,
            isSmallScreen ? 14 : 16,
          ),
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.primary,
        size: ResponsiveUtils.responsiveIconSize(
          context,
          isSmallScreen ? 18 : 20,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatItem({
    required String value,
    required String title,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.responsive(context, AppSpacing.extraSmall),
          vertical: AppSpacing.responsive(context, AppSpacing.small),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  isSmallScreen ? 20 : 24,
                ),
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(
              height: isSmallScreen
                  ? AppSpacing.responsive(context, AppSpacing.extraSmall)
                  : AppSpacing.responsive(context, AppSpacing.small),
            ),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  isSmallScreen ? 10 : 12,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Выход',
          style: GoogleFonts.manrope(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              MediaQuery.of(context).size.width < 350 ? 16 : 18,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: GoogleFonts.manrope(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              MediaQuery.of(context).size.width < 350 ? 14 : 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: GoogleFonts.manrope(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              context.read<UserProvider>().clearUser();
              context.read<CartProvider>().loadCart();
              context.read<FavoritesProvider>().loadFavorites();
            },
            child: Text(
              'Выйти',
              style: GoogleFonts.manrope(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
