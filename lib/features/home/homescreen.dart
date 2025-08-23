import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/routes/routes.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/features/settings/service/goalservice.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  DateTime _currentDate = DateTime.now();
  PageController _pageController = PageController(initialPage: 1);
  int _currentPageIndex = 1;

  // Firebase data
  Map<String, dynamic>? _goalsData;
  bool _isLoadingGoals = true;
  String? _goalsError;

  @override
  void initState() {
    super.initState();
    _loadGoalsData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadGoalsData() async {
    try {
      setState(() {
        _isLoadingGoals = true;
        _goalsError = null;
      });

      final goalsData = await GoalsService.getGoals();

      setState(() {
        _goalsData = goalsData;
        _isLoadingGoals = false;
      });
    } catch (e) {
      setState(() {
        _goalsError = e.toString();
        _isLoadingGoals = false;
      });
    }
  }

  void _navigateToWeek(int direction) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 7 * direction));
    });
  }

  List<DateTime> _getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  BoxDecoration _getCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(40, 50, 49, 0.85),
            const Color.fromARGB(215, 14, 14, 14),
            Color.fromRGBO(33, 43, 42, 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkPrimary.withOpacity(0.8),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightSecondary.withOpacity(0.85),
            AppColors.lightSecondary.withOpacity(0.85),
            AppColors.lightSecondary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimary.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }
