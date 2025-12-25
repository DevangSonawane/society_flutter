# Future Features - Implementation Roadmap

This document tracks features that currently show "coming soon" messages and are planned for future implementation.

## Features with "Coming Soon" Messages

### 1. Residents Module
- **Edit Resident** (`lib/features/residents/presentation/screens/residents_list_screen.dart:392`)
  - Status: Placeholder message shown
  - Implementation: Create edit resident screen/form
  - Priority: Medium

### 2. Complaints Module
- **Add Complaint** (`lib/features/complaints/presentation/screens/complaints_screen.dart:102`)
  - Status: Placeholder message shown
  - Implementation: Create add complaint form/modal
  - Priority: High

- **Edit Complaint** (`lib/features/complaints/presentation/screens/complaints_screen.dart:250, 334`)
  - Status: Placeholder message shown
  - Implementation: Create edit complaint form/modal
  - Priority: Medium

### 3. Permissions Module
- **Add Permission** (`lib/features/permissions/presentation/screens/permissions_screen.dart:101`)
  - Status: Placeholder message shown
  - Implementation: Create add permission form/modal
  - Priority: High

### 4. Vendors Module
- **Add Vendor** (`lib/features/vendors/presentation/screens/vendors_screen.dart:127`)
  - Status: Placeholder message shown
  - Implementation: Create add vendor form/modal
  - Priority: Medium

- **Create Invoice** (`lib/features/vendors/presentation/screens/vendors_screen.dart:114`)
  - Status: Placeholder message shown
  - Implementation: Create invoice generation form
  - Priority: Medium

### 5. Helpers Module
- **Add Helper** (`lib/features/helpers/presentation/screens/helpers_screen.dart:97`)
  - Status: Placeholder message shown
  - Implementation: Create add helper form/modal
  - Priority: Medium

### 6. Users Module
- **Create User** (`lib/features/users/presentation/screens/users_screen.dart:99`)
  - Status: Placeholder message shown
  - Implementation: Create user form/modal
  - Priority: High

### 7. Finance Module
- **Make Payment** (`lib/features/finance/presentation/screens/finance_screen.dart:92`)
  - Status: Placeholder message shown
  - Implementation: Create payment form/modal
  - Priority: High

### 8. Maintenance Payments Module
- **Generate Maintenance Payment** (`lib/features/maintenance_payments/presentation/screens/maintenance_payments_screen.dart:74`)
  - Status: Placeholder message shown
  - Implementation: Create payment generation logic
  - Priority: High

- **Download Invoices** (`lib/features/maintenance_payments/presentation/screens/maintenance_payments_screen.dart:86`)
  - Status: Placeholder message shown
  - Implementation: Implement PDF generation and download
  - Priority: Medium

- **Download Receipts** (`lib/features/maintenance_payments/presentation/screens/maintenance_payments_screen.dart:99`)
  - Status: Placeholder message shown
  - Implementation: Implement receipt generation and download
  - Priority: Medium

- **Export CSV** (`lib/features/maintenance_payments/presentation/screens/maintenance_payments_screen.dart:112`)
  - Status: Placeholder message shown
  - Implementation: Implement CSV export functionality
  - Priority: Low

### 9. Notice Board Module
- **Create Notice** (`lib/features/dashboard/presentation/screens/notice_board_screen.dart:44, 73`)
  - Status: Placeholder message shown
  - Implementation: Create notice form/modal
  - Priority: Medium

### 10. Expenses & Charges Module

#### Deposit on Renovation
- **Add Deposit** (`lib/features/expenses_charges/presentation/screens/deposit_renovation_screen.dart:46, 75`)
  - Status: Placeholder message shown
  - Implementation: Create deposit form/modal
  - Priority: Low

#### Society Owned Room
- **Add Room Charge** (`lib/features/expenses_charges/presentation/screens/society_owned_room_screen.dart:46, 75`)
  - Status: Placeholder message shown
  - Implementation: Create room charge form/modal
  - Priority: Low

## Implementation Notes

### Common Patterns

Most "coming soon" features follow these patterns:

1. **Form/Modal Creation**: Create a form screen or modal dialog
2. **Repository Integration**: Add create/update methods to repositories
3. **Provider Updates**: Update providers to handle new operations
4. **Validation**: Add form validation
5. **Error Handling**: Integrate with error handling system
6. **Analytics**: Add analytics tracking for user actions

### Recommended Implementation Order

**Phase 1 (High Priority)**:
1. Add Complaint
2. Add Permission
3. Create User
4. Make Payment
5. Generate Maintenance Payment

**Phase 2 (Medium Priority)**:
1. Edit Resident
2. Edit Complaint
3. Add Vendor
4. Create Invoice (Vendor)
5. Add Helper
6. Create Notice
7. Download Invoices/Receipts

**Phase 3 (Low Priority)**:
1. Export CSV
2. Add Deposit (Renovation)
3. Add Room Charge

## Technical Considerations

### Form Components
- Reuse existing form components from `lib/shared/widgets/`
- Use `CustomTextField`, `CustomButton` for consistency
- Implement proper validation using `lib/core/utils/validators.dart`

### State Management
- Use Riverpod providers for form state
- Integrate with existing repositories
- Handle loading and error states

### Data Persistence
- Use Supabase repositories for API calls
- Implement offline support using Hive cache
- Use SyncService for offline changes

### User Experience
- Show loading indicators during operations
- Display success/error messages
- Navigate appropriately after operations
- Refresh data after create/update operations

## Testing Requirements

For each new feature:
- [ ] Unit tests for repository methods
- [ ] Widget tests for forms
- [ ] Integration tests for complete flows
- [ ] Error handling tests
- [ ] Validation tests

## Notes

- All "coming soon" messages provide user feedback
- Features are intentionally left for post-launch implementation
- Current app functionality is complete and production-ready
- These features enhance the app but are not critical for initial launch

