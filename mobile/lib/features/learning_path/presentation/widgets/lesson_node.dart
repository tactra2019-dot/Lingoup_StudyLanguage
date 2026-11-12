import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';

class LessonNodeWidget extends StatelessWidget {
  final Unit unit;
  final bool isRightAligned;
  final VoidCallback onTap;

  const LessonNodeWidget({
    super.key,
    required this.unit,
    required this.isRightAligned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = unit.status;
    final isLocked = status == UnitStatus.locked;

    // Node button
    final nodeButton = GestureDetector(
      onTap: isLocked ? null : onTap,
      child: _3DNodeButton(
        status: status,
        progressPercent: unit.progressPercent,
      ),
    );

    // Label and illustration
    final titleWidget = Column(
      crossAxisAlignment: isRightAligned ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Unit ${unit.orderIndex + 1}:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          unit.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    final illustration = _ThematicIllustration(orderIndex: unit.orderIndex, status: status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: isRightAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isRightAligned
            ? [
                illustration,
                const SizedBox(width: 12),
                nodeButton,
                const SizedBox(width: 14),
                Expanded(child: titleWidget),
              ]
            : [
                Expanded(child: titleWidget),
                const SizedBox(width: 14),
                nodeButton,
                const SizedBox(width: 12),
                illustration,
              ],
      ),
    );
  }
}

class _3DNodeButton extends StatelessWidget {
  final UnitStatus status;
  final double progressPercent;

  const _3DNodeButton({
    required this.status,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 80.0;
    const double depth = 10.0;

    Color topColor;
    Color bottomColor;
    Widget centerIcon;
    List<BoxShadow> shadows;

    switch (status) {
      case UnitStatus.completed:
        topColor = const Color(0xFF2ED887);
        bottomColor = const Color(0xFF1EAB65);
        centerIcon = const Icon(Icons.check_rounded, color: Colors.white, size: 44);
        shadows = [
          BoxShadow(
            color: const Color(0xFF1EAB65).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ];
        break;

      case UnitStatus.available:
        topColor = const Color(0xFF42B9EE);
        bottomColor = const Color(0xFF1C87BD);
        centerIcon = Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.people_alt_rounded, color: Colors.white, size: 36),
            if (progressPercent > 0)
              Positioned(
                bottom: 6,
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (progressPercent / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
        shadows = [
          BoxShadow(
            color: const Color(0xFF42B9EE).withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];
        break;

      case UnitStatus.locked:
        topColor = const Color(0xFFBCC6CE);
        bottomColor = const Color(0xFF9AA5AF);
        centerIcon = const Icon(Icons.lock_rounded, color: Colors.white, size: 34);
        shadows = [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ];
        break;
    }

    return SizedBox(
      width: size,
      height: size + depth,
      child: Stack(
        children: [
          // 3D Bottom Base (The Extrusion)
          Positioned(
            top: depth,
            left: 0,
            right: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bottomColor,
                shape: BoxShape.circle,
                boxShadow: shadows,
              ),
            ),
          ),
          // 3D Top Face
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: topColor,
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    topColor,
                    Color.lerp(topColor, bottomColor, 0.4)!,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 2.0,
                ),
              ),
              child: Center(child: centerIcon),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThematicIllustration extends StatelessWidget {
  final int orderIndex;
  final UnitStatus status;

  const _ThematicIllustration({
    required this.orderIndex,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Companion illustrations beside each node matching reference
    String emoji;
    String badgeText;

    switch (orderIndex) {
      case 0:
        emoji = '👋';
        badgeText = 'Start';
        break;
      case 1:
        emoji = '🤖';
        badgeText = 'Bot';
        break;
      case 2:
        emoji = '✈️';
        badgeText = 'Airport';
        break;
      case 3:
        emoji = '🌲';
        badgeText = 'Park';
        break;
      case 4:
        emoji = '📅';
        badgeText = 'Daily';
        break;
      case 5:
        emoji = '🛍️';
        badgeText = 'Store';
        break;
      case 6:
        emoji = '💼';
        badgeText = 'Work';
        break;
      default:
        emoji = '💪';
        badgeText = 'Health';
        break;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 28,
            color: status == UnitStatus.locked ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
}
