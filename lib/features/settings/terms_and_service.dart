import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  BoxDecoration _getCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(40, 50, 49, 1.0), // left/top green
            const Color.fromARGB(255, 14, 14, 14), // middle dark shade
            const Color.fromRGBO(33, 43, 42, 1.0), // right/bottom green
          ],
          begin: Alignment.topLeft, // tilt gradient
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

  BoxDecoration _getWarningCardDecoration() {
    return BoxDecoration(
      color: Colors.yellow.withOpacity(.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.orange.shade300,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.1),
          blurRadius: 6,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  BoxDecoration _getHealthDisclaimerDecoration() {
    return BoxDecoration(
      color: const Color.fromARGB(255, 84, 164, 87).withOpacity(.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.green.shade300,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.1),
          blurRadius: 6,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDarkTheme),
      appBar: AppBar(
        backgroundColor: AppColors.background(isDarkTheme),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(isDarkTheme),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms of Service',
          style: TextStyle(
            color: AppColors.textPrimary(isDarkTheme),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Terms Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                                      Icon(Icons.document_scanner),
                                      SizedBox(width: 10,),
                                      Text(
                    'TrackAI Terms of Service',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  ],),
                  
                  // const SizedBox(height: 8),
                  Text(
                    'Last Updated: August 19, 2025',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getWarningCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.yellow.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Legal Disclaimer',
                        style: TextStyle(
                          color: Colors.yellow.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'IMPORTANT DISCLAIMER: This is a template Terms of Service and does NOT constitute legal advice. You MUST consult with a qualified legal professional to draft or review your Terms of Service to ensure they are appropriate for your specific application, its features (including AI), data handling practices, and target regions (USA/EU). This template is for informational and illustrative purposes ONLY and should not be used as-is for a live application.',
                    style: TextStyle(
                      color: Colors.yellow.shade800,

                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            

            // const SizedBox(height: 20),


                  _buildTermsSection(
                    '1. Introduction',
                    'Welcome to TrackAI ("App", "we", "us", "our"), your personal AI-powered wellness companion. These Terms of Service ("Terms") govern your access to and use of our application and related services (collectively, the "Service"). By accessing or using TrackAI, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '2. Acceptance of Terms',
                    'By downloading, accessing, or using the TrackAI application, you signify your agreement to these Terms. If you do not agree to these Terms, you may not use the App. We reserve the right to modify these Terms at any time. Your continued use of the App after such changes constitutes your acceptance of the new Terms.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '3. Use of the Service',
                    'TrackAI provides tools for tracking wellness-related data, AI-driven insights, and other features related to health and well-being. You are granted a non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes, subject to these Terms.\n\nYou agree not to:\n• Use the App for any illegal purpose or in violation of any local, state, national, or international law.\n• Violate or encourage others to violate the rights of third parties, including intellectual property rights.\n• Use the App to generate content that is harmful, fraudulent, deceptive, threatening, harassing, defamatory, obscene, or otherwise objectionable.\n• Attempt to decompile, reverse engineer, or otherwise attempt to discover the source code of the App.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '4. AI-Powered Features & Disclaimers',
                    'TrackAI utilizes artificial intelligence to provide features such as meal planning, workout suggestions, and nutritional analysis from images.\n\nYou acknowledge that AI-generated content may sometimes be inaccurate or incomplete. Use your judgment and verify critical information when necessary.',
                    isDarkTheme,
                  ),
                  Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getHealthDisclaimerDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety_rounded,
                        color: Colors.green.shade300,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Health Disclaimer',
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'IMPORTANT HEALTH DISCLAIMER: The information and suggestions provided by the AI features, and by TrackAI in general, are for informational and educational purposes only. TrackAI is NOT a medical device and does NOT provide medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition or health objectives. Reliance on any information provided by TrackAI is solely at your own risk.',
                    style: TextStyle(
                      color: Colors.green.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),

                  _buildTermsSection(
                    '5. Data, Privacy, and Permissions',
                    'Your privacy is paramount. TrackAI is designed to be privacy-first by storing most of your data—including your profile, goals, and tracker logs—locally on your device using your browser\'s storage. This data is not sent to our servers.\n\nCertain features require interaction with third-party services or device permissions:\n• Authentication: To secure your account, we use Firebase Authentication (a Google service). Your login credentials are managed by Firebase.\n• AI Features: To provide intelligent features, your inputs (e.g., a photo of a meal, your fitness goals) are sent for processing by Google\'s AI models.\n• Permissions: The app will ask for Camera and/or Gallery access only when you use features that require it, such as the Food Scanner.\n\nFor a complete and detailed explanation of what data is collected and why, please read our Privacy Policy. By using the Service, you agree to the data practices outlined in our Privacy Policy.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '6. Intellectual Property',
                    'The TrackAI application, including its "look and feel", underlying software, and proprietary content are owned by TrackAI or its licensors and are protected by intellectual property laws.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '7. Disclaimers of Warranties',
                    'THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS. TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, TRACKAI DISCLAIMS ALL WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '8. Limitation of Liability',
                    'TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL TRACKAI BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '9. Governing Law',
                    'These Terms shall be governed by the laws of [Specify Jurisdiction, e.g., "the State of Delaware, USA"].\n\nLegal Advice Needed: You MUST consult with a legal professional to determine the appropriate governing law and dispute resolution clauses.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '10. Termination',
                    'We may terminate or suspend your access to the Service immediately, without prior notice or liability, if you breach these Terms.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '11. Changes to Terms',
                    'We reserve the right to modify or replace these Terms at any time.',
                    isDarkTheme,
                  ),

                  _buildTermsSection(
                    '12. Contact Us',
                    'If you have any questions about these Terms, please contact us at: [Provide Your Contact Email Address or Method Here]',
                    isDarkTheme,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection(String title, String content, bool isDarkTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            color: isDarkTheme ? Colors.white70 : Colors.black87,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}