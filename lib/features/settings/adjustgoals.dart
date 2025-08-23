import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trackai/features/onboarding/service/observices.dart';
import 'package:trackai/features/settings/service/geminiservice.dart';
import 'package:trackai/features/settings/service/goalservice.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/core/constants/appcolors.dart';

class AdjustGoalsPage extends StatefulWidget {
  const AdjustGoalsPage({Key? key}) : super(key: key);

  @override
  State<AdjustGoalsPage> createState() => _AdjustGoalsPageState();
}

class _AdjustGoalsPageState extends State<AdjustGoalsPage> {
  Map<String, dynamic>? _goalsData;
  bool _isLoading = false;
  bool _isCalculating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExistingGoals();
  }

  Future<void> _loadExistingGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final existingGoals = await GoalsService.getGoals();
      
      if (existingGoals != null) {
        setState(() {
          _goalsData = existingGoals;
          _isLoading = false;
        });
      } else {
        // No existing goals, calculate new ones
        await _calculateGoals();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load goals: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateGoals() async {
    setState(() {
      _isCalculating = true;
      _error = null;
    });

    try {
      // Get onboarding data from Firebase
      final onboardingData = await OnboardingService.getOnboardingData();
      
      if (onboardingData == null) {
        throw Exception('No onboarding data found. Please complete onboarding first.');
      }

      // Calculate goals using Gemini API
      final calculatedGoals = await GeminiService.calculateNutritionGoals(
        onboardingData: onboardingData,
      );

      if (calculatedGoals == null) {
        throw Exception('Failed to calculate goals. Please try again.');
      }

      // Save calculated goals to Firebase
      await GoalsService.saveGoals(calculatedGoals);

      // Update UI
      setState(() {
        _goalsData = calculatedGoals;
        _isCalculating = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goals calculated and saved successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isCalculating = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _calculateGoalsWithCustomData(Map<String, dynamic> formData) async {
    setState(() {
      _isCalculating = true;
      _error = null;
    });

    try {
      // Calculate goals using the form data directly
      final calculatedGoals = await GeminiService.calculateNutritionGoals(
        onboardingData: formData,
      );

      if (calculatedGoals == null) {
        throw Exception('Failed to calculate goals. Please try again.');
      }

      // Save calculated goals to Firebase
      await GoalsService.saveGoals(calculatedGoals);

      // Update UI
      setState(() {
        _goalsData = calculatedGoals;
        _isCalculating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goals recalculated and saved successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isCalculating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _showRecalculateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RecalculateGoalsDialog(
          onCalculate: _calculateGoalsWithCustomData,
          isCalculating: _isCalculating,
        );
      },
    );
  }

  BoxDecoration _getCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(40, 50, 49, 1.0),
            const Color.fromARGB(255, 14, 14, 14),
            const Color.fromRGBO(33, 43, 42, 1.0),
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
            AppColors.lightSecondary,
            AppColors.lightSecondary,
            AppColors.lightSecondary,
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
        final isDarkTheme = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: isDarkTheme ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            title: Text(
              'Your Daily Targets',
              style: TextStyle(
                color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: isDarkTheme ? AppColors.darkCardBackground : AppColors.lightBackground,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          body: _buildBody(isDarkTheme),
        );
      },
    );
  }

  Widget _buildBody(bool isDarkTheme) {
    if (_isLoading || _isCalculating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWave(
              color: AppColors.darkPrimary,
              size: 50.0,
            ),
            const SizedBox(height: 16),
            Text(
              _isCalculating ? 'Calculating your goals...' : 'Loading goals...',
              style: TextStyle(
                color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_goalsData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.darkPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'No goals found',
              style: TextStyle(
                color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s calculate your personalized nutrition goals',
              style: TextStyle(
                color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateGoals,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Calculate Goals'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.track_changes,
                      color: AppColors.darkPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Daily Targets',
                      style: TextStyle(
                        color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'These are your AI-generated daily nutritional goals. You can recalculate them anytime.',
                  style: TextStyle(
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calories Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.darkPrimary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Calories',
                  style: TextStyle(
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_goalsData!['calories']}',
                  style: TextStyle(
                    color: AppColors.darkPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'kcal',
                  style: TextStyle(
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Macros Grid
          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  isDarkTheme,
                  Icons.fitness_center,
                  'Protein',
                  '${_goalsData!['protein']}',
                  'g',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroCard(
                  isDarkTheme,
                  Icons.grain,
                  'Carbs',
                  '${_goalsData!['carbs']}',
                  'g',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  isDarkTheme,
                  Icons.water_drop,
                  'Fat',
                  '${_goalsData!['fat']}',
                  'g',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroCard(
                  isDarkTheme,
                  Icons.eco,
                  'Fiber',
                  '${_goalsData!['fiber']}',
                  'g',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Enhanced AI Explanation Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: AppColors.darkPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Explanation',
                      style: TextStyle(
                        color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Detailed breakdown of your personalized macro plan',
                  style: TextStyle(
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkTheme 
                        ? AppColors.darkSurfaceColor.withOpacity(0.5)
                        : AppColors.lightSurfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.darkPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Energy Needs Section
                      Text(
                        '**Your Daily Energy Needs:**',
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Your Basal Metabolic Rate (BMR) is the energy your body needs at rest. Your BMR is approximately ${_goalsData!['bmr']} kcal.',
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Factoring in your activity level, your Total Daily Energy Expenditure (TDEE) to maintain your current weight is about ${_goalsData!['tdee']} kcal.',
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Calorie Goal Section
                      Text(
                        '**Your Calorie Goal:**',
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Your target daily calorie intake is ${_goalsData!['calories']} kcal. This represents a ${_goalsData!['calories'] > _goalsData!['tdee'] ? 'surplus' : 'deficit'} of ${(_goalsData!['calories'] - _goalsData!['tdee']).abs()} kcal ${_goalsData!['calories'] > _goalsData!['tdee'] ? 'above' : 'below'} your maintenance level.',
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Macro Plan Section
                      Text(
                        '**Your Custom Macro Plan:**',
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• We\'ve balanced your macros to support your goals, prioritizing protein for muscle preservation/growth, with a healthy mix of carbs for energy and fats for hormonal function. The plan includes sufficient fiber for overall health and digestion.',
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // AI Generated Explanation
                      if (_goalsData!['explanation'] != null && _goalsData!['explanation'].toString().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '**Additional AI Insights:**',
                              style: TextStyle(
                                color: isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _goalsData!['explanation'].toString(),
                              style: TextStyle(
                                color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Recalculate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCalculating ? null : _showRecalculateDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isCalculating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recalculating...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Recalculate Goals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Last updated info
          if (_goalsData!['calculatedAt'] != null)
            Center(
              child: Text(
                'Last updated: ${_formatDate(_goalsData!['calculatedAt'])}',
                style: TextStyle(
                  color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    bool isDarkTheme,
    IconData icon,
    String label,
    String value,
    String unit,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.darkPrimary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Multi-step Recalculate Dialog
class RecalculateGoalsDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onCalculate;
  final bool isCalculating;

  const RecalculateGoalsDialog({
    Key? key,
    required this.onCalculate,
    required this.isCalculating,
  }) : super(key: key);

  @override
  State<RecalculateGoalsDialog> createState() => _RecalculateGoalsDialogState();
}

class _RecalculateGoalsDialogState extends State<RecalculateGoalsDialog> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Form data
  int? _age;
  String? _gender;
  bool _isMetric = true;
  double? _weightKg;
  double? _weightLbs;
  int? _heightCm;
  int? _heightFeet;
  int? _heightInches;
  String? _workoutFrequency;
  String? _goal;

  final List<String> _workoutOptions = [
    'Never',
    '1-2 times per week',
    '3-4 times per week',
    '5+ times per week',
  ];

  final List<String> _goalOptions = [
    'Lose Weight',
    'Gain Weight',
    'Maintain Weight',
  ];

  BoxDecoration _getDialogCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color.fromRGBO(40, 50, 49, 1.0),
          const Color.fromARGB(255, 14, 14, 14),
          const Color.fromRGBO(33, 43, 42, 1.0),
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
  }

  void _nextPage() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _calculateGoals() {
    final formData = {
      'age': _age,
      'gender': _gender,
      'isMetric': _isMetric,
      'weightKg': _weightKg,
      'weightLbs': _weightLbs,
      'heightCm': _heightCm,
      'heightFeet': _heightFeet,
      'heightInches': _heightInches,
      'workoutFrequency': _workoutFrequency,
      'goal': _goal,
      'dateOfBirth': DateTime.now().subtract(Duration(days: (_age ?? 25) * 365)),
    };

    widget.onCalculate(formData);
    Navigator.of(context).pop();
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _age != null && _gender != null;
      case 1:
        if (_isMetric) {
          return _weightKg != null && _heightCm != null;
        } else {
          return _weightLbs != null && _heightFeet != null && _heightInches != null;
        }
      case 2:
        return _workoutFrequency != null && _goal != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: _getDialogCardDecoration(),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Personal Details',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Step ${_currentStep + 1} of 3. Adjust your details to generate a new macro plan.',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep 
                            ? AppColors.darkPrimary 
                            : AppColors.darkPrimary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalDetailsPage(),
                  _buildPhysicalDetailsPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.darkPrimary),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: AppColors.darkPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceedFromStep(_currentStep)
                          ? (_currentStep == 2 ? _calculateGoals : _nextPage)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _currentStep == 2 ? 'Calculate' : 'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildPersonalDetailsPage() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.darkPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextFormField(
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.darkTextPrimary),
              decoration: InputDecoration(
                hintText: 'Enter your age',
                hintStyle: TextStyle(color: AppColors.darkTextSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (value) {
                setState(() {
                  _age = int.tryParse(value);
                });
              },
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Gender',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Male';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _gender == 'Male' 
                          ? AppColors.darkPrimary 
                          : AppColors.darkSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _gender == 'Male' 
                            ? AppColors.darkPrimary 
                            : AppColors.darkPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Male',
                        style: TextStyle(
                          color: _gender == 'Male' 
                              ? Colors.white 
                              : AppColors.darkTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Female';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _gender == 'Female' 
                          ? AppColors.darkPrimary 
                          : AppColors.darkSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _gender == 'Female' 
                            ? AppColors.darkPrimary 
                            : AppColors.darkPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Female',
                        style: TextStyle(
                          color: _gender == 'Female' 
                              ? Colors.white 
                              : AppColors.darkTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalDetailsPage() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit Toggle
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMetric = true;
                        _weightLbs = null;
                        _heightFeet = null;
                        _heightInches = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isMetric ? AppColors.darkPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'Metric (kg/cm)',
                          style: TextStyle(
                            color: _isMetric ? Colors.white : AppColors.darkTextSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMetric = false;
                        _weightKg = null;
                        _heightCm = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isMetric ? AppColors.darkPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'Imperial (lbs/ft)',
                          style: TextStyle(
                            color: !_isMetric ? Colors.white : AppColors.darkTextSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Weight Input
          Text(
            _isMetric ? 'Weight (kg)' : 'Weight (lbs)',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.darkPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextFormField(
              key: ValueKey(_isMetric ? 'weight_kg' : 'weight_lbs'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: AppColors.darkTextPrimary),
              decoration: InputDecoration(
                hintText: _isMetric ? 'Enter weight in kg' : 'Enter weight in lbs',
                hintStyle: TextStyle(color: AppColors.darkTextSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (value) {
                setState(() {
                  if (_isMetric) {
                    _weightKg = double.tryParse(value);
                  } else {
                    _weightLbs = double.tryParse(value);
                  }
                });
              },
            ),
          ),
          SizedBox(height: 24),

          // Height Input
          Text(
            _isMetric ? 'Height (cm)' : 'Height (ft/in)',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          if (_isMetric)
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.darkPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter height in cm',
                  hintStyle: TextStyle(color: AppColors.darkTextSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  setState(() {
                    _heightCm = int.tryParse(value);
                  });
                },
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.darkPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.darkTextPrimary),
                      decoration: InputDecoration(
                        hintText: 'Feet',
                        hintStyle: TextStyle(color: AppColors.darkTextSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _heightFeet = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.darkPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.darkTextPrimary),
                      decoration: InputDecoration(
                        hintText: 'Inches',
                        hintStyle: TextStyle(color: AppColors.darkTextSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _heightInches = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Frequency',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: _workoutOptions.map((option) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _workoutFrequency = option;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _workoutFrequency == option 
                          ? AppColors.darkPrimary 
                          : AppColors.darkSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _workoutFrequency == option 
                            ? AppColors.darkPrimary 
                            : AppColors.darkPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _workoutFrequency == option 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_unchecked,
                          color: _workoutFrequency == option 
                              ? Colors.white 
                              : AppColors.darkTextSecondary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          option,
                          style: TextStyle(
                            color: _workoutFrequency == option 
                                ? Colors.white 
                                : AppColors.darkTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text(
              'Primary Goal',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: _goalOptions.map((option) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _goal = option;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _goal == option 
                          ? AppColors.darkPrimary 
                          : AppColors.darkSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _goal == option 
                            ? AppColors.darkPrimary 
                            : AppColors.darkPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _goal == option 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_unchecked,
                          color: _goal == option 
                              ? Colors.white 
                              : AppColors.darkTextSecondary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          option,
                          style: TextStyle(
                            color: _goal == option 
                                ? Colors.white 
                                : AppColors.darkTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}