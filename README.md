# SCASA Flutter App

**Society Comprehensive Administrative Solution Application**

A production-ready Flutter application for managing housing societies, featuring resident management, financial tracking, complaint handling, and more.

## Status: Production Ready ✅

The app has been fully prepared for production deployment with:
- ✅ Environment configuration management
- ✅ Production build signing (Android & iOS)
- ✅ Error handling and crash reporting
- ✅ Comprehensive testing infrastructure
- ✅ CI/CD pipeline
- ✅ Offline support and data persistence
- ✅ Analytics and performance monitoring
- ✅ Complete documentation

## Features

- 🏠 **Resident Management** - Complete resident database with family and vehicle details
- 💰 **Financial Management** - Track maintenance payments and transactions
- 📋 **Complaint Management** - Submit and track complaints
- ✅ **Permission Management** - Request and approve permissions
- 👥 **User Management** - Multi-role support (Admin, Receptionist, Resident)
- 🏢 **Vendor & Helper Management** - Manage vendors and helpers
- 📢 **Notice Board** - Important announcements and updates
- 🔒 **Secure** - Secure authentication and data encryption
- 📱 **Offline Support** - Work offline with automatic sync

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK
- Android Studio / Xcode (for mobile builds)
- Supabase account

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
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture documentation
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Backend API integration guide
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[FUTURE_FEATURES.md](FUTURE_FEATURES.md)** - Planned features roadmap

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

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## CI/CD

The project includes GitHub Actions workflows for:
- Automated testing on PR
- Building Android, iOS, and Web apps
- Code quality checks

## Project Structure

```
lib/
├── core/           # Core functionality (services, utils, config)
├── features/       # Feature modules
└── shared/         # Shared widgets and models
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

## License

[Add your license here]

## Support

For support, check:
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API questions
- Contact: [your-email@example.com]