void _handleAILabAction(String action) {
  switch (action) {
    case 'body-analyzer':
      Navigator.pushNamed(context, AppRoutes.bodyAnalyzer);
      break;
    case 'smart-gymkit':
      Navigator.pushNamed(context, AppRoutes.smartGymkit);
      break;
    case 'calorie_calc':
      Navigator.pushNamed(context, AppRoutes.calorieCalculator);
      break;
    case 'meal_planner':
      Navigator.pushNamed(context, AppRoutes.mealPlanner);
      break;
    case 'recipe_generator':
      Navigator.pushNamed(context, AppRoutes.recipeGenerator);
      break;
    default:
      _showSnackBar('Feature coming soon!');
      break;
  }
}
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final weekDates = _getWeekDates(_currentDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.001),

            // Calendar Widget
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Month/Year Header with navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _navigateToWeek(-1),
                        icon: Icon(
                          Icons.chevron_left,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          size: 24,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _getMonthYear(_currentDate),
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _navigateToWeek(1),
                        icon: Icon(
                          Icons.chevron_right,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Week days header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              color: isDarkTheme
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Dates row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekDates.map((date) {
                      final isToday =
                          date.day == DateTime.now().day &&
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.accent(isDarkTheme)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isToday
                                    ? Colors.white
                                    : (isDarkTheme
                                          ? Colors.white
                                          : Colors.black87),
                                fontSize: 16,
                                fontWeight: isToday
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Cards Section - Responsive height
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 180,
                maxHeight: screenHeight * 0.25,
              ),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  // Left Card - New Features Coming Soon
                  _buildNewFeaturesCard(isDarkTheme),

                  // Center Card - Main Content
                  _buildMainContentCard(isDarkTheme),

                  // Right Card - Log Activities
                  _buildLogActivitiesCard(isDarkTheme),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPageIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPageIndex == index
                        ? AppColors.primary(isDarkTheme)
                        : (isDarkTheme ? Colors.white30 : Colors.black26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Macro tracking section (now with Firebase data)
            _buildMacroTrackingSection(isDarkTheme),

            SizedBox(height: screenHeight * 0.03),

            // Fiber Remaining section (now with Firebase data)
            _buildFiberSection(isDarkTheme),

            SizedBox(height: screenHeight * 0.03),

            // AI Lab Quick Actions - Full section
            _buildFullAILabSection(isDarkTheme),

            SizedBox(height: screenHeight * 0.03),

            // Wellness Tips Section
            _buildWellnessTipsSection(isDarkTheme),

            SizedBox(height: screenHeight * 0.001),
          ],
        ),
      ),
    );
  }

  Widget _buildNewFeaturesCard(bool isDarkTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.primary(isDarkTheme),
            size: 32,
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              'New Features Coming Soon!',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              "We're always working on new ways to help you on your wellness journey. Stay tuned!",
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 12,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentCard(bool isDarkTheme) {
    // Show loading state
    if (_isLoadingGoals) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: _getCardDecoration(isDarkTheme),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary(isDarkTheme),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your targets...',
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (_goalsError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: _getCardDecoration(isDarkTheme),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.primary(isDarkTheme),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load targets',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to retry',
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show no data state
    if (_goalsData == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: _getCardDecoration(isDarkTheme),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes,
              color: AppColors.primary(isDarkTheme),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Set Your Daily Targets',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Calculate your personalized nutrition goals',
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show data from Firebase
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Icon(
                Icons.track_changes,
                color: AppColors.primary(isDarkTheme),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Daily Macro Targets',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Personalized goals based on your profile.',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Divider(),
          const SizedBox(height: 6),

          // Calories Section with Firebase data
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Calories Remaining',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${_goalsData!['calories'] ?? 0} ',
                                style: TextStyle(
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'kcal',
                                style: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Side Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkTheme ? Colors.white10 : Colors.black12,
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary(isDarkTheme),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogActivitiesCard(bool isDarkTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            color: AppColors.primary(isDarkTheme),
            size: 32,
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              'Log Your Activities',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              'Go to tracker to log your meals, workouts, and daily activities.',
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 12,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTrackingSection(bool isDarkTheme) {
    // Show loading or error states
    if (_isLoadingGoals) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _getCardDecoration(isDarkTheme),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary(isDarkTheme),
            ),
          ),
        ),
      );
    }

    if (_goalsError != null || _goalsData == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _getCardDecoration(isDarkTheme),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.primary(isDarkTheme),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              _goalsData == null
                  ? 'No macro targets set'
                  : 'Failed to load macros',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadGoalsData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(isDarkTheme),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_goalsData == null ? 'Set Goals' : 'Retry'),
            ),
          ],
        ),
      );
    }

    // Use LayoutBuilder for responsive design
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Protein',
                '${_goalsData!['protein'] ?? 0}',
                'g left',
                Icons.flash_on,
                isDarkTheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMacroCard(
                'Carbs',
                '${_goalsData!['carbs'] ?? 0}',
                'g left',
                Icons.grain,
                isDarkTheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMacroCard(
                'Fats',
                '${_goalsData!['fat'] ?? 0}',
                'g left',
                Icons.water_drop,
                isDarkTheme,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroCard(
    String title,
    String value,
    String unit,
    IconData icon,
    bool isDarkTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDarkTheme ? Colors.white : Colors.black).withOpacity(
                0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary(isDarkTheme), size: 24),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiberSection(bool isDarkTheme) {
    // Show loading or error states
    if (_isLoadingGoals) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _getCardDecoration(isDarkTheme),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiber Remaining',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary(isDarkTheme),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary(isDarkTheme).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco,
                color: AppColors.primary(isDarkTheme),
                size: 24,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiber Remaining',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${_goalsData?['fiber'] ?? 0}',
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black87,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' g',
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary(isDarkTheme).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco,
              color: AppColors.primary(isDarkTheme),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullAILabSection(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primary(isDarkTheme),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Lab Quick Actions',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Launch powerful AI assistance with a single tap.',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Body Composition Analyzer - Full width
          GestureDetector(
            onTap: () => _handleAILabAction('body-analyzer'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDarkTheme ? Colors.white : Colors.black)
                    .withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDarkTheme ? Colors.white : Colors.black)
                      .withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary(
                        isDarkTheme,
                      ).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: AppColors.primary(isDarkTheme),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Body Composition Analyzer',
                          style: TextStyle(
                            color: isDarkTheme
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get 18 detailed body composition metrics from our AI.',
                          style: TextStyle(
                            color: isDarkTheme
                                ? Colors.white70
                                : Colors.black54,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grid of 4 smaller cards - Responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildAILabCard(
                          'Smart Gymkit',
                          'Your gym companion.',
                          Icons.show_chart,
                          'smart-gymkit',
                          isDarkTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAILabCard(
                          'Calorie Burn Calc',
                          'Estimate burned calories.',
                          Icons.water_drop,
                          'calorie_calc',
                          isDarkTheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAILabCard(
                          'AI Meal Planner',
                          'Get tailored meal plans.',
                          Icons.restaurant_menu,
                          'meal_planner',
                          isDarkTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAILabCard(
                          'AI Recipe Generator',
                          'Create recipes you have.',
                          Icons.menu_book,
                          'recipe_generator',
                          isDarkTheme,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAILabCard(
    String title,
    String description,
    IconData icon,
    String action,
    bool isDarkTheme,
  ) {
    return GestureDetector(
      onTap: () => _handleAILabAction(action),
      child: Container(
        height: 110, // Fixed height for consistency
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isDarkTheme ? Colors.white : Colors.black)
              .withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDarkTheme ? Colors.white : Colors.black)
                .withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon at top
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary(
                  isDarkTheme,
                ).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary(isDarkTheme),
                size: 16,
              ),
            ),
            
            // Text content at bottom
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkTheme
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDarkTheme
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 10,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessTipsSection(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary(isDarkTheme),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Wellness Tips',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Personalized advice to help you reach your goals (future AI enhancement).',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Wellness Tips with greyish background
          _buildWellnessTip(
            'Aim for 7-9 hours of quality sleep per night to improve mood and energy.',
            isDarkTheme,
          ),
          const SizedBox(height: 12),
          _buildWellnessTip(
            'Stay hydrated by drinking at least 8 glasses of water throughout the day.',
            isDarkTheme,
          ),
          const SizedBox(height: 12),
          _buildWellnessTip(
            'Consistent exercise, even 30 minutes daily, can significantly boost your overall well-being.',
            isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTip(String tip, bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDarkTheme ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDarkTheme ? Colors.white : Colors.black).withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary(isDarkTheme).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: AppColors.primary(isDarkTheme),
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}