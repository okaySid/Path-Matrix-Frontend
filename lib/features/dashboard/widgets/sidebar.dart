import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_exception.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/models/analysis_models.dart';
import '../../../shared/widgets/shared_widgets.dart';
import 'new_analysis_modal.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({super.key});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AnalysisProject> _filteredProjects(List<AnalysisProject> projects) {
    if (_searchQuery.trim().isEmpty) return projects;
    final q = _searchQuery.trim().toLowerCase();
    return projects
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            'v${p.versionNumber}'.contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isCollapsed = appState.isSidebarCollapsed;
    final filtered = _filteredProjects(appState.projects);

    return Container(
      color: AppTheme.sidebarBg,
      child: Column(
        children: [
          _SidebarHeader(isCollapsed: isCollapsed),
          _NewAnalysisButton(isCollapsed: isCollapsed),

          // Search bar — hidden when collapsed
          if (!isCollapsed) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _SidebarSearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Color(0xFF1E293B), height: 1),
          ),

          // Toggle — hidden when collapsed
          if (!isCollapsed)
            _ProjectListToggle(
              showingUserProjects: appState.showingUserProjects,
              onUserTap: () {
                context.read<AppState>().switchToUserProjects();
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              onAllTap: () {
                context.read<AppState>().switchToAllProjects();
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),

          if (isCollapsed) const SizedBox(height: 8),

          // Project list
          Expanded(
            child: filtered.isEmpty
                ? _EmptySidebarState(
                    isCollapsed: isCollapsed,
                    isSearching: _searchQuery.isNotEmpty,
                    onClearSearch: () => setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    }),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _ProjectItem(
                      project: filtered[index],
                      isSelected: appState.currentProjectId ==
                          filtered[index].id,
                      isCollapsed: isCollapsed,
                      showDelete: appState.showingUserProjects,
                      searchQuery: _searchQuery,
                    ),
                  ),
          ),
          _SidebarFooter(isCollapsed: isCollapsed),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SidebarSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 12, color: AppTheme.sidebarText),
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          prefixIcon:
              const Icon(Icons.search, size: 15, color: Color(0xFF475569)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close,
                      size: 13, color: Color(0xFF475569)),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: AppTheme.primaryLight.withOpacity(0.6), width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectListToggle extends StatelessWidget {
  final bool showingUserProjects;
  final VoidCallback onUserTap;
  final VoidCallback onAllTap;

  const _ProjectListToggle({
    required this.showingUserProjects,
    required this.onUserTap,
    required this.onAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToggleTab(
                label: 'My Projects',
                isActive: showingUserProjects,
                onTap: onUserTap,
              ),
            ),
            Expanded(
              child: _ToggleTab(
                label: 'All Projects',
                isActive: !showingUserProjects,
                onTap: onAllTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar Header
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarHeader extends StatelessWidget {
  final bool isCollapsed;

  const _SidebarHeader({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isCollapsed ? 0 : 16,
        16,
        isCollapsed ? 0 : 8,
        16,
      ),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.route_rounded,
                color: Colors.white, size: 18),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flow Analyzer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Figma Analysis Tool',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left,
                  size: 20, color: Color(0xFF64748B)),
              onPressed: () => context.read<AppState>().toggleSidebar(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Analysis Button
// ─────────────────────────────────────────────────────────────────────────────
class _NewAnalysisButton extends StatelessWidget {
  final bool isCollapsed;

  const _NewAnalysisButton({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: isCollapsed
          ? Tooltip(
              message: 'New Analysis',
              child: InkWell(
                onTap: () => _open(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _open(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }

  void _open(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const NewAnalysisModal(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project Item
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectItem extends StatelessWidget {
  final AnalysisProject project;
  final bool isSelected;
  final bool isCollapsed;
  final bool showDelete;
  final String searchQuery;

  const _ProjectItem({
    required this.project,
    required this.isSelected,
    required this.isCollapsed,
    required this.showDelete,
    required this.searchQuery,
  });

  Color get _statusColor {
    switch (project.status) {
      case AnalysisStatus.running:
        return AppTheme.statusRunning;
      case AnalysisStatus.completed:
        return AppTheme.statusCompleted;
      default:
        return AppTheme.statusIdle;
    }
  }

  String get _statusLabel {
    switch (project.status) {
      case AnalysisStatus.running:
        return 'Running';
      case AnalysisStatus.completed:
        return 'Completed';
      default:
        return 'Idle';
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return Tooltip(
        message: '${project.name} v${project.versionNumber}',
        child: _buildCollapsedItem(context),
      );
    }
    return _buildExpandedItem(context);
  }

  Widget _buildCollapsedItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => context.read<AppState>().loadAnalysis(project.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.sidebarActive : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: _statusColor, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: () => context.read<AppState>().loadAnalysis(project.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.sidebarActive : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: AppTheme.primaryLight.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: _statusColor, shape: BoxShape.circle),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: project.name,
                      query: searchQuery,
                      isSelected: isSelected,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'v${project.versionNumber}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(project.lastUpdated),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showDelete)
                InkWell(
                  onTap: () => _confirmDelete(context),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline,
                        size: 14, color: Color(0xFF475569)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DeleteConfirmDialog(project: project),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Highlighted Text
// ─────────────────────────────────────────────────────────────────────────────
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final bool isSelected;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: 13,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      color: isSelected ? Colors.white : AppTheme.sidebarText,
    );

    if (query.isEmpty) {
      return Text(text,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchStart = lowerText.indexOf(lowerQuery);

    if (matchStart == -1) {
      return Text(text,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }

    final matchEnd = matchStart + query.length;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          if (matchStart > 0) TextSpan(text: text.substring(0, matchStart)),
          TextSpan(
            text: text.substring(matchStart, matchEnd),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFFF59E0B).withOpacity(0.15),
            ),
          ),
          if (matchEnd < text.length) TextSpan(text: text.substring(matchEnd)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptySidebarState extends StatelessWidget {
  final bool isCollapsed;
  final bool isSearching;
  final VoidCallback onClearSearch;

  const _EmptySidebarState({
    required this.isCollapsed,
    required this.isSearching,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) return const SizedBox.shrink();

    if (isSearching) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 28, color: Color(0xFF475569)),
            const SizedBox(height: 8),
            const Text(
              'No projects found',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onClearSearch,
              child: const Text(
                'Clear search',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'No projects found.',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 12, color: Color(0xFF475569), height: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete Confirm Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _DeleteConfirmDialog extends StatefulWidget {
  final AnalysisProject project;

  const _DeleteConfirmDialog({required this.project});

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.error, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delete Project',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      Text('This action cannot be undone',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_outlined,
                        size: 18, color: AppTheme.error),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.project.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                          'Version ${widget.project.versionNumber}  •  ${_formatDate(widget.project.lastUpdated)}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.error.withOpacity(0.3)),
                    ),
                    child: Text(
                      'v${widget.project.versionNumber}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.warning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 15, color: AppTheme.warning),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'All analysis results for this version will be permanently removed from the database.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Keep Project',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDeleting ? null : _handleDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Delete',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      final message = await context
          .read<AppState>()
          .deleteProject(widget.project.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(greenSnackbar(message));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        final msg = e is ApiException
            ? e.message
            : e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(redSnackbar(msg));
      }
    }
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar Footer
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarFooter extends StatelessWidget {
  final bool isCollapsed;

  const _SidebarFooter({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 8 : 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: isCollapsed
          ? Column(
              children: [
                Tooltip(
                  message: 'Expand sidebar',
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFF64748B)),
                    onPressed: () =>
                        context.read<AppState>().toggleSidebar(),
                  ),
                ),
                Tooltip(
                  message: 'Logout',
                  child: IconButton(
                    icon: const Icon(Icons.logout,
                        size: 16, color: Color(0xFF64748B)),
                    onPressed: () => context.read<AppState>().logout(),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent.withOpacity(0.8),
                        AppTheme.primary.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Logged In',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout,
                      size: 16, color: Color(0xFF64748B)),
                  onPressed: () => context.read<AppState>().logout(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
    );
  }
}