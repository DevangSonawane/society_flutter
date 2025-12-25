import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../shared/widgets/data_table_widget.dart';
import '../../../../shared/widgets/table_action_buttons.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/animations/shimmer_loading.dart';
import '../../../../shared/widgets/animated_dialog.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/deposit_model.dart';
import '../../providers/deposits_provider.dart';
import 'add_deposit_screen.dart';

class DepositRenovationScreen extends ConsumerStatefulWidget {
  const DepositRenovationScreen({super.key});

  @override
  ConsumerState<DepositRenovationScreen> createState() => _DepositRenovationScreenState();
}

class _DepositRenovationScreenState extends ConsumerState<DepositRenovationScreen> {
  String _searchQuery = '';

  Color _getStatusColor(DepositStatus status) {
    switch (status) {
      case DepositStatus.pending:
        return AppColors.warningYellow;
      case DepositStatus.refunded:
        return AppColors.successGreen;
      case DepositStatus.forfeited:
        return AppColors.errorRed;
    }
  }

  String _getStatusLabel(DepositStatus status) {
    switch (status) {
      case DepositStatus.pending:
        return 'Pending';
      case DepositStatus.refunded:
        return 'Refunded';
      case DepositStatus.forfeited:
        return 'Forfeited';
    }
  }

  Future<void> _deleteDeposit(String id, String flatNumber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AnimatedAlertDialog(
        title: 'Delete Deposit',
        content: Text('Are you sure you want to delete deposit for flat $flatNumber? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(depositsNotifierProvider.notifier).deleteDeposit(id);
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Deposit deleted successfully',
            type: SnackbarType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Error deleting deposit: ${e.toString()}',
            type: SnackbarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositsAsync = ref.watch(depositsNotifierProvider);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return depositsAsync.when(
      data: (deposits) {
        final thisMonth = deposits.where((d) {
          final now = DateTime.now();
          return d.createdAt.month == now.month && d.createdAt.year == now.year;
        }).length;
        final pending = deposits.where((d) => d.status == DepositStatus.pending).length;
        final totalAmount = deposits.fold<double>(0, (sum, d) => sum + d.amount);
        
        final filteredDeposits = _searchQuery.isEmpty
            ? deposits
            : deposits.where((d) {
                final query = _searchQuery.toLowerCase();
                return d.flatNumber.toLowerCase().contains(query) ||
                    (d.ownerName != null && d.ownerName!.toLowerCase().contains(query)) ||
                    (d.phoneNumber != null && d.phoneNumber!.toLowerCase().contains(query));
              }).toList();

        return Container(
          color: AppColors.backgroundLight,
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deposit on Renovation', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage deposits collected for renovation work',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Add Deposit',
                              icon: Icons.add,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddDepositScreen(),
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
                              Text('Deposit on Renovation', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage deposits collected for renovation work',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Add Deposit',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddDepositScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                
                ResponsiveStatisticsGrid(
                  children: [
                    StatisticsCard(
                      title: 'Total Deposits',
                      value: AppFormatters.currency(totalAmount),
                      subtitle: '${deposits.length} deposits',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.account_balance_wallet,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'This Month',
                      value: '$thisMonth',
                      subtitle: 'Deposits this month',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.calendar_today,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Pending',
                      value: '$pending',
                      subtitle: 'Pending deposits',
                      borderColor: AppColors.warningYellow,
                      valueColor: AppColors.warningYellow,
                      icon: Icons.pending,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by flat number, owner name, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                
                filteredDeposits.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.account_balance_wallet,
                        title: 'No deposits found',
                        message: _searchQuery.isEmpty
                            ? 'Add your first deposit to get started'
                            : 'Try adjusting your search query',
                      )
                    : isMobile
                        ? Column(
                            children: filteredDeposits.map((deposit) {
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
                                                Text(
                                                  deposit.flatNumber,
                                                  style: AppTextStyles.h4,
                                                ),
                                                if (deposit.ownerName != null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    deposit.ownerName!,
                                                    style: AppTextStyles.bodySmall,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(deposit.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _getStatusLabel(deposit.status),
                                              style: TextStyle(
                                                color: _getStatusColor(deposit.status),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Amount: ${AppFormatters.currency(deposit.amount)}',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Date: ${AppFormatters.date(deposit.depositDate)}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () => _deleteDeposit(deposit.id, deposit.flatNumber),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : DataTableWidget(
                            columns: const [
                              'Flat Number',
                              'Owner',
                              'Amount',
                              'Date',
                              'Status',
                              'Actions',
                            ],
                            rows: filteredDeposits.map((deposit) {
                              return [
                                Text(deposit.flatNumber),
                                Text(deposit.ownerName ?? 'N/A'),
                                Text(AppFormatters.currency(deposit.amount)),
                                Text(AppFormatters.date(deposit.depositDate)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(deposit.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getStatusLabel(deposit.status),
                                    style: TextStyle(
                                      color: _getStatusColor(deposit.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TableActionButtons(
                                  onDelete: () => _deleteDeposit(deposit.id, deposit.flatNumber),
                                ),
                              ];
                            }).toList(),
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
              ShimmerLoading(width: 200, height: 32),
              const SizedBox(height: 24),
              ResponsiveStatisticsGrid(
                children: List.generate(3, (index) => const ShimmerLoading(width: double.infinity, height: 120)),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => ErrorStateWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(depositsNotifierProvider),
      ),
    );
  }
}

