# SCASA Website Flow Documentation

## Overview
SCASA (Society Comprehensive Administrative Solution Application) is a digital platform for managing housing societies. This document outlines the complete user flow and navigation structure of the application.

## Authentication Flow

### Login Process
1. **Entry Point**: User accesses the login page at `/login`
2. **Login Form**:
   - Email or Mobile Number field (required)
   - Password field with show/hide toggle (required)
   - Sign In button
3. **Post-Login**: User is redirected to `/dashboard` upon successful authentication

## Main Navigation Structure

### Sidebar Navigation
The application uses a persistent left sidebar with the following modules:

1. **Dashboard** (`/dashboard`)
2. **Residents** (`/residents`)
3. **Maintenance Payment** (`/maintenance-payments`)
4. **Finance** (`/finance`)
5. **Notice Board** (`/notice-board`) - *Note: Returns 404, may be under development*
6. **Complaint** (`/complaints`)
7. **Permission** (`/permissions`)
8. **Vendor** (`/vendors`)
9. **Helper** (`/helpers`)
10. **Expenses and Charges** (Expandable menu with sub-modules)
    - Deposit on renovation
    - Society Owned Room
11. **User** (`/users`)

### Header Bar (Global Navigation)
- **Toggle Sidebar**: Hamburger menu icon to show/hide sidebar
- **Search Bar**: Global search for "Vendor Name and Resident Name"
- **Notifications**: Bell icon with count badge (shows "3" unread)
- **User Profile**: Circular avatar with initials "HV" (Happy Valley)

---

## Module Flows

### 1. Dashboard (`/dashboard`)

**Purpose**: Main landing page after login providing overview

**Flow**:
- User lands on dashboard after login
- Displays welcome message "Welcome back, Happy Valley!"
- Shows platform description and key features
- No specific actions, informational display only

**User Journey**: Login → Dashboard

---

### 2. Residents Module (`/residents`)

**Purpose**: Manage society residents and their information

#### Main Residents Page (`/residents`)
**Flow**:
1. Navigate to Residents from sidebar
2. View statistics cards:
   - Total Residents (count)
   - Active Residents (count)
   - Owner Occupied (count)
3. View residents table with columns:
   - Name (clickable)
   - Flat Number (clickable)
   - Type (Owner/Rented/Living)
   - Status (active/inactive)
   - Created Date
   - Number of residents in flat
   - Actions (View/Edit/Delete buttons)
4. Filter options:
   - Search by name or flat number
   - Filter by Status (All Status dropdown)
   - Filter by Type (All Type dropdown)
5. **Action Button**: "Add Resident" button → Navigates to Create Resident form

#### Create Resident Flow (`/residents/create`)
**Flow**:
1. Click "Add Resident" button
2. Fill in Owner Information section:
   - Owner's Name* (required)
   - Flat Number* (required)
   - Residency Type* (dropdown, required)
   - Phone Number* (required)
   - Email Address (optional)
3. Add Residents section (dynamic):
   - Name
   - Phone Number
   - Date Joined
   - "Add Resident" button (can add multiple residents)
4. Vehicle Information section (optional):
   - Vehicle Number
   - Vehicle Type (dropdown)
   - "Add Vehicle" button (can add multiple vehicles)
5. Additional Documents section:
   - "Add Document" button
6. Form Actions:
   - "Cancel" button → Returns to residents list
   - "Create Resident" button → Creates resident and returns to list

**User Journey**: Residents List → Add Resident → Fill Form → Create → Back to List

---

### 3. Maintenance Payment Module (`/maintenance-payments`)

**Purpose**: Generate and manage maintenance payment invoices and receipts

#### Main Maintenance Payment Page
**Flow**:
1. Navigate to Maintenance Payment from sidebar
2. View statistics cards:
   - Total Collection (₹ amount)
   - Collected (₹ amount with percentage)
   - Pending (₹ amount)
3. Action buttons in header:
   - "Generate Payment" button
   - "Download All Invoice" button
   - "Download All Receipt" button
   - "Export CSV" button
