class Ingredient {
  final String name;
  final String amount;
  final double? baseAmount;
  final String unit;
  final String? note;
  final String category;

  Ingredient({
    required this.name,
    required this.amount,
    this.baseAmount,
    this.unit = '',
    this.note,
    this.category = 'General',
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      amount: json['amount']?.toString() ?? '',
      baseAmount: json['baseAmount'] != null
          ? (json['baseAmount'] as num).toDouble()
          : _parseAmount(json['amount']?.toString() ?? ''),
      unit: json['unit'] ?? '',
      note: json['note'],
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'baseAmount': baseAmount,
        'unit': unit,
        'note': note,
        'category': category,
      };

  static double? _parseAmount(String amt) {
    if (amt.isEmpty) return null;
    final parts = amt.trim().split(' ');
    if (parts.isEmpty) return null;
    final first = parts[0];
    if (first.contains('/')) {
      final frac = first.split('/');
      if (frac.length == 2) {
        final n = double.tryParse(frac[0]);
        final d = double.tryParse(frac[1]);
        if (n != null && d != null && d != 0) return n / d;
      }
    }
    return double.tryParse(first);
  }

  String getScaledAmount(double factor) {
    if (baseAmount == null || baseAmount == 0) return amount;
    final scaled = baseAmount! * factor;
    return _formatFraction(scaled);
  }

  static String _formatFraction(double val) {
    if (val <= 0) return '';
    if ((val - val.round()).abs() < 0.05) return val.round().toString();
    final whole = val.floor();
    final rem = val - whole;
    String fracStr = '';
    if ((rem - 0.25).abs() < 0.08) {
      fracStr = '1/4';
    } else if ((rem - 0.33).abs() < 0.08) {
      fracStr = '1/3';
    } else if ((rem - 0.5).abs() < 0.08) {
      fracStr = '1/2';
    } else if ((rem - 0.66).abs() < 0.08) {
      fracStr = '2/3';
    } else if ((rem - 0.75).abs() < 0.08) {
      fracStr = '3/4';
    } else {
      return val.toStringAsFixed(1);
    }

    if (whole == 0) return fracStr;
    return '$whole $fracStr';
  }
}

class InstructionStep {
  final int step;
  final String title;
  final String text;
  final String time;
  final int timerMinutes;

  InstructionStep({
    required this.step,
    required this.title,
    required this.text,
    this.time = '5 min',
    this.timerMinutes = 5,
  });

  factory InstructionStep.fromJson(dynamic json, int index) {
    if (json is String) {
      return InstructionStep(
        step: index + 1,
        title: 'Step ${index + 1}',
        text: json,
        time: '5 min',
        timerMinutes: 5,
      );
    }
    final map = json as Map<String, dynamic>;
    final timeStr = map['time']?.toString() ?? '5 min';
    final parsedTime = int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;
    return InstructionStep(
      step: map['step'] is int ? map['step'] : (index + 1),
      title: map['title'] ?? 'Step ${index + 1}',
      text: map['text'] ?? '',
      time: timeStr,
      timerMinutes: parsedTime > 0 ? parsedTime : 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'title': title,
        'text': text,
        'time': time,
        'timerMinutes': timerMinutes,
      };
}

class Nutrition {
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;

  Nutrition({
    this.protein = 25,
    this.carbs = 35,
    this.fat = 12,
    this.fiber = 4,
  });

  factory Nutrition.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Nutrition();
    return Nutrition(
      protein: json['protein'] is int ? json['protein'] : (int.tryParse(json['protein']?.toString() ?? '') ?? 25),
      carbs: json['carbs'] is int ? json['carbs'] : (int.tryParse(json['carbs']?.toString() ?? '') ?? 35),
      fat: json['fat'] is int ? json['fat'] : (int.tryParse(json['fat']?.toString() ?? '') ?? 12),
      fiber: json['fiber'] is int ? json['fiber'] : (int.tryParse(json['fiber']?.toString() ?? '') ?? 4),
    );
  }

  Map<String, dynamic> toJson() => {
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
      };
}

class Recipe {
  final String id;
  final String title;
  final String category;
  final String prepTime;
  final String cookTime;
  final int servings;
  final String calories;
  final String image;
  final String imageIcon;
  final String overview;
  final List<Ingredient> ingredients;
  final List<InstructionStep> instructions;
  final Nutrition nutrition;
  final List<String> chefTips;
  final bool isAiGenerated;
  final bool isCustomUser;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    this.prepTime = '15 min',
    this.cookTime = '25 min',
    this.servings = 4,
    this.calories = '450 kcal',
    this.image = '',
    this.imageIcon = '🍲',
    this.overview = '',
    required this.ingredients,
    required this.instructions,
    Nutrition? nutrition,
    this.chefTips = const [],
    this.isAiGenerated = false,
    this.isCustomUser = false,
  }) : nutrition = nutrition ?? Nutrition();

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingList = (json['ingredients'] as List? ?? [])
        .map((i) => i is Map<String, dynamic> ? Ingredient.fromJson(i) : Ingredient(name: i.toString(), amount: '1'))
        .toList();

    final instList = (json['instructions'] as List? ?? [])
        .asMap()
        .entries
        .map((e) => InstructionStep.fromJson(e.value, e.key))
        .toList();

    final tips = (json['chefTips'] as List? ?? [])
        .map((t) => t.toString())
        .toList();

    return Recipe(
      id: json['id'] ?? 'recipe_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Delicious Recipe',
      category: json['category'] ?? 'Gourmet',
      prepTime: json['prepTime'] ?? '15 min',
      cookTime: json['cookTime'] ?? '25 min',
      servings: json['servings'] is int ? json['servings'] : (int.tryParse(json['servings']?.toString() ?? '') ?? 4),
      calories: json['calories'] ?? '450 kcal',
      image: json['image'] ?? '',
      imageIcon: json['imageIcon'] ?? '🍲',
      overview: json['overview'] ?? '',
      ingredients: ingList,
      instructions: instList,
      nutrition: Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>?),
      chefTips: tips,
      isAiGenerated: json['isAiGenerated'] == true,
      isCustomUser: json['isCustomUser'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'prepTime': prepTime,
        'cookTime': cookTime,
        'servings': servings,
        'calories': calories,
        'image': image,
        'imageIcon': imageIcon,
        'overview': overview,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'instructions': instructions.map((i) => i.toJson()).toList(),
        'nutrition': nutrition.toJson(),
        'chefTips': chefTips,
        'isAiGenerated': isAiGenerated,
        'isCustomUser': isCustomUser,
      };

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    String? prepTime,
    String? cookTime,
    int? servings,
    String? calories,
    String? image,
    String? imageIcon,
    String? overview,
    List<Ingredient>? ingredients,
    List<InstructionStep>? instructions,
    Nutrition? nutrition,
    List<String>? chefTips,
    bool? isAiGenerated,
    bool? isCustomUser,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      image: image ?? this.image,
      imageIcon: imageIcon ?? this.imageIcon,
      overview: overview ?? this.overview,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutrition: nutrition ?? this.nutrition,
      chefTips: chefTips ?? this.chefTips,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      isCustomUser: isCustomUser ?? this.isCustomUser,
    );
  }
}
