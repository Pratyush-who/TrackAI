import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/features/tracker/tracker_screens/expense_saving_alcohol_money_etc.dart';
import 'package:trackai/features/tracker/tracker_screens/meditation.dart';
import 'package:trackai/features/tracker/tracker_screens/mood_tracker.dart';
import 'package:trackai/features/tracker/tracker_screens/sleep_tracker.dart';

class Trackerscreen extends StatefulWidget {
  const Trackerscreen({Key? key}) : super(key: key);

  @override
  State<Trackerscreen> createState() => _TrackerscreenState();
}

class _TrackerscreenState extends State<Trackerscreen> {
  bool showFavoritesOnly = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteTrackers = <String>{};

  final List<TrackerItem> allTrackers = [
    TrackerItem(
      id: 'sleep',
      title: 'Sleep Tracker',
      description: 'Track your sleep duration and quality.',
      unit: 'hours',
      icon: Icons.bedtime,
      color: Color(0xFF6B73FF),
      screen: SleepTrackerScreen(),
    ),
    TrackerItem(
      id: 'mood',
      title: 'Mood Tracker',
      description: 'Log your daily mood and notes.',
      unit: '1-10 scale',
      icon: Icons.sentiment_satisfied,
      color: Color(0xFFFF9500),
      screen: MoodTrackerScreen(),
    ),
    TrackerItem(
      id: 'meditation',
      title: 'Meditation Tracker',
      description: 'Log your meditation sessions and duration.',
      unit: 'minutes',
      icon: Icons.self_improvement,
      color: Color(0xFF34C759),
      screen: MeditationTrackerScreen(),
    ),
    TrackerItem(
      id: 'expense',
      title: 'Expense Tracker',
      description: 'Monitor your spending and budget.',
      unit: 'currency',
      icon: Icons.attach_money,
      color: Color(0xFFFF3B30),
      screen: ExpenseTrackerScreen(),
    ),
    TrackerItem(
      id: 'savings',
      title: 'Savings Tracker',
      description: 'Keep track of your savings goals.',
      unit: 'currency',
      icon: Icons.savings,
      color: Color(0xFF007AFF),
      screen: SavingsTrackerScreen(),
    ),
    TrackerItem(
      id: 'alcohol',
      title: 'Alcohol Tracker',
      description: 'Track your alcohol consumption.',
      unit: 'drinks',
      icon: Icons.local_bar,
      color: Color(0xFF8E4EC6),
      screen: AlcoholTrackerScreen(),
    ),
    TrackerItem(
      id: 'study',
      title: 'Study Time Tracker',
      description: 'Log your study sessions and focus periods.',
      unit: 'hours',
      icon: Icons.school,
      color: Color(0xFF5856D6),
      screen: StudyTrackerScreen(),
    ),
    TrackerItem(
      id: 'mental_wellbeing',
      title: 'Mental Well-being Tracker',
      description: 'Reflect on your mental state and well-being.',
      unit: '1-5 scale',
      icon: Icons.psychology,
      color: Color(0xFFAF52DE),
      screen: MentalWellbeingTrackerScreen(),
    ),
    TrackerItem(
      id: 'workout',
      title: 'Workout Tracker',
      description: 'Log your workouts, sets, reps, and duration.',
      unit: 'details',
      icon: Icons.fitness_center,
      color: Color(0xFFFF6B35),
      screen: WorkoutTrackerScreen(),
    ),
    TrackerItem(
      id: 'weight',
      title: 'Weight Tracker',
      description: 'Monitor your body weight.',
      unit: 'kg / lbs',
      icon: Icons.monitor_weight,
      color: Color(0xFF32D74B),
      screen: WeightTrackerScreen(),
    ),
    TrackerItem(
      id: 'menstrual',
      title: 'Menstrual Cycle',
      description: 'Log your period start date to predict the next one.',
      unit: 'date',
      icon: Icons.favorite,
      color: Color(0xFFFF2D92),
      screen: MenstrualTrackerScreen(),
    ),
  ];

