class GroceryItem {
  final String id;
  final String name;
  final String amount;
  final String unit;
  final String note;
  final String aisleId;
  final String aisleName;
  final String aisleEmoji;
  final String recipeTitle;
  bool isChecked;
  final int addedAt;

  GroceryItem({
    required this.id,
    required this.name,
    this.amount = '',
    this.unit = '',
    this.note = '',
    required this.aisleId,
    required this.aisleName,
    required this.aisleEmoji,
    this.recipeTitle = 'My Pantry',
    this.isChecked = false,
    int? addedAt,
  }) : addedAt = addedAt ?? DateTime.now().millisecondsSinceEpoch;

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] ?? 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      unit: json['unit'] ?? '',
      note: json['note'] ?? '',
      aisleId: json['aisleId'] ?? 'pantry',
      aisleName: json['aisleName'] ?? 'Pantry, Oils & Spices',
      aisleEmoji: json['aisleEmoji'] ?? '🧂',
      recipeTitle: json['recipeTitle'] ?? 'My Pantry',
      isChecked: json['isChecked'] == true || json['checked'] == true,
      addedAt: json['addedAt'] is int ? json['addedAt'] : DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'unit': unit,
        'note': note,
        'aisleId': aisleId,
        'aisleName': aisleName,
        'aisleEmoji': aisleEmoji,
        'recipeTitle': recipeTitle,
        'isChecked': isChecked,
        'addedAt': addedAt,
      };

  static Map<String, String> getAisleForIngredient(String name) {
    final n = name.toLowerCase();
    if (n.contains('chicken') ||
        n.contains('pork') ||
        n.contains('beef') ||
        n.contains('salmon') ||
        n.contains('meat') ||
        n.contains('shrimp') ||
        n.contains('fish') ||
        n.contains('bacon') ||
        n.contains('steak')) {
      return {'id': 'meat', 'name': 'Meat & Seafood', 'emoji': '🥩'};
    }
    if (n.contains('garlic') ||
        n.contains('onion') ||
        n.contains('tomato') ||
        n.contains('lemon') ||
        n.contains('lime') ||
        n.contains('ginger') ||
        n.contains('spinach') ||
        n.contains('broccoli') ||
        n.contains('mango') ||
        n.contains('kangkong') ||
        n.contains('scallion') ||
        n.contains('calamansi') ||
        n.contains('basil') ||
        n.contains('cilantro') ||
        n.contains('chili') ||
        n.contains('vegetable') ||
        n.contains('potato') ||
        n.contains('carrot')) {
      return {'id': 'produce', 'name': 'Fresh Produce', 'emoji': '🥬'};
    }
    if (n.contains('milk') ||
        n.contains('cream') ||
        n.contains('butter') ||
        n.contains('cheese') ||
        n.contains('egg') ||
        n.contains('parmesan') ||
        n.contains('mozzarella') ||
        n.contains('yogurt')) {
      return {'id': 'dairy', 'name': 'Dairy & Eggs', 'emoji': '🥛'};
    }
    if (n.contains('rice') ||
        n.contains('pasta') ||
        n.contains('noodle') ||
        n.contains('bread') ||
        n.contains('gnocchi') ||
        n.contains('graham') ||
        n.contains('tortilla') ||
        n.contains('flour')) {
      return {'id': 'grains', 'name': 'Grains & Bakery', 'emoji': '🍞'};
    }
    return {'id': 'pantry', 'name': 'Pantry, Oils & Spices', 'emoji': '🧂'};
  }
}
