import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/grocery_item.dart';
import '../services/recipe_database.dart';
import '../services/storage_service.dart';
import '../services/generator_service.dart';

class AppState extends ChangeNotifier {
  List<Recipe> _savedRecipes = [];
  List<GroceryItem> _groceryList = [];
  Recipe? _activeRecipe;
  int _currentServings = 4;
  int _currentTabIndex = 0;
  bool _isLoading = false;
  String? _geminiApiKey;

  List<Recipe> get savedRecipes => _savedRecipes;
  List<GroceryItem> get groceryList => _groceryList;
  Recipe? get activeRecipe => _activeRecipe;
  int get currentServings => _currentServings;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  String? get geminiApiKey => _geminiApiKey;

  int get unboughtGroceryCount => _groceryList.where((i) => !i.isChecked).length;

  AppState() {
    _initData();
  }

  Future<void> _initData() async {
    _savedRecipes = await StorageService.getSavedRecipes();
    _groceryList = await StorageService.getGroceryList();
    _geminiApiKey = await StorageService.getApiKey();

    if (_activeRecipe == null && RecipeDatabase.initialRecipes.isNotEmpty) {
      _activeRecipe = RecipeDatabase.initialRecipes[0];
      _currentServings = _activeRecipe!.servings;
    }
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setActiveRecipe(Recipe recipe) {
    _activeRecipe = recipe;
    _currentServings = recipe.servings;
    _currentTabIndex = 2; // Navigate to Recipe Details tab
    notifyListeners();
  }

  void setServings(int servings) {
    if (servings >= 1 && servings <= 16) {
      _currentServings = servings;
      notifyListeners();
    }
  }

  bool isRecipeSaved(String id) {
    return _savedRecipes.any((r) => r.id == id);
  }

  Future<void> toggleSaveRecipe(Recipe recipe) async {
    final existingIdx = _savedRecipes.indexWhere((r) => r.id == recipe.id);
    if (existingIdx >= 0) {
      _savedRecipes.removeAt(existingIdx);
    } else {
      _savedRecipes.insert(0, recipe);
    }
    await StorageService.saveSavedRecipes(_savedRecipes);
    notifyListeners();
  }

  Future<void> removeSavedRecipe(String id) async {
    _savedRecipes.removeWhere((r) => r.id == id);
    await StorageService.saveSavedRecipes(_savedRecipes);
    notifyListeners();
  }

  Future<void> clearAllSaved() async {
    _savedRecipes.clear();
    await StorageService.saveSavedRecipes(_savedRecipes);
    notifyListeners();
  }

  Future<void> addCustomRecipe(Recipe recipe) async {
    _savedRecipes.insert(0, recipe);
    await StorageService.saveSavedRecipes(_savedRecipes);
    setActiveRecipe(recipe);
    notifyListeners();
  }

  Future<void> remixActiveRecipe(String remixType) async {
    if (_activeRecipe == null) return;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _activeRecipe = GeneratorService.remixRecipe(_activeRecipe!, remixType);
    _currentServings = _activeRecipe!.servings;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addIngredientsToGrocery(Recipe recipe, double factor) async {
    for (final ing in recipe.ingredients) {
      final aisleInfo = GroceryItem.getAisleForIngredient(ing.name);
      final scaledAmt = ing.getScaledAmount(factor);

      final existingIdx = _groceryList.indexWhere(
        (i) => i.name.toLowerCase() == ing.name.toLowerCase() && !i.isChecked,
      );

      if (existingIdx >= 0) {
        final ex = _groceryList[existingIdx];
        _groceryList[existingIdx] = GroceryItem(
          id: ex.id,
          name: ex.name,
          amount: '${ex.amount.isNotEmpty ? '${ex.amount} + ' : ''}$scaledAmt',
          unit: ing.unit,
          aisleId: ex.aisleId,
          aisleName: ex.aisleName,
          aisleEmoji: ex.aisleEmoji,
          recipeTitle: recipe.title,
          isChecked: false,
        );
      } else {
        _groceryList.add(
          GroceryItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}_${ing.name.hashCode}',
            name: ing.name,
            amount: scaledAmt,
            unit: ing.unit,
            note: ing.note ?? '',
            aisleId: aisleInfo['id']!,
            aisleName: aisleInfo['name']!,
            aisleEmoji: aisleInfo['emoji']!,
            recipeTitle: recipe.title,
            isChecked: false,
          ),
        );
      }
    }
    await StorageService.saveGroceryList(_groceryList);
    notifyListeners();
  }

  Future<void> addQuickGroceryItem(String name) async {
    if (name.trim().isEmpty) return;
    final aisleInfo = GroceryItem.getAisleForIngredient(name);
    _groceryList.add(
      GroceryItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        amount: '1',
        unit: 'item',
        aisleId: aisleInfo['id']!,
        aisleName: aisleInfo['name']!,
        aisleEmoji: aisleInfo['emoji']!,
        recipeTitle: 'My Pantry',
        isChecked: false,
      ),
    );
    await StorageService.saveGroceryList(_groceryList);
    notifyListeners();
  }

  Future<void> toggleGroceryItem(String id) async {
    final idx = _groceryList.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      _groceryList[idx].isChecked = !_groceryList[idx].isChecked;
      await StorageService.saveGroceryList(_groceryList);
      notifyListeners();
    }
  }

  Future<void> removeGroceryItem(String id) async {
    _groceryList.removeWhere((i) => i.id == id);
    await StorageService.saveGroceryList(_groceryList);
    notifyListeners();
  }

  Future<void> clearGroceryList() async {
    _groceryList.clear();
    await StorageService.saveGroceryList(_groceryList);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _geminiApiKey = key;
    await StorageService.setApiKey(key);
    notifyListeners();
  }
}
