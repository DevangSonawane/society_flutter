import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../providers/maintenance_payments_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../data/models/maintenance_payment_model.dart';

class ResidentMaintenanceScreen extends ConsumerWidget {
  const ResidentMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final padding = Responsive.getScreenPadding(context);

    if (user?.flatNo == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('My Maintenance Payments'),
          backgroundColor: AppColors.white,
        ),
        body: Center(
          child: Padding(
            padding: padding,
            child: Text(
              'Flat number not found. Please contact administrator.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final paymentsAsync = ref.watch(residentMaintenancePaymentsProvider(user!.flatNo!));

    return paymentsAsync.when(
      data: (myPayments) {
        // Calculate statistics
        final totalPaid = myPayments
            .where((p) => p.status == PaymentStatus.paid)
            .fold<double>(0, (sum, p) => sum + p.amount);
        
        final totalUnpaid = myPayments
            .where((p) => p.status == PaymentStatus.unpaid || p.status == PaymentStatus.overdue)
            .fold<double>(0, (sum, p) => sum + p.amount);
        
        final totalPending = myPayments
            .where((p) => p.status == PaymentStatus.partial)
            .fold<double>(0, (sum, p) => sum + p.amount);

        final paidCount = myPayments.where((p) => p.status == PaymentStatus.paid).length;
        final unpaidCount = myPayments.where((p) => 
          p.status == PaymentStatus.unpaid || p.status == PaymentStatus.overdue
        ).length;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('My Maintenance Payments'),
            backgroundColor: AppColors.white,
          ),
          body: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics
                ResponsiveStatisticsGrid(
                  children: [
                    StatisticsCard(
                      title: 'Total Paid',
                      value: AppFormatters.currency(totalPaid),
                      subtitle: '$paidCount payments',
                      icon: Icons.check_circle,
                      borderColor: AppColors.successGreen,
                      valueColor: AppColors.successGreen,
                    ),
                    StatisticsCard(
                      title: 'Unpaid',
                      value: AppFormatters.currency(totalUnpaid),
                      subtitle: '$unpaidCount pending',
                      icon: Icons.pending,
                      borderColor: AppColors.warningYellow,
                      valueColor: AppColors.warningYellow,
                    ),
                    StatisticsCard(
                      title: 'Pending',
                      value: AppFormatters.currency(totalPending),
                      subtitle: 'Partial payments',
                      icon: Icons.schedule,
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Payment History
                Text('Payment History', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                
                if (myPayments.isEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No maintenance payments found',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...myPayments.map((payment) => _buildPaymentCard(context, ref, payment)),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('My Maintenance Payments'),
          backgroundColor: AppColors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('My Maintenance Payments'),
          backgroundColor: AppColors.white,
        ),
        body: Center(
          child: Padding(
            padding: padding,
            child: Text(
              'Error loading payments: $error',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    WidgetRef ref,
    MaintenancePaymentModel payment,
  ) {
    final statusColor = _getStatusColor(payment.status);
    final statusText = payment.status.name.toUpperCase();
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                        '${_getMonthName(payment.month)} ${payment.year}',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flat ${payment.flatNumber}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.borderLight),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount:', style: AppTextStyles.bodyMedium),
                Text(
                  AppFormatters.currency(payment.amount),
                  style: AppTextStyles.h4.copyWith(color: AppColors.primaryPurple),
                ),
              ],
            ),
            if (payment.paidDate != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid Date:', style: AppTextStyles.bodySmall),
                  Text(
                    AppFormatters.dateShort(payment.paidDate!),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              if (payment.paymentMethod != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Method:', style: AppTextStyles.bodySmall),
                    Text(
                      payment.paymentMethod!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
              if (payment.receiptNumber != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Receipt Number:', style: AppTextStyles.bodySmall),
                    Text(
                      payment.receiptNumber!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            if (payment.status != PaymentStatus.paid) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Due Date:', style: AppTextStyles.bodySmall),
                  Text(
                    AppFormatters.dateShort(payment.dueDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: payment.status == PaymentStatus.overdue
                          ? AppColors.errorRed
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            if (payment.status == PaymentStatus.unpaid || payment.status == PaymentStatus.overdue) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Pay Now',
                  icon: Icons.payment,
                  onPressed: () {
                    // TODO: Navigate to payment screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment functionality coming soon'),
                        backgroundColor: AppColors.primaryPurple,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.successGreen;
      case PaymentStatus.overdue:
        return AppColors.errorRed;
      case PaymentStatus.partial:
        return AppColors.warningYellow;
      case PaymentStatus.unpaid:
        return AppColors.warningYellow;
    }
  }

  String _getMonthName(int month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

