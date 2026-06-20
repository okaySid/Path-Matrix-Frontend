import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/analysis_models.dart';

class PathsTab extends StatefulWidget {
  final List<PathModel> paths;

  const PathsTab({super.key, required this.paths});

  @override
  State<PathsTab> createState() => _PathsTabState();
}

class _PathConnector extends StatelessWidget {
  final String? label;
  final bool highlighted;

  const _PathConnector({
    required this.label,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: highlighted ? const Color(0xFFF59E0B) : Colors.grey.shade700,
          ),
          if (hasLabel) ...[
            const SizedBox(width: 6),
            Container(
              constraints: const BoxConstraints(maxWidth: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: highlighted
                    ? const Color(0xFFFFF8E7)
                    : Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: highlighted
                      ? const Color(0xFFF59E0B)
                      : Colors.blueGrey.shade200,
                ),
              ),
              child: Text(
                label!,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: highlighted
                      ? const Color(0xFF92400E)
                      : Colors.blueGrey.shade800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PathsTabState extends State<PathsTab> {
  String _searchQuery = '';
  int? _filterLength;
  String? _highlightedNode; // null = nothing selected
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PathModel> get _filtered {
    return widget.paths.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.pathDisplay.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLength =
          _filterLength == null || p.length == _filterLength;
      return matchesSearch && matchesLength;
    }).toList();
  }

  List<int> get _availableLengths =>
      widget.paths.map((p) => p.length).toSet().toList()..sort();

  bool _pathContainsNode(PathModel path, String nodeName) =>
      path.nodes.contains(nodeName);

  void _onNodeTap(String nodeName) {
    setState(() {
      // Toggle: clicking the same node again clears the highlight
      _highlightedNode = _highlightedNode == nodeName ? null : nodeName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Toolbar row ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SearchBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                height: 38,
                child: _LengthFilter(
                  availableLengths: _availableLengths,
                  selectedLength: _filterLength,
                  onChanged: (v) => setState(() => _filterLength = v),
                ),
              ),
              const SizedBox(width: 12),
              _ResultCount(count: filtered.length, total: widget.paths.length),
            ],
          ),

          // ── Active highlight banner ───────────────────
          if (_highlightedNode != null) ...[
            const SizedBox(height: 10),
            _HighlightBanner(
              nodeName: _highlightedNode!,
              matchCount: filtered
                  .where((p) => _pathContainsNode(p, _highlightedNode!))
                  .length,
              onClear: () => setState(() => _highlightedNode = null),
            ),
          ],

          const SizedBox(height: 14),

          // ── Path cards ───────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyFilterResult(onClear: () {
                    setState(() {
                      _searchQuery = '';
                      _filterLength = null;
                      _highlightedNode = null;
                      _searchController.clear();
                    });
                  })
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final path = filtered[index];
                      final isHighlighted = _highlightedNode != null &&
                          _pathContainsNode(path, _highlightedNode!);
                      return _PathCard(
                        path: path,
                        index: index,
                        highlightedNode: _highlightedNode,
                        isHighlighted: isHighlighted,
                        onNodeTap: _onNodeTap,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Path Card — one card per path with clickable node chips
// ─────────────────────────────────────────────────────────────────────────────
class _PathCard extends StatelessWidget {
  final PathModel path;
  final int index;
  final String? highlightedNode;
  final bool isHighlighted;
  final ValueChanged<String> onNodeTap;

  const _PathCard({
    required this.path,
    required this.index,
    required this.highlightedNode,
    required this.isHighlighted,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFFFFFBEB) // warm amber tint
            : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFFF59E0B) // amber border
              : AppTheme.border,
          width: isHighlighted ? 1.5 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: path ID + length badge ──────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFFF59E0B).withOpacity(0.15)
                        : AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isHighlighted
                          ? const Color(0xFFF59E0B).withOpacity(0.4)
                          : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    path.id,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isHighlighted
                          ? const Color(0xFF92400E)
                          : AppTheme.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${path.length} steps',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // ── Right: node chips with arrows ──────────
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _buildChips(),
              ),
            ),

            // ── Highlight indicator icon ───────────────
            if (isHighlighted)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 2),
                child: Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChips() {
  final chips = <Widget>[];
  
  for (int i = 0; i < path.nodes.length; i++) {
    final nodeName = path.nodes[i];
    final isActiveNode = highlightedNode == nodeName;

    chips.add(
      _NodeChip(
        label: nodeName,
        isActive: isActiveNode,
        onTap: () => onNodeTap(nodeName),
      ),
    );

    // Add connector AFTER each node except the last one
    if (i < path.nodes.length - 1) {
      final connectorLabel = i < path.connectors.length 
          ? path.connectors[i] 
          : null;
      
      chips.add(
        _PathConnector(
          label: connectorLabel,
          highlighted: isActiveNode,
        ),
      );
    }
  }
  
  return chips;
}

  // List<Widget> _buildChips() {
  //   final chips = <Widget>[];
  //   for (int i = 0; i < path.nodes.length; i++) {
  //     final nodeName = path.nodes[i];
  //     final isActiveNode = highlightedNode == nodeName;

  //     chips.add(
  //       _NodeChip(
  //         label: nodeName,
  //         isActive: isActiveNode,
  //         onTap: () => onNodeTap(nodeName),
  //       ),
  //     );

  //     if (i < path.nodes.length - 1) {
  //       chips.add(
  //         Icon(
  //           Icons.arrow_forward,
  //           size: 12,
  //           color: isActiveNode
  //               ? const Color(0xFFF59E0B)
  //               : AppTheme.textTertiary,
  //         ),
  //       );
  //     }
  //   }
  //   return chips;
  // }
}

