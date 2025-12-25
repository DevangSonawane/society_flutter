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
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Date'; // Date or Amount

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
    final transactionsAsync = ref.watch(allTransactionsProvider);
    
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
    List<TransactionModel> filterTransactions(List<TransactionModel> transactions) {
      return transactions.where((t) {
        // Category filter
        if (_selectedCategory != 'All') {
          final categoryMap = {
            'Maintenance': 'maintenance',
            'Vendor': 'vendor',
            'Deposit': 'deposit',
            'Room Charge': 'room_charge',
            'Manual': 'manual',
          };
          final expectedCategory = categoryMap[_selectedCategory];
          if (expectedCategory != null && t.category != expectedCategory) {
            return false;
          }
        }
        
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          // Match if any field contains the query (OR logic)
          final matchesDescription = t.description.toLowerCase().contains(query);
          final matchesReference = t.referenceNumber?.toLowerCase().contains(query) ?? false;
          final matchesPaidBy = t.paidBy?.toLowerCase().contains(query) ?? false;
          final matchesPaidTo = t.paidTo?.toLowerCase().contains(query) ?? false;
          
          if (!matchesDescription && !matchesReference && !matchesPaidBy && !matchesPaidTo) {
            return false;
          }
        }
        
        return true;
      }).toList();
    }
    
    // Sort transactions
    List<TransactionModel> sortTransactions(List<TransactionModel> transactions) {
      final sorted = List<TransactionModel>.from(transactions);
      if (_sortBy == 'Date') {
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_sortBy == 'Amount') {
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
      }
      return sorted;
    }
    
    final filteredCredits = sortTransactions(filterTransactions(credits));
    final filteredDebits = sortTransactions(filterTransactions(debits));
    
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
                      Row(
                        children: [
                          Expanded(
                            child: // ignore: deprecated_member_use
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: AppColors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                labelText: 'Category',
                              ),
                              items: ['All', 'Maintenance', 'Vendor', 'Deposit', 'Room Charge', 'Manual']
                                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: // ignore: deprecated_member_use
                            DropdownButtonFormField<String>(
                              initialValue: _sortBy,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: AppColors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                labelText: 'Sort By',
                              ),
                              items: ['Date', 'Amount']
                                  .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _sortBy = value!;
                                });
                              },
                            ),
                          ),
                        ],
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
                        value: _selectedCategory,
                        items: ['All', 'Maintenance', 'Vendor', 'Deposit', 'Room Charge', 'Manual']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _sortBy,
                        items: ['Date', 'Amount']
                            .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                            });
                          }
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
            leading: _buildSourceIcon(transaction.source),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (transaction.source != null) ...[
                  const SizedBox(width: 8),
                  _buildSourceBadge(transaction.source!),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  AppFormatters.dateShort(transaction.createdAt),
                  style: AppTextStyles.bodySmall,
                ),
                if (transaction.category != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.category!.replaceAll('_', ' ').toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(transaction.amount),
                  style: TextStyle(
                    color: type == TransactionType.credit ? AppColors.successGreen : AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (transaction.referenceNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.referenceNumber!.length > 8 
                        ? 'Ref: ${transaction.referenceNumber!.substring(0, 8)}...'
                        : 'Ref: ${transaction.referenceNumber!}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceIcon(TransactionSource? source) {
    if (source == null) return const Icon(Icons.receipt, color: AppColors.textSecondary);
    
    switch (source) {
      case TransactionSource.maintenance:
        return const Icon(Icons.home, color: AppColors.primaryPurple);
      case TransactionSource.vendor:
        return const Icon(Icons.business, color: AppColors.infoBlue);
      case TransactionSource.deposit:
        return const Icon(Icons.account_balance_wallet, color: AppColors.warningYellow);
      case TransactionSource.roomCharge:
        return const Icon(Icons.room, color: AppColors.successGreen);
      case TransactionSource.manual:
        return const Icon(Icons.payment, color: AppColors.textSecondary);
    }
  }

  Widget _buildSourceBadge(TransactionSource source) {
    final labels = {
      TransactionSource.maintenance: 'Maint',
      TransactionSource.vendor: 'Vendor',
      TransactionSource.deposit: 'Deposit',
      TransactionSource.roomCharge: 'Room',
      TransactionSource.manual: 'Manual',
    };
    
    final colors = {
      TransactionSource.maintenance: AppColors.primaryPurple,
      TransactionSource.vendor: AppColors.infoBlue,
      TransactionSource.deposit: AppColors.warningYellow,
      TransactionSource.roomCharge: AppColors.successGreen,
      TransactionSource.manual: AppColors.textSecondary,
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors[source]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors[source]!.withValues(alpha: 0.3)),
      ),
      child: Text(
        labels[source]!,
        style: TextStyle(
          color: colors[source],
          fontSize: 10,
          fontWeight: FontWeight.w600,
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
    final errorMessage = error.toString();
    final isAuthError = errorMessage.toLowerCase().contains('authentication') ||
        errorMessage.toLowerCase().contains('permission') ||
        errorMessage.toLowerCase().contains('session');
    final isTableError = errorMessage.toLowerCase().contains('relation') ||
        errorMessage.toLowerCase().contains('does not exist');
    
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
              if (isAuthError)
                Text(
                  'Authentication error. Please check your login status.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed),
                  textAlign: TextAlign.center,
                )
              else if (isTableError)
                Text(
                  'Database table not found. Please check your database configuration.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  errorMessage.length > 200 
                      ? '${errorMessage.substring(0, 200)}...'
                      : errorMessage,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Retry',
                icon: Icons.refresh,
                onPressed: () {
                  // Refresh the provider
                  ref.invalidate(transactionsProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

