import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/widgets/app_drawer.dart';
import 'shared/widgets/app_header.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/residents/presentation/screens/residents_list_screen.dart';
import 'features/residents/presentation/screens/create_resident_screen.dart';
import 'features/residents/presentation/screens/resident_profile_screen.dart';
import 'features/maintenance_payments/presentation/screens/resident_maintenance_screen.dart';
import 'core/utils/permissions.dart';
import 'features/maintenance_payments/presentation/screens/maintenance_payments_screen.dart';
import 'features/finance/presentation/screens/finance_screen.dart';
import 'features/complaints/presentation/screens/complaints_screen.dart';
import 'features/permissions/presentation/screens/permissions_screen.dart';
import 'features/vendors/presentation/screens/vendors_screen.dart';
import 'features/helpers/presentation/screens/helpers_screen.dart';
import 'features/users/presentation/screens/users_screen.dart';
import 'features/dashboard/presentation/screens/notice_board_screen.dart';
import 'features/expenses_charges/presentation/screens/deposit_renovation_screen.dart';
import 'features/expenses_charges/presentation/screens/society_owned_room_screen.dart';
import 'features/search/presentation/screens/search_results_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'core/config/app_config.dart';
import 'core/services/crash_reporting_service.dart';
import 'shared/widgets/error_boundary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI for immersive mode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Load environment variables
  await AppConfig.load();

  // Initialize crash reporting (wraps app initialization)
  await CrashReportingService.initialize();

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: ErrorBoundary(
        context: 'App',
        child: SCASAApp(),
      ),
    ),
  );
}


class SCASAApp extends StatelessWidget {
  const SCASAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.dashboardRoute: (context) => const MainScaffold(initialRoute: AppConstants.dashboardRoute),
        AppConstants.residentsRoute: (context) => const MainScaffold(initialRoute: AppConstants.residentsRoute),
        AppConstants.createResidentRoute: (context) => const CreateResidentScreen(),
        AppConstants.maintenancePaymentsRoute: (context) => const MainScaffold(initialRoute: AppConstants.maintenancePaymentsRoute),
        AppConstants.financeRoute: (context) => const MainScaffold(initialRoute: AppConstants.financeRoute),
        AppConstants.complaintsRoute: (context) => const MainScaffold(initialRoute: AppConstants.complaintsRoute),
        AppConstants.permissionsRoute: (context) => const MainScaffold(initialRoute: AppConstants.permissionsRoute),
        AppConstants.vendorsRoute: (context) => const MainScaffold(initialRoute: AppConstants.vendorsRoute),
        AppConstants.helpersRoute: (context) => const MainScaffold(initialRoute: AppConstants.helpersRoute),
        AppConstants.usersRoute: (context) => const MainScaffold(initialRoute: AppConstants.usersRoute),
        AppConstants.noticeBoardRoute: (context) => const MainScaffold(initialRoute: AppConstants.noticeBoardRoute),
        AppConstants.depositRenovationRoute: (context) => const MainScaffold(initialRoute: AppConstants.depositRenovationRoute),
        AppConstants.societyOwnedRoomRoute: (context) => const MainScaffold(initialRoute: AppConstants.societyOwnedRoomRoute),
        AppConstants.searchRoute: (context) {
          final query = ModalRoute.of(context)!.settings.arguments as String? ?? '';
          return SearchResultsScreen(query: query);
        },
      },
    );
  }
}

class MainScaffold extends ConsumerStatefulWidget {
  final String initialRoute;

  const MainScaffold({
    super.key,
    required this.initialRoute,
  });

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
  }

  void _navigate(String route) {
    // If navigating to login, use Navigator to replace the entire scaffold
    if (route == AppConstants.loginRoute) {
      ref.read(authProvider.notifier).logout();
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (route) => false,
      );
      return;
    }
    
    // For routes that are handled by MainScaffold, just update the state
    // This avoids Navigator errors since we're already inside a scaffold
    if (_isMainScaffoldRoute(route)) {
      setState(() {
        _currentRoute = route;
      });
    } else {
      // For other routes (like create resident), use Navigator
      Navigator.of(context).pushNamed(route);
    }
  }

  bool _isMainScaffoldRoute(String route) {
    return route == AppConstants.dashboardRoute ||
        route == AppConstants.residentsRoute ||
        route == AppConstants.maintenancePaymentsRoute ||
        route == AppConstants.financeRoute ||
        route == AppConstants.complaintsRoute ||
        route == AppConstants.permissionsRoute ||
        route == AppConstants.vendorsRoute ||
        route == AppConstants.helpersRoute ||
        route == AppConstants.usersRoute ||
        route == AppConstants.noticeBoardRoute ||
        route == AppConstants.depositRenovationRoute ||
        route == AppConstants.societyOwnedRoomRoute;
  }

  Widget _getCurrentScreen() {
    final user = ref.read(authProvider);
    final userRole = Permissions.getUserRole(user);
    
    // For residents, use different screens
    if (userRole == UserRole.resident) {
      switch (_currentRoute) {
        case AppConstants.dashboardRoute:
          return const DashboardScreen();
        case AppConstants.residentsRoute:
          return const ResidentProfileScreen(); // Show their profile instead of list
        case AppConstants.maintenancePaymentsRoute:
          return const ResidentMaintenanceScreen(); // Resident-specific screen
        case AppConstants.noticeBoardRoute:
          return const NoticeBoardScreen(); // Read-only
        case AppConstants.complaintsRoute:
          return const ComplaintsScreen(); // Filtered to their complaints
        case AppConstants.permissionsRoute:
          return const PermissionsScreen(); // Filtered to their permissions
        case AppConstants.helpersRoute:
          return const HelpersScreen(); // Filtered to their flat
        default:
          return const DashboardScreen();
      }
    }
    
    // Admin/Receptionist screens (existing code)
    switch (_currentRoute) {
      case AppConstants.dashboardRoute:
        return const DashboardScreen();
      case AppConstants.residentsRoute:
        return const ResidentsListScreen();
      case AppConstants.maintenancePaymentsRoute:
        return const MaintenancePaymentsScreen();
      case AppConstants.financeRoute:
        return const FinanceScreen();
      case AppConstants.complaintsRoute:
        return const ComplaintsScreen();
      case AppConstants.permissionsRoute:
        return const PermissionsScreen();
      case AppConstants.vendorsRoute:
        return const VendorsScreen();
      case AppConstants.helpersRoute:
        return const HelpersScreen();
      case AppConstants.usersRoute:
        return const UsersScreen();
      case AppConstants.noticeBoardRoute:
        return const NoticeBoardScreen();
      case AppConstants.depositRenovationRoute:
        return const DepositRenovationScreen();
      case AppConstants.societyOwnedRoomRoute:
        return const SocietyOwnedRoomScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLight,
      drawer: AppDrawer(
        currentRoute: _currentRoute,
        onNavigate: _navigate,
      ),
      body: Column(
        children: [
          AppHeader(
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: ErrorBoundary(
                context: 'MainScaffold-${_currentRoute}',
                child: Container(
                  key: ValueKey<String>(_currentRoute),
                  color: AppColors.backgroundLight,
                  child: _getCurrentScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