// ─────────────────────────────────────────────────────────────────────────────
// Node Chip — clickable, highlights when selected
// ─────────────────────────────────────────────────────────────────────────────
class _NodeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NodeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFF59E0B).withOpacity(0.18)
              : AppTheme.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? const Color(0xFFF59E0B)
                : AppTheme.primary.withOpacity(0.2),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? const Color(0xFF92400E)
                : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Highlight Banner — shown when a node is selected
// ─────────────────────────────────────────────────────────────────────────────
class _HighlightBanner extends StatelessWidget {
  final String nodeName;
  final int matchCount;
  final VoidCallback onClear;

  const _HighlightBanner({
    required this.nodeName,
    required this.matchCount,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.highlight_rounded,
              size: 15, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                children: [
                  const TextSpan(text: 'Showing paths containing  '),
                  TextSpan(
                    text: '"$nodeName"',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: '  —  $matchCount path${matchCount == 1 ? '' : 's'} highlighted',
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search paths...',
          prefixIcon:
              const Icon(Icons.search, size: 16, color: AppTheme.textTertiary),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 14),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            borderSide:
                const BorderSide(color: AppTheme.primaryLight, width: 2),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Length filter dropdown
// ─────────────────────────────────────────────────────────────────────────────
class _LengthFilter extends StatelessWidget {
  final List<int> availableLengths;
  final int? selectedLength;
  final ValueChanged<int?> onChanged;

  const _LengthFilter({
    required this.availableLengths,
    required this.selectedLength,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      value: selectedLength,
      hint: const Text('All Lengths', style: TextStyle(fontSize: 12)),
      style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          borderSide:
              const BorderSide(color: AppTheme.primaryLight, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('All Lengths', style: TextStyle(fontSize: 12)),
        ),
        ...availableLengths.map((l) => DropdownMenuItem<int?>(
              value: l,
              child:
                  Text('Length: $l', style: const TextStyle(fontSize: 12)),
            )),
      ],
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result count badge
// ─────────────────────────────────────────────────────────────────────────────
class _ResultCount extends StatelessWidget {
  final int count;
  final int total;

  const _ResultCount({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        '$count / $total',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty filter result
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyFilterResult extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyFilterResult({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 36, color: AppTheme.textTertiary),
          const SizedBox(height: 12),
          const Text(
            'No paths match your filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onClear,
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }
}

