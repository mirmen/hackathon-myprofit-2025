import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/club.dart';
import '../providers/clubs_provider.dart';
import '../utils/app_utils.dart';
import '../utils/cached_image_widget.dart';
import '../theme/app_theme.dart';

class ClubDetailScreen extends StatefulWidget {
  final Club club;

  const ClubDetailScreen({Key? key, required this.club}) : super(key: key);

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  bool _isJoined = false;
  bool _isLoading = false;
  int _selectedTabIndex = 0;

  // Mock data for events, members, and discussions
  final List<Map<String, dynamic>> _mockEvents = [
    {
      'id': '1',
      'title': 'Мастер-класс по латте-арту',
      'date': '25 сентября, 18:00',
      'description': 'Научимся создавать красивые узоры на кофе',
      'participants': 12,
      'maxParticipants': 20,
    },
    {
      'id': '2',
      'title': 'Обсуждение "1984" Дж. Оруэлла',
      'date': '28 сентября, 19:00',
      'description': 'Обсудим антиутопию и её актуальность сегодня',
      'participants': 8,
      'maxParticipants': 15,
    },
    {
      'id': '3',
      'title': 'Книжная ярмарка в центре города',
      'date': '1 октября, 10:00',
      'description': 'Посетим книжную ярмарку с коллективной покупкой',
      'participants': 24,
      'maxParticipants': 30,
    },
  ];

  final List<Map<String, dynamic>> _mockMembers = [
    {
      'id': '1',
      'name': 'Анна Петрова',
      'role': 'Администратор',
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Михаил Сидоров',
      'role': 'Модератор',
      'isOnline': true,
    },
    {
      'id': '3',
      'name': 'Елена Кузнецова',
      'role': 'Участник',
      'isOnline': false,
    },
    {'id': '4', 'name': 'Дмитрий Иванов', 'role': 'Участник', 'isOnline': true},
    {
      'id': '5',
      'name': 'Ольга Смирнова',
      'role': 'Участник',
      'isOnline': false,
    },
  ];

  final List<Map<String, dynamic>> _mockDiscussions = [
    {
      'id': '1',
      'title': 'Рекомендации по новым поступлениям',
      'author': 'Анна Петрова',
      'replies': 24,
      'lastReply': '2 часа назад',
      'isPinned': true,
    },
    {
      'id': '2',
      'title': 'Лучшие места для чтения в городе',
      'author': 'Михаил Сидоров',
      'replies': 17,
      'lastReply': '5 часов назад',
      'isPinned': false,
    },
    {
      'id': '3',
      'title': 'Как выбрать кофемолку для дома?',
      'author': 'Елена Кузнецова',
      'replies': 31,
      'lastReply': 'Вчера',
      'isPinned': false,
    },
  ];

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.club.title,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Club header with image and info
          _buildClubHeader(),

          // Tab bar for switching between sections
          _buildTabBar(),

          // Content based on selected tab
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildClubHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.club.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedImageWidget(
                imageUrl: widget.club.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getClubTypeColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForClubType(),
                color: _getClubTypeColor(),
                size: 60,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            widget.club.description,
            style: GoogleFonts.manrope(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.club.membersCount} участников',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.circle, size: 10, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.club.onlineCount} онлайн',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _toggleMembership,
                child: Text(
                  _isJoined ? 'Покинуть сообщество' : 'Присоединиться',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _isJoined ? Colors.red : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabItem(0, 'Мероприятия'),
          _buildTabItem(1, 'Участники'),
          _buildTabItem(2, 'Обсуждения'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildEventsTab();
      case 1:
        return _buildMembersTab();
      case 2:
        return _buildDiscussionsTab();
      default:
        return _buildEventsTab();
    }
  }

  Widget _buildEventsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockEvents.length,
      itemBuilder: (context, index) {
        final event = _mockEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockMembers.length,
      itemBuilder: (context, index) {
        final member = _mockMembers[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildDiscussionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockDiscussions.length,
      itemBuilder: (context, index) {
        final discussion = _mockDiscussions[index];
        return _buildDiscussionCard(discussion);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event['title'],
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (event['isPinned'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Закреплено',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event['date'],
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event['description'],
              style: GoogleFonts.manrope(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${event['participants']}/${event['maxParticipants']} участников',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    // Simulate event registration
                    AppUtils.showSuccessSnackBar(
                      context,
                      'Вы зарегистрировались на мероприятие "${event['title']}"',
                    );
                  },
                  child: const Text('Зарегистрироваться'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Member avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  member['name'][0],
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['name'],
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member['role'],
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (member['isOnline'])
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(Map<String, dynamic> discussion) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    discussion['title'],
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (discussion['isPinned'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Закреплено',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Автор: ${discussion['author']}',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  discussion['lastReply'],
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 16,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${discussion['replies']} ответов',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Simulate opening discussion
                  AppUtils.showSuccessSnackBar(
                    context,
                    'Открыта тема "${discussion['title']}"',
                  );
                },
                child: const Text('Открыть обсуждение'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getClubTypeColor() {
    switch (widget.club.type) {
      case 'book':
        return const Color(0xFF8C6A4B); // Coffee brown
      case 'coffee':
        return const Color(0xFFCD9F68); // Coffee gold
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
}
