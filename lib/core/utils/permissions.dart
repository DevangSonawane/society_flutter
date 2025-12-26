import '../../features/auth/data/models/user_model.dart';

enum UserRole {
  admin,
  receptionist,
  resident,
}

extension UserRoleExtension on String {
  UserRole toUserRole() {
    switch (toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'receptionist':
        return UserRole.receptionist;
      case 'resident':
        return UserRole.resident;
      default:
        return UserRole.resident;
    }
  }
}

class Permissions {
  /// Check if user can view a module
  static bool canView(UserRole role, String module) {
    switch (role) {
      case UserRole.admin:
        return true; // Admin can view everything
      case UserRole.receptionist:
        // Receptionist can view most modules but not Users
        return module != 'users' && module != 'vendors' && module != 'helpers';
      case UserRole.resident:
        // Residents can view: maintenance_payments, notice_board, complaints, permissions, helpers, dashboard, residents (own profile)
        return module == 'maintenance_payments' ||
               module == 'notice_board' ||
               module == 'complaints' ||
               module == 'permissions' ||
               module == 'helpers' ||
               module == 'dashboard' ||
               module == 'residents';
    }
  }

  /// Check if user can create in a module
  static bool canCreate(UserRole role, String module) {
    switch (role) {
      case UserRole.admin:
        return true; // Admin can create everything
      case UserRole.receptionist:
        // Receptionist can create complaints and permissions
        return module == 'complaints' || module == 'permissions';
      case UserRole.resident:
        // Resident can create: complaints, permissions, helpers (assign to their flat)
        return module == 'complaints' || 
               module == 'permissions' || 
               module == 'helpers';
    }
  }

  /// Check if user can update in a module
  static bool canUpdate(UserRole role, String module) {
    switch (role) {
      case UserRole.admin:
        return true; // Admin can update everything
      case UserRole.receptionist:
        // Receptionist can update complaints and permissions they created
        return module == 'complaints' || module == 'permissions';
      case UserRole.resident:
        // Resident can only update own complaints/permissions
        return module == 'complaints' || module == 'permissions';
    }
  }

  /// Check if user can delete in a module
  static bool canDelete(UserRole role, String module) {
    switch (role) {
      case UserRole.admin:
        return true; // Admin can delete everything
      case UserRole.receptionist:
        return false; // Receptionist cannot delete anything
      case UserRole.resident:
        return false; // Resident cannot delete anything
    }
  }

  /// Check if user can manage users
  static bool canManageUsers(UserRole role) {
    return role == UserRole.admin;
  }

  /// Check if user can manage vendors
  static bool canManageVendors(UserRole role) {
    return role == UserRole.admin;
  }

  /// Check if user can manage helpers
  static bool canManageHelpers(UserRole role) {
    return role == UserRole.admin;
  }

  /// Check if user can view all residents
  static bool canViewAllResidents(UserRole role) {
    return role == UserRole.admin || role == UserRole.receptionist;
  }

  /// Check if user can view all maintenance payments
  static bool canViewAllPayments(UserRole role) {
    return role == UserRole.admin || role == UserRole.receptionist;
  }

  /// Check if user can add notices
  static bool canAddNotice(UserRole role) {
    return role == UserRole.admin || role == UserRole.receptionist;
  }

  /// Get user role from UserModel
  static UserRole getUserRole(UserModel? user) {
    if (user == null) return UserRole.resident;
    return user.role.toUserRole();
  }
}

