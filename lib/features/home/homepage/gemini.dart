import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Gemini {
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  String get apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
    return key;
  }

  Future<String> analyzeNutritionFromImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final prompt = """
      Analyze this food image and provide detailed nutrition information. Please include:

      🥗 FOOD IDENTIFICATION:
      - Name of the food item(s)
      - Main ingredients visible
      - Estimated portion size

      📊 NUTRITIONAL BREAKDOWN (per serving):
      - Calories (kcal)
      - Protein (g)
      - Carbohydrates (g)
      - Fat (g)
      - Fiber (g)
      - Sugar (g)
      - Sodium (mg)

      🏷️ NUTRITIONAL HIGHLIGHTS:
      - Key vitamins and minerals
      - Health benefits
      - Dietary considerations (vegan, gluten-free, etc.)

      ⚠️ HEALTH NOTES:
      - Any potential allergens
      - Preparation method impact on nutrition
      - Suggestions for healthier alternatives if applicable

      Please provide accurate estimates based on standard nutritional data. If exact values cannot be determined, provide reasonable ranges and mention the uncertainty.
      """;

      return await _callGeminiVision(prompt, base64Image);
    } catch (e) {
      throw Exception('Failed to analyze nutrition: $e');
    }
  }

  Future<String> describeFoodFromImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final prompt = """
      Describe this food image in detail. Please provide:

      🍽️ FOOD DESCRIPTION:
      - What food items are visible?
      - Cooking method and preparation style
      - Visual appearance (color, texture, presentation)
      - Estimated portion size

      🌍 CULINARY CONTEXT:
      - Cuisine type or origin
      - Traditional or modern preparation
      - Common serving occasions

      👨‍🍳 PREPARATION INSIGHTS:
      - Likely cooking techniques used
      - Key ingredients and seasonings
      - Cooking time estimation

      😋 TASTE AND TEXTURE PROFILE:
      - Expected flavors (sweet, salty, spicy, etc.)
      - Texture description
      - Aroma characteristics

      🥘 SERVING SUGGESTIONS:
      - Best accompaniments
      - Beverage pairings
      - Ideal eating temperature

      📖 INTERESTING FACTS:
      - Cultural significance if applicable
      - Nutritional highlights
      - Recipe tips or variations

      Please be descriptive and engaging, as if you're a food enthusiast sharing knowledge about the dish.
      """;

      return await _callGeminiVision(prompt, base64Image);
    } catch (e) {
      throw Exception('Failed to describe food: $e');
    }
  }

  Future<String> _callGeminiVision(String prompt, String base64Image) async {
    final url = Uri.parse('$baseUrl/gemini-1.5-flash:generateContent?key=$apiKey');
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          
          return responseData['candidates'][0]['content']['parts'][0]['text'] ?? 
                 'No response generated';
        } else {
          throw Exception('Invalid response format from Gemini API');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception('API Error (${response.statusCode}): ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Please check your internet connection');
      }
      rethrow;
    }
  }

  // Alternative method for text-only requests (if needed)
  Future<String> generateTextResponse(String prompt) async {
    final url = Uri.parse('$baseUrl/gemini-1.5-flash:generateContent?key=$apiKey');
    
    final requestBody = {
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
        'maxOutputTokens': 1024,
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['candidates'][0]['content']['parts'][0]['text'] ?? 
               'No response generated';
      } else {
        final errorData = json.decode(response.body);
        throw Exception('API Error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to generate response: $e');
    }
  }
}