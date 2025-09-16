import 'package:flutter/material.dart';
import 'package:trackai/core/constants/appcolors.dart';

class AllDonePage extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const AllDonePage({Key? key, required this.onComplete, required this.onBack})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkPrimary,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'All Done!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Checkmark with text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.darkPrimary,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "You're all set! Let's generate your personalized health plan.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Thank you for\ntrusting us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Privacy message
                    const Text(
                      'We promise to always keep your personal\ninformation private and secure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Create plan button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Create my plan',
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
}
