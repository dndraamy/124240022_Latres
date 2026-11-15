import 'package:flutter/material.dart';

class AppTheme {
  // Palette Rick & Morty Portal Dimension
  static const Color spaceDark = Color(0xFF0B0F19);      // Dark deep space background
  static const Color surfaceCard = Color(0xFF161F30);    // Card / surface background
  static const Color surfaceCardLight = Color(0xFF1E2C44);// Active card / elevated surface
  
  // Neon Portal Colors
  static const Color portalGreen = Color(0xFF00FF9D);    // Vibrant Portal Neon Green
  static const Color portalGreenDim = Color(0xFF00C875); // Button / secondary portal
  static const Color portalYellow = Color(0xFFFEE715);   // Morty Yellow / Highlight
  static const Color portalBlue = Color(0xFF00E5FF);     // Portal Cyan / Energy
  
  // Status Colors (WCAG compliant high contrast)
  static const Color aliveColor = Color(0xFF00FF9D);     // Neon Green
  static const Color deadColor = Color(0xFFFF5252);      // Bright Coral Red
  static const Color unknownColor = Color(0xFFFFB74D);   // Amber Orange
  
  // High Contrast Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);    // Crisp Off-White (100% readable)
  static const Color textSecondary = Color(0xFF94A3B8);  // Soft Slate Gray (high contrast on dark)
  static const Color textAccent = Color(0xFF00FF9D);     // Portal Glow Text

  // Input border & accents
  static const Color borderSubtle = Color(0xFF334155);   // Slate border
  static const Color borderFocused = Color(0xFF00FF9D);  // Neon border
}
