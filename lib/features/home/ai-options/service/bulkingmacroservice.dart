class BulkingMacrosService {
  static Future<Map<String, dynamic>?> calculateBulkingMacros({
    required String gender,
    required double weight,
    required double height,
    required int age,
    required String activityLevel,
    required double targetGain,
    required int timeframe,
    Map<String, dynamic>? userProfile,
  }) async {
    try {
      double bmr = _calculateBMR(gender, weight, height, age);

      double tdee = _calculateTDEE(bmr, activityLevel);

      double weeklyGainTarget = targetGain / timeframe;
      double dailyCaloricSurplus = _calculateCaloricSurplus(weeklyGainTarget);

      double totalCalories = tdee + dailyCaloricSurplus;

      Map<String, dynamic> macros = _calculateMacros(
        totalCalories,
        weight,
        gender,
        activityLevel,
      );

      List<String> recommendations = _generateRecommendations(
        gender,
        weight,
        targetGain,
        timeframe,
        weeklyGainTarget,
      );

      List<Map<String, String>> mealTiming = _generateMealTiming();

      return {
        'bmr': bmr.round(),
        'tdee': tdee.round(),
        'surplus': dailyCaloricSurplus.round(),
        'calories': totalCalories.round(),
        'protein': macros['protein'].round(),
        'carbs': macros['carbs'].round(),
        'fat': macros['fat'].round(),
        'weeklyGainRate': weeklyGainTarget.toStringAsFixed(2),
        'recommendations': recommendations,
        'mealTiming': mealTiming,
        'calculatedAt': DateTime.now(),
        'userInput': {
          'gender': gender,
          'weight': weight,
          'height': height,
          'age': age,
          'activityLevel': activityLevel,
          'targetGain': targetGain,
          'timeframe': timeframe,
        },
      };
    } catch (e) {
      print('Error calculating bulking macros: $e');
      return null;
    }
  }

  static double _calculateBMR(
    String gender,
    double weight,
    double height,
    int age,
  ) {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  static double _calculateTDEE(double bmr, String activityLevel) {
    final activityMultipliers = {
      'Sedentary (desk job, no exercise)': 1.2,
      'Lightly Active (light exercise 1-3 days/week)': 1.375,
      'Moderately Active (moderate exercise 3-5 days/week)': 1.55,
      'Very Active (hard exercise 6-7 days/week)': 1.725,
      'Super Active (very hard exercise, physical job)': 1.9,
    };

    double multiplier = activityMultipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  static double _calculateCaloricSurplus(double weeklyGainTarget) {
    return (weeklyGainTarget * 7000) / 7;
  }

  static Map<String, double> _calculateMacros(
    double totalCalories,
    double weight,
    String gender,
    String activityLevel,
  ) {
    double proteinGrams = weight * 2.0;
    double proteinCalories = proteinGrams * 4;

    double fatCalories = totalCalories * 0.25;
    double fatGrams = fatCalories / 9;

    double remainingCalories = totalCalories - proteinCalories - fatCalories;
    double carbGrams = remainingCalories / 4;

    return {'protein': proteinGrams, 'carbs': carbGrams, 'fat': fatGrams};
  }

  static List<String> _generateRecommendations(
    String gender,
    double weight,
    double targetGain,
    int timeframe,
    double weeklyGainTarget,
  ) {
    List<String> recommendations = [];

    recommendations.add(
      'Aim for 2.0g of protein per kg of body weight to support muscle growth and recovery.',
    );

    if (weeklyGainTarget > 0.5) {
      recommendations.add(
        'Your weekly gain target of ${weeklyGainTarget.toStringAsFixed(2)}kg/week is aggressive. Consider aiming for 0.25-0.5kg/week for lean muscle gains.',
      );
    } else if (weeklyGainTarget < 0.25) {
      recommendations.add(
        'Your weekly gain target is conservative. You may see slower progress but will minimize fat gain.',
      );
    }

    recommendations.add(
      'Spread your protein intake across 4-6 meals throughout the day for optimal muscle protein synthesis.',
    );

    recommendations.add(
      'Drink at least 3-4 liters of water daily to support metabolism and muscle function.',
    );

    recommendations.add(
      'Combine this nutrition plan with a progressive overload strength training program for best results.',
    );

    recommendations.add(
      'Ensure 7-9 hours of quality sleep nightly for optimal recovery and hormone regulation.',
    );

    return recommendations;
  }

  static List<Map<String, String>> _generateMealTiming() {
    return [
      {
        'time': '7:00 AM',
        'description': 'Breakfast: High-protein meal with complex carbs',
      },
      {
        'time': '10:00 AM',
        'description': 'Mid-morning snack: Protein shake or Greek yogurt',
      },
      {
        'time': '1:00 PM',
        'description':
            'Lunch: Balanced meal with protein, carbs, and healthy fats',
      },
      {
        'time': '4:00 PM',
        'description': 'Pre-workout: Light snack with fast-digesting carbs',
      },
      {
        'time': '6:00 PM',
        'description': 'Post-workout: Protein-rich meal with simple carbs',
      },
      {
        'time': '9:00 PM',
        'description': 'Dinner: Protein with vegetables and healthy fats',
      },
    ];
  }

  static String generateBulkingPlanText(Map<String, dynamic> results) {
    final buffer = StringBuffer();

    buffer.writeln('=== AI BULKING MACRO PLAN ===');
    buffer.writeln('Generated: ${results['calculatedAt']}');
    buffer.writeln();

    buffer.writeln('DAILY MACRO TARGETS:');
    buffer.writeln('Calories: ${results['calories']} cal');
    buffer.writeln('Protein: ${results['protein']}g');
    buffer.writeln('Carbs: ${results['carbs']}g');
    buffer.writeln('Fat: ${results['fat']}g');
    buffer.writeln();

    buffer.writeln('METABOLIC INFORMATION:');
    buffer.writeln('BMR: ${results['bmr']} calories/day');
    buffer.writeln('TDEE: ${results['tdee']} calories/day');
    buffer.writeln('Caloric Surplus: ${results['surplus']} calories/day');
    buffer.writeln(
      'Expected Weekly Gain: ${results['weeklyGainRate']} kg/week',
    );
    buffer.writeln();

    buffer.writeln('USER INPUT:');
    final userInput = results['userInput'] as Map<String, dynamic>;
    buffer.writeln('Gender: ${userInput['gender']}');
    buffer.writeln('Weight: ${userInput['weight']}kg');
    buffer.writeln('Height: ${userInput['height']}cm');
    buffer.writeln('Age: ${userInput['age']} years');
    buffer.writeln('Activity Level: ${userInput['activityLevel']}');
    buffer.writeln(
      'Target Gain: ${userInput['targetGain']}kg in ${userInput['timeframe']} weeks',
    );
    buffer.writeln();

    buffer.writeln('AI RECOMMENDATIONS:');
    final recommendations = results['recommendations'] as List<String>;
    for (int i = 0; i < recommendations.length; i++) {
      buffer.writeln('${i + 1}. ${recommendations[i]}');
    }
    buffer.writeln();

    buffer.writeln('SUGGESTED MEAL TIMING:');
    final mealTiming = results['mealTiming'] as List<Map<String, String>>;
    for (final meal in mealTiming) {
      buffer.writeln('${meal['time']}: ${meal['description']}');
    }
    buffer.writeln();

    buffer.writeln('=== IMPORTANT NOTES ===');
    buffer.writeln('- Adjust portions based on hunger and progress');
    buffer.writeln('- Weigh yourself weekly and adjust calories if needed');
    buffer.writeln('- Focus on whole foods and quality nutrition');
    buffer.writeln('- Stay consistent with both diet and training');

    return buffer.toString();
  }

  static Future<void> saveBulkingPlan(Map<String, dynamic> plan) async {
    try {
      print('Bulking plan saved: $plan');
    } catch (e) {
      print('Error saving bulking plan: $e');
    }
  }

  static Future<Map<String, dynamic>?> getSavedBulkingPlan() async {
    try {
      return null;
    } catch (e) {
      print('Error loading saved bulking plan: $e');
      return null;
    }
  }
}
