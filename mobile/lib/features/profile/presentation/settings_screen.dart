import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      leading: const Icon(Icons.language_rounded, color: AppColors.primaryMint),
                      title: const Text('Target Learning Language', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('English (A1 Beginner)'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                      onTap: () => context.push('/language-selection'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined, color: AppColors.accentBlue),
                      title: const Text('Daily Study Reminder', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Keep your streak alive'),
                      trailing: Switch(
                        value: true,
                        activeColor: AppColors.primaryMint,
                        onChanged: (val) {},
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      leading: const Icon(Icons.volume_up_outlined, color: Color(0xFFFF9800)),
                      title: const Text('Sound & Pronunciation', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Play native audio in lessons'),
                      trailing: Switch(
                        value: true,
                        activeColor: AppColors.primaryMint,
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'About Application',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Material(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
                      title: Text('Version', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text('1.0.0 (Final Project)', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.school_outlined, color: AppColors.textSecondary),
                      title: Text('Project Topic', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Mobile Application Development Final Project'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFD4D4), width: 1.5),
                  backgroundColor: const Color(0xFFFFF5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
