import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/analysis_models.dart';

class ScreensTab extends StatefulWidget {
  final List<NodeModel> screens;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData icon;
  final Color iconColor;
  final String tagLabel;
  final Color tagColor;

  const ScreensTab({
    super.key,
    required this.screens,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.icon,
    required this.iconColor,
    required this.tagLabel,
    required this.tagColor,
  });

  @override
  State<ScreensTab> createState() => _ScreensTabState();
}

class _ScreensTabState extends State<ScreensTab> {
  String _searchQuery = '';

  List<NodeModel> get _filtered => widget.screens
      .where((s) =>
          _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.id.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    if (widget.screens.isEmpty) {
      return _EmptyState(
        title: widget.emptyTitle,
        subtitle: widget.emptySubtitle,
        icon: widget.icon,
        iconColor: widget.iconColor,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SearchField(onChanged: (v) => setState(() => _searchQuery = v)),
              ),
              const SizedBox(width: 12),
              _IssueCountBadge(
                count: widget.screens.length,
                color: widget.tagColor,
                label: widget.tagLabel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No results', style: TextStyle(color: AppTheme.textTertiary)),
                  )
                : _ScreensList(
                    screens: _filtered,
                    tagLabel: widget.tagLabel,
                    tagColor: widget.tagColor,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search screens...',
          prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.textTertiary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primaryLight, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _IssueCountBadge extends StatelessWidget {
  final int count;
  final Color color;
  final String label;

  const _IssueCountBadge({
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreensList extends StatelessWidget {
  final List<NodeModel> screens;
  final String tagLabel;
  final Color tagColor;

  const _ScreensList({
    required this.screens,
    required this.tagLabel,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: screens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final screen = screens[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tagColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screen.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      screen.id,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tagColor.withOpacity(0.3)),
                ),
                child: Text(
                  tagLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.monitor_outlined, size: 16, color: AppTheme.textTertiary),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
