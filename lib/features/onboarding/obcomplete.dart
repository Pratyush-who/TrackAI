import 'package:flutter/material.dart';
import 'package:trackai/core/constants/appcolors.dart';

class OnboardingCompletionPage extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const OnboardingCompletionPage({
    Key? key,
    required this.onComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  State<OnboardingCompletionPage> createState() =>
      _OnboardingCompletionPageState();
}

class _OnboardingCompletionPageState extends State<OnboardingCompletionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header with icon
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
                      Icons.rocket_launch,
                      color: AppColors.darkPrimary,
                      size: 32,
                    ),
                  ),
                ],
              ),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'How TrackAI Works',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Here\'s how we help you succeed.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Second title
                    Text(
                      'How TrackAI Works',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Features list
                    _buildFeatureItem(
                      'G',
                      'Powered by Google AI',
                      'Built on Google\'s most advanced APIs for reliable and smart tracking.',
                      AppColors.darkPrimary,
                    ),

                    const SizedBox(height: 24),

                    _buildFeatureItem(
                      '⚡',
                      'Smarter Progress Insights',
                      'AI-driven tracking to help you improve habits, health, and productivity.',
                      AppColors.darkPrimary,
                    ),

                    const SizedBox(height: 24),

                    _buildFeatureItem(
                      '🔒',
                      'Secure & Private',
                      'Your data is encrypted and stays 100% in your control.',
                      AppColors.darkPrimary,
                    ),
                  ],
                ),
              ),

              // Action Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start My Journey',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    String emoji,
    String title,
    String description,
    Color accentColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon/Emoji container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: emoji == 'G'
                ? Text(
                    'G',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  )
                : Text(emoji, style: TextStyle(fontSize: 24)),
          ),
        ),

        const SizedBox(width: 16),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
