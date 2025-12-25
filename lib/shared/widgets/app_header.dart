import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/constants/animation_constants.dart';
import 'animations/fade_in_widget.dart';
import 'animated_dialog.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

class AppHeader extends ConsumerWidget {
  final VoidCallback onMenuTap;
  final String? searchHint;
  final Function(String)? onSearchChanged;

  const AppHeader({
    super.key,
    required this.onMenuTap,
    this.searchHint,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);
    final notificationCount = unreadCountAsync.valueOrNull ?? 0;
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          height: AppConstants.headerHeight,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppConstants.paddingSmall : AppConstants.paddingMedium,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Menu Toggle (Left side)
              FadeInWidget(
                delay: const Duration(milliseconds: 100),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onMenuTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.menu,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Spacer to push items to the right
              if (!isMobile) ...[
                const SizedBox(width: AppConstants.paddingMedium),
                // Search Bar (Desktop/Tablet)
                Expanded(
                  child: FadeInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: searchHint ?? 'Search Vendor Name and Resident Name...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.gray100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: onSearchChanged,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              AppConstants.searchRoute,
                              arguments: value.trim(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
              
              // Right side items (Notifications and User Profile)
              if (!isMobile)
                const SizedBox(width: AppConstants.paddingMedium),
              
              const SizedBox(width: 8),
              
              // Search Icon (mobile only - right side)
              if (isMobile) ...[
                const Spacer(),
                FadeInWidget(
                  delay: const Duration(milliseconds: 200),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppConstants.searchRoute,
                          arguments: '',
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.search,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              
              // Notifications
              FadeInWidget(
                delay: const Duration(milliseconds: 300),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              notificationCount > 9 ? '9+' : '$notificationCount',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // User Profile
              FadeInWidget(
                delay: const Duration(milliseconds: 400),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      AnimatedAlertDialog.show(
                        context: context,
                        title: 'Profile',
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primaryPurple,
                              child: const Text(
                                'HV',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Happy Valley Admin',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('happyvalleyadmin@scasa.pro'),
                            const SizedBox(height: 8),
                            const Text('Administrator'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                    child: CircleAvatar(
                        radius: isMobile ? 18 : 20,
                        backgroundColor: AppColors.primaryPurple,
                        child: Text(
                          'HV',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
