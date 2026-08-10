class AppConstants {
  // Chat Bot Animation Constants
  static const int shakeDurationMs = 1800;
  static const double shakeAngleStart = -0.012;
  static const double shakeAngleEnd = 0.012;
  
  static const int blinkIntervalSeconds = 4;
  static const int blinkDurationMs = 150;
  
  // Floating position offsets and bounds
  static const double initialXOffset = 85.0;
  static const double initialYOffset = 200.0;
  
  static const double dragCloseThreshold = 80.0;
  static const double dragCloseVelocityThreshold = 300.0;
  
  static const double floatMinX = 10.0;
  static const double floatMaxXOffset = 80.0;
  static const double floatMinY = 50.0;
  static const double floatMaxYOffset = 180.0;

  // Scroll duration
  static const int scrollDurationMs = 300;
  
  // Blur config
  static const double blurSigmaX = 5.0;
  static const double blurSigmaY = 5.0;
}
