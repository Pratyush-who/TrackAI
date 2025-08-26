import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackai/core/constants/appcolors.dart';
import 'package:trackai/core/themes/theme_provider.dart';
import 'package:trackai/features/home/ai-options/service/filedownload.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Mealplanner extends StatefulWidget {
  const Mealplanner({Key? key}) : super(key: key);

  @override
  _MealplannerState createState() => _MealplannerState();
}

class _MealplannerState extends State<Mealplanner> {
  bool isLoading = false;
  bool isLoadingRecentPlans = false;
  Map<String, dynamic>? mealPlan;
  List<Map<String, dynamic>> recentPlans = [];
  bool isRecentPlansExpanded = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController caloriesController = TextEditingController(
    text: '2000',
  );
  final TextEditingController cuisineController = TextEditingController();
  final TextEditingController healthConditionsController =
      TextEditingController();
  final TextEditingController restrictionsController = TextEditingController();
  final TextEditingController preferencesController = TextEditingController();

  String selectedDays = '7 Days';
  String selectedDietType = 'Any / No Specific Diet';

  final List<String> dayOptions = [
    '3 Days',
    '5 Days',
    '7 Days',
    '14 Days',
    '30 Days',
  ];
  final List<String> dietOptions = [
    'Any / No Specific Diet',
    'Keto',
    'Paleo',
    'Vegan',
    'Vegetarian',
    'Mediterranean',
    'Low Carb',
    'Intermittent Fasting',
    'DASH Diet',
    'Whole30',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentPlans();
    isRecentPlansExpanded = false;
  }

  String _generatePlanHash(Map<String, String> planParams) {
    String paramString =
        '${planParams['calories']}_${planParams['days']}_${planParams['dietType']}_${planParams['cuisine']}_${planParams['healthConditions']}_${planParams['restrictions']}_${planParams['preferences']}';
    var bytes = utf8.encode(paramString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  
Future<Map<String, dynamic>?> _generateMealPlanWithGemini() async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env file');
    }

    final numDays = int.parse(selectedDays.split(' ')[0]);
    final targetCalories = caloriesController.text.trim();
    final dietType = selectedDietType;
    final cuisine = cuisineController.text.trim();
    final healthConditions = healthConditionsController.text.trim();
    final restrictions = restrictionsController.text.trim();
    final preferences = preferencesController.text.trim();

    // Construct the prompt
    String prompt = '''
Create a detailed ${numDays}-day meal plan with the following specifications:

**Requirements:**
- Daily calorie target: ${targetCalories} kcal
- Diet type: ${dietType}
${cuisine.isNotEmpty ? '- Cuisine preference: ${cuisine}' : ''}
${healthConditions.isNotEmpty ? '- Health conditions: ${healthConditions}' : ''}
${restrictions.isNotEmpty ? '- Dietary restrictions: ${restrictions}' : ''}
${preferences.isNotEmpty ? '- Food preferences: ${preferences}' : ''}

**Response Format (JSON only):**
{
  "Day 1": {
    "breakfast": {
      "name": "Meal name",
      "calories": 350,
      "recipe": "Detailed cooking instructions"
    },
    "lunch": {
      "name": "Meal name",
      "calories": 550,
      "recipe": "Detailed cooking instructions"
    },
    "dinner": {
      "name": "Meal name",
      "calories": 700,
      "recipe": "Detailed cooking instructions"
    },
    "snacks": {
      "name": "Snack name",
      "calories": 400,
      "recipe": "Preparation instructions"
    },
    "totalCalories": 2000
  },
  ... (continue for all ${numDays} days),
  "planSummary": {
    "totalDays": ${numDays},
    "avgDailyCalories": 2000,
    "totalCalories": ${numDays * int.parse(targetCalories)},
    "dietType": "${dietType}",
    "generatedOn": "${DateTime.now().toString().split(' ')[0]}"
  }
}

**Important Guidelines:**
1. Each meal should have realistic calorie counts that add up to the daily target
2. Provide detailed, actionable recipes with cooking instructions
3. Ensure meals are varied and nutritionally balanced
4. Consider the specified diet type and restrictions
5. Make recipes practical for home cooking
6. Include preparation time considerations
7. Return ONLY valid JSON, no additional text or formatting
''';

    // Updated API endpoint - this is the key fix
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${apiKey}',
    );

