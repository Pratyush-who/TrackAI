import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/services/auth_services.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/features/analytics/analyticsscreen.dart';
import 'package:trackai/features/home/homescreen.dart';
import 'package:trackai/features/settings/settingsscreen.dart';
import 'package:trackai/features/tracker/trackerscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late AnimationController _fabExpandController;
  late Animation<double> _fabAnimation;
  late Animation<double> _fabExpandAnimation;
  late Animation<Offset> _fabSlideAnimation1;
  late Animation<Offset> _fabSlideAnimation2;
  bool _isFabExpanded = false;
  bool _patternBackgroundEnabled = false;
  late List<Widget> _pages;

  

  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.track_changes_outlined,
      activeIcon: Icons.track_changes,
      label: 'Trackers',
    ),
    BottomNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
    ),
    BottomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const Homescreen(),
      const Trackerscreen(),
      const AnalyticsScreen(),
      Settingsscreen(
        onPatternBackgroundChanged: _savePatternPreference,
        patternBackgroundEnabled: _patternBackgroundEnabled,
      ),
    ];

    _loadPreferences();
    _pageController = PageController(initialPage: currentIndex);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabExpandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabExpandController, curve: Curves.elasticOut),
    );

    // Horizontal slide animations (right to left)
    _fabSlideAnimation1 =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _fabExpandController,
            curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
          ),
        );

    _fabSlideAnimation2 =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _fabExpandController,
            curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
          ),
        );

    _fabAnimationController.forward();
  }

  void _loadPreferences() async {
    // Load pattern background preference from shared preferences or similar
    // For now, using a simple state variable
    setState(() {
      _patternBackgroundEnabled = false; // Load from storage
    });
  }

  void _savePatternPreference(bool enabled) async {
    // Save to shared preferences or similar
    setState(() {
      _patternBackgroundEnabled = enabled;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    _fabExpandController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
      if ((index - _pageController.page!.round()).abs() == 1) {
        // Animate only for adjacent pages
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      } else {
        // Jump for non-adjacent pages to avoid jitter
        _pageController.jumpToPage(index);
      }
      HapticFeedback.lightImpact();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _toggleFabExpansion() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
    if (_isFabExpanded) {
      _fabExpandController.forward();
    } else {
      _fabExpandController.reverse();
    }
    HapticFeedback.lightImpact();
  }

  void _onDescribeFood() {
    _toggleFabExpansion();
    // Add your describe food functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Describe Food feature coming soon!')),
    );
  }

  void _onScanNutrition() {
    _toggleFabExpansion();
    // Add your scan nutrition functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan Nutrition feature coming soon!')),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseService.signOut();
      // AuthWrapper will automatically handle navigation to LoginPage
      print('Logout successful - AuthWrapper will handle navigation');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildPatternBackground(bool isDark) {
    if (!_patternBackgroundEnabled) return const SizedBox.shrink();

    return Positioned.fill(
      child: CustomPaint(
        painter: PatternBackgroundPainter(
          color: isDark
              ? Colors.white.withOpacity(0.03)
              : Colors.black.withOpacity(0.02),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          extendBody: false,
          backgroundColor: AppColors.background(isDark),
          appBar: _buildAppBar(isDark, themeProvider),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.backgroundLinearGradient(isDark),
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: _pages.map((page) {
                    // Pass the pattern background state to SettingsScreen
                    if (page is Settingsscreen) {
                      return Settingsscreen(
                        onPatternBackgroundChanged: _savePatternPreference,
                        patternBackgroundEnabled: _patternBackgroundEnabled,
                      );
                    }
                    return page;
                  }).toList(),
                ),
              ),
              _buildPatternBackground(isDark),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(isDark),
          floatingActionButton: _buildExpandableFAB(isDark),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, ThemeProvider themeProvider) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundLinearGradient(isDark),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.black : AppColors.lightGrey)
                  .withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.appBarGradient.createShader(bounds),
            child: Text(
              'TrackAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Theme Switch Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(isDark).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary(isDark).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              themeProvider.toggleTheme();
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(turns: animation, child: child);
              },
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey<bool>(isDark),
                color: AppColors.primary(isDark),
                size: 22,
              ),
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ),
        // User Profile Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(isDark).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary(isDark).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: AppColors.primary(isDark).withOpacity(0.2),
              child: FirebaseService.userPhotoURL != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        FirebaseService.userPhotoURL!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: AppColors.primary(isDark),
                          size: 20,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: AppColors.primary(isDark),
                      size: 20,
                    ),
            ),
            color: AppColors.cardBackground(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.textPrimary(isDark),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      FirebaseService.userDisplayName,
                      style: TextStyle(color: AppColors.textPrimary(isDark)),
                    ),
                  ],
                ),
              ),
              PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.errorColor),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(isDark);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.black : AppColors.lightGrey).withOpacity(
              0.1,
            ),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color.fromRGBO(95, 200, 185, 1.0),
        unselectedItemColor: const Color.fromARGB(255, 128, 133, 132),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(95, 200, 185, 1.0),
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Color.fromRGBO(95, 200, 185, 1.0),
        ),
        items: _navItems.map((item) {
          final isSelected = _navItems.indexOf(item) == currentIndex;
          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: const Color.fromRGBO(95, 200, 185, 1.0),
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandableFAB(bool isDark) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop for expanded FABs
        if (_isFabExpanded)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 300,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

        // Expandable buttons row
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Scan Nutrition Button (appears first, furthest left)
            SlideTransition(
              position: _fabSlideAnimation2,
              child: ScaleTransition(
                scale: _fabExpandAnimation,
                child: Opacity(
                  opacity: _fabExpandAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Scan',
                            style: TextStyle(
                              color: isDark ? Colors.black87 : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FloatingActionButton(
                          heroTag: "scan_nutrition",
                          mini: true,
                          onPressed: _onScanNutrition,
                          backgroundColor: AppColors.accent(isDark),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Describe Food Button (appears second, middle)
            SlideTransition(
              position: _fabSlideAnimation1,
              child: ScaleTransition(
                scale: _fabExpandAnimation,
                child: Opacity(
                  opacity: _fabExpandAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Describe',
                            style: TextStyle(
                              color: isDark ? Colors.black87 : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FloatingActionButton(
                          heroTag: "describe_food",
                          mini: true,
                          onPressed: _onDescribeFood,
                          backgroundColor: AppColors.primary(isDark),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main FAB (always visible, rightmost)
            AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: FloatingActionButton(
                    heroTag: "main_fab",
                    onPressed: _toggleFabExpansion,
                    backgroundColor: const Color.fromRGBO(95, 200, 185, 1.0),
                    shape: const CircleBorder(),
                    elevation: 6,
                    child: AnimatedRotation(
                      turns: _isFabExpanded ? 0.125 : 0, // 45 degree rotation
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.primary(isDark).withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary(isDark)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for pattern background
class PatternBackgroundPainter extends CustomPainter {
  final Color color;

  PatternBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw grid pattern
    for (double i = 0; i < size.width; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint..strokeWidth = 0.5,
      );
    }

    for (double i = 0; i < size.height; i += spacing * 2) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
