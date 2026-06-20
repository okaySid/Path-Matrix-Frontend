import 'package:flutter/material.dart';
import '../../../shared/models/analysis_models.dart';
import '../widgets/metrics_row.dart';
import '../widgets/analysis_tabs.dart';

/// Standalone full-page view for an analysis result.
/// Currently embedded inside the dashboard workspace,
/// but extracted here for future deep-link routing support.
class AnalysisDetailPage extends StatelessWidget {
  final AnalysisProject project;

  const AnalysisDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final result = project.result;
    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No analysis result available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetricsRow(result: result),
            const SizedBox(height: 24),
            AnalysisTabs(result: result),
          ],
        ),
      ),
    );
  }
}
