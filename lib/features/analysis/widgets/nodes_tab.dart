import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/analysis_models.dart';
import 'data_table_widget.dart';

class NodesTab extends StatefulWidget {
  final List<NodeModel> nodes;

  const NodesTab({super.key, required this.nodes});

  @override
  State<NodesTab> createState() => _NodesTabState();
}

class _NodesTabState extends State<NodesTab> {
  String _searchQuery = '';

  List<NodeModel> get _filtered => widget.nodes
      .where((n) =>
          _searchQuery.isEmpty ||
          n.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.id.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search nodes by name or ID...',
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
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${_filtered.length} nodes',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AppDataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Node Name')),
                DataColumn(label: Text('Node ID')),
                DataColumn(label: Text('')),
              ],
              rows: _filtered.asMap().entries.map((entry) {
                final index = entry.key;
                final node = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.monitor_outlined,
                              size: 14,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            node.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          node.id,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 14, color: AppTheme.textTertiary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: node.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Node ID copied'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              width: 160,
                            ),
                          );
                        },
                        tooltip: 'Copy ID',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
