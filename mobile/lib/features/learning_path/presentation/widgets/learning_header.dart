import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';

class LearningHeader extends StatelessWidget {
  final UserProfile? user;
  final String levelCode;
  final String flagEmoji;
  final VoidCallback? onLanguageTap;

  const LearningHeader({
    super.key,
    required this.user,
    this.levelCode = 'A1',
    this.flagEmoji = '🇺🇸',
    this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    final streak = user?.currentStreak ?? 0;
    final xp = user?.totalXp ?? 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 8,
        20,
        18,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Language & Level Badge
          GestureDetector(
            onTap: onLanguageTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    flagEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Level',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          height: 1,
                        ),
                      ),
                      Text(
                        levelCode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Streak Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$streak Days',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'Streak',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // XP Diamond Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$xp',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'XP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        height: 1.1,
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
}
