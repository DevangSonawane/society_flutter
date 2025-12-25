import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../core/utils/formatters.dart';
import 'make_payment_screen.dart';
import '../../providers/finance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilterType = 'All Type';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    
    return transactionsAsync.when(
      data: (transactions) => _buildContent(context, transactions),
      loading: () => _buildLoading(context),
      error: (error, stack) => _buildError(context, error),
    );
  }

  Widget _buildContent(BuildContext context, List<TransactionModel> transactions) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);
    
    // Calculate statistics
    final credits = transactions.where((t) => t.type == TransactionType.credit).toList();
    final debits = transactions.where((t) => t.type == TransactionType.debit).toList();
    final totalCredits = credits.fold<double>(0, (sum, t) => sum + t.amount);
    final totalDebits = debits.fold<double>(0, (sum, t) => sum + t.amount);
    final balance = totalCredits - totalDebits;
    
    // Filter transactions
    final filteredCredits = credits.where((t) {
      if (_selectedFilterType != 'All Type' && _selectedFilterType != 'Credit') return false;
      if (_searchQuery.isEmpty) return true;
      return t.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    
    final filteredDebits = debits.where((t) {
      if (_selectedFilterType != 'All Type' && _selectedFilterType != 'Debit') return false;
      if (_searchQuery.isEmpty) return true;
      return t.description.toLowerCase().contains(_searchQuery.toLowerCase());
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
                      Text('Finance', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        'Complete financial overview of all transactions',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Make Payment',
                          icon: Icons.payment,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MakePaymentScreen(),
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
                          Text('Finance', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Complete financial overview of all transactions',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      CustomButton(
                        text: 'Make Payment',
                        icon: Icons.payment,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MakePaymentScreen(),
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
                  title: 'Total Credits',
                  value: AppFormatters.currency(totalCredits),
                  subtitle: 'Income received',
                  borderColor: AppColors.successGreen,
                  valueColor: AppColors.successGreen,
                  icon: Icons.trending_up,
                  showTrend: true,
                ),
                StatisticsCard(
                  title: 'Total Debits',
                  value: AppFormatters.currency(totalDebits),
                  subtitle: 'Expenses paid',
                  borderColor: AppColors.errorRed,
                  valueColor: AppColors.errorRed,
                  icon: Icons.trending_down,
                  showTrend: true,
                ),
                StatisticsCard(
                  title: 'Balance',
                  value: AppFormatters.currency(balance),
                  subtitle: 'Net balance',
                  borderColor: AppColors.infoBlue,
                  valueColor: AppColors.infoBlue,
                  icon: Icons.account_balance,
                  showTrend: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search and Filters
            isMobile
                ? Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
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
                      const SizedBox(height: 12),
                      // ignore: deprecated_member_use
                      DropdownButtonFormField<String>(
                        value: _selectedFilterType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All Type', 'Credit', 'Debit']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterType = value!;
                          });
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
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
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedFilterType,
                        items: ['All Type', 'Credit', 'Debit']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterType = value!;
                          });
                        },
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            
            // Tabs
            Card(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Credit (${filteredCredits.length})'),
                      Tab(text: 'Debit (${filteredDebits.length})'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTransactionList(filteredCredits, TransactionType.credit),
                        _buildTransactionList(filteredDebits, TransactionType.debit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions, TransactionType type) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No ${type.name} transactions found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(transaction.description),
            subtitle: Text(AppFormatters.dateShort(transaction.createdAt)),
            trailing: Text(
              AppFormatters.currency(transaction.amount),
              style: TextStyle(
                color: type == TransactionType.credit ? AppColors.successGreen : AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
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
                'Error loading transactions',
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

