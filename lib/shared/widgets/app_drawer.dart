import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/permissions.dart';
import '../../core/constants/animation_constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../models/navigation_item.dart';
import 'animations/fade_slide_widget.dart';
import 'animations/fade_in_widget.dart';
import 'role_guard.dart';

class AppDrawer extends ConsumerStatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _expensesExpanded = false;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: AppConstants.dashboardRoute,
    ),
    NavigationItem(
      title: 'Residents',
      icon: Icons.people,
      route: AppConstants.residentsRoute,
    ),
    NavigationItem(
      title: 'Maintenance Payment',
      icon: Icons.credit_card,
      route: AppConstants.maintenancePaymentsRoute,
    ),
    NavigationItem(
      title: 'Finance',
      icon: Icons.attach_money,
      route: AppConstants.financeRoute,
    ),
    NavigationItem(
      title: 'Notice Board',
      icon: Icons.campaign,
      route: AppConstants.noticeBoardRoute,
    ),
    NavigationItem(
      title: 'Complaint',
      icon: Icons.report_problem,
      route: AppConstants.complaintsRoute,
    ),
    NavigationItem(
      title: 'Permission',
      icon: Icons.description,
      route: AppConstants.permissionsRoute,
    ),
    NavigationItem(
      title: 'Vendor',
      icon: Icons.business,
      route: AppConstants.vendorsRoute,
    ),
    NavigationItem(
      title: 'Helper',
      icon: Icons.build,
      route: AppConstants.helpersRoute,
    ),
    NavigationItem(
      title: 'User',
      icon: Icons.person,
      route: AppConstants.usersRoute,
    ),
  ];

  final List<NavigationItem> _expensesItems = [
    NavigationItem(
      title: 'Deposit on renovation',
      icon: Icons.home_work,
      route: AppConstants.depositRenovationRoute,
    ),
    NavigationItem(
      title: 'Society Owned Room',
      icon: Icons.room,
      route: AppConstants.societyOwnedRoomRoute,
    ),
  ];

  bool _isActive(String route) {
    return widget.currentRoute == route;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Drawer(
      width: Responsive.getDrawerWidth(context),
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: Container(
              padding: EdgeInsets.only(
                top: statusBarHeight + AppConstants.paddingMedium,
                bottom: AppConstants.paddingMedium,
                left: AppConstants.paddingLarge,
                right: AppConstants.paddingLarge,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'SC',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    'ASA',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
              children: [
                ..._navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final module = _getModuleFromRoute(item.route);
                  return RoleGuard(
                    module: module,
                    permissionType: PermissionType.view,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FadeSlideWidget(
                        delay: AnimationConstants.staggerDelay * (index + 1),
                        direction: SlideDirection.left,
                        child: _buildMenuItem(item),
                      ),
                    ),
                  );
                }),
                
                // Expenses and Charges with Sub-menu (Admin only)
                RoleGuard(
                  requiredRole: UserRole.admin,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FadeSlideWidget(
                      delay: AnimationConstants.staggerDelay * (_navigationItems.length + 1),
                      direction: SlideDirection.left,
                      child: _buildExpensesMenuItem(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Logout Button
          FadeSlideWidget(
            delay: AnimationConstants.staggerDelay * (_navigationItems.length + 2),
            direction: SlideDirection.left,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: _buildMenuItem(
                NavigationItem(
                  title: 'Logout',
                  icon: Icons.logout,
                  route: AppConstants.loginRoute,
                ),
                isLogout: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(NavigationItem item, {bool isLogout = false}) {
    final isActive = !isLogout && _isActive(item.route);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          widget.onNavigate(item.route);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: AnimationConstants.normal,
          curve: AnimationConstants.defaultCurve,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: AnimationConstants.fast,
                child: Icon(
                  item.icon,
                  key: ValueKey('${item.route}_$isActive'),
                  size: 22,
                  color: isActive 
                      ? AppColors.white 
                      : (isLogout ? AppColors.textSecondary : AppColors.gray600),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: AnimationConstants.fast,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isActive 
                        ? AppColors.white 
                        : (isLogout ? AppColors.textSecondary : AppColors.textPrimary),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                  child: Text(item.title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesMenuItem() {
    final isAnyActive = _isAnyExpensesActive();
    final isExpandedOrActive = _expensesExpanded || isAnyActive;
    
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _expensesExpanded = !_expensesExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: AnimationConstants.normal,
              curve: AnimationConstants.defaultCurve,
              decoration: BoxDecoration(
                color: isExpandedOrActive
                    ? AppColors.primaryPurple
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 22,
                    color: isExpandedOrActive
                        ? AppColors.white
                        : AppColors.gray600,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Expenses and Charge',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isExpandedOrActive
                            ? AppColors.white
                            : AppColors.textPrimary,
                        fontWeight: isExpandedOrActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(
                    _expensesExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 22,
                    color: isExpandedOrActive
                        ? AppColors.white
                        : AppColors.gray600,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expensesExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Column(
              children: _expensesItems.map((item) {
                final isActive = _isActive(item.route);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigate(item.route);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: AnimationConstants.normal,
                        curve: AnimationConstants.defaultCurve,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryPurpleLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isActive 
                                  ? AppColors.white 
                                  : AppColors.gray600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isActive
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  bool _isAnyExpensesActive() {
    return _expensesItems.any((item) => _isActive(item.route));
  }

  String? _getModuleFromRoute(String route) {
    if (route == AppConstants.dashboardRoute) return 'dashboard';
    if (route == AppConstants.residentsRoute) return 'residents';
    if (route == AppConstants.maintenancePaymentsRoute) return 'maintenance_payments';
    if (route == AppConstants.financeRoute) return 'finance';
    if (route == AppConstants.complaintsRoute) return 'complaints';
    if (route == AppConstants.permissionsRoute) return 'permissions';
    if (route == AppConstants.vendorsRoute) return 'vendors';
    if (route == AppConstants.helpersRoute) return 'helpers';
    if (route == AppConstants.usersRoute) return 'users';
    if (route == AppConstants.noticeBoardRoute) return 'notice_board';
    return null;
  }
}
