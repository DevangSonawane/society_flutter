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
import '../../providers/complaints_provider.dart';
import 'add_complaint_screen.dart';
import 'edit_complaint_screen.dart';
import 'view_complaint_screen.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(complaintsNotifierProvider);
    final user = ref.watch(authProvider);
    final userRole = Permissions.getUserRole(user);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return complaintsAsync.when(
      data: (allComplaints) {
        // Filter complaints for residents (only their own)
        final complaints = userRole == UserRole.resident && user?.flatNo != null
            ? allComplaints.where((c) => c.flatNumber == user!.flatNo).toList()
            : allComplaints;
        
        final thisMonth = complaints.where((c) {
          final now = DateTime.now();
          return c.createdAt.month == now.month && c.createdAt.year == now.year;
        }).length;
        final pending = complaints.where((c) => (c.status ?? 'Pending') == 'Pending').length;
        
        // Filter complaints based on search query
        final filteredComplaints = _searchQuery.isEmpty
            ? complaints
            : complaints.where((c) {
                final query = _searchQuery.toLowerCase();
                return c.complainerName.toLowerCase().contains(query) ||
                    (c.phoneNumber?.toLowerCase().contains(query) ?? false) ||
                    (c.email?.toLowerCase().contains(query) ?? false) ||
                    (c.flatNumber?.toLowerCase().contains(query) ?? false) ||
                    c.complaintText.toLowerCase().contains(query);
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
                          Text('Complaints Management', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and track resident complaints',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Add Complaint',
                              icon: Icons.add,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddComplaintScreen(),
                                  ),
                                );
                              },
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
                              Text('Complaints Management', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage and track resident complaints',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Add Complaint',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddComplaintScreen(),
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
                      title: 'Total Complaints',
                      value: '${complaints.length}',
                      subtitle: 'All complaints',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.report_problem,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'This Month',
                      value: '$thisMonth',
                      subtitle: 'Complaints this month',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.calendar_today,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Pending',
                      value: '$pending',
                      subtitle: 'Pending complaints',
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
                    hintText: 'Search complaints by name, phone, email, flat, wing, or complaint text...',
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
                
                // Complaints Table/Cards
                filteredComplaints.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No complaints found',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : isMobile
                        ? Column(
                            children: filteredComplaints.map((complaint) {
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
                                                Text(complaint.complainerName, style: AppTextStyles.h4),
                                                const SizedBox(height: 4),
                                                Text(complaint.flatNumber ?? 'N/A', style: AppTextStyles.bodySmall),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(complaint.status ?? 'Pending').withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              complaint.status ?? 'Pending',
                                              style: TextStyle(
                                                color: _getStatusColor(complaint.status ?? 'Pending'),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(complaint.complaintText, style: AppTextStyles.bodyMedium),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(complaint.phoneNumber ?? 'N/A', style: AppTextStyles.bodySmall),
                                          const SizedBox(width: 16),
                                          Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(complaint.email ?? 'N/A', style: AppTextStyles.bodySmall),
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
                                                  builder: (context) => ViewComplaintScreen(complaint: complaint),
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
                                                  builder: (context) => EditComplaintScreen(complaint: complaint),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () {
                                              ref.read(complaintsNotifierProvider.notifier).deleteComplaint(complaint.id);
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
                                  DataColumn(label: Text('Complaint')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Created Date')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: filteredComplaints.map((complaint) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(complaint.complainerName)),
                                      DataCell(Text(complaint.phoneNumber ?? 'N/A')),
                                      DataCell(Text(complaint.email ?? 'N/A')),
                                      DataCell(Text(complaint.flatNumber ?? 'N/A')),
                                      DataCell(
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            complaint.complaintText,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(complaint.status ?? 'Pending').withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            complaint.status ?? 'Pending',
                                            style: TextStyle(
                                              color: _getStatusColor(complaint.status ?? 'Pending'),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(AppFormatters.dateShort(complaint.createdAt))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.visibility, size: 20),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ViewComplaintScreen(complaint: complaint),
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
                                                    builder: (context) => EditComplaintScreen(complaint: complaint),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                              onPressed: () {
                                                ref.read(complaintsNotifierProvider.notifier).deleteComplaint(complaint.id);
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
                        ShimmerLoading(width: 250, height: 16),
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
                            ShimmerLoading(width: 250, height: 16),
                          ],
                        ),
                        ShimmerLoading(width: 150, height: 56),
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
                    'Error loading complaints',
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
      case 'resolved':
        return AppColors.successGreen;
      case 'in progress':
        return AppColors.infoBlue;
      default:
        return AppColors.textSecondary;
    }
  }
}
