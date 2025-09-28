import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/clubs_provider.dart';
import '../providers/auth_provider.dart';
import '../models/club.dart';
import '../utils/app_utils.dart';
import '../utils/cached_image_widget.dart';
import '../theme/app_theme.dart';
import 'reading_challenges_screen.dart';
import 'club_detail_screen.dart';

class ClubsScreen extends StatefulWidget {
  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClubsProvider>().loadClubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Сообщества',
          style: GoogleFonts.montserrat(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.onSurface),
            onPressed: () {}, // TODO: Implement search functionality
          ),
        ],
      ),
      body: Consumer<ClubsProvider>(
        builder: (context, clubsProvider, child) {
          if (clubsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Column(
            children: [
              // Enhanced filter tabs
              _buildFilterSection(clubsProvider),

              // Clubs list
              Expanded(
                child: clubsProvider.clubs.isEmpty
                    ? _buildEmptyState()
                    : _buildClubsList(clubsProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReadingChallenges(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReadingChallengesScreen()),
    );
  }

  Widget _buildChallengeCard(
    String title,
    String progressText,
    double progress,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppSpacing.responsive(context, AppSpacing.small),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.all(
        AppSpacing.responsive(context, AppSpacing.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.responsive(context, AppSpacing.small)),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(
                width: AppSpacing.responsive(context, AppSpacing.medium),
              ),
              Text(
                progressText,
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ClubsProvider clubsProvider) {
    return Container(
      height: ResponsiveUtils.responsiveSize(context, 60),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.responsive(context, AppSpacing.large),
        vertical: AppSpacing.responsive(context, AppSpacing.small),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', 'Все сообщества', clubsProvider),
          _buildFilterChip('book', 'Книжные', clubsProvider),
          _buildFilterChip('coffee', 'Кофейные', clubsProvider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String type,
    String label,
    ClubsProvider clubsProvider,
  ) {
    final isSelected = clubsProvider.selectedType == type;

    return Padding(
      padding: EdgeInsets.only(
        right: AppSpacing.responsive(context, AppSpacing.medium),
      ),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textLight,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => clubsProvider.setType(type),
        selectedColor: AppColors.primary.withOpacity(0.15),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.responsive(context, AppSpacing.large),
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.responsive(context, AppSpacing.medium),
          vertical: AppSpacing.responsive(context, AppSpacing.small),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'coffee':
        return Icons.local_cafe_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Widget _buildClubsList(ClubsProvider clubsProvider) {
    return RefreshIndicator(
      onRefresh: () => clubsProvider.loadClubs(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.responsive(context, AppSpacing.large),
          vertical: AppSpacing.responsive(context, AppSpacing.medium),
        ),
        itemCount: clubsProvider.clubs.length,
        itemBuilder: (context, index) {
          final club = clubsProvider.clubs[index];
          return ClubCard(club: club);
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
            padding: EdgeInsets.all(
              AppSpacing.responsive(context, AppSpacing.large),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_rounded,
              size: ResponsiveUtils.responsiveIconSize(context, 64),
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.responsive(context, AppSpacing.large)),
          Text(
            'Сообщества не найдены',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 22),
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.responsive(context, AppSpacing.small)),
          Text(
            'Попробуйте изменить фильтры поиска',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.responsive(context, AppSpacing.large)),
          OutlinedButton(
            onPressed: () {
              context.read<ClubsProvider>().setType('all');
            },
            child: Text('Показать все сообщества'),
          ),
        ],
      ),
    );
  }
}

class ClubCard extends StatefulWidget {
  final Club club;

  const ClubCard({Key? key, required this.club}) : super(key: key);

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  bool _isJoined = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    final clubsProvider = context.read<ClubsProvider>();
    final isMember = await clubsProvider.isUserMember(widget.club.id);
    if (mounted) {
      setState(() {
        _isJoined = isMember;
      });
    }
  }

  Future<void> _toggleMembership() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final clubsProvider = context.read<ClubsProvider>();
    bool success;

    if (_isJoined) {
      success = await clubsProvider.leaveClub(widget.club.id);
    } else {
      success = await clubsProvider.joinClub(widget.club.id);
    }

    if (mounted) {
      if (success) {
        setState(() {
          _isJoined = !_isJoined;
        });

        AppUtils.showSuccessSnackBar(
          context,
          _isJoined
              ? 'Вы присоединились к сообществу "${widget.club.title}"'
              : 'Вы покинули сообщество "${widget.club.title}"',
        );
      } else {
        AppUtils.showErrorSnackBar(
          context,
          'Ошибка при ${_isJoined ? 'покидании' : 'присоединении к'} сообществу',
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
      margin: EdgeInsets.only(
        bottom: AppSpacing.responsive(context, AppSpacing.medium),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppSpacing.responsive(context, AppSpacing.small),
        ),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.club.imageUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      AppSpacing.responsive(context, AppSpacing.small),
                    ),
                    topRight: Radius.circular(
                      AppSpacing.responsive(context, AppSpacing.small),
                    ),
                  ),
                  child: CachedImageWidget(
                    imageUrl: widget.club.imageUrl!,
                    width: double.infinity,
                    height: ResponsiveUtils.responsiveSize(context, 140),
                    fit: BoxFit.cover,
                  ),
                ),
                if (_isJoined)
                  Positioned(
                    top: AppSpacing.responsive(context, AppSpacing.small),
                    right: AppSpacing.responsive(context, AppSpacing.small),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.responsive(
                          context,
                          AppSpacing.medium,
                        ),
                        vertical: AppSpacing.responsive(
                          context,
                          AppSpacing.extraSmall,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: _getClubTypeColor(),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.responsive(context, AppSpacing.large),
                        ),
                      ),
                      child: Text(
                        'Участник',
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            12,
                          ),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          else
            Container(
              height: ResponsiveUtils.responsiveSize(context, 140),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getClubTypeColor().withOpacity(0.15),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    AppSpacing.responsive(context, AppSpacing.small),
                  ),
                  topRight: Radius.circular(
                    AppSpacing.responsive(context, AppSpacing.small),
                  ),
                ),
              ),
              child: Icon(
                _getIconForClubType(),
                color: _getClubTypeColor(),
                size: ResponsiveUtils.responsiveIconSize(context, 48),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(
              AppSpacing.responsive(context, AppSpacing.medium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.club.title,
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(
                  height: AppSpacing.responsive(context, AppSpacing.small),
                ),
                Text(
                  widget.club.description,
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: AppSpacing.responsive(context, AppSpacing.medium),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: ResponsiveUtils.responsiveIconSize(context, 16),
                          color: AppColors.textLight,
                        ),
                        SizedBox(
                          width: AppSpacing.responsive(
                            context,
                            AppSpacing.extraSmall,
                          ),
                        ),
                        Text(
                          '${widget.club.membersCount}',
                          style: GoogleFonts.montserrat(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              14,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: AppSpacing.responsive(context, AppSpacing.large),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: ResponsiveUtils.responsiveIconSize(context, 16),
                          color: AppColors.textLight,
                        ),
                        SizedBox(
                          width: AppSpacing.responsive(
                            context,
                            AppSpacing.extraSmall,
                          ),
                        ),
                        Text(
                          '56', // TODO: Replace with widget.club.commentsCount if added to model
                          style: GoogleFonts.montserrat(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              14,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: AppSpacing.responsive(context, AppSpacing.large),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: ResponsiveUtils.responsiveIconSize(context, 16),
                          color: AppColors.textLight,
                        ),
                        SizedBox(
                          width: AppSpacing.responsive(
                            context,
                            AppSpacing.extraSmall,
                          ),
                        ),
                        Text(
                          '7', // TODO: Replace with widget.club.eventsCount if added to model
                          style: GoogleFonts.montserrat(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              14,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: AppSpacing.responsive(context, AppSpacing.large),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: ResponsiveUtils.responsiveIconSize(context, 10),
                          color: AppColors.success,
                        ),
                        SizedBox(
                          width: AppSpacing.responsive(
                            context,
                            AppSpacing.extraSmall,
                          ),
                        ),
                        Text(
                          '${widget.club.onlineCount} онлайн',
                          style: GoogleFonts.montserrat(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              14,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSpacing.responsive(context, AppSpacing.small),
                ),
                Text(
                  '2 часа назад: Мастер-класс по латте-арту', // TODO: Replace with widget.club.lastActivity if added to model
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 13),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(
                  height: AppSpacing.responsive(context, AppSpacing.medium),
                ),
                if (_isLoading)
                  Center(
                    child: SizedBox(
                      width: ResponsiveUtils.responsiveSize(context, 20),
                      height: ResponsiveUtils.responsiveSize(context, 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (_isJoined)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ClubDetailScreen(club: widget.club),
                              ),
                            );
                          },
                          child: Text('Подробнее'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: AppColors.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.responsive(
                                  context,
                                  AppSpacing.small,
                                ),
                              ),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.responsive(
                                context,
                                AppSpacing.small,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: AppSpacing.responsive(
                          context,
                          AppSpacing.medium,
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: _toggleMembership,
                          child: Text('Выйти'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red, // Changed to red
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.responsive(
                                  context,
                                  AppSpacing.small,
                                ),
                              ),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.responsive(
                                context,
                                AppSpacing.small,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClubDetailScreen(club: widget.club),
                        ),
                      );
                    },
                    child: Text('Присоединиться'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.responsive(context, AppSpacing.small),
                        ),
                      ),
                      elevation: 0,
                      minimumSize: Size(
                        double.infinity,
                        ResponsiveUtils.responsiveSize(context, 44),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getClubTypeColor() {
    switch (widget.club.type) {
      case 'book':
        return Color(0xFF8C6A4B); // Coffee brown
      case 'coffee':
        return Color(0xFFCD9F68); // Coffee gold
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForClubType() {
    switch (widget.club.type) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'coffee':
        return Icons.local_cafe_rounded;
      default:
        return Icons.group_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'book':
        return 'Книжный';
      case 'coffee':
        return 'Кофейный';
      default:
        return 'Общий';
    }
  }
}
