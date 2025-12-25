import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../shared/widgets/responsive_action_bar.dart';
import '../../../../core/utils/formatters.dart';
import 'generate_payment_screen.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/csv_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/maintenance_payments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenancePaymentsScreen extends ConsumerWidget {
  const MaintenancePaymentsScreen({super.key});

  Future<void> _downloadAllInvoices(BuildContext context, List<dynamic> payments) async {
    try {
      // Generate PDFs for all unpaid payments
      final unpaidPayments = payments.where((p) => p['status'] == 'unpaid').toList();
      
      if (unpaidPayments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No unpaid invoices to download'),
            backgroundColor: AppColors.warningYellow,
          ),
        );
        return;
      }

      // Generate first invoice as example
      final firstPayment = unpaidPayments.first;
      final pdfFile = await PdfService.generateInvoice(
        residentName: firstPayment['residentName'] ?? '',
        flatNumber: firstPayment['flatNumber'] ?? '',
        amount: (firstPayment['amount'] as num?)?.toDouble() ?? 0.0,
        month: _getMonthName(firstPayment['month'] ?? 1),
        year: firstPayment['year'] ?? DateTime.now().year,
        invoiceNumber: firstPayment['id'] ?? 'INV-001',
      );

      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Maintenance Invoice');
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice downloaded successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading invoice: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _downloadAllReceipts(BuildContext context, List<dynamic> payments) async {
    try {
      // Generate PDFs for all paid payments
      final paidPayments = payments.where((p) => p['status'] == 'paid').toList();
      
      if (paidPayments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No paid receipts to download'),
            backgroundColor: AppColors.warningYellow,
          ),
        );
        return;
      }

      // Generate first receipt as example
      final firstPayment = paidPayments.first;
      final pdfFile = await PdfService.generateReceipt(
        residentName: firstPayment['residentName'] ?? '',
        flatNumber: firstPayment['flatNumber'] ?? '',
        amount: (firstPayment['amount'] as num?)?.toDouble() ?? 0.0,
        paymentDate: firstPayment['paidDate'] ?? DateTime.now().toString(),
        receiptNumber: firstPayment['receiptNumber'] ?? 'RCP-001',
        paymentMode: firstPayment['paymentMethod'] ?? 'Cash',
      );

      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Payment Receipt');
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt downloaded successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading receipt: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _exportCsv(BuildContext context, List<dynamic> payments) async {
    try {
      final paymentsData = payments.map((p) => {
        'residentName': p['residentName'] ?? '',
        'flatNumber': p['flatNumber'] ?? '',
        'amount': (p['amount'] as num?)?.toDouble() ?? 0.0,
        'month': _getMonthName(p['month'] ?? 1),
        'year': p['year'] ?? DateTime.now().year,
        'status': p['status'] ?? 'unpaid',
        'paymentDate': p['paidDate'] ?? '',
        'invoiceNumber': p['id'] ?? '',
      }).toList();

      final csvFile = await CsvService.exportPaymentsToCsv(paymentsData);
      await Share.shareXFiles([XFile(csvFile.path)], text: 'Maintenance Payments Export');
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV exported successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting CSV: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  String _getMonthName(int month) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.successGreen;
      case 'overdue':
        return AppColors.errorRed;
      case 'partial':
        return AppColors.warningYellow;
      case 'unpaid':
      default:
        return AppColors.warningYellow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(maintenancePaymentsProvider);
    
    return paymentsAsync.when(
      data: (payments) {
        final paymentsData = payments.map((p) => {
          'id': p.id,
          'residentName': p.residentName,
          'flatNumber': p.flatNumber,
          'amount': p.amount,
          'month': p.month,
          'year': p.year,
          'status': p.status.name,
          'paidDate': p.paidDate?.toString() ?? '',
          'receiptNumber': p.receiptNumber ?? '',
          'paymentMethod': p.paymentMethod ?? '',
        }).toList();
        return _buildContent(context, ref, paymentsData);
      },
      loading: () => _buildLoading(context),
      error: (error, stack) => _buildError(context, error),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> payments) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

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
                      Text('Maintenance Payments', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        'Generate and manage maintenance payment invoices',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Generate',
                          icon: Icons.add,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GeneratePaymentScreen(),
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
                          Text('Maintenance Payments', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Generate and manage maintenance payment invoices',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      ResponsiveActionBar(
                        children: [
                          CustomButton(
                            text: 'Generate',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GeneratePaymentScreen(),
                                ),
                              );
                            },
                          ),
                          CustomButton(
                            text: 'Download All Invoice',
                            icon: Icons.download,
                            onPressed: () => _downloadAllInvoices(context, payments),
                            type: ButtonType.secondary,
                          ),
                          CustomButton(
                            text: 'Download All Receipt',
                            icon: Icons.receipt,
                            onPressed: () => _downloadAllReceipts(context, payments),
                            type: ButtonType.secondary,
                          ),
                          CustomButton(
                            text: 'Export CSV',
                            icon: Icons.file_download,
                            onPressed: () => _exportCsv(context, payments),
                            type: ButtonType.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            
            // Statistics Cards
            ResponsiveStatisticsGrid(
              children: [
                StatisticsCard(
                  title: 'Total Collection',
                  value: AppFormatters.currency(16400),
                  subtitle: 'All time',
                  borderColor: AppColors.primaryPurple,
                  valueColor: AppColors.primaryPurple,
                  icon: Icons.account_balance_wallet,
                  showTrend: true,
                ),
                StatisticsCard(
                  title: 'Collected',
                  value: AppFormatters.currency(4350),
                  subtitle: '26.5% collection rate',
                  borderColor: AppColors.successGreen,
                  valueColor: AppColors.successGreen,
                  icon: Icons.check_circle,
                  showTrend: true,
                ),
                StatisticsCard(
                  title: 'Pending',
                  value: AppFormatters.currency(12050),
                  borderColor: AppColors.warningYellow,
                  valueColor: AppColors.warningYellow,
                  icon: Icons.pending,
                  showTrend: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Payments Table
            if (payments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No payments found. Generate payments to get started.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            else
              Card(
                elevation: 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Resident Name')),
                      DataColumn(label: Text('Flat Number')),
                      DataColumn(label: Text('Month/Year')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Due Date')),
                      DataColumn(label: Text('Paid Date')),
                    ],
                    rows: payments.map((p) {
                      final monthName = _getMonthName(p['month'] ?? 1);
                      final year = p['year'] ?? DateTime.now().year;
                      return DataRow(
                        cells: [
                          DataCell(Text(p['residentName'] ?? '')),
                          DataCell(Text(p['flatNumber'] ?? '')),
                          DataCell(Text('$monthName $year')),
                          DataCell(Text(AppFormatters.currency((p['amount'] as num?)?.toDouble() ?? 0.0))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(p['status'] ?? 'unpaid').withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p['status'] ?? 'unpaid',
                                style: TextStyle(
                                  color: _getStatusColor(p['status'] ?? 'unpaid'),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(p['dueDate'] ?? '')),
                          DataCell(Text(p['paidDate'] ?? '-')),
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
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Container(
      color: AppColors.backgroundLight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
              const SizedBox(height: 16),
              Text(
                'Error loading payments',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