    print('Making API request to: ${url}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 8192,
        }
      }),
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode != 200) {
      // More detailed error handling
      Map<String, dynamic>? errorData;
      try {
        errorData = json.decode(response.body);
      } catch (e) {
        // If response body is not JSON
      }
      
      if (errorData != null && errorData.containsKey('error')) {
        final error = errorData['error'];
        throw Exception('Gemini API Error: ${error['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('Failed to generate meal plan: ${response.statusCode} - ${response.body}');
      }
    }

    final responseData = json.decode(response.body);
    
    if (responseData['candidates'] == null || 
        responseData['candidates'].isEmpty) {
      throw Exception('No meal plan generated by AI');
    }

    final generatedText = responseData['candidates'][0]['content']['parts'][0]['text'];
    
    print('Generated text: ${generatedText}');
    
    // Clean up the response text to extract JSON
    String cleanedText = generatedText.trim();
    
    // Remove any markdown code blocks if present
    if (cleanedText.startsWith('```json')) {
      cleanedText = cleanedText.substring(7);
    }
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText.substring(3);
    }
    if (cleanedText.endsWith('```')) {
      cleanedText = cleanedText.substring(0, cleanedText.length - 3);
    }
    
    cleanedText = cleanedText.trim();

    // Parse the JSON response
    final mealPlanData = json.decode(cleanedText) as Map<String, dynamic>;
    
    // Validate the structure
    if (!mealPlanData.containsKey('planSummary')) {
      throw Exception('Invalid meal plan structure: missing planSummary');
    }

    return mealPlanData;

  } catch (e) {
    print('Error generating meal plan with Gemini: $e');
    rethrow;
  }
}

  Future<void> _loadRecentPlans() async {
    if (_auth.currentUser == null) return;

    setState(() {
      isLoadingRecentPlans = true;
    });

    try {
      final userId = _auth.currentUser!.uid;
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealplans')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      setState(() {
        recentPlans = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'date': data['date'] ?? '',
            'calories': data['calories'] ?? '',
            'dietType': data['dietType'] ?? '',
            'days': data['days'] ?? '',
            'plan': data['plan'] ?? {},
            'createdAt': data['createdAt'],
            'planHash': data['planHash'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading recent plans: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading recent plans: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingRecentPlans = false;
      });
    }
  }

  Future<bool> _saveMealPlanToFirebase(Map<String, dynamic> plan) async {
    if (_auth.currentUser == null) return false;

    try {
      final userId = _auth.currentUser!.uid;
      final planParams = {
        'calories': caloriesController.text.trim(),
        'days': selectedDays,
        'dietType': selectedDietType,
        'cuisine': cuisineController.text.trim(),
        'healthConditions': healthConditionsController.text.trim(),
        'restrictions': restrictionsController.text.trim(),
        'preferences': preferencesController.text.trim(),
      };

      final planHash = _generatePlanHash(planParams);

      // Check if a similar plan already exists
      final existingPlans = await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealplans')
          .where('planHash', isEqualTo: planHash)
          .get();

      if (existingPlans.docs.isNotEmpty) {
        // Update existing plan with new timestamp
        final existingDoc = existingPlans.docs.first;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('mealplans')
            .doc(existingDoc.id)
            .update({
              'createdAt': FieldValue.serverTimestamp(),
              'date': DateTime.now().toString().split(' ')[0],
              'plan': plan, // Update with new AI-generated plan
            });
        return true;
      }

      // Create new plan
      final mealPlanData = {
        'title': '$selectedDays ${selectedDietType} Plan',
        'date': DateTime.now().toString().split(' ')[0],
        'calories': caloriesController.text.trim(),
        'dietType': selectedDietType,
        'days': selectedDays,
        'cuisine': cuisineController.text.trim(),
        'healthConditions': healthConditionsController.text.trim(),
        'restrictions': restrictionsController.text.trim(),
        'preferences': preferencesController.text.trim(),
        'plan': plan,
        'planHash': planHash,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealplans')
          .add(mealPlanData);

      return true;
    } catch (e) {
      print('Error saving meal plan to Firebase: $e');
      return false;
    }
  }

  Future<void> _deleteMealPlan(String planId) async {
    if (_auth.currentUser == null) return;

    try {
      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('mealplans')
          .doc(planId)
          .delete();

      setState(() {
        recentPlans.removeWhere((plan) => plan['id'] == planId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal plan deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting meal plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting meal plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  BoxDecoration getMealCardDecoration(bool isDarkTheme) {
    if (isDarkTheme) {
      return BoxDecoration(
        color: Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF404040), width: 1),
      );
    } else {
      return BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      );
    }
  }

  Future<void> generateMealPlan() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to generate meal plans'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Generate meal plan using Gemini AI
      final newPlan = await _generateMealPlanWithGemini();
      
      if (newPlan == null) {
        throw Exception('Failed to generate meal plan');
      }

      // Save to Firebase
      final saved = await _saveMealPlanToFirebase(newPlan);

      if (saved) {
        setState(() {
          mealPlan = newPlan;
        });

        // Reload recent plans to reflect the new/updated plan
        await _loadRecentPlans();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI-powered meal plan generated and saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save meal plan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating meal plan: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Optionally, you could fall back to a mock meal plan here
      print('Detailed error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadMealPlan() async {
    if (mealPlan == null) return;

    try {
      String content = _generateMealPlanContent();
      String planTitle = '${selectedDays}_${selectedDietType}_MealPlan';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
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
              Text('Downloading meal plan...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      Map<String, dynamic> result = await FileDownloadService.downloadMealPlan(
        content,
        planTitle,
      );

      await FileDownloadService.showDownloadResult(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading meal plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateMealPlanContent() {
    if (mealPlan == null) return '';

    String content = 'AI-POWERED PERSONALIZED MEAL PLAN\n';
    content += '=' * 50 + '\n\n';
    content += 'Generated on: ${DateTime.now().toString().split(' ')[0]}\n';
    content += 'Daily Calorie Goal: ${caloriesController.text} kcal\n';
    content += 'Plan Duration: $selectedDays\n';
    content += 'Diet Type: $selectedDietType\n';
    
    if (cuisineController.text.isNotEmpty) {
      content += 'Cuisine Preference: ${cuisineController.text}\n';
    }
    if (healthConditionsController.text.isNotEmpty) {
      content += 'Health Conditions: ${healthConditionsController.text}\n';
    }
    if (restrictionsController.text.isNotEmpty) {
      content += 'Dietary Restrictions: ${restrictionsController.text}\n';
    }
    if (preferencesController.text.isNotEmpty) {
      content += 'Food Preferences: ${preferencesController.text}\n';
    }
    
    content += '\n';

    final summary = mealPlan!['planSummary'] as Map<String, dynamic>;
    content += 'PLAN SUMMARY\n';
    content += '-' * 20 + '\n';
    content += 'Average Daily Calories: ${summary['avgDailyCalories']} kcal\n';
    content += 'Total Plan Calories: ${summary['totalCalories']} kcal\n\n';

    mealPlan!.forEach((day, meals) {
      if (day == 'planSummary') return;

      content += '${day.toUpperCase()}\n';
      content += '=' * (day.length + 10) + '\n';

      final dayMeals = meals as Map<String, dynamic>;

      ['breakfast', 'lunch', 'dinner', 'snacks'].forEach((mealType) {
        if (dayMeals.containsKey(mealType)) {
          final meal = dayMeals[mealType] as Map<String, dynamic>;

          content += '\n${mealType.toUpperCase()}\n';
          content += '${meal['name']} (${meal['calories']} kcal)\n';
          content += 'Recipe: ${meal['recipe']}\n';
        }
      });

      if (dayMeals.containsKey('totalCalories')) {
        content += '\nDaily Total: ${dayMeals['totalCalories']} kcal\n';
      }
      content += '\n' + '-' * 50 + '\n\n';
    });

    return content;
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    required bool isDarkTheme,
    int maxLines = 1,
    TextInputType? keyboardType,
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
                color: isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required isDarkTheme,
    required Function(String?) onChanged,
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
          isExpanded: true,
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
                color: isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
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
        ),
      ],
    );
  }

  Widget buildMealCard(String mealType, Map<String, dynamic> mealData, bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: getMealCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '${mealData['name']} (${mealData['calories']} kcal)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Recipe: ${mealData['recipe']}',
            style: TextStyle(
              fontSize: 13,
              color: isDarkTheme ? Colors.grey[300] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecentPlansSection(bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isRecentPlansExpanded = !isRecentPlansExpanded;
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
                    'Recent Meal Plans',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Container(
                  
                  child: IconButton(
                    icon: Icon(
                      isRecentPlansExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        isRecentPlansExpanded = !isRecentPlansExpanded;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isRecentPlansExpanded) ...[
            SizedBox(height: 16),
            if (isLoadingRecentPlans)
              Center(
                child: CircularProgressIndicator(
                  color: isDarkTheme
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                ),
              )
            else if (recentPlans.isNotEmpty) ...[
              ...recentPlans.take(5).map((plan) {
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
                              plan['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkTheme
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              '${plan['date']} • ${plan['calories']} kcal/day',
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
                            mealPlan = plan['plan'];
                            isRecentPlansExpanded = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: isDarkTheme
                                  ? Color(0xFF2a2a2a)
                                  : Colors.white,
                              title: Text(
                                'Delete Meal Plan',
                                style: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete this meal plan?',
                                style: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deleteMealPlan(plan['id']);
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
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
                  'No recent meal plans found. Generate your first AI-powered plan above!',
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

  Widget buildMealPlanDisplay(bool isDarkTheme) {
    if (mealPlan == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: getCardDecoration(isDarkTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI-Generated Meal Plan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.file_download,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: downloadMealPlan,
                ),
              ),
            ],
          ),

          if (mealPlan!.containsKey('planSummary')) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? AppColors.darkPrimary.withOpacity(0.1)
                    : AppColors.lightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary)
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Meal Plan Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${mealPlan!['planSummary']['totalDays']}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                          ),
                          Text(
                            'Days',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkTheme
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: (isDarkTheme
                            ? Colors.grey[600]
                            : Colors.grey[400]),
                      ),
                      Column(
                        children: [
                          Text(
                            '${mealPlan!['planSummary']['avgDailyCalories']}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                          ),
                          Text(
                            'Avg. Calories',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkTheme
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 20),

          ...mealPlan!.entries.where((entry) => entry.key != 'planSummary').map(
            (entry) {
              final day = entry.key;
              final meals = entry.value as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(20),
                decoration: getCardDecoration(isDarkTheme),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (meals.containsKey('totalCalories'))
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkTheme ? AppColors.darkPrimary.withOpacity(0.2) : AppColors.lightPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${meals['totalCalories']} kcal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),

                    ...['breakfast', 'lunch', 'dinner', 'snacks'].map((mealType) {
                      if (meals.containsKey(mealType)) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: buildMealCard(
                            mealType,
                            meals[mealType] as Map<String, dynamic>,
                            isDarkTheme,
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }).toList(),
                  ],
                ),
              );
            },
          ).toList(),
        ],
      ),
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
                  Icons.restaurant_menu,
                  color: isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'AI Meal Planner',
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
                // Form Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: getCardDecoration(isDarkTheme),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            color: isDarkTheme
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'AI Meal Planner',
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
                        'Generate personalized meal plans using advanced AI. Get detailed recipes and nutrition tailored to your needs.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkTheme
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Form Fields
                      buildInputField(
                        label: 'Daily Calorie Goal (kcal)',
                        controller: caloriesController,
                        isDarkTheme: isDarkTheme,
                        placeholder: '2000',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: buildDropdownField(
                              isDarkTheme: isDarkTheme,
                              label: 'Number of Days',
                              value: selectedDays,
                              options: dayOptions,
                              onChanged: (value) {
                                setState(() {
                                  selectedDays = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: buildDropdownField(
                              isDarkTheme: isDarkTheme,
                              label: 'Diet Type (Optional)',
                              value: selectedDietType,
                              options: dietOptions,
                              onChanged: (value) {
                                setState(() {
                                  selectedDietType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      buildInputField(
                        isDarkTheme: isDarkTheme,
                        label: 'Cuisine Preference (Optional)',
                        controller: cuisineController,
                        placeholder: 'E.g., Indian, Italian, Mexican',
                      ),
                      SizedBox(height: 16),

                      buildInputField(
                        isDarkTheme: isDarkTheme,
                        label: 'Health Conditions or Diseases (Optional)',
                        controller: healthConditionsController,
                        placeholder:
                            'E.g., high blood pressure, diabetes, PCOS',
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),

                      buildInputField(
                        isDarkTheme: isDarkTheme,
                        label: 'Other Dietary Restrictions (Optional)',
                        controller: restrictionsController,
                        placeholder: 'E.g., gluten-free, allergies to nuts',
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),

                      buildInputField(
                        isDarkTheme: isDarkTheme,
                        label: 'Food Preferences/Dislikes (Optional)',
                        controller: preferencesController,
                        placeholder:
                            'E.g., loves chicken, dislikes broccoli, prefers spicy food',
                        maxLines: 3,
                      ),

                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : generateMealPlan,
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
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    Text('AI Generating Your Plan...'),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome),
                                    SizedBox(width: 8),
                                    Text(
                                      'Generate AI Meal Plan',
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

                // Recent Plans Section
                SizedBox(height: 24),
                buildRecentPlansSection(isDarkTheme),

                // Meal Plan Display
                if (mealPlan != null) ...[
                  SizedBox(height: 24),
                  buildMealPlanDisplay(isDarkTheme),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}