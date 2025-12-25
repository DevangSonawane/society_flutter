import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/utils/permissions.dart';

/// Widget that conditionally shows/hides content based on user role and permission
class RoleGuard extends ConsumerWidget {
  final Widget child;
  final String? module;
  final PermissionType permissionType;
  final UserRole? requiredRole;
  final bool hideIfNoAccess;

  const RoleGuard({
    super.key,
    required this.child,
    this.module,
    this.permissionType = PermissionType.view,
    this.requiredRole,
    this.hideIfNoAccess = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final userRole = Permissions.getUserRole(user);

    // If specific role is required, check that
    if (requiredRole != null) {
      if (userRole != requiredRole) {
        return hideIfNoAccess ? const SizedBox.shrink() : _buildAccessDenied(context);
      }
      return child;
    }

    // If module is specified, check permissions
    if (module != null) {
      bool hasAccess = false;
      switch (permissionType) {
        case PermissionType.view:
          hasAccess = Permissions.canView(userRole, module!);
          break;
        case PermissionType.create:
          hasAccess = Permissions.canCreate(userRole, module!);
          break;
        case PermissionType.update:
          hasAccess = Permissions.canUpdate(userRole, module!);
          break;
        case PermissionType.delete:
          hasAccess = Permissions.canDelete(userRole, module!);
          break;
      }

      if (!hasAccess) {
        return hideIfNoAccess ? const SizedBox.shrink() : _buildAccessDenied(context);
      }
    }

    return child;
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Access Denied',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

enum PermissionType {
  view,
  create,
  update,
  delete,
}

