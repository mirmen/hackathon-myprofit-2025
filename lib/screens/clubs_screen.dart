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
          'Клубы',
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(width: 12),
              Text(
                progressText,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
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
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', 'Все', clubsProvider),
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
        onSelected: (_) => clubsProvider.setType(type),
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Клубы не найдены',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Попробуйте изменить фильтры поиска',
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
              context.read<ClubsProvider>().setType('all');
            },
            child: Text('Показать все клубы'),
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
              ? 'Вы присоединились к клубу "${widget.club.title}"'
              : 'Вы покинули клуб "${widget.club.title}"',
        );
      } else {
        AppUtils.showErrorSnackBar(
          context,
          'Ошибка при ${_isJoined ? 'покидании' : 'присоединении к'} клубу',
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
        border: Border.all(color: AppColors.divider, width: 1),
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
          // Club image
          if (widget.club.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedImageWidget(
                imageUrl: widget.club.imageUrl!,
                width: 70,
                height: 70,
              ),
            )
          else
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getClubTypeColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForClubType(),
                color: _getClubTypeColor(),
                size: 32,
              ),
            ),
          SizedBox(width: 16),

          // Club info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Club title - full title visible
                Text(
                  widget.club.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 8),

                // Members and online info
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${widget.club.membersCount} участников',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.circle, size: 10, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      '${widget.club.onlineCount} онлайн',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
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
        widget.club.description,
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
          // Club type badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getClubTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getTypeLabel(widget.club.type),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getClubTypeColor(),
              ),
            ),
          ),

          // Online indicator
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: AppColors.success),
              SizedBox(width: 6),
              Text(
                '${widget.club.onlineCount} онлайн',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
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
        height: 44,
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
            : OutlinedButton(
                onPressed: _toggleMembership,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isJoined ? AppColors.primary : AppColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  _isJoined ? 'Покинуть клуб' : 'Присоединиться',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isJoined ? AppColors.primary : AppColors.primary,
                  ),
                ),
              ),
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
