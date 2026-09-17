import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/generator_service.dart';
import '../widgets/grocery_list_modal.dart';
import '../widgets/api_key_dialog.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = ['Chicken', 'Garlic', 'Rice', 'Soy Sauce'];
  int _servings = 4;
  double _maxCookingTime = 25;
  final String _cuisine = 'Any Style';
  bool _isGenerating = false;

  final List<Map<String, String>> _pantryStaples = [
    {'name': 'Chicken', 'emoji': '🍗'},
    {'name': 'Garlic', 'emoji': '🧄'},
    {'name': 'Rice', 'emoji': '🍚'},
    {'name': 'Eggs', 'emoji': '🥚'},
    {'name': 'Soy Sauce', 'emoji': '🍶'},
    {'name': 'Onions', 'emoji': '🧅'},
    {'name': 'Tomatoes', 'emoji': '🍅'},
    {'name': 'Butter', 'emoji': '🧈'},
    {'name': 'Pork', 'emoji': '🥩'},
    {'name': 'Shrimp', 'emoji': '🦐'},
    {'name': 'Spinach', 'emoji': '🥬'},
    {'name': 'Pasta', 'emoji': '🍝'},
  ];

  final List<Map<String, dynamic>> _servingOptions = [
    {'label': '👤 1 (Solo)', 'value': 1},
    {'label': '👥 2 (Couple)', 'value': 2},
    {'label': '👨‍👩‍👧 4 (Family)', 'value': 4},
    {'label': '👨‍👩‍👦‍👦 6 (Large)', 'value': 6},
    {'label': '🍽️ 8+ (Party)', 'value': 8},
  ];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient(String name) {
    final clean = name.trim();
    if (clean.isNotEmpty && !_ingredients.any((i) => i.toLowerCase() == clean.toLowerCase())) {
      setState(() {
        _ingredients.add(clean);
        _ingredientController.clear();
      });
    }
  }

  void _toggleStaple(String name) {
    setState(() {
      if (_ingredients.any((i) => i.toLowerCase() == name.toLowerCase())) {
        _ingredients.removeWhere((i) => i.toLowerCase() == name.toLowerCase());
      } else {
        _ingredients.add(name);
      }
    });
  }

  Future<void> _generateRecipe() async {
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 ingredient!')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final appState = context.read<AppState>();
      final recipe = await GeneratorService.generateRecipe(
        ingredients: _ingredients,
        servings: _servings,
        maxPrepTime: _maxCookingTime.toInt(),
        cuisine: _cuisine,
        customApiKey: appState.geminiApiKey,
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        appState.setActiveRecipe(recipe);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 AI synthesized: ${recipe.title}!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate recipe. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0E131F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI KITCHEN STUDIO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Color(0xFFFF8C5A),
                        ),
                      ),
                      Text(
                        'Recipe Generator',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFFBF5),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFFFBF5)),
                            onPressed: () => GroceryListModal.show(context),
                          ),
                          if (appState.unboughtGroceryCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B35),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  '${appState.unboughtGroceryCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: Color(0xFF8E9BAE)),
                        onPressed: () => ApiKeyDialog.show(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF231422), Color(0xFF161D2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x4DFF6B35)),
                ),
                child: const Row(
                  children: [
                    Text('✨', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What\'s in your kitchen today?',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFFFBF5),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select ingredients or tap pantry staples to craft a custom gourmet dish.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF8E9BAE), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Ingredients Tag Box
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YOUR INGREDIENTS (${_ingredients.length})',
                    style: _sectionLabelStyle,
                  ),
                  if (_ingredients.isNotEmpty)
                    InkWell(
                      onTap: () => setState(() => _ingredients.clear()),
                      child: const Text('Clear All', style: TextStyle(fontSize: 11, color: Color(0xFF8E9BAE))),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Input Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Type ingredient (e.g. Chicken, Tomato)...',
                        hintStyle: const TextStyle(color: Color(0xFF5A667A), fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF161D2E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF2A344D)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF2A344D)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                      ),
                      onSubmitted: (v) => _addIngredient(v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: const Color(0xFFFFFBF5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onPressed: () => _addIngredient(_ingredientController.text),
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Active Tag Chips
              if (_ingredients.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _ingredients.map((ing) {
                    return Chip(
                      label: Text(ing, style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 12, fontWeight: FontWeight.w700)),
                      backgroundColor: const Color(0xFF1E283F),
                      deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFFFF8C5A)),
                      side: const BorderSide(color: Color(0x66FF6B35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onDeleted: () {
                        setState(() {
                          _ingredients.remove(ing);
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),

              // Quick Pantry Staples
              const Text('QUICK PANTRY STAPLES (TAP TO ADD)', style: _sectionLabelStyle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pantryStaples.map((staple) {
                  final name = staple['name']!;
                  final emoji = staple['emoji']!;
                  final isAdded = _ingredients.any((i) => i.toLowerCase() == name.toLowerCase());

                  return InkWell(
                    onTap: () => _toggleStaple(name),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAdded ? const Color(0x33FF6B35) : const Color(0xFF161D2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAdded ? const Color(0xFFFF6B35) : const Color(0xFF2A344D),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isAdded ? const Color(0xFFFF8C5A) : const Color(0xFF8E9BAE),
                            ),
                          ),
                          if (isAdded) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check, size: 12, color: Color(0xFFFF8C5A)),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Servings Picker
              const Text('👨‍👩‍👧 HOW MANY PEOPLE ARE WE FEEDING?', style: _sectionLabelStyle),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _servingOptions.map((opt) {
                    final isSel = _servings == opt['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _servings = opt['value'] as int),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF161D2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF2A344D),
                            ),
                          ),
                          child: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSel ? const Color(0xFFFFFBF5) : const Color(0xFF8E9BAE),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Max Cooking Time Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MAX COOKING TIME', style: _sectionLabelStyle),
                  Text(
                    '${_maxCookingTime.toInt()} Minutes',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF8C5A),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFFF6B35),
                  inactiveTrackColor: const Color(0xFF2A344D),
                  thumbColor: const Color(0xFFFF6B35),
                  overlayColor: const Color(0x33FF6B35),
                ),
                child: Slider(
                  value: _maxCookingTime,
                  min: 10,
                  max: 60,
                  divisions: 10,
                  onChanged: (v) => setState(() => _maxCookingTime = v),
                ),
              ),
              const SizedBox(height: 24),

              // Synthesize Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: const Color(0xFFFFFBF5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 6,
                    shadowColor: const Color(0x66FF6B35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isGenerating ? null : _generateRecipe,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isGenerating ? 'AI Synthesizing Gourmet Dish...' : 'Synthesize Gourmet Recipe ✨',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static const TextStyle _sectionLabelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    color: Color(0xFF8E9BAE),
  );
}
