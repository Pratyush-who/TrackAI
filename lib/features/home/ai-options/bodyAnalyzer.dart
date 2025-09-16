import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _feetController = TextEditingController();
  final _inchesController = TextEditingController();

  String _selectedGender = '';
  String _selectedUnit = 'kg';
  String _selectedHeightUnit = 'cm';
  String _selectedActivityLevel = '';
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  bool _showAllMetrics = false;
  String? _aiRecommendation;
  bool _isLoadingRecommendation = false;
  List<DocumentSnapshot> _pastAnalyses = [];
  bool _isLoadingHistory = false;
  bool _isRecentAnalysesExpanded = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  void initState() {
    super.initState();
    _loadPastAnalyses();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    super.dispose();
  }

  Future<void> _loadPastAnalyses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('body_analyses')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      setState(() {
        _pastAnalyses = querySnapshot.docs;
        _isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading past analyses: $e');
      setState(() {
        _isLoadingHistory = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePastAnalysis() async {
    final user = _auth.currentUser;
    if (user == null || _analysisResult == null) return;

    try {
      final analysisData = {
        'timestamp': FieldValue.serverTimestamp(),
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
        'weight': double.parse(_weightController.text),
        'weightUnit': _selectedUnit,
        'height': _selectedHeightUnit == 'cm'
            ? double.parse(_heightController.text)
            : (double.parse(_feetController.text) * 12 +
                  double.parse(_inchesController.text)),
        'heightUnit': _selectedHeightUnit,
        'activityLevel': _selectedActivityLevel,
        'results': _analysisResult,
        'aiRecommendation': _aiRecommendation,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('body_analyses')
          .add(analysisData);

      await _loadPastAnalyses();
    } catch (e) {
      print('Error saving analysis: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving analysis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  BoxDecoration getCardDecoration(bool isDarkTheme) {
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
      );
    }
  }

  Future<void> _analyzeBodyComposition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      final age = int.parse(_ageController.text);
      final weight = double.parse(_weightController.text);

      double height;
      if (_selectedHeightUnit == 'cm') {
        height = double.parse(_heightController.text);
      } else {
        final feet = double.parse(_feetController.text);
        final inches = double.parse(_inchesController.text);
        height = (feet * 12 + inches) * 2.54;
      }

      double weightKg = _selectedUnit == 'kg' ? weight : weight * 0.453592;
      double heightCm = height;

      setState(() {
        _analysisResult = _generateAIAnalysis(
          weightKg,
          heightCm,
          age,
          _selectedGender,
        );
        _isAnalyzing = false;
      });

      await _savePastAnalysis();
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _generateAIAnalysis(
    double weight,
    double height,
    int age,
    String gender,
  ) {
    double bmi = weight / ((height / 100) * (height / 100));

    double bodyFatPercent;
    if (gender == 'Male') {
      bodyFatPercent = (1.20 * bmi) + (0.23 * age) - 16.2;
    } else {
      bodyFatPercent = (1.20 * bmi) + (0.23 * age) - 5.4;
    }
    bodyFatPercent = bodyFatPercent.clamp(5.0, 50.0);

    double bodyFatMass = weight * (bodyFatPercent / 100);
    double leanMass = weight - bodyFatMass;
    double skeletalMuscleMass = leanMass * (gender == 'Male' ? 0.45 : 0.36);
    double boneMass = weight * (gender == 'Male' ? 0.15 : 0.12);
    double organMass = weight * 0.06;
    double waterMass = leanMass * 0.73;
    double proteinMass = leanMass * 0.20;

    double bmr;
    if (gender == 'Male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    int metabolicAge = _calculateMetabolicAge(bmi, bodyFatPercent, age, gender);
    int visceralFatRating = _calculateVisceralFat(bmi, age, gender);
    double subcutaneousFat = bodyFatPercent * 0.85;
    double bodyWaterPercent = (waterMass / weight) * 100;

    int overallScore = _calculateOverallScore(
      bmi,
      bodyFatPercent,
      visceralFatRating,
      age,
      gender,
    );

    return {
      'overallScore': overallScore,
      'bodyWeight': weight,
      'bmi': bmi,
      'bodyFat': bodyFatPercent,
      'skeletalMuscle': skeletalMuscleMass,
      'visceralFat': visceralFatRating,
      'bodyFatMass': bodyFatMass,
      'leanMass': leanMass,
      'muscleMass': skeletalMuscleMass * 1.2,
      'boneMass': boneMass,
      'organMass': organMass,
      'waterMass': waterMass,
      'proteinMass': proteinMass,
      'bmr': bmr,
      'metabolicAge': metabolicAge,
      'subcutaneousFat': subcutaneousFat,
      'bodyWater': bodyWaterPercent,
    };
  }

  int _calculateMetabolicAge(
    double bmi,
    double bodyFat,
    int chronologicalAge,
    String gender,
  ) {
    double ageFactor = chronologicalAge.toDouble();

    if (bmi < 18.5)
      ageFactor += 3;
    else if (bmi > 25)
      ageFactor += (bmi - 25) * 1.5;

    double optimalBodyFat = gender == 'Male' ? 15.0 : 23.0;
    ageFactor += (bodyFat - optimalBodyFat).abs() * 0.5;

    return ageFactor.round().clamp(
      chronologicalAge - 10,
      chronologicalAge + 20,
    );
  }

  int _calculateVisceralFat(double bmi, int age, String gender) {
    double rating = 1.0;

    if (bmi > 30)
      rating += 8;
    else if (bmi > 25)
      rating += 4;

    if (age > 40) rating += (age - 40) * 0.1;
    if (gender == 'Male') rating += 1;

    return rating.round().clamp(1, 30);
  }

  int _calculateOverallScore(
    double bmi,
    double bodyFat,
    int visceralFat,
    int age,
    String gender,
  ) {
    double score = 100.0;

    double optimalBMI = 22.0;
    score -= (bmi - optimalBMI).abs() * 2;

    double optimalBodyFat = gender == 'Male' ? 15.0 : 23.0;
    score -= (bodyFat - optimalBodyFat).abs() * 1.5;

    if (visceralFat > 10) score -= (visceralFat - 10) * 3;

    if (age > 30) score -= (age - 30) * 0.2;

    return score.round().clamp(20, 100);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String _getBodyFatCategory(double bodyFat, String gender) {
    if (gender == 'Male') {
      if (bodyFat < 10) return 'Essential';
      if (bodyFat < 18) return 'Athletic';
      if (bodyFat < 25) return 'Good';
      return 'Excess';
    } else {
      if (bodyFat < 16) return 'Essential';
      if (bodyFat < 24) return 'Athletic';
      if (bodyFat < 31) return 'Good';
      return 'Excess';
    }
  }

  String _getVisceralFatCategory(int visceralFat) {
    if (visceralFat <= 12) return 'Healthy';
    if (visceralFat <= 16) return 'Excess';
    return 'High Risk';
  }

  Widget _buildMetricItem({
  required String title,
  required String value,
  required String unit,
  required bool isDarkTheme,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: isDarkTheme ? Color(0xFF1a1a1a) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isDarkTheme ? Color(0xFF333333) : Color(0xFFE0E0E0),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
            ),
            if (unit.isNotEmpty) ...[
              SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}


  String _generateAIReport() {
    if (_analysisResult == null) return '';

    final bmi = _analysisResult!['bmi'];
    final bodyFat = _analysisResult!['bodyFat'];
    final visceralFat = _analysisResult!['visceralFat'];

    String report = '';

    // BMI assessment
    if (bmi >= 18.5 && bmi < 25) {
      report += 'Your BMI is within the healthy range, ';
    } else if (bmi < 18.5) {
      report += 'Your BMI indicates underweight status, ';
    } else if (bmi < 30) {
      report += 'Your BMI indicates overweight status, ';
    } else {
      report += 'Your BMI indicates obesity, ';
    }

    // Lean mass assessment
    report +=
        'and your lean mass is also good, suggesting a decent level of muscle. ';

    // Visceral fat assessment
    if (visceralFat <= 12) {
      report += 'Your visceral fat level is healthy. ';
    } else {
      report +=
          'A slight concern is the visceral fat level, which is at the upper end of the healthy range. ';
      report +=
          'Maintaining this level or lowering it towards the lower end of the 1-12 range is recommended. ';
    }

    // Body fat assessment
    final optimalBodyFat = _selectedGender == 'Male' ? 20.0 : 25.0;
    if (bodyFat <= optimalBodyFat) {
      report += 'Your body fat percentage is excellent. ';
    } else {
      report +=
          'Your body fat percentage is acceptable, aiming to keep it below ${optimalBodyFat.toInt()}% could bring further health benefits.';
    }

    return report;
  }

  Future<void> _getAIRecommendation() async {
    if (_analysisResult == null) return;

    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key not found in environment variables');
      }

      final prompt =
          """
As a certified fitness and nutrition expert, provide personalized health recommendations based on this comprehensive body composition analysis:

**Personal Profile:**
- Age: ${_ageController.text} years
- Gender: $_selectedGender
- Activity Level: $_selectedActivityLevel

**Body Composition Analysis:**
- Body Weight: ${_analysisResult!['bodyWeight'].toStringAsFixed(1)} kg
- BMI: ${_analysisResult!['bmi'].toStringAsFixed(1)} (${_getBMICategory(_analysisResult!['bmi'])})
- Body Fat: ${_analysisResult!['bodyFat'].toStringAsFixed(1)}% (${_getBodyFatCategory(_analysisResult!['bodyFat'], _selectedGender)})
- Skeletal Muscle: ${_analysisResult!['skeletalMuscle'].toStringAsFixed(1)} kg
- Visceral Fat Level: ${_analysisResult!['visceralFat']} (${_getVisceralFatCategory(_analysisResult!['visceralFat'])})
- Lean Mass: ${_analysisResult!['leanMass'].toStringAsFixed(1)} kg
- Muscle Mass: ${_analysisResult!['muscleMass'].toStringAsFixed(1)} kg
- Bone Mass: ${_analysisResult!['boneMass'].toStringAsFixed(1)} kg
- Body Water: ${_analysisResult!['bodyWater'].toStringAsFixed(1)}%
- BMR: ${_analysisResult!['bmr'].toStringAsFixed(0)} kcal/day
- Metabolic Age: ${_analysisResult!['metabolicAge']} years
- Overall Health Score: ${_analysisResult!['overallScore']}/100

**Provide detailed recommendations in exactly this format:**

## Overall Health Assessment
[2-3 sentences analyzing current health status and key areas of concern]

## Priority Focus Areas
**1. [Most Important Metric]**
- Current status and what it means
- Specific improvement target
- Timeline for improvement

**2. [Second Priority]**
- Current status and what it means
- Specific improvement target
- Timeline for improvement

**3. [Third Priority]**
- Current status and what it means
- Specific improvement target
- Timeline for improvement

## Exercise Recommendations
**Strength Training:**
- [Specific exercises and frequency]
- [Progressive overload guidance]

**Cardiovascular Training:**
- [Type, intensity, and duration]
- [Weekly schedule]

**Flexibility & Recovery:**
- [Specific recovery protocols]

## Nutrition Strategy
**Caloric Requirements:**
- Daily calorie target: [specific number] kcal
- Protein target: [specific grams] g/day
- Carbohydrate timing and amounts

**Meal Planning:**
- [3-4 specific meal/snack recommendations]
- [Hydration requirements]
- [Supplement considerations if any]

## Expected Timeline & Milestones
- Week 2-4: [Expected changes]
- Month 2-3: [Expected improvements]
- Month 6+: [Long-term goals]

**Important Note:** Consult healthcare providers before making significant changes to diet or exercise routines.
""";

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
            'maxOutputTokens': 1200,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

          await _savePastAnalysis();
        } else {
          throw Exception('Invalid response structure from Gemini API');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoadingRecommendation = false;
        _aiRecommendation = '''Error generating AI recommendation: $e

Please ensure:
1. Your Gemini API key is properly configured
2. You have an active internet connection
3. The API service is available

Get your free API key at: https://makersuite.google.com/app/apikey''';
      });
    }
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    required bool isDarkTheme,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: suffixIcon,
            hintStyle: TextStyle(
              color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDarkTheme ? Color(0xFF2a2a2a) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkTheme ? Color(0xFF404040) : Color(0xFFd1d5db),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkTheme ? Color(0xFF404040) : Color(0xFFd1d5db),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkTheme
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget buildDropdownField({
    required String? value,
    required String label,
    required List<String> options,
    required isDarkTheme,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
    bool isExpanded = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: isExpanded,
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkTheme ? Color(0xFF2a2a2a) : Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkTheme ? Color(0xFF404040) : Color(0xFFd1d5db),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkTheme ? Color(0xFF404040) : Color(0xFFd1d5db),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkTheme
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                width: 2,
              ),
            ),
          ),
          dropdownColor: isDarkTheme ? Color(0xFF2a2a2a) : Colors.white,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          validator: validator,
        ),
      ],
    );
  }

  Widget buildMetricCard(
    String title,
    String value,
    String unit,
    String? category,
    bool isDarkTheme, {
    bool isMainMetric = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMainMetric ? 20 : 16),
      decoration: BoxDecoration(
        color: isDarkTheme ? Color(0xFF2a2a2a) : Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme ? Color(0xFF404040) : Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
              fontSize: isMainMetric ? 14 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isMainMetric ? 12 : 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: isMainMetric ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                    fontSize: isMainMetric ? 18 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (category != null && category.isNotEmpty) ...[
            SizedBox(height: 6),
            Text(
              category,
              style: TextStyle(
                color: _getCategoryColor(category),
                fontSize: isMainMetric ? 13 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'normal':
      case 'healthy':
      case 'athletic':
      case 'good':
      case 'excellent':
        return Colors.green;
      case 'overweight':
      case 'excess':
        return Colors.orange;
      case 'obese':
      case 'high risk':
        return Colors.red;
      case 'underweight':
      case 'essential':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  Widget buildRecentAnalysesSection(bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isRecentAnalysesExpanded = !_isRecentAnalysesExpanded;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: isDarkTheme
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recent Body Analyses',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  _isRecentAnalysesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isDarkTheme
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isRecentAnalysesExpanded) ...[
            SizedBox(height: 16),
            if (_isLoadingHistory)
              Center(
                child: CircularProgressIndicator(
                  color: isDarkTheme
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                ),
              )
            else if (_pastAnalyses.isNotEmpty) ...[
              ..._pastAnalyses.take(5).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                final results = data['results'] as Map<String, dynamic>? ?? {};

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Color(0xFF2a2a2a) : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkTheme
                          ? Color(0xFF404040)
                          : Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI: ${results['bmi']?.toStringAsFixed(1) ?? 'N/A'} • Body Fat: ${results['bodyFat']?.toStringAsFixed(1) ?? 'N/A'}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkTheme
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              timestamp != null
                                  ? '${timestamp.day}/${timestamp.month}/${timestamp.year} • Score: ${results['overallScore']?.toInt() ?? 0}/100'
                                  : 'Date N/A • Score: ${results['overallScore']?.toInt() ?? 0}/100',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkTheme
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.visibility,
                          size: 20,
                          color: isDarkTheme
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _analysisResult = results;
                            _aiRecommendation = data['aiRecommendation'];
                            _isRecentAnalysesExpanded = false;
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'No recent analyses found. Complete your first body analysis above!',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _getScoreDescription(int score) {
    if (score >= 85) return 'Excellent Health';
    if (score >= 70) return 'Good Health';
    if (score >= 55) return 'Fair Health';
    if (score >= 40) return 'Needs Improvement';
    return 'Poor Health';
  }

  Widget _buildEnhancedMetricItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required bool isDarkTheme,
    String? category,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      height: 80, // Reduced height as requested
      decoration: BoxDecoration(
        color: isDarkTheme ? Color(0xFF2a2a2a) : Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme ? Color(0xFF404040) : Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkTheme ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (category != null) ...[
                  SizedBox(height: 2),
                  Text(
                    category,
                    style: TextStyle(
                      color: _getCategoryColor(category),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(
                        color: isDarkTheme
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  
Widget buildResultsDisplay(bool isDarkTheme) {
  if (_analysisResult == null) return SizedBox.shrink();

  return Container(
    padding: EdgeInsets.all(20),
    decoration: getCardDecoration(isDarkTheme),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: isDarkTheme
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'AI Body Composition Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // AI Generated Report Text
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme ? Color(0xFF2a2a2a) : Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkTheme ? Color(0xFF404040) : Color(0xFFE0E0E0),
            ),
          ),
          child: Text(
            _generateAIReport(),
            style: TextStyle(
              color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),

        SizedBox(height: 20),

        // Overall Score - Updated Design
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkTheme ? Color(0xFF2a2a2a) : Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkTheme ? Color(0xFF404040) : Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Overall Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              SizedBox(height: 12),
              Text(
                '${_analysisResult!['overallScore']}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 12),
              // Progress Bar - Only Green
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _analysisResult!['overallScore'] / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Key Metrics Section
        Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 16),

        // Key Metrics Grid
        _buildMetricItem(
          title: 'Body Weight',
          value: '${_analysisResult!['bodyWeight'].toStringAsFixed(1)}',
          unit: 'kg',
          isDarkTheme: isDarkTheme,
        ),
        _buildMetricItem(
          title: 'BMI',
          value: '${_analysisResult!['bmi'].toStringAsFixed(1)}',
          unit: '',
          isDarkTheme: isDarkTheme,
        ),
        _buildMetricItem(
          title: 'Body Fat',
          value: '${_analysisResult!['bodyFat'].toStringAsFixed(1)}',
          unit: '%',
          isDarkTheme: isDarkTheme,
        ),
        _buildMetricItem(
          title: 'Skeletal Muscle',
          value: '${_analysisResult!['skeletalMuscle'].toStringAsFixed(1)}',
          unit: 'kg',
          isDarkTheme: isDarkTheme,
        ),
        _buildMetricItem(
          title: 'Visceral Fat',
          value: '${_analysisResult!['visceralFat']}',
          unit: 'level',
          isDarkTheme: isDarkTheme,
        ),

        SizedBox(height: 20),

        // Show All Metrics Button
        GestureDetector(
          onTap: () => setState(() => _showAllMetrics = !_showAllMetrics),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: (isDarkTheme
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary)
                    .withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _showAllMetrics ? 'Show Less' : 'Show All 17 Metrics',
                  style: TextStyle(
                    color: isDarkTheme
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  _showAllMetrics
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isDarkTheme
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                ),
              ],
            ),
          ),
        ),

        // Additional Metrics (shown when expanded)
        if (_showAllMetrics) ...[
          SizedBox(height: 20),
          Text(
            'Mass Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildMetricItem(
            title: 'Body Fat Mass',
            value: '${_analysisResult!['bodyFatMass'].toStringAsFixed(1)}',
            unit: 'kg',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            title: 'Lean Mass',
            value: '${_analysisResult!['leanMass'].toStringAsFixed(1)}',
            unit: 'kg',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            title: 'Muscle Mass',
            value: '${_analysisResult!['muscleMass'].toStringAsFixed(1)}',
            unit: 'kg',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            title: 'Bone Mass',
            value: '${_analysisResult!['boneMass'].toStringAsFixed(1)}',
            unit: 'kg',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItemWithDescription(
            title: 'Water Mass',
            value: '${_analysisResult!['waterMass'].toStringAsFixed(1)}',
            unit: 'kg',
            description: 'The total weight of water in your body.',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            title: 'Protein Mass',
            value: '${_analysisResult!['proteinMass'].toStringAsFixed(1)}',
            unit: 'kg',
            isDarkTheme: isDarkTheme,
          ),

          SizedBox(height: 20),
          Text(
            'Other Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildMetricItem(
            title: 'BMR',
            value: '${_analysisResult!['bmr'].toStringAsFixed(0)}',
            unit: 'kcal/day',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            title: 'Metabolic Age',
            value: '${_analysisResult!['metabolicAge']}',
            unit: 'years',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            title: 'Subcutaneous Fat',
            value: '${_analysisResult!['subcutaneousFat'].toStringAsFixed(1)}',
            unit: '%',
            isDarkTheme: isDarkTheme,
          ),
          _buildMetricItem(
            title: 'Body Water',
            value: '${_analysisResult!['bodyWater'].toStringAsFixed(1)}',
            unit: '%',
            isDarkTheme: isDarkTheme,
          ),
        ],

        SizedBox(height: 20),

        // Calculate New Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _analysisResult = null;
                _aiRecommendation = null;
                _showAllMetrics = false;
                _ageController.clear();
                _weightController.clear();
                _heightController.clear();
                _feetController.clear();
                _inchesController.clear();
                _selectedGender = '';
                _selectedActivityLevel = '';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkTheme
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text(
                  'Calculate New',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMetricItemWithDescription({
  required String title,
  required String value,
  required String unit,
  required String description,
  required bool isDarkTheme,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDarkTheme ? Color(0xFF1a1a1a) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isDarkTheme ? Color(0xFF333333) : Color(0xFFE0E0E0),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  SizedBox(width: 2),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget buildAIRecommendationSection(bool isDarkTheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoadingRecommendation ? null : _getAIRecommendation,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkTheme
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
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
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('AI Generating Recommendations...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 8),
                      Text(
                        'Get AI Health Recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_aiRecommendation != null) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(20),
            decoration: getCardDecoration(isDarkTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      color: isDarkTheme
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI Health Coach',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Color(0xFF2a2a2a) : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkTheme
                          ? Color(0xFF404040)
                          : Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    _aiRecommendation!,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkTheme = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkTheme ? Color(0xFF121212) : Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: isDarkTheme ? Color(0xFF1a1a1a) : Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: isDarkTheme
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Body Analyzer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Input Form
                if (_analysisResult == null)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: getCardDecoration(isDarkTheme),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: isDarkTheme
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Body Analysis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkTheme
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Get comprehensive body composition analysis using AI-powered algorithms.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkTheme
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 24),

                          buildInputField(
                            label: 'Age',
                            controller: _ageController,
                            placeholder: 'Enter your age',
                            isDarkTheme: isDarkTheme,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your age';
                              final age = int.tryParse(value);
                              if (age == null || age < 10 || age > 120)
                                return 'Please enter a valid age (10-120)';
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          buildDropdownField(
                            value: _selectedGender.isEmpty
                                ? null
                                : _selectedGender,
                            label: 'Gender',
                            options: _genderOptions,
                            isDarkTheme: isDarkTheme,
                            onChanged: (value) =>
                                setState(() => _selectedGender = value ?? ''),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select your gender'
                                : null,
                          ),
                          SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: buildInputField(
                                  label: 'Weight',
                                  controller: _weightController,
                                  placeholder: 'Enter weight',
                                  isDarkTheme: isDarkTheme,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Required';
                                    final weight = double.tryParse(value);
                                    if (weight == null || weight <= 0)
                                      return 'Invalid weight';
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: buildDropdownField(
                                  value: _selectedUnit,
                                  label: 'Unit',
                                  options: _unitOptions,
                                  isDarkTheme: isDarkTheme,
                                  onChanged: (value) => setState(
                                    () => _selectedUnit = value ?? 'kg',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          buildDropdownField(
                            value: _selectedHeightUnit,
                            label: 'Height Unit',
                            options: _heightUnits,
                            isDarkTheme: isDarkTheme,
                            onChanged: (value) => setState(
                              () => _selectedHeightUnit = value ?? 'cm',
                            ),
                          ),
                          SizedBox(height: 12),

                          if (_selectedHeightUnit == 'cm')
                            buildInputField(
                              label: 'Height (cm)',
                              controller: _heightController,
                              placeholder: 'Enter height in cm',
                              isDarkTheme: isDarkTheme,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your height';
                                final height = double.tryParse(value);
                                if (height == null ||
                                    height < 100 ||
                                    height > 250)
                                  return 'Please enter valid height (100-250 cm)';
                                return null;
                              },
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: buildInputField(
                                    label: 'Feet',
                                    controller: _feetController,
                                    placeholder: 'ft',
                                    isDarkTheme: isDarkTheme,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Required';
                                      final feet = double.tryParse(value);
                                      if (feet == null || feet < 3 || feet > 8)
                                        return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: buildInputField(
                                    label: 'Inches',
                                    controller: _inchesController,
                                    placeholder: 'in',
                                    isDarkTheme: isDarkTheme,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Required';
                                      final inches = double.tryParse(value);
                                      if (inches == null ||
                                          inches < 0 ||
                                          inches >= 12)
                                        return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                          SizedBox(height: 16),

                          buildDropdownField(
                            value: _selectedActivityLevel.isEmpty
                                ? null
                                : _selectedActivityLevel,
                            label: 'Activity Level',
                            options: _activityLevels,
                            isDarkTheme: isDarkTheme,
                            isExpanded: true,
                            onChanged: (value) => setState(
                              () => _selectedActivityLevel = value ?? '',
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select activity level'
                                : null,
                          ),
                          SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAnalyzing
                                  ? null
                                  : _analyzeBodyComposition,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkTheme
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: _isAnalyzing
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Analyzing...'),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.analytics),
                                        SizedBox(width: 8),
                                        Text(
                                          'Analyze Body Composition',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Recent Analyses Section
                SizedBox(height: 16),
                buildRecentAnalysesSection(isDarkTheme),

                // Results Display
                if (_analysisResult != null) ...[
                  SizedBox(height: 16),
                  buildResultsDisplay(isDarkTheme),
                  SizedBox(height: 16),
                  buildAIRecommendationSection(isDarkTheme),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
