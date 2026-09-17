import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../models/grocery_item.dart';
import 'recipe_database.dart';

class StorageService {
  static const String _savedKey = 'cooksy_saved_recipes_v1';
  static const String _groceryKey = 'cooksy_grocery_list_v1';
  static const String _apiKeyKey = 'cooksy_gemini_api_key';

  static Future<List<Recipe>> getSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_savedKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      // Seed initial default favorites
      final initial = [
        RecipeDatabase.initialRecipes[0], // Chicken Adobo
        RecipeDatabase.initialRecipes[1], // Sinangag
        RecipeDatabase.initialRecipes[2], // Garlic Butter Chicken
      ];
      await saveSavedRecipes(initial);
      return initial;
    }
    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveSavedRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await prefs.setString(_savedKey, jsonStr);
  }

  static Future<List<GroceryItem>> getGroceryList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_groceryKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((e) => GroceryItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveGroceryList(List<GroceryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_groceryKey, jsonStr);
  }

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }
}
