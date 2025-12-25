import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/animation_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../shared/widgets/animations/shimmer_loading.dart';
import '../../providers/dashboard_stats_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    
    return SingleChildScrollView(
      padding: Responsive.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card with Animation
          FadeSlideWidget(
            duration: AnimationConstants.medium,
            child: _buildWelcomeCard(context),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Cards
          statsAsync.when(
            data: (stats) => FadeSlideWidget(
              delay: const Duration(milliseconds: 200),
              child: ResponsiveStatisticsGrid(
                children: [
                  StatisticsCard(
                    title: 'Total Residents',
                    value: '${stats.totalResidents}',
                    subtitle: 'Registered residents',
                    borderColor: AppColors.primaryPurple,
                    valueColor: AppColors.primaryPurple,
                    icon: Icons.people,
                    animationDelay: const Duration(milliseconds: 0),
                  ),
                  StatisticsCard(
                    title: 'Maintenance Collection',
                    value: AppFormatters.currency(stats.totalMaintenanceCollection),
                    subtitle: 'Total collected',
                    borderColor: AppColors.successGreen,
                    valueColor: AppColors.successGreen,
                    icon: Icons.attach_money,
                    animationDelay: const Duration(milliseconds: 100),
                  ),
                  StatisticsCard(
                    title: 'Pending Complaints',
                    value: '${stats.pendingComplaints}',
                    subtitle: 'Requires attention',
                    borderColor: AppColors.warningYellow,
                    valueColor: AppColors.warningYellow,
                    icon: Icons.report_problem,
                    isPulse: stats.pendingComplaints > 0,
                    animationDelay: const Duration(milliseconds: 200),
                  ),
                  StatisticsCard(
                    title: 'Active Permissions',
                    value: '${stats.activePermissions}',
                    subtitle: 'Approved or pending',
                    borderColor: AppColors.infoBlue,
                    valueColor: AppColors.infoBlue,
                    icon: Icons.description,
                    animationDelay: const Duration(milliseconds: 300),
                  ),
                  StatisticsCard(
                    title: 'Total Vendors',
                    value: '${stats.totalVendors}',
                    subtitle: 'Registered vendors',
                    borderColor: AppColors.primaryPurple,
                    valueColor: AppColors.primaryPurple,
                    icon: Icons.business,
                    animationDelay: const Duration(milliseconds: 400),
                  ),
                  StatisticsCard(
                    title: 'Active Helpers',
                    value: '${stats.totalHelpers}',
                    subtitle: 'Registered helpers',
                    borderColor: AppColors.successGreen,
                    valueColor: AppColors.successGreen,
                    icon: Icons.build,
                    animationDelay: const Duration(milliseconds: 500),
                  ),
                ],
              ),
            ),
            loading: () => ResponsiveStatisticsGrid(
              children: List.generate(6, (index) => CardShimmer()),
            ),
            error: (error, stack) => Container(
              color: AppColors.backgroundLight,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading statistics',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString().length > 100 
                          ? '${error.toString().substring(0, 100)}...'
                          : error.toString(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // SCASA Description Card
          FadeSlideWidget(
            delay: const Duration(milliseconds: 600),
            child: _buildDescriptionCard(),
          ),
          
          const SizedBox(height: 24),
          
          // Key Features Grid
          FadeSlideWidget(
            delay: const Duration(milliseconds: 700),
            child: _buildKeyFeatures(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurpleLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInWidget(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Welcome back, Happy Valley!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInWidget(
            delay: const Duration(milliseconds: 600),
            child: Text(
              "Here's what's happening in your society today.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCASA',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SCASA is a comprehensive digital solution designed to streamline and modernize the management of housing societies. Our platform empowers administrators, receptionists, and residents with powerful tools to manage daily operations, track finances, handle maintenance, and maintain transparent communication.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFeatures(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive cross axis count
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    
    // Responsive aspect ratio - adjust based on screen size and content
    // Mobile: taller cards to accommodate content
    // Tablet/Desktop: wider cards
    final childAspectRatio = isMobile 
        ? (screenWidth < 400 ? 0.85 : 0.9)  // Smaller phones need taller cards
        : (isTablet ? 1.0 : 1.1);
    
    // Responsive spacing
    final spacing = isMobile ? 12.0 : 16.0;
    
    final features = [
      {
        'icon': Icons.people,
        'title': 'Resident Management',
        'description': 'Manage residents, families, and vehicles',
        'color': AppColors.primaryPurple,
      },
      {
        'icon': Icons.attach_money,
        'title': 'Financial Tracking',
        'description': 'Track payments, transactions, and finances',
        'color': AppColors.successGreen,
      },
      {
        'icon': Icons.report_problem,
        'title': 'Complaint System',
        'description': 'Handle and resolve resident complaints',
        'color': AppColors.warningYellow,
      },
      {
        'icon': Icons.description,
        'title': 'Permission Management',
        'description': 'Manage renovation and permission requests',
        'color': AppColors.infoBlue,
      },
      {
        'icon': Icons.business,
        'title': 'Vendor Management',
        'description': 'Track vendors, invoices, and payments',
        'color': AppColors.primaryPurple,
      },
      {
        'icon': Icons.build,
        'title': 'Helper Assignment',
        'description': 'Manage helpers and their assignments',
        'color': AppColors.successGreen,
      },
      {
        'icon': Icons.campaign,
        'title': 'Notice Board',
        'description': 'Share announcements and notices',
        'color': AppColors.infoBlue,
      },
      {
        'icon': Icons.person,
        'title': 'User Management',
        'description': 'Manage users, roles, and permissions',
        'color': AppColors.primaryPurple,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.primaryPurple,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Key Features',
                style: AppTextStyles.h3.copyWith(
                  fontSize: isMobile ? 18 : null,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return FadeSlideWidget(
                delay: AnimationConstants.cardStaggerDelay * (index + 1),
                direction: SlideDirection.up,
                child: _buildFeatureCard(
                  context,
                  icon: feature['icon'] as IconData,
                  title: feature['title'] as String,
                  description: feature['description'] as String,
                  color: feature['color'] as Color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Add haptic feedback
          // HapticHelper.light();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isMobile ? (isSmallScreen ? 12 : 14) : 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? (isSmallScreen ? 8 : 10) : 12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isMobile ? (isSmallScreen ? 20 : 22) : 24,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? (isSmallScreen ? 8 : 10) : 12),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: isMobile ? (isSmallScreen ? 12 : 13) : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isMobile ? (isSmallScreen ? 3 : 4) : 4),
              Flexible(
                child: Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? (isSmallScreen ? 9 : 10) : 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
