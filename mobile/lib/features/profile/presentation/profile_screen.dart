import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../auth/data/auth_repository.dart';
import '../../learning_path/data/learning_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.valueOrNull;
    final progressAsync = ref.watch(progressOverviewProvider);
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // User Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: AppColors.mintGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMint.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🎓', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Learner',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Level A1 • English Learner',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Grid
            progressAsync.when(
              data: (ProgressOverview progress) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _ProfileStatCard(
                    emoji: '💎',
                    title: 'Total XP',
                    value: '${progress.totalXp}',
                    color: AppColors.accentBlue,
                  ),
                  _ProfileStatCard(
                    emoji: '🔥',
                    title: 'Current Streak',
                    value: '${progress.currentStreak} Days',
                    color: const Color(0xFFFF9800),
                  ),
                  _ProfileStatCard(
                    emoji: '🏆',
                    title: 'Longest Streak',
                    value: '${progress.longestStreak} Days',
                    color: const Color(0xFFFFB946),
                  ),
                  _ProfileStatCard(
                    emoji: '✅',
                    title: 'Lessons Done',
                    value: '${progress.completedLessons}/${progress.totalLessons}',
                    color: AppColors.successGreen,
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.primaryMint),
                ),
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 20),

            // Streak Calendar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Learning Streak',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      streakAsync.when(
                        data: (StreakData s) => Text(
                          '${s.currentStreak} days active 🔥',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Complete a lesson or practice quiz each day to keep your learning streak alive.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  streakAsync.when(
                    data: (StreakData s) {
                      final days = s.calendarDays;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (index) {
                          final isToday = index == 6;
                          final hasActivity = days.isNotEmpty;
                          return Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isToday && hasActivity
                                  ? const Color(0xFFFF9800)
                                  : isToday
                                      ? AppColors.primaryMint
                                      : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                isToday ? '🔥' : '${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isToday ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Achievements Quick Link
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Text('🏆', style: TextStyle(fontSize: 22))),
                  ),
                  title: const Text(
                    'Achievements & Badges',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'View all earned medals and milestones',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                  onTap: () => context.push('/achievements'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final Color color;

  const _ProfileStatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
