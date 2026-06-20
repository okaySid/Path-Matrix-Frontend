import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../analysis/widgets/analysis_tabs.dart';
import 'new_analysis_modal.dart';

class DashboardWorkspace extends StatelessWidget {
  const DashboardWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    final currentProject = context.watch<AppState>().currentProject;

    if (currentProject == null) {
      return _EmptyWorkspace();
    }

    return _ProjectWorkspace(projectId: currentProject.id);
  }
}

// ──────────────────────────────────────────────
// Empty state — shown when no project is selected
// ──────────────────────────────────────────────
class _EmptyWorkspace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _IllustrationPlaceholder(),
            const SizedBox(height: 28),
            const Text(
              'Welcome to Figma Flow Analyzer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Click 'New Analysis' to generate your first Path Matrix.",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const NewAnalysisModal(),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                // OutlinedButton.icon(
                //   onPressed: () {},
                //   icon: const Icon(Icons.play_circle_outline, size: 18),
                //   label: const Text('Watch Demo'),
                //   style: OutlinedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 20, vertical: 12),
                //     side: const BorderSide(color: AppTheme.border),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     textStyle: const TextStyle(
                //         fontSize: 14, fontWeight: FontWeight.w500),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 48),
            const _FeatureCards(),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Illustration placeholder in empty state
// ──────────────────────────────────────────────
class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            left: 32,
            child: _FlowNode(label: 'Home', color: AppTheme.primary),
          ),
          Positioned(
            top: 64,
            left: 12,
            child:
                _FlowNode(label: 'Login', color: AppTheme.accent, size: 40),
          ),
          Positioned(
            top: 64,
            right: 12,
            child: _FlowNode(
                label: 'Sign Up', color: AppTheme.success, size: 40),
          ),
          Positioned(
            bottom: 20,
            left: 60,
            child: _FlowNode(
                label: 'Dashboard', color: AppTheme.warning, size: 48),
          ),
          Positioned(
            top: 46,
            left: 68,
            child: Icon(Icons.arrow_downward,
                size: 12, color: AppTheme.textTertiary),
          ),
          Positioned(
            top: 85,
            left: 42,
            child: Icon(Icons.arrow_downward,
                size: 12, color: AppTheme.textTertiary),
          ),
          Positioned(
            top: 85,
            right: 42,
            child: Icon(Icons.arrow_downward,
                size: 12, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _FlowNode extends StatelessWidget {
  final String label;
  final Color color;
  final double size;

  const _FlowNode({
    required this.label,
    required this.color,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.45,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  @override
  Widget build(BuildContext context) {
    const features = [
      (Icons.account_tree_outlined, 'Path Analysis',
          'Discover all unique user journeys'),
      (Icons.device_hub, 'Node Mapping', 'Map every screen and connection'),
      (Icons.warning_amber_outlined, 'Issue Detection',
          'Find orphans and dead ends'),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: features
          .map((f) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(f.$1, size: 20, color: AppTheme.primaryLight),
                      const SizedBox(height: 8),
                      Text(
                        f.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.$3,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────
// Project workspace — shown when a project is selected
// ──────────────────────────────────────────────
class _ProjectWorkspace extends StatelessWidget {
  final String projectId;

  const _ProjectWorkspace({required this.projectId});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<AppState>().currentProject!;
    final isLoading = context.watch<AppState>().isLoadingAnalysis;

    // Show spinner while waiting for Spring Boot response
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Fetching analysis from Figma...',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // No result yet — show idle or running state
    if (project.result == null) {
      return _NoResultWorkspace(status: project.status.name);
    }

    // Result loaded — show the full dashboard with tabs
    return Container(
  color: AppTheme.surface,
  child: Column(                        // ← Column, not scrollable
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Project header — fixed, never scrolls
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 12, color: AppTheme.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.figmaUrl,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            StatusChip(status: project.status.name.capitalize()),
          ],
        ),
      ),
      const SizedBox(height: 20),
      // Tabs expand to fill ALL remaining height — no page-level scroll
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: AnalysisTabs(result: project.result!),
        ),
      ),
    ],
  ),
);
    // return Container(
    //   color: AppTheme.surface,
    //   child: SingleChildScrollView(
    //     padding: const EdgeInsets.all(24),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         // Project header row
    //         Row(
    //           children: [
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     project.name,
    //                     style: const TextStyle(
    //                       fontSize: 20,
    //                       fontWeight: FontWeight.w700,
    //                       color: AppTheme.textPrimary,
    //                       letterSpacing: -0.3,
    //                     ),
    //                   ),
    //                   const SizedBox(height: 4),
    //                   Row(
    //                     children: [
    //                       const Icon(Icons.link,
    //                           size: 12, color: AppTheme.textTertiary),
    //                       const SizedBox(width: 4),
    //                       Expanded(
    //                         child: Text(
    //                           project.figmaUrl,
    //                           style: const TextStyle(
    //                             fontSize: 12,
    //                             color: AppTheme.textTertiary,
    //                           ),
    //                           overflow: TextOverflow.ellipsis,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             StatusChip(status: project.status.name.capitalize()),
    //           ],
    //         ),
    //         const SizedBox(height: 20),
    //         AnalysisTabs(result: project.result!),
    //       ],
    //     ),
    //   ),
    // );
  }
}

// ──────────────────────────────────────────────
// No result state — idle or running
// ──────────────────────────────────────────────
class _NoResultWorkspace extends StatelessWidget {
  final String status;

  const _NoResultWorkspace({required this.status});

  @override
  Widget build(BuildContext context) {
    final isRunning = status == 'running';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRunning) ...[
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Analysis is running...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fetching Figma data and computing path matrices',
              style:
                  TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ] else ...[
            const Icon(Icons.hourglass_empty,
                size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            const Text(
              'Analysis not started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click on a project in the sidebar to load its analysis',
              style:
                  TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// String extension used for status chip label
// ──────────────────────────────────────────────
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}