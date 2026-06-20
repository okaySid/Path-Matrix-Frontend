import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AppDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? dataRowHeight;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.dataRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppTheme.borderLight),
              headingRowHeight: 40,
              dataRowMinHeight: dataRowHeight ?? 48,
              dataRowMaxHeight: dataRowHeight ?? 56,
              dividerThickness: 1,
              border: TableBorder(
                horizontalInside: BorderSide(color: AppTheme.border, width: 1),
              ),
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.3,
              ),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }
}
