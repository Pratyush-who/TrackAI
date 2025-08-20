import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
      color: Colors.yellow.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.shade300, width: 1),
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
          'Privacy Policy',
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
  crossAxisAlignment: CrossAxisAlignment.start, // 👈 outer column
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 👈 inner column
      children: [
        Row(
          children: [
            Icon(Icons.security, color: Colors.green),
            Text(
              ' TrackAI Privacy Policy',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Text(
          'Last Updated: August 19, 2025',
          style: TextStyle(
            color: isDarkTheme ? Colors.white70 : Colors.black54,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
    SizedBox(height: 18),
            SizedBox(height: 18,),

            // Header
            // Legal Disclaimer Card
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
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Legal Disclaimer',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'IMPORTANT DISCLAIMER: This is a template Privacy Policy and does NOT constitute legal advice. You MUST consult with a qualified legal professional to draft or review your Privacy Policy to ensure it is appropriate for your specific application, its features (including AI), data handling practices (especially regarding health and personal data), and target regions (USA/EU, considering GDPR, CCPA/CPRA, HIPAA if applicable, etc.). This template is for informational and illustrative purposes ONLY and should not be used as-is for a live application.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: _getCardDecoration(isDarkTheme),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '1. Introduction',
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // const SizedBox(height: 16),
      
      const SizedBox(height: 16),
      Text(
        'Welcome to TrackAI ("App", "we", "us", "our"). We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our application. By using TrackAI, you consent to the data practices described in this policy.',
        style: TextStyle(
          color: isDarkTheme ? Colors.white70 : Colors.black87,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 16),

            // Permissions Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Permissions We Request',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The app only requests permissions when you use specific features that require them:',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Camera Permission
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: const Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Camera Permission',
                              style: TextStyle(
                                color: isDarkTheme
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This is requested when you use the Food Scanner feature to take a new picture of your meal for nutritional analysis.',
                              style: TextStyle(
                                color: isDarkTheme
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Gallery Access
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.photo_library,
                          color: const Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File/Gallery Access',
                              style: TextStyle(
                                color: isDarkTheme
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This is requested if you choose to upload an existing photo from your device\'s gallery for the Food Scanner.',
                              style: TextStyle(
                                color: isDarkTheme
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Information Collection Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3. Information We Collect and Why',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TrackAI is designed to be privacy-first. We handle data in two ways: data stored locally on your device, and data processed by third-party services for specific features.',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data Stored Locally Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storage,
                        color: const Color(0xFF4CAF50),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data Stored Locally on Your Device',
                        style: TextStyle(
                          color: const Color(0xFF4CAF50),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The following information is stored directly in your browser\'s local storage. This data is not sent to our servers and remains private to you on your device.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile & Goals
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '• Profile & Goals: ',
                          style: TextStyle(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Information you provide during onboarding (age, gender, weight, height, goals) and your calculated macro targets.\n',
                        ),
                        TextSpan(
                          text: 'Why: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text:
                              'To personalize the app, power calculations for BMI and nutrition charts, and tailor AI recommendations.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tracker Logs
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '• Tracker Logs: ',
                          style: TextStyle(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              'All entries for any tracker (e.g., mood ratings, sleep hours, exercise details, custom tracker data).\n',
                        ),
                        TextSpan(
                          text: 'Why: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text:
                              'This is the core function of the app, allowing you to track your habits and view your progress in the Analytics section.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // App Preferences
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '• App Preferences: ',
                          style: TextStyle(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Your settings, such as favorite trackers, dashboard configuration, and theme choice.\n',
                        ),
                        TextSpan(
                          text: 'Why: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text:
                              'To customize your experience and remember your settings between visits.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Temporary AI Results
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '• Temporary AI Results & Session Data: ',
                          style: TextStyle(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              'The app may remember the last result from an AI tool (like a meal plan) for your convenience. The history of "Ask AI" messages is stored only for your current session and is deleted when you close the app.\n',
                        ),
                        TextSpan(
                          text: 'Why: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text:
                              'To make the app more user-friendly so you can easily refer back to recent information during a session.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const SizedBox(height: 16),

            // Data Processed by Third-Party Services Card
            // Data Processed by Third-Party Services Card - Updated with bullet points
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_sync,
                        color: const Color(0xFF2196F3),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data Processed by Third-Party \nServices',
                        style: TextStyle(
                          color: const Color(0xFF2196F3),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To enable certain features, we use secure, trusted third-party services. The information is sent for processing only and is not stored by TrackAI on any server.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Firebase Authentication
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '• Firebase Authentication: ',
                          style: TextStyle(
                            color: const Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Your account information (email, name, securely hashed password, or Google account ID).\n',
                        ),
                        TextSpan(
                          text: 'Why: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text:
                              'To provide a secure way for you to log in, manage your account, and protect your data. This is handled by Google\'s Firebase platform.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Google AI
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '• Google AI (via Genkit): ',
                          style: TextStyle(
                            color: const Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              'The specific inputs you provide to AI features (e.g., a photo for nutritional analysis, text prompts for meal plans, or questions for the assistant).\n',
                        ),
                        TextSpan(
                          text: 'Why: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text:
                              'This is necessary for the AI models to analyze your request and generate a tailored response. Your inputs are used for processing and are governed by Google\'s privacy policies.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data Storage and Security
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4. Data Storage and Security',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'As most of your data is stored in your web browser\'s local storage, its security is tied to your device\'s security. This means:\n\n• Your data is not automatically synced across devices.\n• Clearing your browser\'s data for this site will permanently delete your locally stored information.',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '5. Your Data Rights (USA/EU Focus)',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Given that data is stored locally on your device, you have direct control over it. This includes:\n\n• Access: You can access your data directly within the App.\n• Modification: You can modify or delete individual log entries (if this functionality is provided by the App).\n• Deletion: You can delete all your data by clearing your browser\'s local storage for this App, or using any in-app "delete all data" feature if available.\n\nFor users in the European Union (GDPR) and California (CCPA/CPRA): You have specific rights regarding your data. Since most data is local, you directly control it. For data processed by third-party services like Firebase and Google, their respective privacy policies apply. If you have questions about your data, please contact us, and we will provide information or facilitate as appropriate.\n\nLegal Advice Needed: A legal professional will help you detail these rights accurately.',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Children's Privacy
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '6. Children\'s Privacy',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TrackAI is not intended for use by children under the age of 13 (or a higher age if stipulated by local law, e.g., 16 in some EU countries for GDPR consent). We do not knowingly collect personal information from children.',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Changes to Privacy Policy
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7. Changes to This Privacy Policy',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the App and updating the "Last Updated" date.',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contact Us
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _getCardDecoration(isDarkTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '8. Contact Us',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If you have any questions about this Privacy Policy, please contact us at: [Provide Your Contact Email Address or Method Here, e.g., privacy@trackai.example.com]',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
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

  Widget _buildLocalDataItem(String title, String description, String why) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF2E7D32),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: const Color(0xFF2E7D32),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          why,
          style: TextStyle(
            color: const Color(0xFF2E7D32),
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildThirdPartyItem(String title, String description, String why) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF1565C0),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: const Color(0xFF1565C0),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          why,
          style: TextStyle(
            color: const Color(0xFF1565C0),
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