4. View payment table/list with filters:
   - Search functionality
   - Status filters
   - Date filters

**User Journey**: Maintenance Payments → Generate/View Payments → Download Documents

---

### 4. Finance Module (`/finance`)

**Purpose**: Complete financial overview of all transactions

#### Main Finance Page
**Flow**:
1. Navigate to Finance from sidebar
2. View financial summary cards:
   - Total Credits (₹ amount) - Income received
   - Total Debits (₹ amount) - Expenses paid
   - Balance (₹ amount)
3. Action button:
   - "Make Payment" button
4. Transaction list with tabs:
   - "Credit" tab (shows credit transactions)
   - "Debit" tab (shows debit transactions)
5. Filter options:
   - Search transactions
   - Filter by Type (All Type dropdown)
   - Sort by Date button
   - Sort by Amount button

**User Journey**: Finance → View Summary → Filter Transactions → Make Payment (if needed)

---

### 5. Complaint Module (`/complaints`)

**Purpose**: Manage and track resident complaints

#### Main Complaints Page
**Flow**:
1. Navigate to Complaints from sidebar
2. View statistics cards:
   - Total Complaints (count)
   - This Month (count)
   - Pending (count)
3. Action button:
   - "Add Complaint" button
4. Search and filter:
   - Search by name, phone, email, flat, wing, or complaint text
5. View complaints list/table

**User Journey**: Complaints → View List → Add Complaint → Track Status

---

### 6. Permission Module (`/permissions`)

**Purpose**: Manage and track resident permissions

#### Main Permissions Page
**Flow**:
1. Navigate to Permissions from sidebar
2. View statistics cards:
   - Total Permissions (count)
   - This Month (count)
   - Pending (count)
3. Action button:
   - "Add Permission" button
4. Search and filter:
   - Search by name, phone, email, flat, wing, or permission text
5. View permissions list/table

**User Journey**: Permissions → View List → Add Permission → Track Status

---

### 7. Vendor Module (`/vendors`)

**Purpose**: Manage vendors, invoices, and track payments

#### Main Vendors Page
**Flow**:
1. Navigate to Vendors from sidebar
2. View statistics cards:
   - Total Vendors (count)
   - Total Bill (₹ amount)
   - Other financial metrics
3. Action buttons:
   - "Create Invoice" button
   - "Add Vendor" button
4. Search and filter:
   - Search by name, email, phone, or work details
5. View vendors table with columns:
   - Name
   - Email
   - Phone
   - Work/Service Type
   - Total Bill Amount
   - Paid Amount
   - Pending Amount
   - Status (Paid/Pending)
   - Actions (View/Edit/Delete buttons)

**User Journey**: Vendors → View List → Add Vendor/Create Invoice → Manage Payments

---

### 8. Helper Module (`/helpers`)

**Purpose**: Manage helpers and link them to flats/rooms

#### Main Helpers Page
**Flow**:
1. Navigate to Helpers from sidebar
2. View statistics cards:
   - Total Helpers (count)
   - Total Men (count of male helpers)
   - Total Women (likely, based on pattern)
3. Action button:
   - "Add Helper" button
4. Search and filter:
   - Search by name, phone, type, or notes
5. View helpers table with columns:
   - Name
   - Phone Number
   - Type (Home/Office/etc.)
   - Gender (Male/Female)
   - Assigned Flats/Rooms
   - Notes
   - Actions (View/Edit/Delete buttons)

**User Journey**: Helpers → View List → Add Helper → Assign to Flats → Manage

---

### 9. Expenses and Charges Module

**Purpose**: Manage various expenses and charges

#### Sub-modules:
1. **Deposit on Renovation**
   - Manage deposits collected for renovation work
   
2. **Society Owned Room**
   - Manage charges for society-owned rooms/spaces

**Flow**: Click on "Expenses and Charges" → Menu expands → Select sub-module → Manage respective charges

---

### 10. User Module (`/users`)

**Purpose**: Manage all system users (admins, receptionists, residents)

