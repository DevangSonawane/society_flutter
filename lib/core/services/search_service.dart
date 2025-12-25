import 'package:flutter/material.dart';
import '../../features/residents/data/models/resident_model.dart';
import '../../features/vendors/data/models/vendor_model.dart';
import '../../features/complaints/data/models/complaint_model.dart';
import '../../features/permissions/data/models/permission_model.dart';
import '../../features/helpers/data/models/helper_model.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/dashboard/data/models/notice_model.dart';

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'resident', 'vendor', 'complaint', etc.
  final String? route;
  final Map<String, dynamic>? data;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.route,
    this.data,
  });
}

class SearchService {
  /// Search across all modules
  static List<SearchResult> searchAll({
    required String query,
    List<ResidentModel>? residents,
    List<VendorModel>? vendors,
    List<ComplaintModel>? complaints,
    List<PermissionModel>? permissions,
    List<HelperModel>? helpers,
    List<UserModel>? users,
    List<NoticeModel>? notices,
  }) {
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) return results;

    // Search Residents
    if (residents != null) {
      for (final resident in residents) {
        if (_matches(resident.ownerName, lowerQuery) ||
            _matches(resident.flatNumber, lowerQuery) ||
            _matches(resident.phoneNumber, lowerQuery) ||
            (resident.email != null && _matches(resident.email!, lowerQuery))) {
          results.add(SearchResult(
            id: resident.id,
            title: resident.ownerName,
            subtitle: '${resident.flatNumber} • ${resident.phoneNumber}',
            type: 'resident',
            route: '/residents',
            data: {'residentId': resident.id},
          ));
        }
      }
    }

    // Search Vendors
    if (vendors != null) {
      for (final vendor in vendors) {
        if (_matches(vendor.name, lowerQuery) ||
            _matches(vendor.phoneNumber, lowerQuery) ||
            _matches(vendor.email, lowerQuery) ||
            (vendor.workDetails != null && _matches(vendor.workDetails!, lowerQuery))) {
          results.add(SearchResult(
            id: vendor.id,
            title: vendor.name,
            subtitle: vendor.phoneNumber,
            type: 'vendor',
            route: '/vendors',
            data: {'vendorId': vendor.id},
          ));
        }
      }
    }

    // Search Complaints
    if (complaints != null) {
      for (final complaint in complaints) {
        if (_matches(complaint.complainerName, lowerQuery) ||
            _matches(complaint.flatNumber, lowerQuery) ||
            _matches(complaint.complaintText, lowerQuery) ||
            (complaint.phoneNumber != null && _matches(complaint.phoneNumber!, lowerQuery))) {
          results.add(SearchResult(
            id: complaint.id,
            title: complaint.complainerName,
            subtitle: complaint.complaintText.length > 50
                ? '${complaint.complaintText.substring(0, 50)}...'
                : complaint.complaintText,
            type: 'complaint',
            route: '/complaints',
            data: {'complaintId': complaint.id},
          ));
        }
      }
    }

    // Search Permissions
    if (permissions != null) {
      for (final permission in permissions) {
        if (_matches(permission.residentName, lowerQuery) ||
            _matches(permission.flatNumber, lowerQuery) ||
            _matches(permission.permissionText, lowerQuery)) {
          results.add(SearchResult(
            id: permission.id,
            title: permission.residentName,
            subtitle: permission.permissionText.length > 50
                ? '${permission.permissionText.substring(0, 50)}...'
                : permission.permissionText,
            type: 'permission',
            route: '/permissions',
            data: {'permissionId': permission.id},
          ));
        }
      }
    }

    // Search Helpers
    if (helpers != null) {
      for (final helper in helpers) {
        if (_matches(helper.name, lowerQuery) ||
            (helper.phone != null && _matches(helper.phone!, lowerQuery)) ||
            (helper.notes != null && _matches(helper.notes!, lowerQuery))) {
          results.add(SearchResult(
            id: helper.id,
            title: helper.name,
            subtitle: '${helper.helperType ?? 'Helper'} • ${helper.phone ?? 'N/A'}',
            type: 'helper',
            route: '/helpers',
            data: {'helperId': helper.id},
          ));
        }
      }
    }

    // Search Users
    if (users != null) {
      for (final user in users) {
        if (_matches(user.name, lowerQuery) ||
            _matches(user.email, lowerQuery) ||
            (user.mobileNumber != null && _matches(user.mobileNumber!, lowerQuery))) {
          results.add(SearchResult(
            id: user.id,
            title: user.name,
            subtitle: user.email,
            type: 'user',
            route: '/users',
            data: {'userId': user.id},
          ));
        }
      }
    }

    // Search Notices
    if (notices != null) {
      for (final notice in notices) {
        if (_matches(notice.title, lowerQuery) ||
            _matches(notice.content, lowerQuery) ||
            _matches(notice.author, lowerQuery)) {
          results.add(SearchResult(
            id: notice.id,
            title: notice.title,
            subtitle: notice.content.length > 50
                ? '${notice.content.substring(0, 50)}...'
                : notice.content,
            type: 'notice',
            route: '/notice-board',
            data: {'noticeId': notice.id},
          ));
        }
      }
    }

    return results;
  }

  static bool _matches(String text, String query) {
    return text.toLowerCase().contains(query);
  }

  static String getTypeLabel(String type) {
    switch (type) {
      case 'resident':
        return 'Resident';
      case 'vendor':
        return 'Vendor';
      case 'complaint':
        return 'Complaint';
      case 'permission':
        return 'Permission';
      case 'helper':
        return 'Helper';
      case 'user':
        return 'User';
      case 'notice':
        return 'Notice';
      default:
        return 'Item';
    }
  }

  static IconData getTypeIcon(String type) {
    switch (type) {
      case 'resident':
        return Icons.person;
      case 'vendor':
        return Icons.business;
      case 'complaint':
        return Icons.report_problem;
      case 'permission':
        return Icons.check_circle;
      case 'helper':
        return Icons.support_agent;
      case 'user':
        return Icons.account_circle;
      case 'notice':
        return Icons.campaign;
      default:
        return Icons.search;
    }
  }
}

