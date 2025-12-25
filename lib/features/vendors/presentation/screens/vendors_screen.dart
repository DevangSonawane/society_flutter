import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../shared/widgets/responsive_action_bar.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/vendors_provider.dart';
import 'add_vendor_screen.dart';
import 'edit_vendor_screen.dart';
import 'view_vendor_screen.dart';
import 'create_invoice_screen.dart';

class VendorsScreen extends ConsumerStatefulWidget {
  const VendorsScreen({super.key});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(vendorsNotifierProvider);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return vendorsAsync.when(
      data: (vendors) {
        final totalBill = vendors.fold<double>(0, (sum, v) => sum + v.totalBill);
        final totalPaid = vendors.fold<double>(0, (sum, v) => sum + v.paidAmount);
        
        // Filter vendors based on search query
        final filteredVendors = _searchQuery.isEmpty
            ? vendors
            : vendors.where((v) {
                final query = _searchQuery.toLowerCase();
                return v.name.toLowerCase().contains(query) ||
                    v.email.toLowerCase().contains(query) ||
                    (v.phone?.toLowerCase().contains(query) ?? false) ||
                    (v.workType?.toLowerCase().contains(query) ?? false);
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
                          Text('Vendor Management', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage vendors, invoices, and track payments',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  text: 'Add Vendor',
                                  icon: Icons.add,
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  text: 'Create Invoice',
                                  icon: Icons.receipt,
                                  onPressed: () {},
                                  type: ButtonType.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vendor Management', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage vendors, invoices, and track payments',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          ResponsiveActionBar(
                            children: [
                              CustomButton(
                                text: 'Create Invoice',
                                icon: Icons.receipt,
                                onPressed: () {
                                  // Show vendor selection dialog or use first vendor
                                  if (vendors.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateInvoiceScreen(vendor: vendors.first),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('No vendors available'),
                                        backgroundColor: AppColors.warningYellow,
                                      ),
                                    );
                                  }
                                },
                                type: ButtonType.secondary,
                              ),
                              CustomButton(
                                text: 'Add Vendor',
                                icon: Icons.add,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddVendorScreen(),
                                    ),
                                  );
                                },
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
                      title: 'Total Vendors',
                      value: '${vendors.length}',
                      subtitle: 'Registered vendors',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.business,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Total Bill',
                      value: AppFormatters.currency(totalBill),
                      subtitle: 'All time',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.attach_money,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Paid',
                      value: AppFormatters.currency(totalPaid),
                      subtitle: 'Amount paid',
                      borderColor: AppColors.successGreen,
                      valueColor: AppColors.successGreen,
                      icon: Icons.check_circle,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search vendors by name, email, phone, or work details...',
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
                
                // Vendors Table/Cards
                filteredVendors.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No vendors found',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : isMobile
                        ? Column(
                            children: filteredVendors.map((vendor) {
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
                                                Text(vendor.name, style: AppTextStyles.h4),
                                                const SizedBox(height: 4),
                                                Text(vendor.email, style: AppTextStyles.bodySmall),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: vendor.status == 'Paid'
                                                  ? AppColors.successGreenLight
                                                  : AppColors.warningYellowLight,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              vendor.status,
                                              style: TextStyle(
                                                color: vendor.status == 'Paid'
                                                    ? AppColors.successGreen
                                                    : AppColors.warningYellow,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Total Bill', style: AppTextStyles.bodySmall),
                                                Text(AppFormatters.currency(vendor.totalBill), style: AppTextStyles.bodyMedium),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Paid', style: AppTextStyles.bodySmall),
                                                Text(AppFormatters.currency(vendor.paidAmount), style: AppTextStyles.bodyMedium),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Pending', style: AppTextStyles.bodySmall),
                                                Text(AppFormatters.currency(vendor.outstandingBill), style: AppTextStyles.bodyMedium),
                                              ],
                                            ),
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
                                                  builder: (context) => ViewVendorScreen(vendor: vendor),
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
                                                  builder: (context) => EditVendorScreen(vendor: vendor),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () {
                                              ref.read(vendorsNotifierProvider.notifier).deleteVendor(vendor.id);
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
                                  DataColumn(label: Text('Work Type')),
                                  DataColumn(label: Text('Total Bill')),
                                  DataColumn(label: Text('Paid')),
                                  DataColumn(label: Text('Pending')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: filteredVendors.map((vendor) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(vendor.name)),
                                      DataCell(Text(vendor.email)),
                                      DataCell(Text(vendor.phone ?? 'N/A')),
                                      DataCell(Text(vendor.workType ?? 'N/A')),
                                      DataCell(Text(AppFormatters.currency(vendor.totalBill))),
                                      DataCell(Text(AppFormatters.currency(vendor.paidAmount))),
                                      DataCell(Text(AppFormatters.currency(vendor.outstandingBill))),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: vendor.status == 'Paid'
                                                ? AppColors.successGreenLight
                                                : AppColors.warningYellowLight,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            vendor.status,
                                            style: TextStyle(
                                              color: vendor.status == 'Paid'
                                                  ? AppColors.successGreen
                                                  : AppColors.warningYellow,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
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
                                                    builder: (context) => ViewVendorScreen(vendor: vendor),
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
                                                    builder: (context) => EditVendorScreen(vendor: vendor),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                              onPressed: () {
                                                ref.read(vendorsNotifierProvider.notifier).deleteVendor(vendor.id);
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
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
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
                  'Error loading vendors',
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
      ),
    );
  }
}
