import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/services/auth_services.dart';
import 'package:trackai/core/services/streak_service.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/features/analytics/analyticsscreen.dart';
import 'package:trackai/features/home/homescreen.dart';
import 'package:trackai/features/settings/service/cam_Screen.dart';
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
  late Animation<double> _fabRotationAnimation;
  bool _isFabExpanded = false;
  bool _patternBackgroundEnabled = false;
  late List<Widget> _pages;

  // Streak-related variables
  int _currentStreak = 0;
  int _longestStreak = 0;
  bool _isLoadingStreak = true;

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
    _loadStreakData();
    _pageController = PageController(initialPage: currentIndex);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabExpandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _fabExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabExpandController, curve: Curves.easeOutCubic),
    );

    // Smoother slide animations
    _fabSlideAnimation1 =
        Tween<Offset>(
          begin: const Offset(0.8, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _fabExpandController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _fabSlideAnimation2 =
        Tween<Offset>(
          begin: const Offset(0.8, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _fabExpandController,
            curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    // Smoother rotation animation
    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _fabExpandController, curve: Curves.easeInOut),
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

  // Load streak data
  Future<void> _loadStreakData() async {
    try {
      final currentStreak = await StreakService.getCurrentStreakCount();
      final longestStreak = await StreakService.getLongestStreak();
      
      setState(() {
        _currentStreak = currentStreak;
        _longestStreak = longestStreak;
        _isLoadingStreak = false;
      });
    } catch (e) {
      print('Error loading streak data: $e');
      setState(() {
        _isLoadingStreak = false;
      });
    }
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

  void _onDescribeFood() async {
    _toggleFabExpansion();
    
    // Add slight delay for better UX
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ImageAnalysisScreen(
            analysisType: 'describe',
          ),
        ),
      );
    }
  }

  void _onScanNutrition() async {
    _toggleFabExpansion();
    
    // Add slight delay for better UX
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ImageAnalysisScreen(
            analysisType: 'scan',
          ),
        ),
      );
    }
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

  void _showStreakDialog(bool isDark) {
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
        title: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: AppColors.primary(isDark),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Streak Stats',
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStreakStatRow(
              'Current Streak',
              '$_currentStreak days',
              Icons.whatshot,
              isDark,
            ),
            const SizedBox(height: 16),
            _buildStreakStatRow(
              'Longest Streak',
              '$_longestStreak days',
              Icons.emoji_events,
              isDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Keep logging in daily to maintain your streak!',
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primary(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStatRow(String title, String value, IconData icon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary(isDark),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColors.backgroundLinearGradient(isDark),
            ),
            child: Stack(
              children: [
                // Pattern background behind content but still allowing interactions
                if (_patternBackgroundEnabled)
                  Positioned.fill(
                    child: IgnorePointer( // This is the key fix - ignores pointer events
                      child: CustomPaint(
                        painter: PatternBackgroundPainter(
                          color: isDark
                              ? Colors.white.withOpacity(0.12) // More visible in dark mode
                              : Colors.black.withOpacity(0.08), // More visible in light mode
                        ),
                      ),
                    ),
                  ),
                // Main content on top
                PageView(
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
              ],
            ),
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
        // Streak Indicator - Made clickable
        GestureDetector(
          onTap: () => _showStreakDialog(isDark),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(isDark).withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkPrimary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: _isLoadingStreak
                ? Container(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentStreak > 99 ? '99+' : _currentStreak.toString(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        // Theme Switch Button - made smaller while keeping border radius
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(isDark).withOpacity(0.8),
            borderRadius: BorderRadius.circular(52),
            border: Border.all(
              color: AppColors.primary(isDark).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Container(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                themeProvider.toggleTheme();
              },
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: AppColors.primary(isDark),
                size: 20,
              ),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
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
        unselectedItemColor: isDark 
            ? Colors.grey[600] 
            : Colors.grey[500],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
        items: _navItems.map((item) {
          final isSelected = _navItems.indexOf(item) == currentIndex;
          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandableFAB(bool isDark) {
    return AnimatedBuilder(
      animation: _fabExpandController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Backdrop for expanded FABs - only show when expanding
            if (_fabExpandController.value > 0.0)
              Positioned(
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: _fabExpandController.value,
                  child: Container(
                    width: 280 * _fabExpandController.value,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.3 * _fabExpandController.value)
                          : Colors.white.withOpacity(0.8 * _fabExpandController.value),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1 * _fabExpandController.value),
                          blurRadius: 10 * _fabExpandController.value,
                          spreadRadius: 2 * _fabExpandController.value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Expandable buttons row
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Scan Nutrition Button
                if (_fabExpandController.value > 0.0)
                  SlideTransition(
                    position: _fabSlideAnimation2,
                    child: FadeTransition(
                      opacity: _fabExpandAnimation,
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

                // Describe Food Button
                if (_fabExpandController.value > 0.0)
                  SlideTransition(
                    position: _fabSlideAnimation1,
                    child: FadeTransition(
                      opacity: _fabExpandAnimation,
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

                // Main FAB - smoother animation
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
                        child: AnimatedBuilder(
                          animation: _fabRotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _fabRotationAnimation.value * 2 * 3.14159,
                              child: const Icon(
                                Icons.add,
                                color: AppColors.white,
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
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

// Custom painter for pattern background - Updated to dots pattern
class PatternBackgroundPainter extends CustomPainter {
  final Color color;

  PatternBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill; // Changed to fill for dots

    const spacing = 30.0; // Spacing between dots
    const dotRadius = 1.5; // Radius of each dot

    // Draw grid of dots
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          dotRadius,
          paint,
        );
      }
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