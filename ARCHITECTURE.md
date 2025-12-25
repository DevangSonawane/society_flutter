# SCASA Flutter App - Architecture Documentation

## Overview

SCASA (Society Comprehensive Administrative Solution Application) is a Flutter application built with a clean architecture pattern, using Riverpod for state management and Supabase as the backend.

## Architecture Pattern

The app follows a **Feature-Based Clean Architecture** pattern:

```
lib/
├── core/           # Core functionality (services, utils, config)
├── features/       # Feature modules (auth, residents, complaints, etc.)
└── shared/         # Shared widgets and models
```

## Layer Structure

### 1. Core Layer (`lib/core/`)

Contains app-wide functionality:

- **config/**: App configuration and environment variables
- **constants/**: App-wide constants
- **services/**: Core services (logging, crash reporting, analytics)
- **storage/**: Local storage (Hive) and caching
- **theme/**: App theming
- **utils/**: Utility functions and helpers
- **security/**: Security-related services

### 2. Features Layer (`lib/features/`)

Each feature is self-contained with:

```
feature_name/
├── data/
│   ├── models/        # Data models
│   └── repositories/   # Data access layer
├── domain/            # Business logic (if needed)
├── presentation/
│   ├── screens/       # UI screens
│   └── widgets/      # Feature-specific widgets
└── providers/         # Riverpod state management
```

### 3. Shared Layer (`lib/shared/`)

Shared across features:

- **models/**: Shared data models
- **widgets/**: Reusable UI components

## State Management

### Riverpod

The app uses **Flutter Riverpod** for state management:

- **StateNotifierProvider**: For complex state with business logic
- **FutureProvider**: For async data fetching
- **Provider**: For simple values and dependencies

### Example Provider Structure

```dart
// Provider for repository
final repositoryProvider = Provider<Repository>((ref) {
  return Repository();
});

// Provider for data
final dataProvider = FutureProvider<List<Model>>((ref) {
  final repository = ref.watch(repositoryProvider);
  return repository.getData();
});
```

## Data Flow

```
UI (Screen)
  ↓
Provider (State Management)
  ↓
Repository (Data Access)
  ↓
Supabase Service / Cache Service
  ↓
Supabase / Local Storage
```

## Key Components

### 1. Authentication

- **AuthProvider**: Manages authentication state
- **AuthGate**: Widget that checks auth status
- **LoginScreen**: Login UI
- Uses Supabase Auth for authentication

### 2. Navigation

- **MainScaffold**: Main app scaffold with drawer
- **AppDrawer**: Navigation drawer
- **AppHeader**: Top app bar
- Named routes in `main.dart`

### 3. Data Persistence

- **HiveService**: Local database initialization
- **CacheService**: Data caching layer
- **SyncService**: Offline sync functionality

### 4. Error Handling

- **ErrorHandler**: Centralized error handling
- **ErrorBoundary**: Widget for catching errors
- **CrashReportingService**: Error tracking

### 5. Logging & Monitoring

- **LoggerService**: Structured logging
- **AnalyticsService**: User analytics
- **PerformanceService**: Performance monitoring

## Dependency Injection

Riverpod provides dependency injection:

```dart
// Define provider
final myServiceProvider = Provider<MyService>((ref) {
  return MyService();
});

// Use in widget
final service = ref.watch(myServiceProvider);
```

## Environment Configuration

Environment variables are managed through:

- **AppConfig**: Loads and provides environment variables
- **.env**: Environment-specific configuration
- Supports: development, staging, production

## Security

- **SecureStorageService**: Secure storage for sensitive data
- **Environment Variables**: API keys stored in .env
- **ProGuard**: Code obfuscation for Android
- **Certificate Pinning**: (To be implemented)

## Testing Strategy

### Unit Tests
- Test providers and repositories
- Mock dependencies
- Location: `test/unit/`

### Widget Tests
- Test UI components
- Test user interactions
- Location: `test/widget/`

### Integration Tests
- Test complete user flows
- Test across features
- Location: `test/integration/`

## Build Configuration

### Android
- **build.gradle.kts**: Build configuration
- **proguard-rules.pro**: Code obfuscation rules
- **key.properties**: Signing configuration

### iOS
- **Info.plist**: App configuration
- **Signing**: Managed through Xcode

## CI/CD

GitHub Actions workflows:

- **test.yml**: Run tests on PR
- **build-android.yml**: Build Android app
- **build-ios.yml**: Build iOS app
- **build-web.yml**: Build web app

## Performance Considerations

- **Lazy Loading**: Load data on demand
- **Caching**: Cache frequently accessed data
- **Image Optimization**: Optimize images before use
- **Code Splitting**: Split large features

## Future Improvements

- [ ] Implement certificate pinning
- [ ] Add more comprehensive error recovery
- [ ] Implement advanced caching strategies
- [ ] Add more performance optimizations
- [ ] Implement push notifications
- [ ] Add biometric authentication

## Diagrams

### App Structure
```
SCASAApp
└── ErrorBoundary
    └── AuthGate
        ├── LoginScreen (if not authenticated)
        └── MainScaffold (if authenticated)
            ├── AppHeader
            ├── AppDrawer
            └── CurrentScreen
                ├── DashboardScreen
                ├── ResidentsListScreen
                ├── ComplaintsScreen
                └── ... (other screens)
```

### Data Flow
```
Screen → Provider → Repository → SupabaseService → Supabase
                ↓
            CacheService → HiveService → Local Storage
```

## References

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

