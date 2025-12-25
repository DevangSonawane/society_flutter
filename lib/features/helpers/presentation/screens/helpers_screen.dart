import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../shared/widgets/animations/shimmer_loading.dart';
import '../../../../shared/widgets/animations/fade_in_widget.dart';
import '../../providers/helpers_provider.dart';
import 'add_helper_screen.dart';
import 'edit_helper_screen.dart';
import 'view_helper_screen.dart';

class HelpersScreen extends ConsumerStatefulWidget {
  const HelpersScreen({super.key});

  @override
  ConsumerState<HelpersScreen> createState() => _HelpersScreenState();
}

class _HelpersScreenState extends ConsumerState<HelpersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final helpersAsync = ref.watch(helpersNotifierProvider);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return helpersAsync.when(
      data: (helpers) {
        final totalMen = helpers.where((h) => h.gender == 'Male').length;
        final totalWomen = helpers.where((h) => h.gender == 'Female').length;
        
        // Filter helpers based on search query
        final filteredHelpers = _searchQuery.isEmpty
            ? helpers
            : helpers.where((h) {
                final query = _searchQuery.toLowerCase();
                return h.name.toLowerCase().contains(query) ||
                    (h.phone?.toLowerCase().contains(query) ?? false) ||
                    (h.helperType?.toLowerCase().contains(query) ?? false) ||
                    (h.notes?.toLowerCase().contains(query) ?? false) ||
                    h.assignedFlats.any((flat) => flat.toLowerCase().contains(query));
              }).toList();
        
        return Container(
          color: AppColors.backgroundLight,
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Helper Management', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage helpers and link them to the flats/rooms they work in',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Add Helper',
                              icon: Icons.add,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Helper Management', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage helpers and link them to the flats/rooms they work in',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Add Helper',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddHelperScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                
                // Statistics Cards
                ResponsiveStatisticsGrid(
                  children: [
                    StatisticsCard(
                      title: 'Total Helpers',
                      value: '${helpers.length}',
                      subtitle: 'Registered helpers',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.build,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Total Men',
                      value: '$totalMen',
                      subtitle: 'Male helpers',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.person,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Total Women',
                      value: '$totalWomen',
                      subtitle: 'Female helpers',
                      borderColor: AppColors.warningYellow,
                      valueColor: AppColors.warningYellow,
                      icon: Icons.person_outline,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search helpers by name, phone, type, or notes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                // Helpers Table/Cards
                filteredHelpers.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No helpers found',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : isMobile
                        ? Column(
                            children: filteredHelpers.map((helper) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(helper.name, style: AppTextStyles.h4),
                                                const SizedBox(height: 4),
                                                Text(helper.phone ?? 'N/A', style: AppTextStyles.bodySmall),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.home, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(helper.helperType ?? 'N/A', style: AppTextStyles.bodySmall),
                                          const SizedBox(width: 16),
                                          Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(helper.gender ?? 'N/A', style: AppTextStyles.bodySmall),
                                        ],
                                      ),
                                      if (helper.assignedFlats.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                helper.assignedFlats.join(', '),
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, size: 20),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ViewHelperScreen(helper: helper),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditHelperScreen(helper: helper),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () {
                                              ref.read(helpersNotifierProvider.notifier).deleteHelper(helper.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : Card(
                            elevation: 0,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Type')),
                                  DataColumn(label: Text('Gender')),
                                  DataColumn(label: Text('Assigned Flats')),
                                  DataColumn(label: Text('Notes')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: filteredHelpers.map((helper) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(helper.name)),
                                      DataCell(Text(helper.phone ?? 'N/A')),
                                      DataCell(Text(helper.helperType ?? 'N/A')),
                                      DataCell(Text(helper.gender ?? 'N/A')),
                                      DataCell(Text(helper.assignedFlats.join(', '))),
                                      DataCell(Text(helper.notes ?? '-')),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.visibility, size: 20),
                                              onPressed: () {},
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 20),
                                              onPressed: () {},
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                              onPressed: () {
                                                ref.read(helpersNotifierProvider.notifier).deleteHelper(helper.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        color: AppColors.backgroundLight,
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(width: 200, height: 32),
                        const SizedBox(height: 8),
                        ShimmerLoading(width: 280, height: 16),
                        const SizedBox(height: 16),
                        ShimmerLoading(width: double.infinity, height: 56),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading(width: 200, height: 32),
                            const SizedBox(height: 8),
                            ShimmerLoading(width: 280, height: 16),
                          ],
                        ),
                        ShimmerLoading(width: 130, height: 56),
                      ],
                    ),
              const SizedBox(height: 24),
              
              // Statistics cards shimmer
              ResponsiveStatisticsGrid(
                children: [
                  const CardShimmer(),
                  const CardShimmer(),
                  const CardShimmer(),
                ],
              ),
              const SizedBox(height: 24),
              
              // Search shimmer
              ShimmerLoading(width: double.infinity, height: 56),
              const SizedBox(height: 24),
              
              // Table rows shimmer
              ...List.generate(3, (index) => const TableRowShimmer()),
            ],
          ),
        ),
      ),
      error: (error, stack) => Container(
        color: AppColors.backgroundLight,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInWidget(
                  delay: const Duration(milliseconds: 100),
                  child: const Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
                ),
                const SizedBox(height: 16),
                FadeInWidget(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Error loading helpers',
                    style: AppTextStyles.h3,
                  ),
                ),
                const SizedBox(height: 8),
                FadeInWidget(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
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
