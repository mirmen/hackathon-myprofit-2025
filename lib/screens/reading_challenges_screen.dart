import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/reading_challenges_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';
import '../models/reading_challenge.dart';

class ReadingChallengesScreen extends StatefulWidget {
  @override
  _ReadingChallengesScreenState createState() =>
      _ReadingChallengesScreenState();
}

class _ReadingChallengesScreenState extends State<ReadingChallengesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetBooksController = TextEditingController();
  final TextEditingController _bonusPointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReadingChallengesProvider>().loadChallenges();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetBooksController.dispose();
    _bonusPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Читательские Челленджи',
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
      body: Consumer<ReadingChallengesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadChallenges(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Участвуйте в совместных челленджах и получайте бонусные баллы!',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLight,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Популярные челленджи',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (provider.challenges.isEmpty)
                    Center(
                      child: Text(
                        'Нет доступных челленджей',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  else
                    ...provider.challenges
                        .map((challenge) => _buildChallengeCard(challenge))
                        .toList(),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Создать свой челлендж',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Предложите свою идею для книжного челленджа сообществу',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _showCreateChallengeDialog,
                            child: Text('Предложить челлендж'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChallengeCard(ReadingChallenge challenge) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '';

    final progress = challenge.getUserProgress(userId);
    final total = challenge.targetBooks;
    final percentage = challenge.getProgressPercentage(userId);

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
          // Header
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Progress
          Container(
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$progress/$total книг',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${challenge.participants.length} участников',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.stars, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '+${challenge.bonusPoints}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _joinChallenge(challenge),
                      child: Text(
                        challenge.isUserParticipating(userId)
                            ? (progress > 0 ? 'Продолжить' : 'Участвую')
                            : 'Присоединиться',
                        style: TextStyle(fontSize: 12),
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

  void _showCreateChallengeDialog() {
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Создать челлендж',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Название челленджа',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите описание';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetBooksController,
                        decoration: InputDecoration(
                          labelText: 'Количество книг',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите количество';
                          }
                          final num = int.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'Введите корректное число';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _bonusPointsController,
                        decoration: InputDecoration(
                          labelText: 'Бонусные баллы',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите количество баллов';
                          }
                          final num = int.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'Введите корректное число';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Отмена'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _createChallenge();
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Создать'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createChallenge() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final success = await context
        .read<ReadingChallengesProvider>()
        .createChallenge(
          title: _titleController.text,
          description: _descriptionController.text,
          bookIds:
              [], // In a real app, this would be populated with actual book IDs
          targetBooks: int.parse(_targetBooksController.text),
          bonusPoints: int.parse(_bonusPointsController.text),
          creatorId: authProvider.currentUser!.id,
        );

    if (success) {
      AppUtils.showSuccessSnackBar(context, 'Челлендж создан!');
      context.read<ReadingChallengesProvider>().loadChallenges();

      // Clear controllers
      _titleController.clear();
      _descriptionController.clear();
      _targetBooksController.clear();
      _bonusPointsController.clear();
    } else {
      AppUtils.showErrorSnackBar(context, 'Ошибка при создании челленджа');
    }
  }

  void _joinChallenge(ReadingChallenge challenge) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    // Check if user is already participating
    if (challenge.isUserParticipating(authProvider.currentUser!.id)) {
      AppUtils.showSuccessSnackBar(
        context,
        'Вы уже участвуете в этом челлендже!',
      );
      return;
    }

    final success = await context
        .read<ReadingChallengesProvider>()
        .joinChallenge(challenge.id, authProvider.currentUser!.id);

    if (success) {
      AppUtils.showSuccessSnackBar(context, 'Вы присоединились к челленджу!');
      context.read<ReadingChallengesProvider>().loadChallenges();
    } else {
      AppUtils.showErrorSnackBar(
        context,
        'Ошибка при присоединении к челленджу',
      );
    }
  }
}
