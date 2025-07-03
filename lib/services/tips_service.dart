import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/tip_model.dart';

class TipsService {
  // Using API-Ninjas for quotes (requires API key)
  // Note: In a real app, you would store this API key securely
  
  // General quotes (no category - works with free API key)
  static const String _quotes_url = 'https://api.api-ninjas.com/v1/quotes';
  
  // API key for API-Ninjas
  static const String _api_key = 'ryjVRHVKw5S4yz7Gi6ekqQ==aE4eBop9bvLEHHQj'; // User's API key
  
  // Fetch eco-friendly tips from API-Ninjas
  Future<List<Tip>> fetchTips() async {
    try {
      developer.log('Attempting to fetch quotes from API-Ninjas');
      
      // Try to get quotes from API-Ninjas
      final response = await http.get(
        Uri.parse(_quotes_url),
        headers: {
          'X-Api-Key': _api_key,
          'Content-Type': 'application/json',
        },
      );
      
      developer.log('API response status: ${response.statusCode}');
      developer.log('API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        developer.log('API parsed data: $jsonData');
        
        // If we got quotes from API-Ninjas, use them
        if (jsonData.isNotEmpty) {
          developer.log('Successfully received quotes');
          final List<Tip> apiTips = jsonData.map((json) => Tip.fromJson({
            'quote': json['quote'],
            'author': json['author'] ?? 'Unknown',
          })).toList();
          
          // Add custom eco tips
          final List<Tip> allTips = [...apiTips, ..._getCustomEcoTips()];
          allTips.shuffle();
          return allTips;
        } else {
          developer.log('API returned empty data');
        }
      } else {
        developer.log('API request failed with status: ${response.statusCode}');
      }
      
      // If all API calls fail, return custom tips
      developer.log('All API calls failed or returned empty, using custom tips');
      return _getCustomEcoTips();
    } catch (e) {
      // Return custom tips if any error occurs
      developer.log('Error fetching tips: $e');
      return _getCustomEcoTips();
    }
  }
  
  // This method has been replaced by the fetchTips method above
  // which now uses API-Ninjas directly
  
  // Fallback method to get custom eco-friendly tips
  List<Tip> _getCustomEcoTips() {
    return [
      Tip(text: "Choose public transportation over driving alone to reduce your carbon footprint.", author: "EcoCal"),
      Tip(text: "Walking or cycling for short trips not only reduces emissions but improves your health.", author: "EcoCal"),
      Tip(text: "Carpooling can reduce emissions by up to 75% compared to driving alone.", author: "EcoCal"),
      Tip(text: "Maintain proper tire pressure to improve fuel efficiency and reduce emissions.", author: "EcoCal"),
      Tip(text: "Consider an electric or hybrid vehicle for your next car purchase.", author: "EcoCal"),
      Tip(text: "Plan and combine multiple errands into one trip to save fuel and time.", author: "EcoCal"),
      Tip(text: "Use video conferencing instead of traveling for meetings when possible.", author: "EcoCal"),
      Tip(text: "Avoid idling your vehicle for more than 10 seconds to save fuel and reduce pollution.", author: "EcoCal"),
      Tip(text: "Remove unnecessary weight from your vehicle to improve fuel efficiency.", author: "EcoCal"),
      Tip(text: "Consider using ride-sharing services instead of owning a car in urban areas.", author: "EcoCal"),
      Tip(text: "Driving at a steady pace can improve fuel efficiency by up to 30%.", author: "EcoCal"),
      Tip(text: "Regular vehicle maintenance can improve fuel efficiency and reduce emissions.", author: "EcoCal"),
      Tip(text: "Consider telecommuting or working from home when possible to reduce commuting emissions.", author: "EcoCal"),
      Tip(text: "Use cruise control on highways to maintain a constant speed and save fuel.", author: "EcoCal"),
      Tip(text: "Choose direct flights when possible as takeoffs and landings use the most fuel.", author: "EcoCal"),
    ];
  }
}
