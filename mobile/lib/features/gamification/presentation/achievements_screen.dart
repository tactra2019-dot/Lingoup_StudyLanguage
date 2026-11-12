import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../learning_path/data/learning_repository.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements & Badges'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: achievementsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMint),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (achievements) {
            if (achievements.isEmpty) {
              return const Center(child: Text('No achievements available.'));
            }

            final earnedCount = achievements.where((a) => a.earned).length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.mintGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMint.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Milestones Unlocked',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$earnedCount of ${achievements.length} Badges Earned',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ...achievements.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: a.earned ? AppColors.primaryMint : const Color(0xFFE2EBF0),
                          width: a.earned ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: a.earned ? const Color(0xFFE8FAF5) : AppColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                a.iconEmoji,
                                style: TextStyle(
                                  fontSize: 26,
                                  color: a.earned ? null : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: a.earned ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                                if (a.description != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    a.description!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: a.earned
                                      ? AppColors.primaryMint.withOpacity(0.12)
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  a.earned ? 'UNLOCKED' : 'LOCKED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: a.earned ? AppColors.primaryDark : AppColors.textHint,
                                  ),
                                ),
                              ),
                              if (a.xpReward > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '+${a.xpReward} XP',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
