import 'package:flutter/material.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/features/onboarding/completion.dart';
import 'package:trackai/features/onboarding/desiredweight.dart';
import 'package:trackai/features/onboarding/dietpref.dart';
import 'package:trackai/features/onboarding/dob.dart';
import 'package:trackai/features/onboarding/genderselection.dart';
import 'package:trackai/features/onboarding/goalpace.dart';
import 'package:trackai/features/onboarding/goalselection.dart';
import 'package:trackai/features/onboarding/heightweight.dart';
import 'package:trackai/features/onboarding/observices.dart';
import 'package:trackai/features/onboarding/resultshowcase.dart';
import 'package:trackai/features/onboarding/workoutfrequency.dart';
import 'package:trackai/features/home/homepage.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentPageIndex = 0;
  bool _isLoading = false;

  // Onboarding data
  Map<String, dynamic> onboardingData = {
    'gender': '',
    'workoutFrequency': '',
    'heightFeet': 5,
    'heightInches': 6,
    'weightLbs': 119.0,
    'isMetric': false,
    'dateOfBirth': null,
    'goal': '',
    'desiredWeight': 110.0,
    'goalPace': '',
    'dietPreference': '',
    'completedAt': null,
  };

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializePages();
    _animationController.forward();
  }

  void _initializePages() {
    _pages.addAll([
      GenderSelectionPage(
        onNext: _nextPage,
        onDataUpdate: (data) => _updateData('gender', data),
      ),
      WorkoutFrequencyPage(
        onNext: _nextPage,
        onBack: _previousPage,
        onDataUpdate: (data) => _updateData('workoutFrequency', data),
      ),
      ResultsShowcasePage(onNext: _nextPage, onBack: _previousPage),
      HeightWeightPage(
        onNext: _nextPage,
        onBack: _previousPage,
        onDataUpdate: _updateHeightWeightData,
        initialData: onboardingData,
      ),
      DateOfBirthPage(
        onNext: _nextPage,
        onBack: _previousPage,
        onDataUpdate: (data) => _updateData('dateOfBirth', data),
      ),
      GoalSelectionPage(
        onNext: _nextPage,
        onBack: _previousPage,
        onDataUpdate: (data) => _updateData('goal', data),
      ),
      DesiredWeightPage(
        onNext: _nextPage,
        onBack: _previousPage,
        onDataUpdate: (data) => _updateData('desiredWeight', data),
        isMetric: onboardingData['isMetric'] ?? false,
      ),
      GoalPacePage(
        onNext: _nextPage,
        onBack: _previousPage,
        onDataUpdate: (data) => _updateData('goalPace', data),
      ),
      DietPreferencePage(
        onNext: _nextPage,
        onBack: _previousPage,
        onDataUpdate: (data) => _updateData('dietPreference', data),
      ),
      CompletionPage(onComplete: _completeOnboarding, onBack: _previousPage),
    ]);
  }

  void _updateData(String key, dynamic value) {
    setState(() {
      onboardingData[key] = value;
    });
  }

  void _updateHeightWeightData(Map<String, dynamic> data) {
    setState(() {
      onboardingData.addAll(data);
    });
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save onboarding data to Firestore
      onboardingData['completedAt'] = DateTime.now();
      await OnboardingService.saveOnboardingData(onboardingData);

      if (mounted) {
        // AuthWrapper will automatically detect completion and show HomePage
        print('Onboarding completed - AuthWrapper will handle navigation');

        // Add a small delay for Firestore to update and trigger the stream
        await Future.delayed(const Duration(milliseconds: 500));

        // Force navigation to HomePage as a backup if stream doesn't trigger
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('Error completing onboarding: $e');
      if (mounted) {
        _showErrorSnackBar(
          'Failed to save your information. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.85, 1.0],
            colors: [
              AppColors.black,
              AppColors.darkCardBackground,
              AppColors.darkPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Progress indicator
              Positioned(
                top: 20,
                left: 24,
                right: 24,
                child: _buildProgressIndicator(),
              ),

              // Page view
              Positioned.fill(
                top: 80,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _pages,
                  ),
                ),
              ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.successColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_currentPageIndex + 1} of ${_pages.length}',
              style: TextStyle(
                color: AppColors.textSecondary(true),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${((_currentPageIndex + 1) / _pages.length * 100).round()}%',
              style: TextStyle(
                color: AppColors.textSecondary(true),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentPageIndex + 1) / _pages.length,
          backgroundColor: AppColors.darkGrey,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.successColor),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
