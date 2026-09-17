import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'storage_service.dart';

class GeneratorService {
  static const String _defaultEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static Future<Recipe> generateRecipe({
    required List<String> ingredients,
    int servings = 4,
    int maxPrepTime = 30,
    String cuisine = 'Any Style',
    String? customApiKey,
  }) async {
    final storedKey = await StorageService.getApiKey();
    final apiKey = (customApiKey != null && customApiKey.trim().isNotEmpty)
        ? customApiKey.trim()
        : (storedKey != null && storedKey.trim().isNotEmpty)
            ? storedKey.trim()
            : null;

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final onlineRecipe = await _generateWithGemini(
          apiKey: apiKey.trim(),
          ingredients: ingredients,
          servings: servings,
          maxPrepTime: maxPrepTime,
          cuisine: cuisine,
        );
        if (onlineRecipe != null) return onlineRecipe;
      } catch (e) {
        // Fall back seamlessly to offline synthesis
      }
    }

    // Offline Smart Rule-Based Synthesis
    return _generateOffline(
      ingredients: ingredients,
      servings: servings,
      maxPrepTime: maxPrepTime,
      cuisine: cuisine,
    );
  }

  static Future<Recipe?> _generateWithGemini({
    required String apiKey,
    required List<String> ingredients,
    required int servings,
    required int maxPrepTime,
    required String cuisine,
  }) async {
    final prompt = '''
You are an expert masterchef AI. Create a complete gourmet recipe based on these inputs:
- Ingredients available: ${ingredients.join(', ')}
- Servings: $servings people
- Max Cooking Time: $maxPrepTime minutes
- Cuisine style: $cuisine

Return STRICTLY valid JSON with no surrounding markdown or explanation, following this schema:
{
  "title": "Dish Name",
  "category": "Filipino/Chicken/Italian/Breakfast/General",
  "prepTime": "10 min",
  "cookTime": "20 min",
  "servings": $servings,
  "calories": "450 kcal",
  "imageIcon": "🍲",
  "overview": "Appetizing 2-sentence description of the dish.",
  "ingredients": [
    { "name": "Ingredient name", "amount": "2", "baseAmount": 2, "unit": "cups", "category": "Produce/Meat/Dairy/Pantry" }
  ],
  "instructions": [
    { "step": 1, "title": "Prep Aromatics", "text": "Detailed step instruction.", "time": "5 min" }
  ],
  "nutrition": {
    "protein": 30,
    "carbs": 40,
    "fat": 15,
    "fiber": 5
  },
  "chefTips": [
    "Expert cooking tip 1",
    "Expert cooking tip 2"
  ]
}
''';

    final response = await http.post(
      Uri.parse('$_defaultEndpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.7,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) {
        final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonMap = jsonDecode(cleanText) as Map<String, dynamic>;
        jsonMap['isAiGenerated'] = true;
        jsonMap['image'] = _getHeroImageForTitle(jsonMap['title'] ?? '');
        return Recipe.fromJson(jsonMap);
      }
    }
    return null;
  }

  static Recipe _generateOffline({
    required List<String> ingredients,
    required int servings,
    required int maxPrepTime,
    required String cuisine,
  }) {
    final ingLower = ingredients.map((i) => i.toLowerCase()).toList();
    final bool hasChicken = ingLower.any((i) => i.contains('chicken') || i.contains('poultry'));
    final bool hasRice = ingLower.any((i) => i.contains('rice') || i.contains('sinangag'));
    final bool hasEgg = ingLower.any((i) => i.contains('egg'));

    String title;
    String category;
    String imageIcon;
    String image;
    String overview;
    List<Ingredient> recipeIngs = [];
    List<InstructionStep> steps = [];

    if (hasChicken && hasRice) {
      title = 'Savory Garlic Herb Chicken & Wok Rice';
      category = 'Chicken';
      imageIcon = '🍗';
      image = 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&auto=format&fit=crop&q=80';
      overview = 'Tender seared chicken cutlets served over a bed of fragrant golden garlic wok-tossed rice.';
      recipeIngs = [
        Ingredient(name: 'Chicken Thighs/Breast', amount: '${(150 * servings).round()}', baseAmount: (150.0 * servings), unit: 'g', category: 'Meat & Seafood'),
        Ingredient(name: 'Cooked Jasmine Rice', amount: '$servings', baseAmount: servings.toDouble(), unit: 'cups', category: 'Grains & Bakery'),
        Ingredient(name: 'Garlic', amount: '${2 * servings}', baseAmount: (2.0 * servings), unit: 'cloves', note: 'minced', category: 'Fresh Produce'),
        Ingredient(name: 'Soy Sauce & Butter', amount: '2', baseAmount: 2, unit: 'tbsp', category: 'Pantry, Oils & Spices'),
        Ingredient(name: 'Scallions / Green Onions', amount: '2', baseAmount: 2, unit: 'stalks', category: 'Fresh Produce'),
      ];
      steps = [
        InstructionStep(step: 1, title: 'Sear Chicken', text: 'Season chicken with salt, pepper, and garlic powder. Pan-sear in olive oil for 8 minutes until golden.', time: '8 min', timerMinutes: 8),
        InstructionStep(step: 2, title: 'Wok-Fry the Rice', text: 'In the same skillet, sauté minced garlic until golden, then toss in cold rice and soy sauce on high heat.', time: '5 min', timerMinutes: 5),
        InstructionStep(step: 3, title: 'Platter & Garnish', text: 'Slice chicken, arrange on top of garlic rice, and garnish with sliced scallions.', time: '2 min', timerMinutes: 2),
      ];
    } else if (hasRice || hasEgg) {
      title = 'Golden Chef Fried Rice with Pan-Seared Egg';
      category = 'Fried Rice';
      imageIcon = '🍚';
      image = 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&auto=format&fit=crop&q=80';
      overview = 'Fragrant wok-fried rice tossed with golden garlic, fluffy scrambled eggs, and green scallions.';
      recipeIngs = [
        Ingredient(name: 'Cooked Rice', amount: '$servings', baseAmount: servings.toDouble(), unit: 'cups', category: 'Grains & Bakery'),
        Ingredient(name: 'Fresh Eggs', amount: '$servings', baseAmount: servings.toDouble(), unit: 'large', category: 'Dairy & Eggs'),
        Ingredient(name: 'Garlic & Onions', amount: '4', baseAmount: 4, unit: 'cloves', category: 'Fresh Produce'),
        Ingredient(name: 'Soy Sauce & Sesame Oil', amount: '2', baseAmount: 2, unit: 'tbsp', category: 'Pantry, Oils & Spices'),
      ];
      steps = [
        InstructionStep(step: 1, title: 'Scramble Eggs', text: 'Whisk eggs and scramble softly in a hot oiled wok for 1 minute. Set aside.', time: '2 min', timerMinutes: 2),
        InstructionStep(step: 2, title: 'Wok-Toss Rice', text: 'Sauté garlic until fragrant. Add cold rice and seasonings; stir-fry vigorously for 5 minutes.', time: '5 min', timerMinutes: 5),
        InstructionStep(step: 3, title: 'Fold & Serve', text: 'Fold the scrambled eggs back into the rice and serve steaming hot.', time: '2 min', timerMinutes: 2),
      ];
    } else {
      final mainIng = ingredients.isNotEmpty ? ingredients.first : 'Fresh Harvest';
      title = 'Gourmet $mainIng Skillet Medley';
      category = 'Gourmet';
      imageIcon = '🍲';
      image = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80';
      overview = 'A wholesome, flavor-packed skillet dish harmoniously combining $mainIng with aromatic herbs and garlic.';
      recipeIngs = ingredients.map((ing) => Ingredient(name: ing, amount: '1', baseAmount: 1, unit: 'portion', category: 'General')).toList();
      recipeIngs.addAll([
        Ingredient(name: 'Olive Oil', amount: '2', baseAmount: 2, unit: 'tbsp', category: 'Pantry, Oils & Spices'),
        Ingredient(name: 'Garlic & Onion', amount: '3', baseAmount: 3, unit: 'cloves', category: 'Fresh Produce'),
        Ingredient(name: 'Sea Salt & Cracked Pepper', amount: '1', baseAmount: 1, unit: 'pinch', category: 'Pantry, Oils & Spices'),
      ]);
      steps = [
        InstructionStep(step: 1, title: 'Prep & Chop', text: 'Rinse and slice all ingredients into uniform bite-sized pieces.', time: '5 min', timerMinutes: 5),
        InstructionStep(step: 2, title: 'Sauté in Olive Oil', text: 'Heat oil in a heavy skillet. Sauté garlic, onion, and main ingredients until tender and aromatic.', time: '8 min', timerMinutes: 8),
        InstructionStep(step: 3, title: 'Season & Serve', text: 'Season to taste with sea salt, herbs, and pepper. Serve immediately.', time: '2 min', timerMinutes: 2),
      ];
    }

    return Recipe(
      id: 'gen_recipe_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      prepTime: '10 min',
      cookTime: '${maxPrepTime > 15 ? 15 : maxPrepTime} min',
      servings: servings,
      calories: '${350 + (servings * 25)} kcal',
      image: image,
      imageIcon: imageIcon,
      overview: overview,
      ingredients: recipeIngs,
      instructions: steps,
      nutrition: Nutrition(protein: 30, carbs: 40, fat: 14, fiber: 4),
      chefTips: [
        'High heat creates rich pan caramelization for enhanced depth of flavor.',
        'Taste at each step to ensure perfect seasoning balance.',
      ],
      isAiGenerated: true,
    );
  }

  static Recipe remixRecipe(Recipe recipe, String remixType) {
    switch (remixType) {
      case 'air_fryer':
        return recipe.copyWith(
          title: '${recipe.title} (Air Fryer Edition)',
          prepTime: '10 min',
          cookTime: '15 min',
          chefTips: [
            'Preheat air fryer to 380°F (195°C) for 3 minutes before adding ingredients.',
            'Shake the basket halfway through cooking for optimal, even crispiness.',
          ],
          instructions: recipe.instructions.map((s) {
            if (s.step == 1) {
              return InstructionStep(
                step: 1,
                title: 'Air Fryer Prep',
                text: 'Lightly coat ingredients with cooking spray. Preheat air fryer to 380°F.',
                time: '3 min',
                timerMinutes: 3,
              );
            } else if (s.step == 2) {
              return InstructionStep(
                step: 2,
                title: 'Air Fry to Crispy',
                text: 'Place in a single layer in the basket. Cook at 380°F for 12-14 minutes, shaking at 7 minutes.',
                time: '14 min',
                timerMinutes: 14,
              );
            }
            return s;
          }).toList(),
        );

      case 'kid_friendly':
        return recipe.copyWith(
          title: '${recipe.title} (Kid-Friendly & Mild)',
          chefTips: [
            'Cut all ingredients into bite-sized fun shapes for easier eating.',
            'Mellow all intense spices and add a slight honey sweetness.',
          ],
          ingredients: recipe.ingredients.map((i) {
            if (i.name.toLowerCase().contains('chili') || i.name.toLowerCase().contains('pepper')) {
              return Ingredient(name: '${i.name} (Mild / Optional)', amount: '1', unit: 'pinch');
            }
            return i;
          }).toList(),
        );

      case 'dairy_free':
        return recipe.copyWith(
          title: '${recipe.title} (Dairy-Free)',
          ingredients: recipe.ingredients.map((i) {
            final n = i.name.toLowerCase();
            if (n.contains('butter')) return Ingredient(name: 'Olive Oil / Vegan Butter', amount: i.amount, unit: i.unit);
            if (n.contains('cream') || n.contains('milk')) return Ingredient(name: 'Coconut Cream / Oat Milk', amount: i.amount, unit: i.unit);
            if (n.contains('cheese') || n.contains('parmesan')) return Ingredient(name: 'Nutritional Yeast / Vegan Cheese', amount: i.amount, unit: i.unit);
            return i;
          }).toList(),
        );

      case 'keto':
        return recipe.copyWith(
          title: '${recipe.title} (Keto / Low-Carb)',
          nutrition: Nutrition(protein: 45, carbs: 6, fat: 34, fiber: 4),
          ingredients: recipe.ingredients.map((i) {
            final n = i.name.toLowerCase();
            if (n.contains('rice')) return Ingredient(name: 'Riced Cauliflower', amount: i.amount, unit: i.unit);
            if (n.contains('sugar')) return Ingredient(name: 'Erythritol / Monk Fruit', amount: i.amount, unit: i.unit);
            return i;
          }).toList(),
        );

      case '15_min_express':
        return recipe.copyWith(
          title: '${recipe.title} (15-Min Express)',
          prepTime: '5 min',
          cookTime: '10 min',
          instructions: [
            InstructionStep(step: 1, title: 'Express High-Heat Sear', text: 'Heat oil on high heat. Sauté all aromatics and proteins rapidly for 6 minutes.', time: '6 min', timerMinutes: 6),
            InstructionStep(step: 2, title: 'One-Pan Glaze', text: 'Pour in sauce and toss continuously for 4 minutes until glazed and piping hot.', time: '4 min', timerMinutes: 4),
          ],
        );

      default:
        return recipe;
    }
  }

  static Map<String, dynamic> calculateCost(Recipe recipe, int servings) {
    double basePerServing = 2.20;
    final title = recipe.title.toLowerCase();
    final category = recipe.category.toLowerCase();

    if (title.contains('salmon') || title.contains('steak') || title.contains('shrimp')) {
      basePerServing = 3.80;
    } else if (title.contains('fried rice') || title.contains('egg') || title.contains('pasta') || title.contains('arroz caldo') || title.contains('sinangag')) {
      basePerServing = 1.60;
    } else if (title.contains('chicken') || category.contains('chicken') || title.contains('adobo')) {
      basePerServing = 2.30;
    }

    final total = basePerServing * servings;
    return {
      'total': '\$${total.toStringAsFixed(2)}',
      'perServing': '\$${basePerServing.toStringAsFixed(2)}',
      'isBudgetFriendly': total <= 12.00,
    };
  }

  static String _getHeroImageForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('chicken')) {
      return 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&auto=format&fit=crop&q=80';
    }
    if (t.contains('rice')) {
      return 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&auto=format&fit=crop&q=80';
    }
    if (t.contains('salmon') || t.contains('fish')) {
      return 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80';
  }
}
