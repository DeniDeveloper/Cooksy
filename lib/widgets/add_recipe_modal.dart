import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/app_state.dart';

class AddRecipeModal extends StatefulWidget {
  const AddRecipeModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddRecipeModal(),
    );
  }

  @override
  State<AddRecipeModal> createState() => _AddRecipeModalState();
}

class _AddRecipeModalState extends State<AddRecipeModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController(text: '15 min');
  final TextEditingController _cookTimeController = TextEditingController(text: '20 min');

  String _selectedCategory = 'Filipino';
  String _selectedEmoji = '🍗';
  int _servings = 4;

  final List<String> _categories = ['Filipino', 'Chicken', 'Fried Rice', 'Italian', 'Breakfast', 'Gourmet'];
  final List<String> _emojis = ['🍗', '🍚', '🍲', '🍝', '🥩', '🥗', '🥣', '🥞'];

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState?.validate() ?? false) {
      final ingLines = _ingredientsController.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final instLines = _instructionsController.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final ingredients = ingLines.map((line) {
        return Ingredient(name: line, amount: '1', unit: 'portion', category: _selectedCategory);
      }).toList();

      final instructions = instLines.asMap().entries.map((e) {
        return InstructionStep(
          step: e.key + 1,
          title: 'Step ${e.key + 1}',
          text: e.value,
          time: '5 min',
          timerMinutes: 5,
        );
      }).toList();

      final newRecipe = Recipe(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        category: _selectedCategory,
        imageIcon: _selectedEmoji,
        prepTime: _prepTimeController.text.trim(),
        cookTime: _cookTimeController.text.trim(),
        servings: _servings,
        overview: 'Special homemade family recipe saved with love.',
        ingredients: ingredients,
        instructions: instructions,
        isCustomUser: true,
      );

      context.read<AppState>().addCustomRecipe(newRecipe);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Family Recipe saved to your Cookbook!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF161D2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF2A344D))),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('📝', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Add Family Recipe',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFFBF5),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8E9BAE)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scrollable Form Fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish Name
                    const Text('DISH NAME', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 14),
                      decoration: _inputDecoration('e.g. Grandma\'s Special Chicken Adobo'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter dish name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category & Emoji Icon Picker
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CATEGORY', style: _labelStyle),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                dropdownColor: const Color(0xFF0E131F),
                                style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 13),
                                decoration: _inputDecoration(''),
                                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedCategory = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('EMOJI', style: _labelStyle),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedEmoji,
                                dropdownColor: const Color(0xFF0E131F),
                                style: const TextStyle(fontSize: 18),
                                decoration: _inputDecoration(''),
                                items: _emojis.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedEmoji = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Servings Picker
                    const Text('SERVINGS (PEOPLE TO FEED)', style: _labelStyle),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [1, 2, 4, 6, 8].map((s) {
                        final isSel = _servings == s;
                        return InkWell(
                          onTap: () => setState(() => _servings = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF0E131F),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF2A344D),
                              ),
                            ),
                            child: Text(
                              '$s',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isSel ? const Color(0xFFFFFBF5) : const Color(0xFF8E9BAE),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Ingredients
                    const Text('INGREDIENTS (ONE PER LINE)', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _ingredientsController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 13),
                      decoration: _inputDecoration('800g Chicken Thighs\n1/3 cup Soy Sauce\n1/3 cup Vinegar\n8 cloves Garlic'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please list ingredients' : null,
                    ),
                    const SizedBox(height: 16),

                    // Instructions
                    const Text('COOKING STEPS (ONE PER LINE)', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 13),
                      decoration: _inputDecoration('Marinate chicken with garlic and soy sauce\nSear chicken in oil for 5 minutes\nPour in vinegar and simmer for 25 minutes\nServe hot over garlic rice'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please list instructions' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: const Color(0xFFFFFBF5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveRecipe,
                        child: const Text(
                          'Save Family Recipe ❤️',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: Color(0xFF8E9BAE),
  );

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF5A667A), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF0E131F),
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
    );
  }
}
