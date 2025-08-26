import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';

class Bodyanalyzer extends StatefulWidget {
  const Bodyanalyzer({Key? key}) : super(key: key);

  @override
  State<Bodyanalyzer> createState() => _BodyanalyzerState();
}

class _BodyanalyzerState extends State<Bodyanalyzer> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedGender = '';
  String _selectedUnit = 'kg';
  String _selectedHeightUnit = 'cm';
  String _selectedActivityLevel = '';
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  bool _showAllMetrics = false;
  String? _aiRecommendation;
  bool _isLoadingRecommendation = false;

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _unitOptions = ['kg', 'lbs'];
  final List<String> _heightUnits = ['cm', 'ft/in'];
  final List<String> _activityLevels = [
    'Sedentary (little/no exercise)',
    'Light (light exercise/sports 1-3 days/week)',
    'Moderate (moderate exercise/sports 3-5 days/week)',
    'Active (hard exercise/sports 6-7 days a week)',
    'Very Active (very hard exercise & physical job)',
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  BoxDecoration _getCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(40, 50, 49, 0.85),
            const Color.fromARGB(215, 14, 14, 14),
            Color.fromRGBO(33, 43, 42, 0.85),
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
            AppColors.lightSecondary.withOpacity(0.85),
            AppColors.lightSecondary.withOpacity(0.85),
            AppColors.lightSecondary.withOpacity(0.85),
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

  Future<void> _analyzeBodyComposition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Simulate analysis with mock data
      await Future.delayed(const Duration(seconds: 2));

      final age = int.parse(_ageController.text);
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);

      // Convert to metric for calculations if needed
      double weightKg = _selectedUnit == 'kg' ? weight : weight * 0.453592;
      double heightCm = _selectedHeightUnit == 'cm' ? height : height * 30.48;

      // Calculate BMI
      double bmi = weightKg / ((heightCm / 100) * (heightCm / 100));

      // Generate mock body composition data
      setState(() {
        _analysisResult = _generateMockAnalysis(
          weightKg,
          bmi,
          age,
          _selectedGender,
        );
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error analyzing data: $e')));
    }
  }

  Map<String, dynamic> _generateMockAnalysis(
    double weight,
    double bmi,
    int age,
    String gender,
  ) {
    // Mock calculations based on weight, BMI, age, and gender
    double bodyFatPercent = gender == 'Male'
        ? (bmi > 25 ? 25 + (bmi - 25) * 0.8 : 15 + (bmi - 20) * 0.5)
        : (bmi > 25 ? 30 + (bmi - 25) * 0.8 : 20 + (bmi - 20) * 0.5);

    double bodyFatMass = weight * (bodyFatPercent / 100);
    double leanMass = weight - bodyFatMass;
    double muscleMass = leanMass * 0.84;
    double boneMass = weight * 0.035;
    double waterMass = leanMass * 0.9;
    double proteinMass = leanMass * 0.168;

    double bmr = gender == 'Male'
        ? 88.362 + (13.397 * weight) + (4.799 * 170) - (5.677 * age)
        : 447.593 + (9.247 * weight) + (3.098 * 170) - (4.330 * age);

    int metabolicAge = age + (bmi > 25 ? (bmi - 25).round() * 2 : 0);
    int visceralFat = (bmi > 30
        ? 15 + (bmi - 30).round()
        : bmi > 25
        ? 10 + (bmi - 25).round() * 2
        : 5);

    int overallScore =
        (100 -
                (bodyFatPercent - (gender == 'Male' ? 15 : 25)).abs() * 2 -
                (bmi - 22).abs() * 1.5 -
                (visceralFat > 12 ? (visceralFat - 12) * 3 : 0))
            .round();
    overallScore = overallScore.clamp(0, 100);

    return {
      'overallScore': overallScore,
      'bodyWeight': weight,
      'bmi': bmi,
      'bodyFat': bodyFatPercent,
      'skeletalMuscle': muscleMass * 0.85,
      'visceralFat': visceralFat,
      'bodyFatMass': bodyFatMass,
      'leanMass': leanMass,
      'muscleMass': muscleMass,
      'boneMass': boneMass,
      'waterMass': waterMass,
      'proteinMass': proteinMass,
      'bmr': bmr,
      'metabolicAge': metabolicAge,
      'subcutaneousFat': bodyFatPercent * 0.7,
      'bodyWater': (waterMass / weight) * 100,
    };
  }

  Future<void> _getAIRecommendation() async {
  if (_analysisResult == null) return;

  setState(() {
    _isLoadingRecommendation = true;
  });

  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    print('API Key available: ${apiKey != null}');

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found in environment variables');
    }

    final prompt = """
Based on the following body composition analysis, provide concise health recommendations:

**Personal Info:**
- Age: ${_ageController.text} years
- Gender: $_selectedGender
- Activity Level: $_selectedActivityLevel

**Body Composition Metrics:**
- Body Weight: ${_analysisResult!['bodyWeight'].toStringAsFixed(1)} kg
- BMI: ${_analysisResult!['bmi'].toStringAsFixed(1)}
- Body Fat: ${_analysisResult!['bodyFat'].toStringAsFixed(1)}%
- Skeletal Muscle: ${_analysisResult!['skeletalMuscle'].toStringAsFixed(1)} kg
- Visceral Fat Level: ${_analysisResult!['visceralFat']}
- Lean Mass: ${_analysisResult!['leanMass'].toStringAsFixed(1)} kg
- Muscle Mass: ${_analysisResult!['muscleMass'].toStringAsFixed(1)} kg
- Bone Mass: ${_analysisResult!['boneMass'].toStringAsFixed(1)} kg
- Body Water: ${_analysisResult!['bodyWater'].toStringAsFixed(1)}%
- Protein Mass: ${_analysisResult!['proteinMass'].toStringAsFixed(1)} kg
- BMR: ${_analysisResult!['bmr'].toStringAsFixed(0)} kcal/day
- Metabolic Age: ${_analysisResult!['metabolicAge']} years

**Instructions:**
1. **Overall Assessment** - Brief 2-3 sentence summary of health status
2. **Key Focus Areas** - Select exactly 3 most important metrics from the above data that need attention and provide specific recommendations for each
3. **Exercise Plan** - 3-4 specific exercise recommendations based on activity level
4. **Diet Guidelines** - 3-4 specific nutritional recommendations (not empty!)
5. **Timeline** - Expected improvements timeline in 3-4 sentences

**Format Requirements:**
- Keep each section concise (2-4 points maximum)
- Use bullet points for recommendations
- Be specific and actionable
- Total response should be under 400 words
- Ensure diet section has actual food/nutrition recommendations
""";

    print('Making API request to Gemini...');
    print(
      'Request URL: https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
    );

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 800, // Reduced from 2048
        },
      }),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if response has the expected structure
      if (data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        setState(() {
          _aiRecommendation =
              data['candidates'][0]['content']['parts'][0]['text'];
          _isLoadingRecommendation = false;
        });
      } else {
        throw Exception('Invalid response structure from Gemini API: $data');
      }
    } else {
      // Handle different HTTP error codes
      String errorMessage;
      switch (response.statusCode) {
        case 400:
          errorMessage = 'Bad Request: ${response.body}';
          break;
        case 401:
          errorMessage = 'Unauthorized: Invalid API key';
          break;
        case 403:
          errorMessage =
              'Forbidden: API key may not have required permissions';
          break;
        case 404:
          errorMessage = 'Not Found: API endpoint not found';
          break;
        case 429:
          errorMessage = 'Rate Limited: Too many requests';
          break;
        case 500:
          errorMessage = 'Server Error: Gemini API internal error';
          break;
        default:
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
      }
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('Error getting AI recommendation: $e');

    setState(() {
      _isLoadingRecommendation = false;
      _aiRecommendation = '''Error getting AI recommendation: $e
      
Please check:
1. Your Gemini API key is correctly set in the .env file
2. The API key has the required permissions
3. Your internet connection is stable
4. You haven't exceeded API rate limits

You can get a free Gemini API key from: https://makersuite.google.com/app/apikey''';
    });

    // Also show error in snackbar for immediate user feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI Recommendation Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkTheme = themeProvider.isDarkMode;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    // Remove transparent background - let it use theme default
    backgroundColor: isDarkTheme ? Colors.black : Colors.white,
    appBar: AppBar(
      // Provide proper background color instead of transparent
      backgroundColor: isDarkTheme 
          ? Colors.black.withOpacity(0.9)
          : Colors.white.withOpacity(0.9),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary(isDarkTheme),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Body Composition Analyzer',
        style: TextStyle(
          color: AppColors.textPrimary(isDarkTheme),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      systemOverlayStyle: isDarkTheme 
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    body: Container(
      // Add a proper background container
      decoration: BoxDecoration(
        gradient: isDarkTheme
            ? LinearGradient(
                colors: [
                  Colors.black,
                  Color(0xFF1A1A1A),
                  Colors.black87,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFF8F9FA),
                  Colors.grey.shade50,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            if (_analysisResult == null) _buildInputForm(isDarkTheme),
            if (_analysisResult != null) ...[
              _buildResultsCard(isDarkTheme),
              SizedBox(height: screenHeight * 0.02),
              _buildAIRecommendationCard(isDarkTheme),
              SizedBox(height: screenHeight * 0.02),
              _buildAnalyzeAgainButton(isDarkTheme),
            ],
            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildInputForm(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _getCardDecoration(isDarkTheme),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Body Composition Analyzer',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Enter your details to receive an AI-powered body composition analysis.',
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),

            // Age Field
            Text(
              'Age',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'E.g., 30',
                hintStyle: TextStyle(
                  color: isDarkTheme ? Colors.white38 : Colors.black38,
                ),
                filled: true,
                fillColor: isDarkTheme
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Gender Field
            Text(
              'Gender',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender.isEmpty ? null : _selectedGender,
              decoration: InputDecoration(
                hintText: 'Select gender',
                hintStyle: TextStyle(
                  color: isDarkTheme ? Colors.white38 : Colors.black38,
                ),
                filled: true,
                fillColor: isDarkTheme
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
              dropdownColor: isDarkTheme ? Color(0xFF2A2A2A) : Colors.white,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
              items: _genderOptions.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Weight Field
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g., 75',
                          hintStyle: TextStyle(
                            color: isDarkTheme
                                ? Colors.white38
                                : Colors.black38,
                          ),
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.02),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkTheme
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.02),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkTheme
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                        dropdownColor: isDarkTheme
                            ? Color(0xFF2A2A2A)
                            : Colors.white,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                        items: _unitOptions.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value ?? 'kg';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Height Field
            Text(
              'Height',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedHeightUnit,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkTheme
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
              dropdownColor: isDarkTheme ? Color(0xFF2A2A2A) : Colors.white,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
              items: _heightUnits.map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHeightUnit = value ?? 'cm';
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: _selectedHeightUnit == 'cm'
                    ? 'cm'
                    : 'feet (e.g., 5.8)',
                hintStyle: TextStyle(
                  color: isDarkTheme ? Colors.white38 : Colors.black38,
                ),
                filled: true,
                fillColor: isDarkTheme
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your height';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Activity Level Field
            Text(
              'Activity Level',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel.isEmpty
                  ? null
                  : _selectedActivityLevel,
              isExpanded: true, // This prevents overflow
              decoration: InputDecoration(
                hintText: 'Select activity level',
                hintStyle: TextStyle(
                  color: isDarkTheme ? Colors.white38 : Colors.black38,
                ),
                filled: true,
                fillColor: isDarkTheme
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ), // Better padding
              ),
              dropdownColor: isDarkTheme ? Color(0xFF2A2A2A) : Colors.white,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              items: _activityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      level,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Allow up to 2 lines
                      style: TextStyle(
                        fontSize: 13, // Slightly smaller font for better fit
                        height: 1.2,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your activity level';
                }
                return null;
              },
            ),
            SizedBox(height: 32),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeBodyComposition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isAnalyzing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Analyzing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Analyze Body Composition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'AI Body Composition Report',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Your BMI indicates ${_analysisResult!['bmi'] > 30
                ? 'obesity'
                : _analysisResult!['bmi'] > 25
                ? 'overweight'
                : 'normal weight'}, and your body fat percentage is ${_analysisResult!['bodyFat'] > 25 ? 'elevated' : 'within normal range'}. Focus on dietary changes and exercise to improve your overall health indicators.',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),

          // Overall Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkTheme
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Overall Score',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '${_analysisResult!['overallScore']}',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _analysisResult!['overallScore'] / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Key Metrics Title
          Text(
            'Key Metrics',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          // Basic Metrics
          _buildMetricItem(
            icon: Icons.monitor_weight_outlined,
            title: 'Body Weight',
            value: '${_analysisResult!['bodyWeight'].toStringAsFixed(1)} kg',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            icon: Icons.straighten,
            title: 'BMI',
            value: _analysisResult!['bmi'].toStringAsFixed(1),
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            icon: Icons.opacity,
            title: 'Body Fat',
            value: '${_analysisResult!['bodyFat'].toStringAsFixed(1)}%',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            icon: Icons.fitness_center,
            title: 'Skeletal Muscle',
            value:
                '${_analysisResult!['skeletalMuscle'].toStringAsFixed(1)} kg',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            icon: Icons.warning_outlined,
            title: 'Visceral Fat',
            value: '${_analysisResult!['visceralFat']} level',
            isDarkTheme: isDarkTheme,
          ),

          if (_showAllMetrics) ...[
            SizedBox(height: 16),
            Text(
              'Mass Breakdown',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildMetricItem(
              icon: Icons.opacity,
              title: 'Body Fat Mass',
              value: '${_analysisResult!['bodyFatMass'].toStringAsFixed(1)} kg',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.fitness_center,
              title: 'Lean Mass',
              value: '${_analysisResult!['leanMass'].toStringAsFixed(1)} kg',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.accessibility_new,
              title: 'Muscle Mass',
              value: '${_analysisResult!['muscleMass'].toStringAsFixed(1)} kg',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.sports_gymnastics,
              title: 'Bone Mass',
              value: '${_analysisResult!['boneMass'].toStringAsFixed(1)} kg',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.water_drop,
              title: 'Water Mass',
              value: '${_analysisResult!['waterMass'].toStringAsFixed(1)} kg',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.biotech,
              title: 'Protein Mass',
              value: '${_analysisResult!['proteinMass'].toStringAsFixed(1)} kg',
              isDarkTheme: isDarkTheme,
            ),
            SizedBox(height: 16),
            Text(
              'Other Indicators',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildMetricItem(
              icon: Icons.local_fire_department,
              title: 'BMR',
              value: '${_analysisResult!['bmr'].toStringAsFixed(0)} kcal/day',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.cake,
              title: 'Metabolic Age',
              value: '${_analysisResult!['metabolicAge']} years',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.layers,
              title: 'Subcutaneous Fat',
              value:
                  '${_analysisResult!['subcutaneousFat'].toStringAsFixed(1)}%',
              isDarkTheme: isDarkTheme,
            ),
            _buildMetricItem(
              icon: Icons.water,
              title: 'Body Water',
              value: '${_analysisResult!['bodyWater'].toStringAsFixed(1)}%',
              isDarkTheme: isDarkTheme,
            ),
          ],

          SizedBox(height: 20),

          // Show All Metrics Button
          InkWell(
            onTap: () {
              setState(() {
                _showAllMetrics = !_showAllMetrics;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showAllMetrics
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _showAllMetrics ? 'Show Less' : 'See All 17 Metrics',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationCard(bool isDarkTheme) {
    return Column(
      children: [
        // AI Recommendations Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoadingRecommendation ? null : _getAIRecommendation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoadingRecommendation
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI Recommendations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // AI Recommendations Content
        if (_aiRecommendation != null) ...[
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Color(0xFF4CAF50), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'AI Health Recommendations',
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildFormattedRecommendation(_aiRecommendation!, isDarkTheme),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormattedRecommendation(
  String recommendation,
  bool isDarkTheme,
) {
  // Split the recommendation into sections and format them
  final lines = recommendation.split('\n');
  List<Widget> widgets = [];

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i].trim();
    if (line.isEmpty) continue;

    // Handle main headers (##)
    if (line.startsWith('## ')) {
      widgets.add(SizedBox(height: widgets.isEmpty ? 0 : 16));
      widgets.add(
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4CAF50).withOpacity(0.1),
                Color(0xFF4CAF50).withOpacity(0.05),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: Color(0xFF4CAF50), width: 3),
            ),
          ),
          child: Text(
            line.substring(3), // Remove "## "
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
      widgets.add(SizedBox(height: 12));
    }
    // Handle sub-headers with **bold** formatting
    else if (line.startsWith('**') &&
        line.endsWith('**') &&
        line.length > 4) {
      widgets.add(SizedBox(height: 12));
      widgets.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF4CAF50),
                size: 14,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  line.substring(2, line.length - 2), // Remove ** **
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      widgets.add(SizedBox(height: 8));
    }
    // Handle bullet points with *
    else if (line.startsWith('* ')) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.01),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _parseInlineFormatting(
                  line.substring(2), // Remove "* "
                  isDarkTheme,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Handle numbered lists
    else if (RegExp(r'^\d+\.').hasMatch(line)) {
      final match = RegExp(r'^(\d+)\.\s*(.*)').firstMatch(line);
      if (match != null) {
        widgets.add(
          Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.01),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkTheme
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.03),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      match.group(1)!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _parseInlineFormatting(match.group(2)!, isDarkTheme),
                ),
              ],
            ),
          ),
        );
      }
    }
    // Handle regular paragraphs - now with consistent card styling
    else if (line.isNotEmpty) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.01),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline,
                  color: Color(0xFF4CAF50),
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _parseInlineFormatting(line, isDarkTheme),
              ),
            ],
          ),
        ),
      );
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}

  Widget _parseInlineFormatting(String text, bool isDarkTheme) {
    List<TextSpan> spans = [];
    List<String> parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        spans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        );
      } else {
        // Bold text
        spans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildAnalyzeAgainButton(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(isDarkTheme),
      child: Column(
        children: [
          Icon(Icons.refresh, color: Color(0xFF4CAF50), size: 32),
          SizedBox(height: 12),
          Text(
            'Analyze Again',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _analysisResult = null;
                  _aiRecommendation = null;
                  _showAllMetrics = false;
                  _ageController.clear();
                  _weightController.clear();
                  _heightController.clear();
                  _selectedGender = '';
                  _selectedActivityLevel = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(color:(isDarkTheme)? Color(0xFF4CAF50):Colors.transparent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'New Analysis',
                style: TextStyle(
                  color: (isDarkTheme)? Color(0xFF4CAF50):Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
