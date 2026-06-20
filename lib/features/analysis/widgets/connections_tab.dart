import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/analysis_models.dart';
import 'data_table_widget.dart';

class ConnectionsTab extends StatefulWidget {
  final List<ConnectionModel> connections;

  const ConnectionsTab({super.key, required this.connections});

  @override
  State<ConnectionsTab> createState() => _ConnectionsTabState();
}

class _ConnectionsTabState extends State<ConnectionsTab> {
  String _searchQuery = '';

  List<ConnectionModel> get _filtered => widget.connections
      .where((c) =>
          _searchQuery.isEmpty ||
          c.sourceName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.targetName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.sourceId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.targetId.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
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
                      hintText: 'Search connections...',
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
                  '${_filtered.length} connections',
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
                DataColumn(label: Text('Source Node')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('Target Node')),
              ],
              rows: _filtered.asMap().entries.map((entry) {
                final index = entry.key;
                final conn = entry.value;
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
                      _NodeCell(
                        name: conn.sourceName,
                        id: conn.sourceId,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    const DataCell(
                      Icon(Icons.arrow_forward, size: 16, color: AppTheme.textTertiary),
                    ),
                    DataCell(
                      _NodeCell(
                        name: conn.targetName,
                        id: conn.targetId,
                        color: AppTheme.accent,
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

class _NodeCell extends StatelessWidget {
  final String name;
  final String id;
  final Color color;

  const _NodeCell({
    required this.name,
    required this.id,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              id,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