#### Main Users Page
**Flow**:
1. Navigate to Users from sidebar
2. View statistics cards:
   - Total Users (count)
   - Admins (count)
   - Receptionists (count)
   - Residents (count)
3. Action button:
   - "Create User" button
4. Search:
   - Search users by various criteria
5. View users table with columns:
   - Name
   - Email
   - Phone
   - Role (admin/receptionist/resident)
   - Flat Number (if resident)
   - Created Date
   - Actions (Edit/Delete buttons)

**User Journey**: Users → View List → Create User → Assign Role → Manage Permissions

---

## Common UI Patterns

### Search Functionality
- **Global Search**: Available in header for "Vendor Name and Resident Name"
- **Module-specific Search**: Each module has its own search with relevant filters

### Filtering
Most modules support:
- Status filters (All Status, Active, Inactive, etc.)
- Type filters (All Type, Owner, Rented, etc.)
- Date range filters (where applicable)
- Custom search filters

### Action Patterns
1. **Create/Add Actions**: 
   - Usually a prominent button with "+" icon
   - Opens form/modal for data entry
   
2. **View/Edit/Delete Actions**:
   - Icon buttons in table rows
   - View: Eye icon
   - Edit: Pencil icon
   - Delete: Trash icon

3. **Bulk Actions**:
   - Export CSV
   - Download All (invoices/receipts)
   - Generate batch operations

### Navigation Patterns
- **Breadcrumb Navigation**: "Back to [Module]" buttons in detail/create pages
- **Sidebar Highlighting**: Active module is highlighted in purple
- **Direct Navigation**: Click on names/flat numbers for quick access to details

---

## Data Flow Patterns

### Create Flow Pattern
1. Navigate to module
2. Click "Add/Create" button
3. Fill form with required fields
4. Add optional/repeating sections (residents, vehicles, documents)
5. Submit → Redirect to list
6. View newly created item in list

### Update Flow Pattern
1. Navigate to module
2. Find item in list/table
3. Click Edit button
4. Modify form fields
5. Submit → Updates item
6. Redirect to list with updated data

### View/Detail Flow Pattern
1. Navigate to module
2. Click on item name or View button
3. See detailed information
4. Option to edit/delete from detail page
5. Back button to return to list

### Delete Flow Pattern
1. Navigate to module
2. Find item in list
3. Click Delete button
4. Confirm deletion (if confirmation dialog)
5. Item removed from list

---

## User Roles and Permissions

Based on the Users module:
- **Admin**: Full system access
- **Receptionist**: Limited access for front desk operations
- **Resident**: Access to own data and services

*Note: Detailed permission matrix needs to be documented separately*

---

## Error Handling Flows

### 404 Error
- Notice Board module returns 404 page
- Error page shows "Page Not Found" with:
  - "Return Home" button → Redirects to dashboard
  - "Go Back" button → Browser back action

### Authentication Errors
- Login failures handled at `/login` page
- Unauthorized access redirects to login

---

## Integration Points

### External Services (Inferred)
- Payment processing for maintenance payments
- Email/SMS notifications (implied by notification system)
- Document generation (invoices, receipts)
- File upload for documents

---

## Summary of Key User Journeys

1. **Resident Management**: Dashboard → Residents → Add Resident → Create → List
2. **Payment Processing**: Dashboard → Maintenance Payment → Generate → View → Download
3. **Financial Tracking**: Dashboard → Finance → View Summary → Make Payment → Record Transaction
4. **Complaint Resolution**: Dashboard → Complaints → Add Complaint → Track → Resolve
5. **Vendor Management**: Dashboard → Vendors → Add Vendor → Create Invoice → Track Payment
6. **User Administration**: Dashboard → Users → Create User → Assign Role → Manage

---

## Notes

- The Notice Board module appears to be under development (404 error)
- Expenses and Charges sub-modules require expansion of parent menu item to access
- All modules follow consistent UI patterns for easier navigation
- Search functionality is both global (header) and module-specific
- Statistics cards provide quick overview at module entry points

