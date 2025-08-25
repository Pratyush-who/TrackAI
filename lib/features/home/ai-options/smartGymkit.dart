import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/features/home/ai-options/service/bulkingmacroservice.dart';
import 'package:trackai/features/home/ai-options/service/filedownload.dart';
import 'package:trackai/features/home/ai-options/service/workoutPlannerService.dart';
import 'package:trackai/features/onboarding/service/observices.dart';

class Smartgymkit extends StatefulWidget {
  const Smartgymkit({Key? key}) : super(key: key);

  @override
  State<Smartgymkit> createState() => _SmartgymkitState();
}

class _SmartgymkitState extends State<Smartgymkit>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Workout Planner Variables
  final TextEditingController _fitnessGoalsController = TextEditingController();
  String _selectedFitnessLevel = 'Select your fitness level';
  String _selectedWorkoutType = 'Any';
  String _selectedPlanDuration = '7 Days';
  String _selectedGoal = '';
  bool _showGoalOptions = false;
  bool _isGeneratingPlan = false;
  Map<String, dynamic>? _savedWorkoutPlan;
  bool _isLoadingSavedPlan = false;

  // Bulking Macros Variables
  String _selectedGender = 'Select gender';
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedWeightUnit = 'kg';
  String _selectedHeightUnit = 'cm';
  String _selectedActivityLevel = 'Select activity level';
  final TextEditingController _targetGainController = TextEditingController();
  String _selectedTargetUnit = 'kg';
  final TextEditingController _timeframeController = TextEditingController();
  Map<String, dynamic>? _bulkingResults;
  Map<String, dynamic>? _onboardingData;
  bool _isCalculatingMacros = false;

  final List<String> _fitnessLevels = [
    'Select your fitness level',
    'Beginner (0-6 months)',
    'Intermediate (6 months - 2 years)',
    'Advanced (2-5 years)',
    'Expert (5+ years)',
  ];

  final List<String> _workoutTypes = [
    'Any',
    'Home Workout',
    'Gym Workout',
    'Calisthenics',
    'Strength Training',
    'Cardio Focus',
    'Hybrid Training',
  ];

  final List<String> _planDurations = [
    '3 Days',
    '5 Days',
    '7 Days',
    '14 Days',
    '21 Days',
    '30 Days',
  ];

  final List<Map<String, String>> _fitnessGoals = [
    {'title': 'Lose weight and improve cardiovascular health', 'icon': '🏃‍♀️'},
    {'title': 'Build muscle and increase overall strength', 'icon': '💪'},
    {'title': 'Improve general fitness and endurance', 'icon': '🏃‍♂️'},
    {'title': 'Increase flexibility and mobility', 'icon': '🤸‍♀️'},
    {'title': 'Tone up and improve body composition', 'icon': '✨'},
    {'title': 'Prepare for a specific sport or event', 'icon': '🏆'},
    {'title': 'Reduce stress and improve mental well-being', 'icon': '🧘‍♀️'},
    {'title': 'Gain functional strength for daily activities', 'icon': '🏠'},
    {'title': 'Improve posture and core stability', 'icon': '🧍‍♀️'},
    {'title': 'Increase energy levels throughout the day', 'icon': '⚡'},
  ];

  final List<String> _genders = ['Select gender', 'Male', 'Female', 'Other'];

  final List<String> _activityLevels = [
    'Select activity level',
    'Sedentary (desk job, no exercise)',
    'Lightly Active (light exercise 1-3 days/week)',
    'Moderately Active (moderate exercise 3-5 days/week)',
    'Very Active (hard exercise 6-7 days/week)',
    'Super Active (very hard exercise, physical job)',
  ];

  final List<String> _weightUnits = ['kg', 'lbs'];
  final List<String> _heightUnits = ['cm', 'ft'];
  final List<String> _targetUnits = ['kg', 'lbs'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadSavedWorkoutPlan();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await OnboardingService.getOnboardingData();
      if (data != null) {
        setState(() {
          _onboardingData = data;
          // Pre-fill data if available
          if (data['gender'] != null) {
            _selectedGender = data['gender'];
          }
          if (data['weightKg'] != null) {
            _weightController.text = data['weightKg'].toString();
          }
          if (data['heightCm'] != null) {
            _heightController.text = data['heightCm'].toString();
          }
          if (data['dateOfBirth'] != null) {
            final age = OnboardingService.calculateAge(data['dateOfBirth']);
            _ageController.text = age.toString();
          }
          if (data['activityLevel'] != null) {
            _selectedActivityLevel = data['activityLevel'];
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadSavedWorkoutPlan() async {
    setState(() {
      _isLoadingSavedPlan = true;
    });

    try {
      final savedPlan = await WorkoutPlannerService.getSavedWorkoutPlan();

      if (savedPlan != null) {
        setState(() {
          _savedWorkoutPlan = savedPlan;
        });
      }
    } catch (e) {
      print('Error loading saved workout plan: $e');
    } finally {
      setState(() {
        _isLoadingSavedPlan = false;
      });
    }
  }

  Future<void> _generateWorkoutPlan() async {
    if (_selectedFitnessLevel == 'Select your fitness level' ||
        _fitnessGoalsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingPlan = true;
    });

    try {
      final workoutPlan = await WorkoutPlannerService.generateWorkoutPlan(
        fitnessGoals: _fitnessGoalsController.text,
        fitnessLevel: _selectedFitnessLevel,
        workoutType: _selectedWorkoutType,
        planDuration: _selectedPlanDuration,
        onboardingData: _onboardingData,
      );

      if (workoutPlan != null) {
        await WorkoutPlannerService.saveWorkoutPlan(workoutPlan);
        setState(() {
          _savedWorkoutPlan = workoutPlan;
        });
        _showWorkoutPlanDialog(workoutPlan);
      } else {
        throw Exception('Failed to generate workout plan. Please try again.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPlan = false;
      });
    }
  }

  Future<void> _calculateBulkingMacros() async {
    if (_selectedGender == 'Select gender' ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _selectedActivityLevel == 'Select activity level' ||
        _targetGainController.text.isEmpty ||
        _timeframeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isCalculatingMacros = true;
    });

    try {
      // Convert units to metric if needed
      double weightInKg = double.parse(_weightController.text);
      if (_selectedWeightUnit == 'lbs') {
        weightInKg = weightInKg * 0.453592;
      }

      double heightInCm = double.parse(_heightController.text);
      if (_selectedHeightUnit == 'ft') {
        heightInCm = heightInCm * 30.48;
      }

      double targetGainInKg = double.parse(_targetGainController.text);
      if (_selectedTargetUnit == 'lbs') {
        targetGainInKg = targetGainInKg * 0.453592;
      }

      final macroResults = await BulkingMacrosService.calculateBulkingMacros(
        gender: _selectedGender,
        weight: weightInKg,
        height: heightInCm,
        age: int.parse(_ageController.text),
        activityLevel: _selectedActivityLevel,
        targetGain: targetGainInKg,
        timeframe: int.parse(_timeframeController.text),
        userProfile: _onboardingData,
      );

      if (macroResults != null) {
        setState(() {
          _bulkingResults = macroResults;
        });
        _showBulkingResultsDialog(macroResults);
      } else {
        throw Exception('Failed to calculate macros. Please try again.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isCalculatingMacros = false;
      });
    }
  }

  void _showWorkoutPlanDialog(Map<String, dynamic> workoutPlan) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkTheme = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WorkoutPlanDialog(
          workoutPlan: workoutPlan,
          onDownload: () => _downloadWorkoutPlan(workoutPlan),
          onShare: () => _shareWorkoutPlan(workoutPlan),
          isDarkTheme: isDarkTheme,
        );
      },
    );
  }

  void _showBulkingResultsDialog(Map<String, dynamic> results) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkTheme = themeProvider.isDarkMode;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BulkingResultsDialog(
          results: results,
          onDownload: () => _downloadBulkingPlan(results),
          onShare: () => _shareBulkingPlan(results),
          isDarkTheme: isDarkTheme,
        );
      },
    );
  }

  Future<void> _downloadWorkoutPlan(Map<String, dynamic> workoutPlan) async {
    try {
      final planText = WorkoutPlannerService.generateWorkoutPlanText(
        workoutPlan,
      );
      final planTitle = workoutPlan['title'] ?? 'Workout Plan';

      // Use the downloadMealPlan method from your service
      final result = await FileDownloadService.downloadMealPlan(
        planText,
        planTitle,
      );

      if (result['success']) {
        await FileDownloadService.showDownloadResult(context, result);
      } else {
        // If download fails, offer share as alternative
        await _showDownloadFailedDialog(result['error'], planText, planTitle);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
          action: SnackBarAction(
            label: 'Share Instead',
            textColor: Colors.white,
            onPressed: () => _shareWorkoutPlan(workoutPlan),
          ),
        ),
      );
    }
  }

  Future<void> _shareWorkoutPlan(Map<String, dynamic> workoutPlan) async {
    try {
      final planText = WorkoutPlannerService.generateWorkoutPlanText(
        workoutPlan,
      );
      final planTitle = workoutPlan['title'] ?? 'Workout Plan';
      await FileDownloadService.shareWorkoutPlan(planText, planTitle);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _downloadBulkingPlan(Map<String, dynamic> results) async {
    try {
      final planText = BulkingMacrosService.generateBulkingPlanText(results);

      // Use the downloadMealPlan method from your service
      final result = await FileDownloadService.downloadMealPlan(
        planText,
        'Bulking_Macros_Plan',
      );

      if (result['success']) {
        await FileDownloadService.showDownloadResult(context, result);
      } else {
        // If download fails, offer share as alternative
        await _showDownloadFailedDialog(
          result['error'],
          planText,
          'Bulking_Macros_Plan',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
          action: SnackBarAction(
            label: 'Share Instead',
            textColor: Colors.white,
            onPressed: () => _shareBulkingPlan(results),
          ),
        ),
      );
    }
  }

  Future<void> _showDownloadFailedDialog(
    String error,
    String content,
    String title,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Download Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Download failed: $error'),
              SizedBox(height: 12),
              Text(
                'Would you like to share the file instead or try save and share?',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FileDownloadService.shareWorkoutPlan(content, title);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sharing: ${e.toString()}'),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                }
              },
              child: Text('Share Only'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final result = await FileDownloadService.saveAndShareMealPlan(
                    content,
                    title,
                  );
                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('File created and share dialog opened'),
                        backgroundColor: AppColors.darkPrimary,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
              ),
              child: Text(
                'Save & Share',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareBulkingPlan(Map<String, dynamic> results) async {
    try {
      final planText = BulkingMacrosService.generateBulkingPlanText(results);
      await FileDownloadService.shareWorkoutPlan(
        planText,
        'Bulking_Macros_Plan',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  BoxDecoration _getCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(40, 50, 49, 1.0),
            Color.fromARGB(255, 30, 30, 30),
            Color.fromRGBO(33, 43, 42, 1.0),
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fitnessGoalsController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _targetGainController.dispose();
    _timeframeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDarkTheme ? Color(0xFF121212) : Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(isDarkTheme),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Smart Gym Kit',
          style: TextStyle(
            color: AppColors.textPrimary(isDarkTheme),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.5),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'Workout Planner'),
            Tab(
              icon: Icon(Icons.local_fire_department),
              text: 'Bulking Macros',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkoutPlannerTab(isDarkTheme, screenHeight),
          _buildBulkingMacrosTab(isDarkTheme, screenHeight),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlannerTab(bool isDarkTheme, double screenHeight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_gymnastics,
                      color: const Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Workout Planner',
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Get a personalized workout plan tailored to your fitness goals, level, and preferred workout type using advanced AI.',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Permission check button
                FutureBuilder<bool>(
                  future: FileDownloadService.requestStoragePermission(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.data!) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Storage permission needed for downloads',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final granted =
                                    await FileDownloadService.requestStoragePermission();
                                if (!granted) {
                                  await FileDownloadService.showPermissionDialog(
                                    context,
                                  );
                                }
                                setState(() {}); // Refresh the UI
                              },
                              child: Text(
                                'Grant',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Loading State for Saved Plan
          if (_isLoadingSavedPlan)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Row(
                children: [
                  SpinKitThreeBounce(color: AppColors.darkPrimary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Loading saved plan...',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Recent Generated Plan Card
          if (_savedWorkoutPlan != null && !_isLoadingSavedPlan)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: AppColors.darkPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Generated Plan',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _savedWorkoutPlan!['title'] ?? 'AI Generated Workout Plan',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${_savedWorkoutPlan!['duration'] ?? _savedWorkoutPlan!['planDuration']} • Type: ${_savedWorkoutPlan!['workoutType']}',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white60 : Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                  if (_savedWorkoutPlan!['generatedAt'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Generated: ${_formatDate(_savedWorkoutPlan!['generatedAt'])}',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white60 : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showWorkoutPlanDialog(_savedWorkoutPlan!),
                          icon: Icon(
                            Icons.visibility,
                            size: 16,
                            color: AppColors.darkPrimary,
                          ),
                          label: Text(
                            'View Plan',
                            style: TextStyle(
                              color: AppColors.darkPrimary,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.darkPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _downloadWorkoutPlan(_savedWorkoutPlan!),
                          icon: Icon(
                            Icons.download,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Download',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Fitness Goals Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Fitness Goals *',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fitnessGoalsController,
                  maxLines: 3,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Describe your specific fitness goals, target areas, and what you want to achieve',
                    hintStyle: TextStyle(
                      color: isDarkTheme ? Colors.white60 : Colors.black45,
                    ),
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showGoalOptions = !_showGoalOptions;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.textPrimary(isDarkTheme),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppColors.darkPrimary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.tune,
                          color: AppColors.darkPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _showGoalOptions
                              ? 'Hide Goal Options'
                              : 'Choose from Popular Goals',
                          style: TextStyle(
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

          // Goal Selection Popup
          if (_showGoalOptions) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Fitness Goals',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showGoalOptions = false;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_fitnessGoals.length, (index) {
                    final goal = _fitnessGoals[index];
                    final isSelected = _selectedGoal == goal['title'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGoal = goal['title']!;
                            _fitnessGoalsController.text = goal['title']!;
                            _showGoalOptions = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkPrimary.withOpacity(0.2)
                                : (isDarkTheme
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.02)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.darkPrimary
                                  : (isDarkTheme
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.black.withOpacity(0.1)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                goal['icon']!,
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  goal['title']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.darkPrimary
                                        : (isDarkTheme
                                              ? Colors.white70
                                              : Colors.black54),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Current Fitness Level Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Fitness Level *',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedFitnessLevel,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  dropdownColor: isDarkTheme
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  items: _fitnessLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFitnessLevel = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Preferred Workout Type Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferred Workout Type',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedWorkoutType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  dropdownColor: isDarkTheme
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  items: _workoutTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkoutType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Plan Duration Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Duration',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedPlanDuration,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  dropdownColor: isDarkTheme
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  items: _planDurations.map((duration) {
                    return DropdownMenuItem(
                      value: duration,
                      child: Text(duration),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlanDuration = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Get Workout Plan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGeneratingPlan ? null : _generateWorkoutPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isGeneratingPlan
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Generating AI Plan...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Generate AI Workout Plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBulkingMacrosTab(bool isDarkTheme, double screenHeight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: const Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Bulking Macro Calculator',
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Get personalized nutrition targets for gaining weight and muscle mass with AI-powered recommendations based on your profile and goals.',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Permission check button
                FutureBuilder<bool>(
                  future: FileDownloadService.requestStoragePermission(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.data!) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Storage permission needed for downloads',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final granted =
                                    await FileDownloadService.requestStoragePermission();
                                if (!granted) {
                                  await FileDownloadService.showPermissionDialog(
                                    context,
                                  );
                                }
                                setState(() {}); // Refresh the UI
                              },
                              child: Text(
                                'Grant',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent Results Card
          if (_bulkingResults != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: AppColors.darkPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Calculation',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMacroItem(
                          'Calories',
                          _bulkingResults!['calories'],
                          'cal',
                          isDarkTheme,
                        ),
                      ),
                      Expanded(
                        child: _buildMacroItem(
                          'Protein',
                          _bulkingResults!['protein'],
                          'g',
                          isDarkTheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMacroItem(
                          'Carbs',
                          _bulkingResults!['carbs'],
                          'g',
                          isDarkTheme,
                        ),
                      ),
                      Expanded(
                        child: _buildMacroItem(
                          'Fat',
                          _bulkingResults!['fat'],
                          'g',
                          isDarkTheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showBulkingResultsDialog(_bulkingResults!),
                          icon: Icon(
                            Icons.visibility,
                            size: 16,
                            color: AppColors.darkPrimary,
                          ),
                          label: Text(
                            'View Details',
                            style: TextStyle(
                              color: AppColors.darkPrimary,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.darkPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _downloadBulkingPlan(_bulkingResults!),
                          icon: Icon(
                            Icons.download,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Download',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Gender Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender *',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  dropdownColor: isDarkTheme
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  items: _genders.map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Weight and Height Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Body Measurements *',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Weight',
                          labelStyle: TextStyle(
                            color: isDarkTheme
                                ? Colors.white60
                                : Colors.black45,
                          ),
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedWeightUnit,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                        dropdownColor: isDarkTheme
                            ? const Color(0xFF2D2D2D)
                            : Colors.white,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                        ),
                        items: _weightUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWeightUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Height',
                          labelStyle: TextStyle(
                            color: isDarkTheme
                                ? Colors.white60
                                : Colors.black45,
                          ),
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedHeightUnit,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                        dropdownColor: isDarkTheme
                            ? const Color(0xFF2D2D2D)
                            : Colors.white,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                        ),
                        items: _heightUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedHeightUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Age Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Age *',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your age in years',
                    hintStyle: TextStyle(
                      color: isDarkTheme ? Colors.white60 : Colors.black45,
                    ),
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Activity Level Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity Level *',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedActivityLevel,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  dropdownColor: isDarkTheme
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  items: _activityLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityLevel = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bulking Goals Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulking Goals *',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _targetGainController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Target Weight Gain',
                          labelStyle: TextStyle(
                            color: isDarkTheme
                                ? Colors.white60
                                : Colors.black45,
                          ),
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedTargetUnit,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                        dropdownColor: isDarkTheme
                            ? const Color(0xFF2D2D2D)
                            : Colors.white,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                        ),
                        items: _targetUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTargetUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _timeframeController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Timeframe (weeks)',
                    labelStyle: TextStyle(
                      color: isDarkTheme ? Colors.white60 : Colors.black45,
                    ),
                    hintText: 'How many weeks to reach your goal?',
                    hintStyle: TextStyle(
                      color: isDarkTheme ? Colors.white60 : Colors.black45,
                    ),
                    filled: true,
                    fillColor: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCalculatingMacros ? null : _calculateBulkingMacros,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isCalculatingMacros
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Calculating with AI...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Calculate AI Bulking Macros',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    String title,
    dynamic value,
    String unit,
    bool isDarkTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDarkTheme ? Colors.white60 : Colors.black45,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value?.toString() ?? '0'}$unit',
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';

    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else {
      dateTime = DateTime.now();
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Enhanced Workout Plan Dialog
// Enhanced Workout Plan Dialog
class WorkoutPlanDialog extends StatelessWidget {
  final Map<String, dynamic> workoutPlan;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final bool isDarkTheme; // Add theme parameter

  const WorkoutPlanDialog({
    Key? key,
    required this.workoutPlan,
    required this.onDownload,
    required this.onShare,
    required this.isDarkTheme, // Make it required
  }) : super(key: key);

  BoxDecoration _getDialogDecoration() {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(40, 50, 49, 1.0),
            Color.fromARGB(255, 30, 30, 30),
            Color.fromRGBO(33, 43, 42, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkPrimary.withOpacity(0.8),
          width: 0.5,
        ),
      );
    } else {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
  }

  Color get _primaryTextColor => isDarkTheme ? Colors.white : Colors.black87;
  Color get _secondaryTextColor =>
      isDarkTheme ? Colors.white70 : Colors.black54;
  Color get _tertiaryTextColor => isDarkTheme ? Colors.white60 : Colors.black45;
  Color get _iconColor => isDarkTheme ? Colors.white70 : Colors.black54;
  Color get _cardBackgroundColor => isDarkTheme
      ? Colors.white.withOpacity(0.1)
      : Colors.black.withOpacity(0.05);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: _getDialogDecoration(),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: AppColors.darkPrimary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      workoutPlan['title'] ?? 'AI Workout Plan',
                      style: TextStyle(
                        color: _primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: _iconColor),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Details
                    _buildDetailRow(
                      'Duration',
                      workoutPlan['duration'] ?? workoutPlan['planDuration'],
                    ),
                    _buildDetailRow('Type', workoutPlan['workoutType']),
                    _buildDetailRow('Level', workoutPlan['fitnessLevel']),
                    _buildDetailRow('Goals', workoutPlan['fitnessGoals']),

                    SizedBox(height: 20),

                    // Overview
                    if (workoutPlan['overview'] != null) ...[
                      Text(
                        'Overview',
                        style: TextStyle(
                          color: _primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        workoutPlan['overview'],
                        style: TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    // Schedule Preview with Detailed Exercises
                    if (workoutPlan['schedule'] != null &&
                        workoutPlan['schedule'] is List) ...[
                      Text(
                        'Workout Schedule',
                        style: TextStyle(
                          color: _primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...((workoutPlan['schedule'] as List).take(5).map((day) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.darkPrimary.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Day Title and Duration
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      day['title'] ?? 'Day ${day['day']}',
                                      style: TextStyle(
                                        color: AppColors.darkPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (day['duration'] != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkPrimary
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        day['duration'],
                                        style: TextStyle(
                                          color: AppColors.darkPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Focus/Type
                              if (day['focus'] != null)
                                Text(
                                  'Focus: ${day['focus']}',
                                  style: TextStyle(
                                    color: _tertiaryTextColor,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),

                              // Rest Day
                              if (day['type'] == 'rest') ...[
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.self_improvement,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Rest Day - Recovery and light stretching',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                              // Workout Day with Exercises
                              else if (day['exercises'] != null &&
                                  day['exercises'] is List) ...[
                                SizedBox(height: 12),
                                Text(
                                  'Exercises:',
                                  style: TextStyle(
                                    color: _primaryTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...((day['exercises'] as List).map((exercise) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDarkTheme
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDarkTheme
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.05),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Exercise Name
                                        Text(
                                          exercise['name'] ??
                                              exercise['exercise'] ??
                                              'Exercise',
                                          style: TextStyle(
                                            color: _primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        // Sets, Reps, Duration
                                        Row(
                                          children: [
                                            if (exercise['sets'] != null) ...[
                                              Icon(
                                                Icons.repeat,
                                                color: AppColors.darkPrimary,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${exercise['sets']} sets',
                                                style: TextStyle(
                                                  color: _secondaryTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (exercise['reps'] != null ||
                                                  exercise['duration'] != null)
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    color: _secondaryTextColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                            if (exercise['reps'] != null) ...[
                                              Text(
                                                '${exercise['reps']} reps',
                                                style: TextStyle(
                                                  color: _secondaryTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ] else if (exercise['duration'] !=
                                                null) ...[
                                              Icon(
                                                Icons.timer,
                                                color: AppColors.darkPrimary,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${exercise['duration']}',
                                                style: TextStyle(
                                                  color: _secondaryTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        // Rest Period
                                        if (exercise['rest'] != null) ...[
                                          SizedBox(height: 2),
                                          Text(
                                            'Rest: ${exercise['rest']}',
                                            style: TextStyle(
                                              color: _tertiaryTextColor,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                        // Notes/Instructions
                                        if (exercise['notes'] != null ||
                                            exercise['instructions'] !=
                                                null) ...[
                                          SizedBox(height: 4),
                                          Text(
                                            exercise['notes'] ??
                                                exercise['instructions'],
                                            style: TextStyle(
                                              color: _tertiaryTextColor,
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }).toList()),
                              ]
                              // Fallback for exercises without detailed structure
                              else if (day['exercises'] != null) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Exercises included in this day',
                                  style: TextStyle(
                                    color: _secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList()),
                      if ((workoutPlan['schedule'] as List).length > 5)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkTheme
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '... and ${(workoutPlan['schedule'] as List).length - 5} more days in the complete plan',
                            style: TextStyle(
                              color: _tertiaryTextColor,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                    ],

                    // AI Tips
                    if (workoutPlan['tips'] != null &&
                        workoutPlan['tips'] is List) ...[
                      Text(
                        'AI Recommendations',
                        style: TextStyle(
                          color: _primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...((workoutPlan['tips'] as List).map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.darkPrimary,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip.toString(),
                                  style: TextStyle(
                                    color: _secondaryTextColor,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onShare();
                      },
                      icon: Icon(Icons.share, size: 18),
                      label: Text('Share Plan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkPrimary,
                        side: BorderSide(color: AppColors.darkPrimary),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDownload();
                      },
                      icon: Icon(Icons.download, size: 18),
                      label: Text('Download Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: TextStyle(color: _primaryTextColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// New Bulking Results Dialog
class BulkingResultsDialog extends StatelessWidget {
  final Map<String, dynamic> results;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final bool isDarkTheme; // Add theme parameter

  const BulkingResultsDialog({
    Key? key,
    required this.results,
    required this.onDownload,
    required this.onShare,
    required this.isDarkTheme, // Make it required
  }) : super(key: key);

  BoxDecoration _getDialogDecoration() {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(40, 50, 49, 1.0),
            Color.fromARGB(255, 30, 30, 30),
            Color.fromRGBO(33, 43, 42, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkPrimary.withOpacity(0.8),
          width: 0.5,
        ),
      );
    } else {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
  }

  Color get _primaryTextColor => isDarkTheme ? Colors.white : Colors.black87;
  Color get _secondaryTextColor =>
      isDarkTheme ? Colors.white70 : Colors.black54;
  Color get _tertiaryTextColor => isDarkTheme ? Colors.white60 : Colors.black45;
  Color get _iconColor => isDarkTheme ? Colors.white70 : Colors.black54;
  Color get _cardBackgroundColor => isDarkTheme
      ? Colors.white.withOpacity(0.1)
      : Colors.black.withOpacity(0.05);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: _getDialogDecoration(),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.darkPrimary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Bulking Macro Plan',
                      style: TextStyle(
                        color: _primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: _iconColor),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Macros
                    Text(
                      'Daily Macro Targets',
                      style: TextStyle(
                        color: _primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMacroCard(
                                  'Calories',
                                  results['calories'],
                                  'cal',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildMacroCard(
                                  'Protein',
                                  results['protein'],
                                  'g',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMacroCard(
                                  'Carbs',
                                  results['carbs'],
                                  'g',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildMacroCard(
                                  'Fat',
                                  results['fat'],
                                  'g',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Metabolic Information
                    Text(
                      'Metabolic Information',
                      style: TextStyle(
                        color: _primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'BMR (Basal Metabolic Rate)',
                            '${results['bmr']} calories/day',
                          ),
                          _buildInfoRow(
                            'TDEE (Total Daily Energy)',
                            '${results['tdee']} calories/day',
                          ),
                          _buildInfoRow(
                            'Caloric Surplus',
                            '${results['surplus']} calories/day',
                          ),
                          if (results['weeklyGainRate'] != null)
                            _buildInfoRow(
                              'Expected Weekly Gain',
                              '${results['weeklyGainRate']} kg/week',
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // AI Recommendations
                    if (results['recommendations'] != null &&
                        results['recommendations'] is List) ...[
                      Text(
                        'AI Nutrition Recommendations',
                        style: TextStyle(
                          color: _primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...((results['recommendations'] as List).map((rec) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkTheme
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: AppColors.darkPrimary,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rec.toString(),
                                  style: TextStyle(
                                    color: _secondaryTextColor,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],

                    // Meal Timing
                    if (results['mealTiming'] != null &&
                        results['mealTiming'] is List) ...[
                      SizedBox(height: 20),
                      Text(
                        'Suggested Meal Timing',
                        style: TextStyle(
                          color: _primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...((results['mealTiming'] as List).map((meal) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkTheme
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                meal['time'] ?? '',
                                style: TextStyle(
                                  color: AppColors.darkPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  meal['description'] ?? '',
                                  style: TextStyle(
                                    color: _secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onShare();
                      },
                      icon: Icon(Icons.share, size: 18),
                      label: Text('Share Plan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkPrimary,
                        side: BorderSide(color: AppColors.darkPrimary),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDownload();
                      },
                      icon: Icon(Icons.download, size: 18),
                      label: Text('Download Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(String title, dynamic value, String unit) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: _secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${value?.toString() ?? '0'}',
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(unit, style: TextStyle(color: _tertiaryTextColor, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: _secondaryTextColor, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: _primaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
