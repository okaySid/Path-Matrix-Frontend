import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/shared_widgets.dart';
import 'settings_dialog.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../../shared/models/analysis_models.dart';


class DashboardActionBar extends StatelessWidget {
  final bool mobile;

  const DashboardActionBar({super.key, this.mobile = false});

  @override
  Widget build(BuildContext context) {
    final hasProject = context.watch<AppState>().currentProject != null;

    if (mobile) return _MobileActionBar(hasProject: hasProject);
    return _DesktopActionBar(hasProject: hasProject);
  }
}

class _DesktopActionBar extends StatelessWidget {
  final bool hasProject;

  const _DesktopActionBar({required this.hasProject});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          // Left: breadcrumb / page title
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 18, color: AppTheme.textTertiary),
              const SizedBox(width: 8),
              Text(
                context.watch<AppState>().currentProject?.name ?? 'Dashboard',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (context.watch<AppState>().currentProject != null) ...[
                const SizedBox(width: 8),
                StatusChip(
                  status: _statusLabel(context.watch<AppState>().currentProject!.status.name),
                ),
              ],
            ],
          ),
          const Spacer(),
          // Right: action buttons
          _ActionButtons(hasProject: hasProject),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'running': return 'Running';
      case 'completed': return 'Completed';
      default: return 'Idle';
    }
  }
}

class _MobileActionBar extends StatelessWidget {
  final bool hasProject;

  const _MobileActionBar({required this.hasProject});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasProject)
          _ActionIconButton(
            icon: Icons.play_arrow_rounded,
            label: 'Run',
            color: AppTheme.success,
            onTap: () => _showSnackBar(context, 'Analysis started...'),
          ),
        _ActionIconButton(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => showSettingsDialog(context),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool hasProject;

  const _ActionButtons({required this.hasProject});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // _ActionChipButton(
        //   icon: Icons.play_arrow_rounded,
        //   label: 'Run Analysis',
        //   color: AppTheme.success,
        //   enabled: hasProject,
        //   onTap: () => _snack(context, '▶ Analysis is running...'),
        // ),
        const SizedBox(width: 8),
        // _ActionChipButton(
        //   icon: Icons.table_chart_outlined,
        //   label: 'Export CSV',
        //   enabled: hasProject,
        //   onTap: () => _snack(context, '📊 Exporting CSV...'),
        // ),
        _SyncButton(hasProject: hasProject),
        const SizedBox(width: 8),
        // _ActionChipButton(
        //   icon: Icons.grid_on_outlined,
        //   label: 'Export Excel',
        //   enabled: hasProject,
        //   onTap: () => _snack(context, '📗 Exporting Excel...'),
        // ),
        _ExportJsonButton(hasProject: hasProject),
        const SizedBox(width: 12),
        const _VerticalDivider(),
        const SizedBox(width: 12),
        _SettingsButton(),
      ],
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        width: 280,
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.textSecondary;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: effectiveColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color ?? AppTheme.textSecondary),
      tooltip: label,
      onPressed: onTap,
    );
  }
}

class _SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showSettingsDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.settings_outlined, size: 18, color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: AppTheme.border);
  }
}

class _SyncButton extends StatelessWidget {
  final bool hasProject;

  const _SyncButton({required this.hasProject});

  @override
  Widget build(BuildContext context) {
    final isSyncing = context.watch<AppState>().isSyncing;

    return Opacity(
      opacity: hasProject ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasProject && !isSyncing
              ? () => _handleSync(context)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show spinner while syncing, icon otherwise
                isSyncing
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryLight,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.sync_rounded,
                        size: 15,
                        color: AppTheme.textSecondary,
                      ),
                const SizedBox(width: 6),
                Text(
                  isSyncing ? 'Syncing...' : 'Sync',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSyncing
                        ? AppTheme.primaryLight
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSync(BuildContext context) async {
    try {
      await context.read<AppState>().syncCurrentProject();

      // Success — show green snackbar with Spring Boot's message
      if (context.mounted) {
        final message = context.read<AppState>().syncMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(message ?? 'Sync completed')),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            width: 360,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Error — show red snackbar with the actual error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
              ],
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            width: 360,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

class _ExportJsonButton extends StatelessWidget {
  final bool hasProject;

  const _ExportJsonButton({required this.hasProject});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: hasProject ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasProject ? () => _handleExport(context) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.data_object_outlined,
                    size: 15, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Export JSON',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
  final project = context.read<AppState>().currentProject;
  if (project == null) return;

  try {
    // Re-fetch the raw JSON string from Spring Boot
    final rawJson = await context.read<AppState>()
        .fetchRawPaths(project.figmaUrl, project.versionNumber);

    // Trigger browser download with the raw response body
    final bytes = utf8.encode(rawJson);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
          'download',
          '${project.name}_v${project.versionNumber}_paths.json')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Paths exported as JSON'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          width: 300,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    e.toString().replaceAll('Exception: ', '')),
              ),
            ],
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          width: 300,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
}