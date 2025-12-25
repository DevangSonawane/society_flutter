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
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/users_provider.dart';
import 'create_user_screen.dart';
import 'edit_user_screen.dart';
import 'view_user_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersNotifierProvider);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return usersAsync.when(
      data: (users) {
        final admins = users.where((u) => u.role == 'Admin').length;
        final receptionists = users.where((u) => u.role == 'Receptionist').length;
        final residents = users.where((u) => u.role == 'Resident').length;
        
        // Filter users based on search query
        final filteredUsers = _searchQuery.isEmpty
            ? users
            : users.where((u) {
                final query = _searchQuery.toLowerCase();
                return u.name.toLowerCase().contains(query) ||
                    u.email.toLowerCase().contains(query) ||
                    (u.phone?.toLowerCase().contains(query) ?? false) ||
                    u.role.toLowerCase().contains(query) ||
                    (u.flatNumber?.toLowerCase().contains(query) ?? false);
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
                          Text('User Management', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage all system users',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Create User',
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
                              Text('User Management', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage all system users',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Create User',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateUserScreen(),
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
                      title: 'Total Users',
                      value: '${users.length}',
                      subtitle: 'All system users',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.people,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Admins',
                      value: '$admins',
                      subtitle: 'Administrators',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.shield,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Receptionists',
                      value: '$receptionists',
                      subtitle: 'Staff members',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.person,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Residents',
                      value: '$residents',
                      subtitle: 'Resident users',
                      borderColor: AppColors.successGreen,
                      valueColor: AppColors.successGreen,
                      icon: Icons.home,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
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
                
                // Users Table/Cards
                filteredUsers.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No users found',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : isMobile
                        ? Column(
                            children: filteredUsers.map((user) {
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
                                                Text(user.name, style: AppTextStyles.h4),
                                                const SizedBox(height: 4),
                                                Text(user.email, style: AppTextStyles.bodySmall),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getRoleColor(user.role).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              user.role,
                                              style: TextStyle(
                                                color: _getRoleColor(user.role),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (user.phone != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(user.phone!, style: AppTextStyles.bodySmall),
                                          ],
                                        ),
                                      ],
                                      if (user.flatNumber != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.home, size: 16, color: AppColors.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(user.flatNumber!, style: AppTextStyles.bodySmall),
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
                                                  builder: (context) => ViewUserScreen(user: user),
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
                                                  builder: (context) => EditUserScreen(user: user),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () {
                                              ref.read(usersNotifierProvider.notifier).deleteUser(user.id);
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
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Flat Number')),
                                  DataColumn(label: Text('Created Date')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: filteredUsers.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user.name)),
                                      DataCell(Text(user.email)),
                                      DataCell(Text(user.phone ?? '-')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(user.role).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user.role,
                                            style: TextStyle(
                                              color: _getRoleColor(user.role),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(user.flatNumber ?? '-')),
                                      DataCell(Text(AppFormatters.dateShort(user.createdAt))),
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
                                                ref.read(usersNotifierProvider.notifier).deleteUser(user.id);
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
                        ShimmerLoading(width: 180, height: 32),
                        const SizedBox(height: 8),
                        ShimmerLoading(width: 200, height: 16),
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
                            ShimmerLoading(width: 180, height: 32),
                            const SizedBox(height: 8),
                            ShimmerLoading(width: 200, height: 16),
                          ],
                        ),
                        ShimmerLoading(width: 140, height: 56),
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
                    'Error loading users',
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.primaryPurple;
      case 'receptionist':
        return AppColors.infoBlue;
      case 'resident':
        return AppColors.successGreen;
      default:
        return AppColors.textSecondary;
    }
  }
}
