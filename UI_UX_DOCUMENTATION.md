# SCASA Flutter App - Complete UI/UX Documentation

## Table of Contents
1. [App Overview](#app-overview)
2. [Navigation Structure](#navigation-structure)
3. [Design System](#design-system)
4. [Screen-by-Screen Documentation](#screen-by-screen-documentation)
5. [Common Components](#common-components)
6. [Responsive Behavior](#responsive-behavior)
7. [User Interactions & Button Actions](#user-interactions--button-actions)

---

## App Overview

**SCASA** (Society Comprehensive Administration System Application) is a Flutter-based mobile and web application for managing housing societies. The app provides a comprehensive solution for administrators, receptionists, and residents to manage daily operations, track finances, handle maintenance, and maintain transparent communication.

### App Architecture
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Backend**: Supabase
- **Theme**: Material Design 3 with custom purple color scheme
- **Responsive**: Mobile-first design with desktop/tablet support

---

## Navigation Structure

### Main Navigation Flow

```
App Launch
    ↓
AuthGate (checks authentication)
    ↓
┌─────────────────┬─────────────────┐
│  Not Logged In  │   Logged In     │
│      ↓          │       ↓         │
│ Login Screen    │ MainScaffold    │
│                 │   (Drawer)      │
└─────────────────┴─────────────────┘
```

### MainScaffold Structure

The app uses a **MainScaffold** wrapper that contains:
1. **AppDrawer** (Left sidebar navigation)
2. **AppHeader** (Top navigation bar)
3. **Content Area** (Current screen)

---

## Design System

### Color Palette

#### Primary Colors
- **Primary Purple**: `#7B2CBF` - Main brand color, used for buttons, active states, icons
- **Primary Purple Light**: `#9D4EDD` - Hover states, gradients
- **Primary Purple Dark**: `#5A189A` - Darker variants

#### Status Colors
- **Success Green**: `#10B981` - Success states, completed items
- **Success Green Light**: `#D1FAE5` - Success backgrounds
- **Error Red**: `#EF4444` - Errors, delete actions, warnings
- **Error Red Light**: `#FEE2E2` - Error backgrounds
- **Warning Yellow**: `#F59E0B` - Warnings, pending states
- **Warning Yellow Light**: `#FEF3C7` - Warning backgrounds
- **Info Blue**: `#3B82F6` - Information, secondary actions
- **Info Blue Light**: `#DBEAFE` - Info backgrounds

#### Neutral Colors
- **White**: `#FFFFFF` - Backgrounds, cards
- **Black**: `#000000` - Text (primary)
- **Gray Scale**: 50-900 range for text hierarchy and borders
  - Text Primary: `#111827` (gray900)
  - Text Secondary: `#6B7280` (gray600)
  - Text Tertiary: `#9CA3AF` (gray400)
  - Border Light: `#E5E7EB` (gray200)
  - Background Light: `#F9FAFB` (gray50)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Headings**: 
  - H1: 32px, Bold
  - H2: 28px, Bold
  - H3: 24px, Semi-bold
  - H4: 20px, Semi-bold
- **Body Text**: 
  - Large: 16px
  - Medium: 14px
  - Small: 12px
- **Buttons**: 16px, Semi-bold (600)

### Spacing
- **Padding Small**: 8px
- **Padding Medium**: 16px
- **Padding Large**: 24px
- **Padding XLarge**: 32px
- **Header Height**: 64px (with SafeArea)

### Border Radius
- **Cards**: 16px
- **Buttons**: 8px
- **Input Fields**: 8px
- **Status Badges**: 4px

---

## Screen-by-Screen Documentation

### 1. Login Screen (`login_screen.dart`)

**Route**: `/login`

#### Layout Structure
- **Background**: White (`AppColors.white`)
- **Layout**: Centered, single column, max width 400px
- **Padding**: Large padding on all sides

#### UI Elements (Top to Bottom)

1. **Logo Section**
   - **Location**: Top center
   - **Content**: 
     - "SC" in black, bold, 48px
     - "ASA" in primary purple, bold, 48px
   - **Spacing**: 48px below logo

2. **Email/Mobile Field**
   - **Label**: "Email or Mobile Number"
   - **Hint**: "Enter email or mobile number"
   - **Type**: Text input with email keyboard
   - **Validation**: Email or phone validator
   - **Styling**: White background, outlined border, 8px radius

3. **Password Field**
   - **Label**: "Password"
   - **Hint**: "Enter password"
   - **Type**: Password input (obscured by default)
   - **Suffix Icon**: Eye icon (visibility toggle)
   - **Action on Eye Click**: Toggles password visibility
   - **Validation**: Password validator
   - **Spacing**: 20px below email field

4. **Sign In Button**
   - **Text**: "Sign In"
   - **Type**: Primary button (purple background, white text)
   - **Location**: Below password field, 32px spacing
   - **Action on Click**:
     - Validates form
     - Shows loading state (spinner)
     - Calls authentication API
     - On success: Navigates to Dashboard
     - On failure: Shows red snackbar with "Invalid email/mobile or password"
   - **Loading State**: Shows circular progress indicator

#### Responsive Behavior
- Same layout on all screen sizes
- Constrained to max 400px width
- Scrollable if content exceeds viewport

---

### 2. MainScaffold (App Shell)

**Route**: All authenticated routes use this wrapper

#### Layout Structure
- **Background**: Light gray (`AppColors.backgroundLight`)
- **Structure**: Column layout with Header and Content

#### AppDrawer (Left Sidebar)

**Location**: Left side, accessible via hamburger menu

**Width**: 
- Mobile: 280px
- Desktop: 320px

**Structure**:

1. **Logo Section** (Top)
   - **Height**: 80px
   - **Content**: "SC" (black) + "ASA" (purple), 28px font
   - **Border**: Bottom border (1px, light gray)

2. **Navigation Items** (Scrollable list)
   - **Active State**: Purple background, white text
   - **Inactive State**: Transparent background, gray text
   - **Items** (in order):
     - Dashboard (dashboard icon)
     - Residents (people icon)
     - Maintenance Payment (credit card icon)
     - Finance (attach money icon)
     - Notice Board (campaign icon)
     - Complaint (report problem icon)
     - Permission (description icon)
     - Vendor (business icon)
     - Helper (build icon)
     - User (person icon)
     - **Expenses and Charge** (expandable section)
       - Deposit on renovation (home work icon)
       - Society Owned Room (room icon)
   - **Action on Click**: 
     - Closes drawer
     - Navigates to selected route
     - Updates active state

3. **Logout Button** (Bottom)
   - **Location**: Fixed at bottom
   - **Icon**: Logout icon (gray)
   - **Text**: "Logout" (gray, medium weight)
   - **Border**: Top border (1px, light gray)
   - **Action on Click**: 
     - Closes drawer
     - Logs out user
     - Navigates to login screen

#### AppHeader (Top Bar)

**Location**: Top of screen, below status bar

**Height**: 64px (with SafeArea)

**Background**: White with bottom border (1px, light gray)

**Left Section**:
- **Menu Icon** (Hamburger)
  - **Action**: Opens drawer
  - **Color**: Text primary (dark gray)

**Center Section** (Desktop/Tablet only):
- **Search Bar**
  - **Width**: Expanded (takes available space)
  - **Hint**: "Search Vendor Name and Resident Name..."
  - **Icon**: Search icon (prefix)
  - **Background**: Light gray (`gray100`)
  - **Border**: None
  - **Action**: Real-time search (onChange callback)

**Right Section**:
- **Search Icon** (Mobile only)
  - **Action**: Opens search dialog
  - **Dialog Content**: Text field with search functionality

- **Notifications Icon**
  - **Icon**: Bell outline
  - **Badge**: Red circle with count (if > 0)
  - **Badge Text**: Count number or "9+" if > 9
  - **Action on Click**: 
    - Opens dialog
    - Shows list of notifications
    - Each notification has: info icon, title, subtitle
    - Close button at bottom

- **User Profile Avatar**
  - **Size**: 
    - Mobile: 36px diameter
    - Desktop: 40px diameter
  - **Background**: Primary purple
  - **Text**: "HV" (initials, white, bold)
  - **Action on Click**: 
    - Opens profile dialog
    - Shows: Avatar (80px), Name, Email, Role
    - Close button

---

### 3. Dashboard Screen (`dashboard_screen.dart`)

**Route**: `/dashboard`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive (16px mobile, 24px desktop)
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Welcome Card**
   - **Background**: Purple gradient (top-left to bottom-right)
   - **Padding**: XLarge (32px)
   - **Border Radius**: 16px
   - **Content**:
     - Title: "Welcome back, Happy Valley!" (white, 32px, bold)
     - Subtitle: "Here's what's happening in your society today." (white, 90% opacity)
   - **Spacing**: 24px below

2. **SCASA Description Card**
   - **Background**: White card
   - **Elevation**: 0
   - **Padding**: XLarge (32px)
   - **Border Radius**: 16px
   - **Content**:
     - Title: "SCASA" (32px, bold)
     - Description: Long text about SCASA platform
     - Key Features section with star icon
   - **Spacing**: 24px below

#### Responsive Behavior
- Same layout on all screen sizes
- Padding adjusts based on screen size

---

### 4. Residents List Screen (`residents_list_screen.dart`)

**Route**: `/residents`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile Layout**: Column
     - Title: "Residents" (H1)
     - Subtitle: "Manage society residents and their information"
     - "Add Resident" button (full width)
   - **Desktop Layout**: Row
     - Left: Title and subtitle
     - Right: "Add Resident" button
   - **Add Resident Button**:
     - **Icon**: Plus icon
     - **Action**: Navigates to Create Resident screen
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards in responsive grid)
   - **Total Residents Card**
     - **Value**: Total count
     - **Subtitle**: "Registered residents"
     - **Color**: Purple border and value
     - **Icon**: People icon
   - **Active Card**
     - **Value**: Active count
     - **Subtitle**: "Currently active"
     - **Color**: Green border and value
     - **Icon**: Check circle icon
   - **Owner Occupied Card**
     - **Value**: Owner-occupied count
     - **Subtitle**: "Owner occupied"
     - **Color**: Blue border and value
     - **Icon**: Home icon
   - **Spacing**: 24px below

3. **Search and Filters Section**
   - **Mobile Layout**: Column
     - Search field (full width)
     - Two dropdowns side by side (Status, Type)
   - **Desktop Layout**: Row
     - Search field (expanded)
     - Status dropdown
     - Type dropdown
   - **Search Field**:
     - **Hint**: "Search residents or flat number..."
     - **Icon**: Search icon (prefix)
     - **Action**: Real-time filtering
   - **Status Dropdown**:
     - **Options**: All Status, Active, Inactive
     - **Action**: Filters by status
   - **Type Dropdown**:
     - **Options**: All Type, Owner-Living, Rented
     - **Action**: Filters by residency type
   - **Spacing**: 24px below

4. **Residents List**
   - **Empty State**: Card with "No residents found" message
   - **Mobile View**: Card list
     - Each card shows:
       - Name (H4)
       - Flat number (secondary text)
       - Status badge (colored)
       - Phone icon + number
       - Home icon + type
       - People icon + member count
       - Action buttons (View, Edit, Delete)
   - **Desktop View**: DataTable
     - **Columns**: Name, Flat Number, Type, Phone, Status, Created Date, Residents, Actions
     - **Action Buttons**: View, Edit, Delete (icon buttons)
   - **View Button**:
     - **Icon**: Eye icon
     - **Action**: Opens dialog with full resident details
   - **Edit Button**:
     - **Icon**: Edit icon
     - **Action**: Shows "coming soon" snackbar
   - **Delete Button**:
     - **Icon**: Delete icon (red)
     - **Action**: 
       - Opens confirmation dialog
       - On confirm: Deletes resident
       - On cancel: Closes dialog

#### View Resident Dialog
- **Title**: "Resident Details"
- **Content**: Scrollable list of:
  - Name
  - Flat
  - Type
  - Phone
  - Email
  - Status
  - Members count
  - Vehicles count
- **Actions**: Close button

#### Delete Confirmation Dialog
- **Title**: "Delete Resident"
- **Content**: "Are you sure you want to delete this resident?"
- **Actions**: 
  - Cancel button
  - Delete button (red text)

---

### 5. Create Resident Screen (`create_resident_screen.dart`)

**Route**: `/create-resident`

#### Layout Structure
- **Background**: Light gray
- **AppBar**: Standard with back button
- **Layout**: Single column, scrollable form

#### UI Elements (Top to Bottom)

1. **Owner Information Section**
   - **Title**: "Owner Information" (H3)
   - **Fields**:
     - Owner's Name* (required)
     - Flat Number* (required)
     - Residency Type* (dropdown: Owner-Living, Rented)
     - Phone Number* (required, phone keyboard)
     - Email Address (optional, email keyboard)
   - **Spacing**: 32px below section

2. **Add Residents Section**
   - **Title**: "Add Residents" (H3)
   - **Input Row** (3 fields):
     - Name field
     - Phone Number field
     - Date Joined field (read-only, calendar picker)
   - **Add Resident Button**:
     - **Type**: Secondary (outlined)
     - **Icon**: Plus icon
     - **Action**: Adds member to list
   - **Members List**:
     - Shows added members as cards
     - Each card: Name, Phone, Delete button
   - **Spacing**: 32px below section

3. **Vehicle Information Section**
   - **Title**: "Vehicle Information" (H3)
   - **Input Row** (2 fields):
     - Vehicle Number field
     - Vehicle Type dropdown (Car, Bike, Scooter, Other)
   - **Add Vehicle Button**:
     - **Type**: Secondary
     - **Icon**: Plus icon
     - **Action**: Adds vehicle to list
   - **Vehicles List**:
     - Shows added vehicles as cards
     - Each card: Vehicle number, Type, Delete button
   - **Spacing**: 32px below section

4. **Additional Documents Section**
   - **Title**: "Additional Documents" (H3)
   - **Add Document Button**:
     - **Type**: Secondary
     - **Icon**: Attach file icon
     - **Action**: Placeholder (no functionality yet)

5. **Form Actions** (Bottom)
   - **Layout**: Row with two buttons
   - **Cancel Button**:
     - **Type**: Secondary (outlined)
     - **Action**: Navigates back
   - **Create Resident Button**:
     - **Type**: Primary (purple)
     - **Icon**: Check icon
     - **Loading State**: Shows spinner
     - **Action**: 
       - Validates form
       - Creates resident
       - Navigates back on success

---

### 6. Maintenance Payments Screen (`maintenance_payments_screen.dart`)

**Route**: `/maintenance-payments`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Generate" button (full width)
   - **Desktop**: Row with title/subtitle left, action buttons right
   - **Action Buttons** (Desktop only):
     - Generate (primary)
     - Download All Invoice (secondary)
     - Download All Receipt (secondary)
     - Export CSV (secondary)
   - **Button Actions**: All show "coming soon" snackbars
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Collection**: Purple, currency value
   - **Collected**: Green, currency value, percentage
   - **Pending**: Yellow, currency value
   - **Spacing**: 24px below

3. **Payment List Placeholder**
   - **Content**: "Payment list will be displayed here"
   - **Styling**: White card with centered text

---

### 7. Finance Screen (`finance_screen.dart`)

**Route**: `/finance`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Make Payment" button
   - **Desktop**: Row with title/subtitle left, "Make Payment" button right
   - **Make Payment Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Credits**: Green, currency value
   - **Total Debits**: Red, currency value
   - **Balance**: Blue, currency value
   - **Spacing**: 24px below

3. **Search and Filter Section**
   - **Mobile**: Column (search field, type dropdown)
   - **Desktop**: Row (search field expanded, type dropdown)
   - **Search Field**: "Search transactions..."
   - **Type Dropdown**: All Type, Credit, Debit
   - **Spacing**: 24px below

4. **Tabs Section**
   - **Card Container**: White card
   - **Tab Bar**: Two tabs
     - "Credit (4)" tab
     - "Debit (1)" tab
   - **Tab Content**: 
     - **Height**: 400px
     - **Content**: List of transactions
     - Each transaction shows:
       - Title: "Transaction X"
       - Subtitle: "Description of transaction"
       - Trailing: Currency amount (colored by type)

---

### 8. Complaints Screen (`complaints_screen.dart`)

**Route**: `/complaints`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Add Complaint" button
   - **Desktop**: Row with title/subtitle left, "Add Complaint" button right
   - **Add Complaint Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Complaints**: Purple, count
   - **This Month**: Blue, count
   - **Pending**: Yellow, count
   - **Spacing**: 24px below

3. **Search Field**
   - **Hint**: "Search complaints by name, phone, email, flat, wing, or complaint text..."
   - **Action**: Real-time filtering
   - **Spacing**: 24px below

4. **Complaints List**
   - **Empty State**: "No complaints found" card
   - **Mobile View**: Card list
     - Each card shows:
       - Name (H4)
       - Flat number
       - Status badge (colored)
       - Complaint text
       - Phone and email icons with values
       - Action buttons (View, Edit, Delete)
   - **Desktop View**: DataTable
     - **Columns**: Name, Phone, Email, Flat, Complaint, Status, Created Date, Actions
   - **View Button**: Opens details dialog
   - **Edit Button**: Shows "coming soon" snackbar
   - **Delete Button**: Deletes complaint (no confirmation)

#### Complaint Details Dialog
- **Title**: "Complaint Details"
- **Content**: Scrollable list of all complaint fields
- **Actions**: Close button

---

### 9. Permissions Screen (`permissions_screen.dart`)

**Route**: `/permissions`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Add Permission" button
   - **Desktop**: Row with title/subtitle left, "Add Permission" button right
   - **Add Permission Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Permissions**: Purple, count
   - **This Month**: Blue, count
   - **Pending**: Yellow, count
   - **Spacing**: 24px below

3. **Search Field**
   - **Hint**: "Search permissions by name, phone, email, flat, wing, or permission text..."
   - **Action**: Real-time filtering
   - **Spacing**: 24px below

4. **Permissions List**
   - **Empty State**: "No permissions found" card
   - **Mobile View**: Card list
     - Each card shows:
       - Name (H4)
       - Flat number
       - Status badge (colored: Pending=Yellow, Approved=Green, Rejected=Red)
       - Permission text
       - Phone and email icons with values
       - Action buttons (View, Edit, Delete)
   - **Desktop View**: DataTable
     - **Columns**: Name, Phone, Email, Flat, Permission, Status, Created Date, Actions
   - **View Button**: Opens details (placeholder)
   - **Edit Button**: Placeholder (no action)
   - **Delete Button**: Deletes permission (no confirmation)

---

### 10. Vendors Screen (`vendors_screen.dart`)

**Route**: `/vendors`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, two buttons stacked
     - "Add Vendor" (primary)
     - "Create Invoice" (secondary)
   - **Desktop**: Row with title/subtitle left, action buttons right
     - "Create Invoice" (secondary)
     - "Add Vendor" (primary)
   - **Button Actions**: Both show "coming soon" snackbars
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Vendors**: Purple, count
   - **Total Bill**: Blue, currency value
   - **Paid**: Green, currency value
   - **Spacing**: 24px below

3. **Search Field**
   - **Hint**: "Search vendors by name, email, phone, or work details..."
   - **Action**: Real-time filtering
   - **Spacing**: 24px below

4. **Vendors List**
   - **Empty State**: "No vendors found" card
   - **Mobile View**: Card list
     - Each card shows:
       - Name (H4)
       - Email
       - Status badge (Paid=Green, Pending=Yellow)
       - Financial info (Total Bill, Paid, Pending in columns)
       - Action buttons (View, Edit, Delete)
   - **Desktop View**: DataTable
     - **Columns**: Name, Email, Phone, Work Type, Total Bill, Paid, Pending, Status, Actions
   - **View Button**: Placeholder
   - **Edit Button**: Placeholder
   - **Delete Button**: Deletes vendor (no confirmation)

---

### 11. Helpers Screen (`helpers_screen.dart`)

**Route**: `/helpers`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Add Helper" button
   - **Desktop**: Row with title/subtitle left, "Add Helper" button right
   - **Add Helper Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Helpers**: Purple, count
   - **Total Men**: Blue, count
   - **Total Women**: Yellow, count
   - **Spacing**: 24px below

3. **Search Field**
   - **Hint**: "Search helpers by name, phone, type, or notes..."
   - **Action**: Real-time filtering
   - **Spacing**: 24px below

4. **Helpers List**
   - **Empty State**: "No helpers found" card
   - **Mobile View**: Card list
     - Each card shows:
       - Name (H4)
       - Phone
       - Helper type and gender icons
       - Assigned flats (if any)
       - Action buttons (View, Edit, Delete)
   - **Desktop View**: DataTable
     - **Columns**: Name, Phone, Type, Gender, Assigned Flats, Notes, Actions
   - **View Button**: Placeholder
   - **Edit Button**: Placeholder
   - **Delete Button**: Deletes helper (no confirmation)

---

### 12. Users Screen (`users_screen.dart`)

**Route**: `/users`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Create User" button
   - **Desktop**: Row with title/subtitle left, "Create User" button right
   - **Create User Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Statistics Cards** (4 cards)
   - **Total Users**: Purple, count
   - **Admins**: Purple, count
   - **Receptionists**: Blue, count
   - **Residents**: Green, count
   - **Spacing**: 24px below

3. **Search Field**
   - **Hint**: "Search users..."
   - **Action**: Real-time filtering
   - **Spacing**: 24px below

4. **Users List**
   - **Empty State**: "No users found" card
   - **Mobile View**: Card list
     - Each card shows:
       - Name (H4)
       - Email
       - Role badge (colored: Admin=Purple, Receptionist=Blue, Resident=Green)
       - Phone (if available)
       - Flat number (if available)
       - Action buttons (View, Edit, Delete)
   - **Desktop View**: DataTable
     - **Columns**: Name, Email, Phone, Role, Flat Number, Created Date, Actions
   - **View Button**: Placeholder
   - **Edit Button**: Placeholder
   - **Delete Button**: Deletes user (no confirmation)

---

### 13. Notice Board Screen (`notice_board_screen.dart`)

**Route**: `/notice-board`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Create Notice" button
   - **Desktop**: Row with title/subtitle left, "Create Notice" button right
   - **Create Notice Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Empty State Card**
   - **Content**: 
     - Campaign icon (64px, gray)
     - "No notices yet" (H3)
     - "Create your first notice to get started" (body text)
   - **Styling**: White card, centered content

---

### 14. Deposit Renovation Screen (`deposit_renovation_screen.dart`)

**Route**: `/deposit-renovation`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Add Deposit" button
   - **Desktop**: Row with title/subtitle left, "Add Deposit" button right
   - **Add Deposit Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Deposits**: Purple, count (currently 0)
   - **This Month**: Blue, count (currently 0)
   - **Pending**: Yellow, count (currently 0)
   - **Spacing**: 24px below

3. **Placeholder Card**
   - **Content**: "Deposit records will be displayed here"
   - **Styling**: White card, centered text

---

### 15. Society Owned Room Screen (`society_owned_room_screen.dart`)

**Route**: `/society-owned-room`

#### Layout Structure
- **Background**: Light gray
- **Padding**: Responsive
- **Layout**: Single column, scrollable

#### UI Elements (Top to Bottom)

1. **Header Section**
   - **Mobile**: Column with title, subtitle, "Add Room Charge" button
   - **Desktop**: Row with title/subtitle left, "Add Room Charge" button right
   - **Add Room Charge Button**:
     - **Action**: Shows "coming soon" snackbar
   - **Spacing**: 24px below

2. **Statistics Cards** (3 cards)
   - **Total Rooms**: Purple, count (currently 0)
   - **Occupied**: Green, count (currently 0)
   - **Available**: Blue, count (currently 0)
   - **Spacing**: 24px below

3. **Placeholder Card**
   - **Content**: "Room records will be displayed here"
   - **Styling**: White card, centered text

---

## Common Components

### CustomButton

**Location**: `shared/widgets/custom_button.dart`

#### Types
1. **Primary Button**
   - **Background**: Primary purple
   - **Text**: White
   - **Padding**: 24px horizontal, 12px vertical
   - **Border Radius**: 8px
   - **Loading State**: White spinner

2. **Secondary Button**
   - **Style**: Outlined
   - **Border**: Gray
   - **Text**: Primary purple
   - **Padding**: Same as primary
   - **Loading State**: Gray spinner

3. **Text Button**
   - **Style**: Text only
   - **Text**: Primary purple
   - **No background or border

#### Props
- `text`: Button label (required)
- `onPressed`: Callback function
- `icon`: Optional icon (left side)
- `type`: ButtonType enum (primary, secondary, text)
- `isLoading`: Boolean for loading state

---

### CustomTextField

**Location**: `shared/widgets/custom_text_field.dart`

#### Styling
- **Background**: White (or gray100 if disabled)
- **Border**: Light gray, 8px radius
- **Focus Border**: Primary purple, 2px width
- **Error Border**: Red
- **Padding**: 16px horizontal, 12px vertical

#### Props
- `label`: Field label (optional)
- `hint`: Placeholder text (optional)
- `controller`: Text controller
- `validator`: Validation function
- `keyboardType`: Input type
- `obscureText`: Password mode
- `readOnly`: Read-only mode
- `suffixIcon`: Right-side icon/widget
- `prefixIcon`: Left-side icon/widget

---

### StatisticsCard

**Location**: `shared/widgets/statistics_card.dart`

#### Layout
- **Container**: White card
- **Border**: Top border (colored, 4px)
- **Content**:
  - Icon (left, colored)
  - Title (top)
  - Value (large, colored, bold)
  - Subtitle (bottom, gray)
  - Optional trend indicator

#### Props
- `title`: Card title
- `value`: Main value (string)
- `subtitle`: Description text
- `borderColor`: Top border color
- `valueColor`: Value text color
- `icon`: Icon data
- `showTrend`: Boolean for trend indicator

---

### ResponsiveStatisticsGrid

**Location**: `shared/widgets/responsive_statistics_grid.dart`

#### Behavior
- **Mobile**: Single column (1 card per row)
- **Tablet**: 2 columns (2 cards per row)
- **Desktop**: 3 columns (3 cards per row)

---

### ResponsiveTable

**Location**: `shared/widgets/responsive_table.dart`

#### Behavior
- **Mobile**: Card list view
- **Desktop**: DataTable with horizontal scroll

---

## Responsive Behavior

### Breakpoints
- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

### Responsive Utilities
- **Responsive.isMobile(context)**: Returns true if mobile
- **Responsive.getScreenPadding(context)**: Returns appropriate padding
- **Responsive.getDrawerWidth(context)**: Returns drawer width

### Layout Adaptations

#### Header
- **Mobile**: Menu icon, search icon, notifications, profile
- **Desktop**: Menu icon, search bar (expanded), notifications, profile

#### Action Buttons
- **Mobile**: Full width, stacked vertically
- **Desktop**: Inline, right-aligned

#### Statistics Grid
- **Mobile**: 1 column
- **Tablet**: 2 columns
- **Desktop**: 3-4 columns

#### Data Tables
- **Mobile**: Card list
- **Desktop**: DataTable with horizontal scroll

---

## User Interactions & Button Actions

### Navigation Flow

1. **Login → Dashboard**
   - On successful login, navigates to dashboard
   - Uses `pushReplacementNamed` to prevent back navigation

2. **Drawer Navigation**
   - Clicking any menu item:
     - Closes drawer
     - Updates current route
     - Changes screen content (no page transition)

3. **Create Resident**
   - Navigates to separate screen (full page)
   - Uses `pushNamed` (can go back)
   - On save: Pops back to residents list

### Button Actions Summary

#### Primary Actions (Purple Buttons)
- **Sign In**: Authenticates user
- **Add Resident**: Opens create resident form
- **Create Resident**: Saves new resident
- **Generate** (Maintenance): Placeholder
- **Make Payment** (Finance): Placeholder
- **Add Complaint**: Placeholder
- **Add Permission**: Placeholder
- **Add Vendor**: Placeholder
- **Create Invoice** (Vendors): Placeholder
- **Add Helper**: Placeholder
- **Create User**: Placeholder
- **Create Notice**: Placeholder
- **Add Deposit**: Placeholder
- **Add Room Charge**: Placeholder

#### Secondary Actions (Outlined Buttons)
- **Cancel**: Navigates back
- **Add Resident** (in form): Adds member to list
- **Add Vehicle** (in form): Adds vehicle to list
- **Add Document**: Placeholder
- **Download All Invoice**: Placeholder
- **Download All Receipt**: Placeholder
- **Export CSV**: Placeholder
- **Create Invoice** (Vendors): Placeholder

#### Icon Button Actions

**View (Eye Icon)**:
- Residents: Opens details dialog
- Complaints: Opens details dialog
- Others: Placeholder

**Edit (Pencil Icon)**:
- All screens: Shows "coming soon" snackbar (except residents which also shows snackbar)

**Delete (Trash Icon)**:
- Residents: Shows confirmation dialog, then deletes
- Complaints: Deletes immediately (no confirmation)
- Permissions: Deletes immediately
- Vendors: Deletes immediately
- Helpers: Deletes immediately
- Users: Deletes immediately

**Menu (Hamburger)**:
- Opens/closes drawer

**Search**:
- Mobile: Opens search dialog
- Desktop: Real-time search in header

**Notifications (Bell)**:
- Opens notifications dialog

**Profile (Avatar)**:
- Opens profile dialog

**Calendar (Date Picker)**:
- Opens date picker dialog
- Returns selected date

### Dialog Interactions

1. **Confirmation Dialogs**
   - Delete Resident: Yes/No confirmation
   - Others: No confirmation (direct delete)

2. **Information Dialogs**
   - Resident Details: Read-only information
   - Complaint Details: Read-only information
   - Profile: Read-only information
   - Notifications: List of notifications

3. **Form Dialogs**
   - Search (Mobile): Text input with cancel button
   - Date Picker: Calendar widget

### Loading States

- **Sign In Button**: Shows spinner during authentication
- **Create Resident Button**: Shows spinner during save
- **All Async Operations**: Show loading indicators

### Error Handling

- **Login Failure**: Red snackbar with error message
- **Form Validation**: Red border on invalid fields
- **API Errors**: Error screens with retry option (in some cases)
- **Empty States**: Friendly messages in cards

### Success Feedback

- **Snackbars**: Used for "coming soon" messages
- **Navigation**: Automatic navigation on success
- **No explicit success messages** (except navigation)

---

## Additional Notes

### Accessibility
- All buttons have tooltips
- Icons are properly sized
- Text has sufficient contrast
- Touch targets are appropriately sized

### Performance
- Lists use lazy loading where applicable
- Images are optimized
- State management uses Riverpod for efficient updates

### Future Enhancements (Placeholders)
Many features show "coming soon" snackbars:
- Add/Edit/Delete operations for most entities
- Document uploads
- Invoice/receipt downloads
- CSV exports
- Payment processing
- Notice creation

---

## Conclusion

This documentation provides a comprehensive overview of the SCASA Flutter app's UI/UX. Every screen, button, interaction, and design element has been documented to facilitate UI improvements and feature development.

For questions or clarifications, refer to the source code files mentioned in each section.


