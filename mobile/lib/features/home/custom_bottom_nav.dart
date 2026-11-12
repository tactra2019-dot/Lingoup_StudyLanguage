import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primaryMint.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            index: 0,
            currentIndex: currentIndex,
            label: 'Path',
            icon: Icons.alt_route_rounded,
            onTap: () => onTap(0),
          ),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            label: 'Vocab',
            icon: Icons.style_rounded,
            onTap: () => onTap(1),
          ),
          _NavItem(
            index: 2,
            currentIndex: currentIndex,
            label: 'Practice',
            icon: Icons.psychology_rounded,
            onTap: () => onTap(2),
          ),
          _NavItem(
            index: 3,
            currentIndex: currentIndex,
            label: 'Profile',
            icon: Icons.person_rounded,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMint : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
