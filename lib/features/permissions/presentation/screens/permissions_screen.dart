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
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../providers/permissions_provider.dart';
import 'add_permission_screen.dart';
import 'edit_permission_screen.dart';
import 'view_permission_screen.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final permissionsAsync = ref.watch(permissionsNotifierProvider);
    final user = ref.watch(authProvider);
    final userRole = Permissions.getUserRole(user);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return permissionsAsync.when(
      data: (allPermissions) {
        // Filter permissions for residents (only their own)
        final permissions = userRole == UserRole.resident && user?.flatNo != null
            ? allPermissions.where((p) => p.flatNumber == user!.flatNo).toList()
            : allPermissions;
        
        final thisMonth = permissions.where((p) {
          final now = DateTime.now();
          return p.createdAt.month == now.month && p.createdAt.year == now.year;
        }).length;
        final pending = permissions.where((p) => (p.status ?? 'Pending') == 'Pending').length;
        
        // Filter permissions based on search query
        final filteredPermissions = _searchQuery.isEmpty
            ? permissions
            : permissions.where((p) {
                final query = _searchQuery.toLowerCase();
                return p.residentName.toLowerCase().contains(query) ||
                    (p.phoneNumber?.toLowerCase().contains(query) ?? false) ||
                    (p.email?.toLowerCase().contains(query) ?? false) ||
                    (p.flatNumber?.toLowerCase().contains(query) ?? false) ||
                    p.permissionText.toLowerCase().contains(query);
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
                          Text('Permissions Management', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and track resident permissions',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Add Permission',
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
                              Text('Permissions Management', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage and track resident permissions',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Add Permission',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPermissionScreen(),
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
                      title: 'Total Permissions',
                      value: '${permissions.length}',
                      subtitle: 'All permissions',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.description,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'This Month',
                      value: '$thisMonth',
                      subtitle: 'Permissions this month',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.calendar_today,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Pending',
                      value: '$pending',
                      subtitle: 'Pending permissions',
                      borderColor: AppColors.warningYellow,
                      valueColor: AppColors.warningYellow,
                      icon: Icons.pending,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search permissions by name, phone, email, flat, wing, or permission text...',
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
                
                // Permissions Table/Cards
                filteredPermissions.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No permissions found',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : isMobile
                        ? Column(
                            children: filteredPermissions.map((permission) {
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
                                                Text(permission.residentName, style: AppTextStyles.h4),
                                                const SizedBox(height: 4),
                                                Text(permission.flatNumber ?? 'N/A', style: AppTextStyles.bodySmall),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(permission.status ?? 'Pending').withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              permission.status ?? 'Pending',
                                              style: TextStyle(
                                                color: _getStatusColor(permission.status ?? 'Pending'),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(permission.permissionText, style: AppTextStyles.bodyMedium),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(permission.phoneNumber ?? 'N/A', style: AppTextStyles.bodySmall),
                                          const SizedBox(width: 16),
                                          Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(permission.email ?? 'N/A', style: AppTextStyles.bodySmall),
                                          ),
                                        ],
                                      ),
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
                                                  builder: (context) => ViewPermissionScreen(permission: permission),
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
                                                  builder: (context) => EditPermissionScreen(permission: permission),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () {
                                              ref.read(permissionsNotifierProvider.notifier).deletePermission(permission.id);
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
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Flat')),
                                  DataColumn(label: Text('Permission')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Created Date')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: filteredPermissions.map((permission) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(permission.residentName)),
                                      DataCell(Text(permission.phoneNumber ?? 'N/A')),
                                      DataCell(Text(permission.email ?? 'N/A')),
                                      DataCell(Text(permission.flatNumber ?? 'N/A')),
                                      DataCell(
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            permission.permissionText,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(permission.status ?? 'Pending').withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            permission.status ?? 'Pending',
                                            style: TextStyle(
                                              color: _getStatusColor(permission.status ?? 'Pending'),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(AppFormatters.dateShort(permission.createdAt))),
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
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditPermissionScreen(permission: permission),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                              onPressed: () {
                                                ref.read(permissionsNotifierProvider.notifier).deletePermission(permission.id);
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
                        ShimmerLoading(width: 220, height: 32),
                        const SizedBox(height: 8),
                        ShimmerLoading(width: 260, height: 16),
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
                            ShimmerLoading(width: 220, height: 32),
                            const SizedBox(height: 8),
                            ShimmerLoading(width: 260, height: 16),
                          ],
                        ),
                        ShimmerLoading(width: 160, height: 56),
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
                    'Error loading permissions',
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warningYellow;
      case 'approved':
        return AppColors.successGreen;
      case 'rejected':
        return AppColors.errorRed;
      default:
        return AppColors.textSecondary;
    }
  }
}
