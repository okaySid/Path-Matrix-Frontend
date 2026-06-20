import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/analysis_models.dart';
import 'paths_tab.dart';
import 'screens_tab.dart';
import 'nodes_tab.dart';
import 'connections_tab.dart';

class AnalysisTabs extends StatefulWidget {
  final AnalysisResult result;

  const AnalysisTabs({super.key, required this.result});

  @override
  State<AnalysisTabs> createState() => _AnalysisTabsState();
}

class _AnalysisTabsState extends State<AnalysisTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AppConstants.dashboardTabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TabBar(controller: _tabController, result: widget.result),
          const Divider(height: 1),
          // Expanded here takes all remaining height from parent
          // _TabContent must NOT also wrap in Expanded — that nests two
          // Expandeds which causes the content to collapse to zero height
          Expanded(
            child: _TabContent(
              controller: _tabController,
              result: widget.result,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  final AnalysisResult result;

  const _TabBar({required this.controller, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          _buildTab('Paths', '${result.totalPaths}', AppTheme.primaryLight),
          _buildTab(
            'Orphan Screens',
            '${result.orphanScreens.length}',
            result.orphanScreens.isEmpty
                ? AppTheme.textTertiary
                : AppTheme.warning,
          ),
          _buildTab(
            'Dead Ends',
            '${result.deadEnds.length}',
            result.deadEnds.isEmpty
                ? AppTheme.textTertiary
                : AppTheme.error,
          ),
          _buildTab(
            'Isolated Screens',
            '${result.isolatedScreens.length}',
            result.isolatedScreens.isEmpty
                ? AppTheme.textTertiary
                : AppTheme.error,
          ),
          _buildTab(
              'Nodes List', '${result.nodes.length}', AppTheme.textSecondary),
          _buildTab('Connections', '${result.connections.length}',
              AppTheme.textSecondary),
        ],
      ),
    );
  }

  Tab _buildTab(String label, String count, Color countColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: countColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: countColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final TabController controller;
  final AnalysisResult result;

  const _TabContent({required this.controller, required this.result});

  @override
  Widget build(BuildContext context) {
    // No Expanded here — parent already provides bounded height via Expanded
    // Nesting Expanded inside Expanded collapses content to zero height
    return TabBarView(
      controller: controller,
      children: [
        PathsTab(paths: result.paths),
        ScreensTab(
          screens: result.orphanScreens,
          emptyTitle: 'No Orphan Screens',
          emptySubtitle: 'All screens have at least one incoming connection.',
          icon: Icons.check_circle_outline,
          iconColor: AppTheme.success,
          tagLabel: 'No Incoming',
          tagColor: AppTheme.warning,
        ),
        ScreensTab(
          screens: result.deadEnds,
          emptyTitle: 'No Dead Ends',
          emptySubtitle: 'All screens have at least one outgoing connection.',
          icon: Icons.check_circle_outline,
          iconColor: AppTheme.success,
          tagLabel: 'No Outgoing',
          tagColor: AppTheme.error,
        ),
        ScreensTab(
          screens: result.isolatedScreens,
          emptyTitle: 'No Isolated Screens',
          emptySubtitle: 'All screens are connected to the flow.',
          icon: Icons.check_circle_outline,
          iconColor: AppTheme.success,
          tagLabel: 'Isolated',
          tagColor: AppTheme.error,
        ),
        NodesTab(nodes: result.nodes),
        ConnectionsTab(connections: result.connections),
      ],
    );
  }
}