import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:trackai/core/constants/appcolors.dart';

class TargetAnalysisPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final double targetAmount;
  final String targetUnit;
  final int targetTimeframe;
  final String goal;

  const TargetAnalysisPage({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.targetAmount,
    required this.targetUnit,
    required this.targetTimeframe,
    required this.goal,
  }) : super(key: key);

  @override
  State<TargetAnalysisPage> createState() => _TargetAnalysisPageState();
}

class _TargetAnalysisPageState extends State<TargetAnalysisPage> {
  String _analysisText = "";
  String _recommendationText = "";
  bool _isLoading = true;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _generateAnalysis();
  }

  Future<void> _generateAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorOccurred = false;
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        throw Exception('API key not found');
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      String goalType = widget.goal == 'gain_weight' ? 'gain' : 'lose';
      String prompt =
          '''
        Analyze this fitness goal and provide a concise analysis and recommendation:
        
        Goal: ${goalType} ${widget.targetAmount} ${widget.targetUnit} in ${widget.targetTimeframe} weeks.
        
        Please provide:
        1. A brief analysis of whether this is an aggressive, moderate, or conservative goal
        2. A short recommendation on how to approach this goal safely and effectively
        
        Format the response with two short paragraphs separated by a blank line.
        Keep the response under 30-40 words for 2nd point and 10-12 words for 1st point, keep it like "Losing 4 kg in 4 weeks is an ambitious goal" accordingly whatever the user demands..
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final text = response.text ?? "";
      final parts = text.split('\n\n');

      if (parts.length >= 2) {
        setState(() {
          _analysisText = parts[0];
          _recommendationText = parts[1];
          _isLoading = false;
        });
      } else {
        // Fallback if the response doesn't split correctly
        setState(() {
          _analysisText = text;
          _recommendationText =
              "Please consult with a health professional for personalized advice.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error generating analysis: $e');
      setState(() {
        _errorOccurred = true;
        _isLoading = false;
        _analysisText = "Unable to generate analysis";
        _recommendationText = "Please check your connection and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5F3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          size: 40,
                          color: AppColors.darkPrimary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Your Target Analysis',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Analysis Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: _isLoading
                            ? const Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF4CAF50),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Generating your personalized analysis...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text(
                                    _analysisText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E2E2E),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 20),

                                  Text(
                                    _recommendationText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  if (_errorOccurred)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: ElevatedButton(
                                        onPressed: _generateAnalysis,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4CAF50,
                                          ),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Try Again'),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
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
}
