import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primaryMint = Color(0xFF21C7A8);
  static const Color primaryDark = Color(0xFF159B83);
  static const Color primaryLight = Color(0xFF4EDFC4);

  // Secondary
  static const Color accentBlue = Color(0xFF42B9EE);
  static const Color accentBlueDark = Color(0xFF2896D0);

  // Status
  static const Color successGreen = Color(0xFF2ED887);
  static const Color errorRed = Color(0xFFEF6464);
  static const Color warningOrange = Color(0xFFFFB946);

  // Background
  static const Color background = Color(0xFFF2F8FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7FBFC);

  // Text
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667684);
  static const Color textHint = Color(0xFFAAB4C0);

  // State
  static const Color lockedGray = Color(0xFFAAB4C0);
  static const Color lockedDark = Color(0xFF8899A6);
  static const Color completedGreen = Color(0xFF2ED877);
  static const Color currentBlue = Color(0xFF42B9EE);

  // Gradients
  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF21C7A8), Color(0xFF159B83)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42B9EE), Color(0xFF2896D0)],
  );

  static const LinearGradient lockedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCDD5DB), Color(0xFFAAB4C0)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2ED887), Color(0xFF18B363)],
  );

  // Header gradient (matches reference image)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF21C7A8), Color(0xFF159B83), Color(0xFF0D7A65)],
  );
}
