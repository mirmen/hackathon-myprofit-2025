import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/clubs_provider.dart';
import '../providers/auth_provider.dart';
import '../models/club.dart';
import '../utils/app_utils.dart';
import '../utils/cached_image_widget.dart';

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
      appBar: AppBar(
        title: Text(
          'Клубы',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<ClubsProvider>(
        builder: (context, clubsProvider, child) {
          if (clubsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filter tabs
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: clubsProvider.types.length,
                  itemBuilder: (context, index) {
                    final type = clubsProvider.types[index];
                    final isSelected = clubsProvider.selectedType == type;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (_) => clubsProvider.setType(type),
                      ),
                    );
                  },
                ),
              ),

              // Clubs list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: clubsProvider.clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubsProvider.clubs[index];
                    return ClubCard(club: club);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'all':
        return 'Все';
      case 'book':
        return 'Книжные';
      case 'coffee':
        return 'Кофейные';
      default:
        return type;
    }
  }
}

class ClubCard extends StatelessWidget {
  final Club club;

  const ClubCard({Key? key, required this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (club.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImageWidget(
                      imageUrl: club.imageUrl!,
                      width: 60,
                      height: 60,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.title,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        club.description,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${club.membersCount} участников',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.circle, size: 8, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${club.onlineCount} онлайн',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _joinClub(context),
                  child: Text('Присоединиться'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _joinClub(BuildContext context) async {
    final clubsProvider = context.read<ClubsProvider>();
    final success = await clubsProvider.joinClub(club.id);

    if (success) {
      AppUtils.showSuccessSnackBar(
        context,
        'Вы присоединились к клубу "${club.title}"',
      );
    } else {
      AppUtils.showErrorSnackBar(context, 'Ошибка при присоединении к клубу');
    }
  }
}
