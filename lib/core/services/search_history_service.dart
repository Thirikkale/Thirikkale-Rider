import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _searchHistoryKey = 'location_search_history';
  static const int _maxHistoryItems = 10;

  /// Add a search item to history
  static Future<void> addToHistory(Map<String, dynamic> location) async {
    try {
      final prefs = SharedPreferencesAsync();
      
      // Get existing history
      final history = await getSearchHistory();
      
      // Remove if already exists (to avoid duplicates and move to top)
      final locationId = location['place_id'] ?? location['description'];
      history.removeWhere((item) => 
        (item['place_id'] ?? item['description']) == locationId);
      
      // Add to beginning of list
      history.insert(0, {
        'description': location['description'] ?? location['formatted_address'] ?? 'Unknown Location',
        'place_id': location['place_id'],
        'geometry': location['geometry'],
        'structured_formatting': location['structured_formatting'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Keep only the most recent items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }
      
      // Save back to preferences
      await prefs.setString(_searchHistoryKey, jsonEncode(history));
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  /// Get search history
  static Future<List<Map<String, dynamic>>> getSearchHistory() async {
    try {
      final prefs = SharedPreferencesAsync();
      final historyString = await prefs.getString(_searchHistoryKey);
      
      if (historyString != null) {
        final List<dynamic> historyJson = jsonDecode(historyString);
        return historyJson.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error getting search history: $e');
    }
    
    return [];
  }

  /// Clear all search history
  static Future<void> clearHistory() async {
    try {
      final prefs = SharedPreferencesAsync();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Remove specific item from history
  static Future<void> removeFromHistory(String locationId) async {
    try {
      final prefs = SharedPreferencesAsync();
      final history = await getSearchHistory();
      
      history.removeWhere((item) => 
        (item['place_id'] ?? item['description']) == locationId);
      
      await prefs.setString(_searchHistoryKey, jsonEncode(history));
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }

  /// Get recent searches with fallback to popular locations
  static Future<List<Map<String, dynamic>>> getRecentSearchesWithFallback() async {
    final history = await getSearchHistory();
    
    // Only return actual search history, no dummy fallback data
    return history;
  }
}
