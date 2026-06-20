class AppConstants {
  // Layout
  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 64.0;
  static const double actionBarHeight = 64.0;
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusFull = 999.0;

  // App Info
  static const String appName = 'Figma Flow Analyzer';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Visualize. Analyze. Optimize.';

  // Tab Labels
  static const List<String> dashboardTabs = [
    'Paths',
    'Orphan Screens',
    'Dead Ends',
    'Isolated Screens',
    'Nodes List',
    'Connections List',
  ];

  // Status Labels
  static const String statusIdle = 'Idle';
  static const String statusRunning = 'Running';
  static const String statusCompleted = 'Completed';
}
