import 'package:flutter/material.dart';

class AppDesignTokens {
  // Colors (Semantic names)
  static const Color colorPrimary = Color(0xFF00D2FF);
  static const Color colorSecondary = Color(0xFF00A3FF);
  
  // Chat Bot Colors
  static const Color chatBgDark = Color(0xFF0D1117);
  static const Color chatBgLight = Colors.white;
  static const Color chatBarrier = Colors.black;
  static const Color chatBorderDark = Colors.white12;
  static const Color chatBorderLight = Color(0x0D000000); // Colors.black.withValues(alpha: 0.05)
  static const Color chatShadow = Colors.black;
  static const Color avatarBorder = Color(0x6600D2FF); // const Color(0xFF00D2FF).withValues(alpha: 0.4)
  static const Color onlineIndicator = Color(0xFF388E3C); // Colors.greenAccent.shade700 or green
  
  // Chat Message Bubble Colors
  static const Color msgBotBgDark = Color(0xFF161B22);
  static const Color msgBotBgLight = Color(0xFFF5F5F5); // Colors.grey.shade100
  static const Color msgTextBotDark = Color(0xFFB0B0B0); // Colors.white70
  static const Color msgTextBotLight = Color(0xFF212121); // Colors.black87
  static const Color msgTextUser = Colors.white;
  
  // Quick Prompt Token Colors
  static const Color quickPromptBg = Color(0x1A00D2FF); // Color(0xFF00D2FF).withValues(alpha: 0.1)
  static const Color quickPromptBorder = Color(0x4D00D2FF); // Color(0xFF00D2FF).withValues(alpha: 0.3)
  static const Color quickPromptText = Color(0xFF00D2FF);
  
  // Floating Button specific
  static const Color botBtnBg = Color(0xFF005691);
  static const Color botBtnShadow = Color(0x8000D2FF); // const Color(0xFF00D2FF).withValues(alpha: 0.5)
  static const Color botEyeBlinkOverlay = Color(0xFF070B16);

  // New Compliance Colors
  static const Color colorCompletedDark = Color(0xFF00FF94);
  static const Color colorCompletedLight = Color(0xFF059669);
  static const Color colorActiveLight = Color(0xFF0284C7);
  
  static const Color colorProfileGradientDark1 = Color(0xFF1F2937);
  static const Color colorProfileGradientDark2 = Color(0xFF111827);
  static const Color colorProfileGradientLightEnd = Color(0xFF7000FF);
  
  static const Color colorErrorBgDark = Color(0x1AFF1744);
  static const Color colorErrorBorder = Color(0x80FF1744);
  static const Color colorErrorText = Color(0xFFFF1744);

  // Spacing & Margins (Semantic names)
  static const double spacingZero = 0.0;
  static const double spacingXS = 4.0;
  static const double spacingS = 6.0;
  static const double spacingM = 8.0;
  static const double spacingL = 10.0;
  static const double spacingXL = 12.0;
  static const double spacingXXL = 14.0;
  static const double spacingXXXL = 16.0;
  static const double spacingHuge = 20.0;
  
  // Spacing Edge Insets
  static const EdgeInsets paddingHeader = EdgeInsets.symmetric(horizontal: spacingHuge);
  static const EdgeInsets paddingMsgList = EdgeInsets.symmetric(horizontal: spacingXXXL, vertical: spacingL);
  static const EdgeInsets paddingBubble = EdgeInsets.symmetric(horizontal: spacingXXL, vertical: spacingL);
  static const EdgeInsets paddingThinking = EdgeInsets.only(left: spacingHuge, bottom: spacingM);
  static const EdgeInsets paddingQuickPrompts = EdgeInsets.symmetric(horizontal: spacingXXXL);
  static const EdgeInsets paddingInputBox = EdgeInsets.only(left: spacingXXXL, right: spacingXXXL, bottom: spacingXXXL, top: spacingS);
  static const EdgeInsets paddingIndicator = EdgeInsets.symmetric(vertical: spacingXL);
}
