import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_screen.dart';
import 'config/theme.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MonivyApp());
}

class MonivyApp extends StatefulWidget {
  const MonivyApp({super.key});

  @override
  State<MonivyApp> createState() => _MonivyAppState();
}

class _MonivyAppState extends State<MonivyApp> {
  final _themeController = ThemeController();
  final _languageController = LanguageController();

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_onSettingsChanged);
    _languageController.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _themeController.removeListener(_onSettingsChanged);
    _languageController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeController.isDarkMode;
    
    return MaterialApp(
      title: 'YMmoney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

/// Splash screen that initializes app in background
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize database
    await DatabaseService().init();
    
    // Process recurring transactions in background
    DatabaseService().processRecurringTransactions();
    
    // Load settings
    ThemeController().loadFromProfile();
    LanguageController().loadFromProfile();
    
    // Navigate to main screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              'Monivy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _languageController = LanguageController();
  
  // Keys to access screen states for refreshing
  final _dashboardKey = GlobalKey<DashboardScreenState>();
  final _transactionsKey = GlobalKey<TransactionsScreenState>();
  final _reportKey = GlobalKey<ReportScreenState>();

  @override
  void initState() {
    super.initState();
    _languageController.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageController.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  void _refreshScreens() {
    // Refresh all screen data after adding/editing transactions
    _dashboardKey.currentState?.refreshData();
    _transactionsKey.currentState?.refreshData();
    _reportKey.currentState?.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Use key to force rebuild when language changes
    final languageKey = ValueKey(_languageController.language);
    
    return Scaffold(
      body: IndexedStack(
        key: languageKey,
        index: _currentIndex,
        children: [
          DashboardScreen(key: _dashboardKey),
          TransactionsScreen(key: _transactionsKey),
          ReportScreen(key: _reportKey),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => AddTransactionScreen(
                onTransactionAdded: _refreshScreens,
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.swap_horiz_rounded,
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                  isDark: isDark,
                ),
                // Spacer for FAB
                const SizedBox(width: 56),
                _buildNavItem(
                  icon: Icons.pie_chart_rounded,
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final unselectedColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primaryBlue : unselectedColor,
          size: 28,
        ),
      ),
    );
  }
}
