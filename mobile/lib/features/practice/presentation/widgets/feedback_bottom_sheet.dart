import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FeedbackBottomSheet extends StatelessWidget {
  final bool isCorrect;
  final String? explanation;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const FeedbackBottomSheet({
    super.key,
    required this.isCorrect,
    this.explanation,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final title = isCorrect ? 'Correct!' : 'Not quite!';
    final subtitle = isCorrect ? 'Well done!' : (explanation ?? 'Try again!');
    final accentColor = isCorrect ? const Color(0xFF2ED887) : AppColors.errorRed;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE5EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textHint,
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Feedback Icon with decorative dots
          Stack(
            alignment: Alignment.center,
            children: [
              // Decorative sparkle dots
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _SparkleDotsPainter(color: accentColor),
                ),
              ),
              // Center circle
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleDotsPainter extends CustomPainter {
  final Color color;

  _SparkleDotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color.withOpacity(0.7);
    final paint2 = Paint()..color = AppColors.accentBlue.withOpacity(0.6);
    final paint3 = Paint()..color = const Color(0xFFFFB946).withOpacity(0.8);

    // Decorative surrounding dots matching reference
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.28), 3.0, paint3);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.55), 2.5, paint2);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.25), 3.0, paint1);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.58), 2.5, paint3);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.15), 2.0, paint1);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.12), 2.5, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
