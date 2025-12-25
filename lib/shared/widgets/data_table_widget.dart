import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';

class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final VoidCallback? onRowTap;
  final Widget Function(int index)? trailingBuilder;
  final bool isResponsive;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.trailingBuilder,
    this.isResponsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile && isResponsive) {
      return _buildMobileView(context);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.gray100),
            dataRowColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return AppColors.gray50;
                }
                return AppColors.white;
              },
            ),
            columns: columns.map((column) {
              return DataColumn(
                label: Text(
                  column,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            rows: rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              
              return DataRow(
                cells: [
                  ...row.map((cell) => DataCell(
                    cell,
                    onTap: onRowTap,
                  )),
                  if (trailingBuilder != null)
                    DataCell(trailingBuilder!(index)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Column(
      children: rows.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.borderLight),
          ),
          child: InkWell(
            onTap: onRowTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...columns.asMap().entries.map((colEntry) {
                    final colIndex = colEntry.key;
                    if (colIndex >= row.length) return const SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${columns[colIndex]}:',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: row[colIndex],
                          ),
                        ],
                      ),
                    );
                  }),
                  if (trailingBuilder != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: trailingBuilder!(index),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

