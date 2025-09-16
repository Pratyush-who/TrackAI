import 'package:flutter/material.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/features/settings/service/geminiservice.dart';
import 'package:trackai/features/settings/service/goalservice.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PersonalizedPlanPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Map<String, dynamic> onboardingData;

  const PersonalizedPlanPage({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.onboardingData,
  }) : super(key: key);

  @override
  State<PersonalizedPlanPage> createState() => _PersonalizedPlanPageState();
}

class _PersonalizedPlanPageState extends State<PersonalizedPlanPage> {
  Map<String, dynamic>? _goalsData;
  bool _isCalculating = false;
  bool _isCalculated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculateGoals();
  }

  Future<void> _calculateGoals() async {
    setState(() {
      _isCalculating = true;
      _error = null;
    });

    try {
      // Calculate goals using Gemini API
      final calculatedGoals = await GeminiService.calculateNutritionGoals(
        onboardingData: widget.onboardingData,
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
        _isCalculated = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkPrimary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.darkPrimary,
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Personalized Plan',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Based on your input, here are your daily targets to get started.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Main Content
              Expanded(
                child: _buildContent(),
              ),

              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.darkPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCalculated ? widget.onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isCalculating) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitWave(
            color: AppColors.darkPrimary,
            size: 50.0,
          ),
          const SizedBox(height: 24),
          Text(
            'Calculating your personalized plan...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This may take a few seconds',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
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
      );
    }

    if (_goalsData != null) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Targets Title
            Text(
              'Your Daily Targets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // Calories Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.lightPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: AppColors.darkPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Calories',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_goalsData!['calories']}',
                    style: TextStyle(
                      color: AppColors.darkPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Macros Row
            Row(
              children: [
                Expanded(
                  child: _buildMacroCard(
                    'Protein',
                    '${_goalsData!['protein']}',
                    'g',
                    Icons.fitness_center,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    'Carbs',
                    '${_goalsData!['carbs']}',
                    'g',
                    Icons.grain,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Second Macros Row
            Row(
              children: [
                Expanded(
                  child: _buildMacroCard(
                    'Fat',
                    '${_goalsData!['fat']}',
                    'g',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    'Fiber',
                    '${_goalsData!['fiber']}',
                    'g',
                    Icons.eco,
                    AppColors.darkPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Health Score Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.pink.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Health score',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '9/10',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // How to reach goals
            Text(
              'How to reach your goals:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Goals list
            _buildGoalItem(
              Icons.favorite,
              'Use health scores to improve your routine',
              Colors.pink,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              Icons.restaurant_menu,
              'Track your food',
              Colors.brown,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              Icons.access_time,
              'Follow your daily calorie recommendation',
              AppColors.darkPrimary,
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              Icons.pie_chart,
              'Balance your carbs, protein, fat',
              Colors.orange,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMacroCard(String title, String value, String unit, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}