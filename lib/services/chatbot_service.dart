// Chatbot service for AI interactions
// Integrates with OpenAI API or Dialogflow

class ChatbotService {
  // TODO: Add your API key
  static const String _apiKey = 'YOUR_OPENAI_API_KEY';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Send message to chatbot and get response
  /// userType: 'farmer' or 'processor'
  Future<String> sendMessage({
    required String message,
    required String userType,
  }) async {
    try {
      // TODO: Implement actual API call
      // Example using OpenAI API:
      //
      // final response = await http.post(
      //   Uri.parse(_apiUrl),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $_apiKey',
      //   },
      //   body: jsonEncode({
      //     'model': 'gpt-3.5-turbo',
      //     'messages': [
      //       {
      //         'role': 'system',
      //         'content': _getSystemPrompt(userType),
      //       },
      //       {
      //         'role': 'user',
      //         'content': message,
      //       },
      //     ],
      //     'max_tokens': 500,
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return data['choices'][0]['message']['content'];
      // }

      // For now, return mock response
      return _getMockResponse(message, userType);
    } catch (e) {
      throw Exception('Error communicating with chatbot: $e');
    }
  }

  /// Get system prompt based on user type
  String _getSystemPrompt(String userType) {
    if (userType == 'farmer') {
      return '''
You are an agricultural waste management assistant helping farmers.
Provide guidance on:
- How to prepare compost and organic fertilizer
- Best practices for waste storage
- Tips for selling agricultural waste
- Sustainable farming practices
Keep responses concise and practical.
''';
    } else {
      return '''
You are a fertilizer processing mentor helping processors.
Provide guidance on:
- Fertilizer production techniques
- Input-output calculations
- Quality control standards
- Market pricing strategies
- Business optimization
Keep responses concise and data-driven.
''';
    }
  }

  /// Mock response for testing (replace with actual API)
  String _getMockResponse(String message, String userType) {
    final lowerMessage = message.toLowerCase();

    if (userType == 'farmer') {
      if (lowerMessage.contains('compost') || lowerMessage.contains('fertilizer')) {
        return "To make compost:\n1. Collect crop residue\n2. Add water for moisture\n3. Turn every 2-3 days\n4. Add cow dung\n5. Ready in 45-60 days";
      } else {
        return "I can help with composting, waste management, and selling tips. What would you like to know?";
      }
    } else {
      if (lowerMessage.contains('production') || lowerMessage.contains('process')) {
        return "Vermicompost Production:\n• Input: 100kg waste\n• Output: 60kg fertilizer\n• Time: 45-60 days\n• ROI: ~150%";
      } else {
        return "I can help with production planning, pricing, and quality control. What would you like to know?";
      }
    }
  }

  /// Get fertilizer making guide
  Future<String> getFertilizerGuide(String wasteType) async {
    return '''
Guide for processing $wasteType:

1. Collection & Sorting
   - Collect fresh waste
   - Remove contaminants

2. Decomposition
   - Add moisture (60-70%)
   - Maintain temperature
   - Turn regularly

3. Maturation
   - Let it cure for 2-3 weeks
   - Check pH levels

4. Quality Check
   - Dark brown color
   - Earthy smell
   - Crumbly texture

Ready to sell in 45-60 days!
''';
  }

  /// Get pricing recommendation
  Future<Map<String, dynamic>> getPricingRecommendation(String fertilizerType) async {
    // Mock data - replace with actual market analysis
    final prices = {
      'Compost': {'min': 15, 'max': 25, 'avg': 20},
      'Vermicompost': {'min': 20, 'max': 30, 'avg': 25},
      'Bio-fertilizer': {'min': 35, 'max': 50, 'avg': 42},
      'Organic Manure': {'min': 10, 'max': 20, 'avg': 15},
    };

    return prices[fertilizerType] ?? {'min': 10, 'max': 30, 'avg': 20};
  }
}
