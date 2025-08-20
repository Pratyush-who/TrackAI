import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';

class HealthFeedbackPage extends StatefulWidget {
  @override
  _HealthFeedbackPageState createState() => _HealthFeedbackPageState();
}

class _HealthFeedbackPageState extends State<HealthFeedbackPage> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool isReportSent = false;
  AnimationController? animationController;
  Animation<double>? slideAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    animationController?.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

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

  BoxDecoration _getSubmitCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(42, 52, 51, 1.0), // slightly more green than original
            const Color.fromARGB(255, 16, 18, 16), // slightly green tinted dark
            const Color.fromRGBO(35, 45, 44, 1.0), // slightly more green than original
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkPrimary.withOpacity(0.9), // slightly more visible
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.12),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(248, 252, 248, 1.0), // very subtle green tint
            const Color.fromRGBO(246, 250, 246, 1.0), // very subtle green tint
            const Color.fromRGBO(244, 248, 244, 1.0), // very subtle green tint
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.7), // slightly more visible
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimary.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  void _submitFeedback() {
    setState(() {
      isReportSent = true;
    });
    animationController?.forward();
    
    // Hide the success bar after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        animationController?.reverse().then((_) {
          setState(() {
            isReportSent = false;
          });
        });
      }
    });

    // Clear form
    emailController.clear();
    subjectController.clear();
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDarkTheme),
      appBar: AppBar(
        title: Text('Health & Feedback'),
        backgroundColor: AppColors.background(isDarkTheme),
        foregroundColor: AppColors.textPrimary(isDarkTheme),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FAQ Section
                Container(
                  width: double.infinity,
                  decoration: _getCardDecoration(isDarkTheme),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: isDarkTheme ? Colors.tealAccent : Colors.teal,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Frequently Asked Questions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildFAQItem(
                        'How do I log data for a tracker?',
                        'Navigate to the \'Trackers\' page from the main menu. Find the tracker you wish to log data for and click the \'Log Data\' button. A dialog will appear prompting you to enter the relevant information.',
                        isDarkTheme,
                      ),
                      SizedBox(height: 16),
                      _buildFAQItem(
                        'How can I customize my dashboard on the Analytics page?',
                        'Go to the \'Analytics\' page. Click on the \'Configure Dashboard Charts\' button at the top. You can then select up to 4 trackers to display as charts on your analytics dashboard.',
                        isDarkTheme,
                      ),
                      SizedBox(height: 16),
                      _buildFAQItem(
                        'Where is my data stored?',
                        'Currently, all your tracker logs, preferences, and dashboard configurations are stored locally in your web browser\'s storage. This means the data is specific to the browser and device you are using.',
                        isDarkTheme,
                      ),
                      SizedBox(height: 16),
                      _buildFAQItem(
                        'How do the AI Lab tools work?',
                        'The AI Lab features use generative AI models to provide assistance. For example, the \'Image to Text\' tool can analyze medical photos, while others can help generate meal plans or workout routines based on your input.',
                        isDarkTheme,
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.tealAccent.withOpacity(0.1) 
                            : Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDarkTheme ? Colors.tealAccent : Colors.teal,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.science_outlined,
                              color: isDarkTheme ? Colors.tealAccent : Colors.teal,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Explore AI Lab Features',
                                style: TextStyle(
                                  color: isDarkTheme ? Colors.tealAccent : Colors.teal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: isDarkTheme ? Colors.tealAccent : Colors.teal,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Submit Feedback Section
                Container(
                  width: double.infinity,
                  decoration: _getSubmitCardDecoration(isDarkTheme),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.feedback_outlined,
                            color: isDarkTheme ? Colors.white : Colors.green[800],
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Submit Feedback',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'We value your input! Let us know how we can improve TrackAI.',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Email Field
                      Text(
                        'Your Email (Optional)',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.green[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.green[800],
                        ),
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          hintStyle: TextStyle(
                            color: isDarkTheme ? Colors.white54 : Colors.green[600],
                          ),
                          filled: true,
                          fillColor: isDarkTheme 
                            ? Colors.black26 
                            : Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white30 : Colors.green[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white30 : Colors.green[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white : Colors.green[600]!,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Subject Field
                      Text(
                        'Subject',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.green[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: subjectController,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.green[800],
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g., Suggestion for new tracker',
                          hintStyle: TextStyle(
                            color: isDarkTheme ? Colors.white54 : Colors.green[600],
                          ),
                          filled: true,
                          fillColor: isDarkTheme 
                            ? Colors.black26 
                            : Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white30 : Colors.green[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white30 : Colors.green[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white : Colors.green[600]!,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Message Field
                      Text(
                        'Message',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.green[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: messageController,
                        maxLines: 5,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.green[800],
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tell us your thoughts...',
                          hintStyle: TextStyle(
                            color: isDarkTheme ? Colors.white54 : Colors.green[600],
                          ),
                          filled: true,
                          fillColor: isDarkTheme 
                            ? Colors.black26 
                            : Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white30 : Colors.green[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white30 : Colors.green[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme ? Colors.white : Colors.green[600]!,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkTheme ? Colors.white : Colors.green[700],
                            foregroundColor: isDarkTheme ? Colors.green[800] : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Submit Feedback',
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
                SizedBox(height: 100), // Extra space for the success bar
              ],
            ),
          ),
          
          // Success Bar
          if (isReportSent)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: AnimatedBuilder(
                animation: slideAnimation!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, slideAnimation!.value * 100),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Report sent successfully!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isDarkTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 6),
        Text(
          answer,
          style: TextStyle(
            fontSize: 13,
            color: isDarkTheme ? Colors.white70 : Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}