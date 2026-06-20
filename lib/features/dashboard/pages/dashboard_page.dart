import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/app_state.dart';
import '../widgets/sidebar.dart';
import '../widgets/action_bar.dart';
import '../widgets/workspace.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.mobileBreakpoint;

    return Scaffold(
      body: isMobile ? _MobileDashboardLayout() : _DesktopDashboardLayout(),
    );
  }
}

// ──────────────────────────────────────────────
// Desktop layout
// ──────────────────────────────────────────────
class _DesktopDashboardLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSidebarCollapsed = context.watch<AppState>().isSidebarCollapsed;
    final sidebarWidth = isSidebarCollapsed
        ? AppConstants.sidebarCollapsedWidth
        : AppConstants.sidebarWidth;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: sidebarWidth,
          child: const DashboardSidebar(),
        ),
        Expanded(
          child: Column(
            children: [
              const DashboardActionBar(),
              const Expanded(child: DashboardWorkspace()),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Mobile layout - drawer-based
// ──────────────────────────────────────────────
class _MobileDashboardLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(child: DashboardSidebar()),
      body: Column(
        children: [
          _MobileTopBar(),
          const Expanded(child: DashboardWorkspace()),
        ],
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, size: 20),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Figma Flow Analyzer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const DashboardActionBar(mobile: true),
        ],
      ),
    );
  }
}
