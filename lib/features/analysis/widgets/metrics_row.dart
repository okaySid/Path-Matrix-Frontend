import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/analysis_models.dart';

class MetricsRow extends StatelessWidget {
  final AnalysisResult result;

  const MetricsRow({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        label: 'Total Screens',
        value: '${result.totalScreens}',
        icon: Icons.monitor_outlined,
        color: AppTheme.primaryLight,
        trend: null,
      ),
      _MetricData(
        label: 'Connections',
        value: '${result.totalConnections}',
        icon: Icons.device_hub,
        color: AppTheme.accent,
        trend: null,
      ),
      _MetricData(
        label: 'Total Paths',
        value: '${result.totalPaths}',
        icon: Icons.account_tree_outlined,
        color: AppTheme.success,
        trend: null,
      ),
      _MetricData(
        label: 'Orphan Screens',
        value: '${result.orphanScreens.length}',
        icon: Icons.not_listed_location_outlined,
        color: result.orphanScreens.isEmpty ? AppTheme.textTertiary : AppTheme.warning,
        trend: result.orphanScreens.isEmpty ? 'clean' : 'warning',
      ),
      _MetricData(
        label: 'Dead Ends',
        value: '${result.deadEnds.length}',
        icon: Icons.do_not_disturb_outlined,
        color: result.deadEnds.isEmpty ? AppTheme.textTertiary : AppTheme.error,
        trend: result.deadEnds.isEmpty ? 'clean' : 'issue',
      ),
      _MetricData(
        label: 'Isolated Screens',
        value: '${result.isolatedScreens.length}',
        icon: Icons.blur_off_outlined,
        color: result.isolatedScreens.isEmpty ? AppTheme.textTertiary : AppTheme.error,
        trend: result.isolatedScreens.isEmpty ? 'clean' : 'issue',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 6
            : constraints.maxWidth > 600
                ? 3
                : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: metrics.map((m) => _MetricCard(data: m)).toList(),
        );
      },
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend; // 'clean', 'warning', 'issue', or null

  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, size: 16, color: data.color),
              ),
              if (data.trend != null) _TrendBadge(trend: data.trend!),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: data.color,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final String trend;

  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend == 'clean') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 10, color: AppTheme.success),
            SizedBox(width: 3),
            Text(
              'Clean',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.success),
            ),
          ],
        ),
      );
    }
    if (trend == 'warning') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.warning_amber, size: 12, color: AppTheme.warning),
      );
    }
    if (trend == 'issue') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.error_outline, size: 12, color: AppTheme.error),
      );
    }
    return const SizedBox.shrink();
  }
}
