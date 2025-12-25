import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/search_service.dart';
import '../../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../../features/residents/providers/residents_provider.dart';
import '../../../../features/vendors/providers/vendors_provider.dart';
import '../../../../features/complaints/providers/complaints_provider.dart';
import '../../../../features/permissions/providers/permissions_provider.dart';
import '../../../../features/helpers/providers/helpers_provider.dart';
import '../../../../features/users/providers/users_provider.dart';
import '../../../../features/dashboard/providers/notices_provider.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.query;
  }

  void _navigateToResult(SearchResult result) {
    // Navigate based on type and route
    // This would need to be implemented based on your routing structure
    Navigator.pop(context);
    // TODO: Implement navigation to specific item
  }

  @override
  Widget build(BuildContext context) {
    final residentsAsync = ref.watch(residentsNotifierProvider);
    final vendorsAsync = ref.watch(vendorsNotifierProvider);
    final complaintsAsync = ref.watch(complaintsNotifierProvider);
    final permissionsAsync = ref.watch(permissionsNotifierProvider);
    final helpersAsync = ref.watch(helpersNotifierProvider);
    final usersAsync = ref.watch(usersNotifierProvider);
    final noticesAsync = ref.watch(noticesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          autofocus: true,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primaryPurple),
            onPressed: () {
              // Search is already happening on change
            },
          ),
        ],
      ),
      body: residentsAsync.when(
        data: (residents) {
          return vendorsAsync.when(
            data: (vendors) {
              return complaintsAsync.when(
                data: (complaints) {
                  return permissionsAsync.when(
                    data: (permissions) {
                      return helpersAsync.when(
                        data: (helpers) {
                          return usersAsync.when(
                            data: (users) {
                              return noticesAsync.when(
                                data: (notices) {
                                  final results = SearchService.searchAll(
                                    query: _searchQuery,
                                    residents: residents,
                                    vendors: vendors,
                                    complaints: complaints,
                                    permissions: permissions,
                                    helpers: helpers,
                                    users: users,
                                    notices: notices,
                                  );

                                  if (_searchQuery.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            size: 64,
                                            color: AppColors.textTertiary,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Start typing to search',
                                            style: AppTextStyles.h3.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (results.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: AppColors.textTertiary,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No results found',
                                            style: AppTextStyles.h3.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try a different search term',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: results.length,
                                    itemBuilder: (context, index) {
                                      final result = results[index];
                                      return FadeInWidget(
                                        delay: Duration(milliseconds: index * 50),
                                        child: Card(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                                              child: Icon(
                                                SearchService.getTypeIcon(result.type),
                                                color: AppColors.primaryPurple,
                                              ),
                                            ),
                                            title: Text(
                                              result.title,
                                              style: AppTextStyles.bodyLarge.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 4),
                                                Text(
                                                  result.subtitle,
                                                  style: AppTextStyles.bodyMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryPurple.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    SearchService.getTypeLabel(result.type),
                                                    style: AppTextStyles.bodySmall.copyWith(
                                                      color: AppColors.primaryPurple,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: const Icon(
                                              Icons.chevron_right,
                                              color: AppColors.textSecondary,
                                            ),
                                            onTap: () => _navigateToResult(result),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (_, __) => const SizedBox.shrink(),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