  List<TrackerItem> get filteredTrackers {
    List<TrackerItem> filtered = allTrackers;

    if (showFavoritesOnly) {
      filtered = filtered.where((tracker) => _favoriteTrackers.contains(tracker.id)).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((tracker) =>
        tracker.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        tracker.description.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.background(isDark),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppColors.backgroundLinearGradient(isDark),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.black : AppColors.lightGrey).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            title: Row(
              children: [
                Text(
                  'Your Trackers (${filteredTrackers.length})',
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showFavoritesOnly = !showFavoritesOnly;
                  });
                  HapticFeedback.lightImpact();
                },
                icon: Icon(
                  showFavoritesOnly ? Icons.star : Icons.star_outline,
                  color: showFavoritesOnly 
                      ? AppColors.primary(isDark)
                      : AppColors.textSecondary(isDark),
                ),
                tooltip: showFavoritesOnly ? 'Show All Trackers' : 'Show Favorites Only',
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textPrimary(isDark),
                ),
                onSelected: (value) {
                  if (value == 'create_custom') {
                    // Handle create custom tracker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Create Custom Tracker feature coming soon!')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'create_custom',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: AppColors.textPrimary(isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'Create Custom Tracker',
                          style: TextStyle(color: AppColors.textPrimary(isDark)),
                        ),
                      ],
                    ),
                  ),
                ],
                color: AppColors.cardBackground(isDark),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColors.backgroundLinearGradient(isDark),
            ),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search all trackers...',
                      hintStyle: TextStyle(color: AppColors.textSecondary(isDark)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary(isDark),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.textSecondary(isDark),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.cardBackground(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary(isDark).withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary(isDark).withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary(isDark),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(color: AppColors.textPrimary(isDark)),
                  ),
                ),

                // Trackers List
                Expanded(
                  child: filteredTrackers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                showFavoritesOnly ? Icons.star_outline : Icons.search_off,
                                size: 64,
                                color: AppColors.textSecondary(isDark),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                showFavoritesOnly
                                    ? 'No favorite trackers yet'
                                    : 'No trackers found',
                                style: TextStyle(
                                  color: AppColors.textSecondary(isDark),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                showFavoritesOnly
                                    ? 'Star some trackers to see them here'
                                    : 'Try adjusting your search query',
                                style: TextStyle(
                                  color: AppColors.textSecondary(isDark),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTrackers.length,
                          itemBuilder: (context, index) {
                            final tracker = filteredTrackers[index];
                            final isFavorite = _favoriteTrackers.contains(tracker.id);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: _getCardDecoration(isDark),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => tracker.screen,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: tracker.color.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              tracker.icon,
                                              color: tracker.color,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tracker.title,
                                                  style: TextStyle(
                                                    color: AppColors.textPrimary(isDark),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Unit: ${tracker.unit}',
                                                  style: TextStyle(
                                                    color: AppColors.textSecondary(isDark),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isFavorite) {
                                                  _favoriteTrackers.remove(tracker.id);
                                                } else {
                                                  _favoriteTrackers.add(tracker.id);
                                                }
                                              });
                                              HapticFeedback.lightImpact();
                                            },
                                            icon: Icon(
                                              isFavorite ? Icons.star : Icons.star_outline,
                                              color: isFavorite 
                                                  ? AppColors.primary(isDark)
                                                  : AppColors.textSecondary(isDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        tracker.description,
                                        style: TextStyle(
                                          color: AppColors.textSecondary(isDark),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => tracker.screen,
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add, color: Colors.white),
                                          label: const Text(
                                            'Log Data',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary(isDark),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrackerItem {
  final String id;
  final String title;
  final String description;
  final String unit;
  final IconData icon;
  final Color color;
  final Widget screen;

  TrackerItem({
    required this.id,
    required this.title,
    required this.description,
    required this.unit,
    required this.icon,
    required this.color,
    required this.screen,
  });
}