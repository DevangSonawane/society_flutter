# SCASA - Society Comprehensive Administrative Solution Application

A Flutter-based mobile application for managing housing societies with comprehensive features for residents, finances, complaints, and administrative tasks.

## Overview

SCASA is a production-ready Flutter application that provides a complete solution for housing society management. The app integrates with Supabase for backend services and offers features for administrators, receptionists, and residents.

## Features

- 🏠 **Resident Management** - Complete resident database with family and vehicle details
- 💰 **Financial Management** - Track maintenance payments, vendor payments, deposits, and room charges
- 📋 **Complaint Management** - Submit and track complaints
- ✅ **Permission Management** - Request and approve permissions
- 👥 **User Management** - Multi-role support (Admin, Receptionist, Resident)
- 🏢 **Vendor & Helper Management** - Manage vendors and helpers
- 📢 **Notice Board** - Important announcements and updates
- 🔒 **Secure Authentication** - Secure login with Supabase Auth
- 📱 **Responsive Design** - Works on mobile, tablet, and desktop

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK
- Android Studio / Xcode (for mobile builds)
- Supabase account and project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd society
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   - Create a `.env` file in the root directory
   - Add your Supabase credentials:
     ```
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Application Flow

### Authentication
1. User opens the app → Login screen
2. Enter email/mobile and password
3. Upon successful authentication → Dashboard

### Main Navigation
The app uses a drawer/sidebar navigation with the following modules:

1. **Dashboard** - Overview and statistics
2. **Residents** - Manage residents, create/edit resident profiles
3. **Maintenance Payments** - Track and manage maintenance payments
4. **Finance** - Complete financial overview aggregating:
   - Maintenance payments (credits)
   - Vendor payments (debits)
   - Deposits (credits/debits)
   - Society room charges (credits)
   - Manual transactions
5. **Notice Board** - View and manage notices
6. **Complaints** - Submit and track complaints
7. **Permissions** - Request and approve permissions
8. **Vendors** - Manage vendor information and payments
9. **Helpers** - Manage helper assignments
10. **Expenses & Charges**
    - Deposit on Renovation
    - Society Owned Room
11. **Users** - Manage user accounts and roles

### Finance Module Flow

The Finance section aggregates data from multiple sources:

1. **Maintenance Payments** → Credits
   - When a maintenance payment is marked as "paid"
   - Format: "Maintenance Payment - Flat {flatNumber} - {month}/{year}"

2. **Vendor Payments** → Debits
   - When vendor bills are paid
   - Format: "Vendor Payment - {vendorName} - {invoiceNumber}"

3. **Deposits** → Credits/Debits
   - Collection: "Deposit on Renovation - Flat {flatNumber}" (credit)
   - Refund: "Deposit Refund - Flat {flatNumber}" (debit)

4. **Room Charges** → Credits
   - Monthly charges for occupied rooms
   - Format: "Room Charge - {roomNumber} - {month}/{year}"

5. **Manual Transactions** → Credits/Debits
   - Created via "Make Payment" button
   - User-defined transactions

## Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration
│   ├── constants/          # App constants
│   ├── routes/             # Route definitions
│   ├── services/           # Core services (Supabase, Logger, etc.)
│   ├── theme/              # App theme and styling
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── dashboard/         # Dashboard
│   ├── residents/          # Resident management
│   ├── maintenance_payments/ # Maintenance payments
│   ├── finance/           # Finance module
│   ├── complaints/        # Complaint management
│   ├── permissions/       # Permission management
│   ├── vendors/           # Vendor management
│   ├── helpers/           # Helper management
│   ├── expenses_charges/  # Deposits and room charges
│   └── users/             # User management
└── shared/                 # Shared components
    ├── models/            # Shared models
    └── widgets/           # Reusable widgets
```

## Data Flow

All data is fetched from Supabase database tables:

- **Residents** → `residents` table
- **Maintenance Payments** → `maintenance_payments` table
- **Vendors** → `vendors` table
- **Deposits** → `deposite_on_renovation` table
- **Society Rooms** → `society_owned_rooms` table
- **Complaints** → `complaints` table
- **Permissions** → `permissions` table
- **Helpers** → `helpers` table
- **Users** → `users` table
- **Notices** → `notices` table

The Finance module aggregates transactions from maintenance payments, vendors, deposits, and room charges in real-time.

## Building for Production

### Android
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Setup Guides

- **Android Keystore**: See `android/KEYSTORE_SETUP.md`
- **iOS Signing**: See `ios/SIGNING_SETUP.md`

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Key Technologies

- **Flutter** - UI framework
- **Riverpod** - State management
- **Supabase** - Backend (database, authentication)
- **Dart** - Programming language

## License

[Add your license here]

## Support

For issues or questions, please contact the development team.
