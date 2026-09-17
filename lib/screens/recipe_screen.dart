import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/recipe.dart';
import '../services/generator_service.dart';
import '../widgets/cook_mode_dialog.dart';
import '../widgets/grocery_list_modal.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final Set<int> _checkedIngredients = {};

  void _shareRecipe(BuildContext context, Recipe recipe) {
    final buffer = StringBuffer('🍳 ${recipe.title} (${recipe.category})\n\n');
    buffer.writeln(recipe.overview);
    buffer.writeln('\n⏱️ Prep: ${recipe.prepTime} | Cook: ${recipe.cookTime} | Servings: ${recipe.servings}');
    buffer.writeln('\n🛒 Ingredients:');
    for (final ing in recipe.ingredients) {
      buffer.writeln('• ${ing.amount} ${ing.unit} ${ing.name}');
    }
    buffer.writeln('\n👨‍🍳 Instructions:');
    for (final s in recipe.instructions) {
      buffer.writeln('${s.step}. ${s.title}: ${s.text}');
    }
    buffer.writeln('\nShared via Cooksy Mobile App ❤️');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 Recipe copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final recipe = appState.activeRecipe;

    if (recipe == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E131F),
        body: Center(
          child: Text('No recipe selected', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final isSaved = appState.isRecipeSaved(recipe.id);
    final factor = appState.currentServings / (recipe.servings > 0 ? recipe.servings : 4);
    final costInfo = GeneratorService.calculateCost(recipe, appState.currentServings);

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFBF5)),
                    onPressed: () => appState.setTabIndex(0),
                  ),
                  const Column(
                    children: [
                      Text(
                        'RECIPE RESULT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Color(0xFFFF8C5A),
                        ),
                      ),
                      Text(
                        'Cooking Guide',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
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
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? const Color(0xFFFF6B35) : const Color(0xFFFFFBF5),
                        ),
                        onPressed: () => appState.toggleSaveRecipe(recipe),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Hero Photo & Badges Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A344D)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          color: const Color(0xFF0E131F),
                          child: recipe.image.isNotEmpty
                              ? Image.network(
                                  recipe.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Center(
                                    child: Text(recipe.imageIcon, style: const TextStyle(fontSize: 54)),
                                  ),
                                )
                              : Center(
                                  child: Text(recipe.imageIcon, style: const TextStyle(fontSize: 54)),
                                ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xD90E131F),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0x33FFFFFF)),
                                ),
                                child: Text(
                                  recipe.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF8C5A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xD90E131F),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0x3310B981)),
                                ),
                                child: Text(
                                  '💰 ${costInfo['isBudgetFriendly'] == true ? 'Under \$12' : costInfo['perServing']}/serv',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            recipe.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFFFBF5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recipe.overview,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE), height: 1.4),
                          ),
                          const SizedBox(height: 16),

                          // Quick Metrics Ribbon with Servings Stepper
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E131F),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF2A344D)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMetricPill(Icons.schedule, 'PREP', recipe.prepTime),
                                _buildMetricPill(Icons.timer, 'COOK', recipe.cookTime, color: const Color(0xFFFF6B35)),
                                _buildMetricPill(Icons.local_fire_department, 'CALORIES', recipe.calories, color: const Color(0xFFF59E0B)),
                                _buildMetricPill(Icons.payments, 'EST. COST', costInfo['total'] as String, color: const Color(0xFF10B981)),
                                // Servings Stepper
                                Column(
                                  children: [
                                    const Text('SERVINGS', style: TextStyle(fontSize: 9, color: Color(0xFF8E9BAE), fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => appState.setServings(appState.currentServings - 1),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: const Color(0x33FF6B35),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFFFF6B35)),
                                            ),
                                            child: const Center(
                                              child: Text('-', style: TextStyle(color: Color(0xFFFF8C5A), fontWeight: FontWeight.bold, fontSize: 13, height: 1)),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(
                                            '${appState.currentServings}',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFFFFBF5)),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => appState.setServings(appState.currentServings + 1),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: const Color(0x33FF6B35),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFFFF6B35)),
                                            ),
                                            child: const Center(
                                              child: Text('+', style: TextStyle(color: Color(0xFFFF8C5A), fontWeight: FontWeight.bold, fontSize: 13, height: 1)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // FEATURE 2: Hands-Free Cook Mode Hero Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: const Color(0xFFFFFBF5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 6,
                    shadowColor: const Color(0x66FF6B35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => CookModeDialog.show(context, recipe),
                  icon: const Icon(Icons.outdoor_grill, size: 24),
                  label: const Text(
                    '👨‍🍳 Start Hands-Free Cook Mode',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // FEATURE 3: 1-Tap AI Recipe Remix Toolbar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A344D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('💡', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              '1-Tap AI Recipe Remix',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFFBF5),
                              ),
                            ),
                          ],
                        ),
                        Text('Smart Tweaks', style: TextStyle(fontSize: 10, color: Color(0xFFFF8C5A), fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap any button to instantly adapt this recipe for your family:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8E9BAE)),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRemixChip(context, appState, '♨️ Air Fryer', 'air_fryer'),
                          _buildRemixChip(context, appState, '👶 Kid-Friendly', 'kid_friendly'),
                          _buildRemixChip(context, appState, '🥥 Dairy-Free', 'dairy_free'),
                          _buildRemixChip(context, appState, '🥑 Keto', 'keto'),
                          _buildRemixChip(context, appState, '⚡ 15-Min Express', '15_min_express'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // FEATURE 4: Macro & Nutrition Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A344D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('🥗', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'Macro & Nutrition Info',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFFBF5),
                              ),
                            ),
                          ],
                        ),
                        Text('Per Serving', style: TextStyle(fontSize: 10, color: Color(0xFF8E9BAE))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildMacroItem('Protein', '${recipe.nutrition.protein}g', const Color(0xFF10B981), recipe.nutrition.protein / 50),
                        _buildMacroItem('Carbs', '${recipe.nutrition.carbs}g', const Color(0xFF38BDF8), recipe.nutrition.carbs / 80),
                        _buildMacroItem('Fat', '${recipe.nutrition.fat}g', const Color(0xFFF59E0B), recipe.nutrition.fat / 30),
                        _buildMacroItem('Fiber', '${recipe.nutrition.fiber}g', const Color(0xFFA855F7), recipe.nutrition.fiber / 15),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Save & Share Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaved ? const Color(0xFF10B981) : const Color(0xFFFF6B35),
                        foregroundColor: const Color(0xFFFFFBF5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => appState.toggleSaveRecipe(recipe),
                      icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                      label: Text(
                        isSaved ? 'Saved in Cookbook' : 'Save Recipe',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2A344D)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF161D2E),
                      ),
                      onPressed: () => _shareRecipe(context, recipe),
                      icon: const Icon(Icons.share, size: 18, color: Color(0xFFFFFBF5)),
                      label: const Text('Share', style: TextStyle(color: Color(0xFFFFFBF5), fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ingredients Checklist Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ingredients Checklist',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFFBF5),
                    ),
                  ),
                  Text(
                    '${recipe.ingredients.length} items',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A344D)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: recipe.ingredients.asMap().entries.map((e) {
                    final idx = e.key;
                    final ing = e.value;
                    final isChecked = _checkedIngredients.contains(idx);
                    final scaledAmt = ing.getScaledAmount(factor);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _checkedIngredients.remove(idx);
                          } else {
                            _checkedIngredients.add(idx);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isChecked ? const Color(0xFFFF6B35) : const Color(0x1AFFFFFF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isChecked ? const Color(0xFFFF6B35) : const Color(0xFF5A667A),
                                ),
                              ),
                              child: isChecked
                                  ? const Icon(Icons.check, size: 14, color: Color(0xFFFFFBF5))
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${ing.name}${ing.note != null ? ' (${ing.note})' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isChecked ? const Color(0xFF5A667A) : const Color(0xFFFFFBF5),
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x26FF6B35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$scaledAmt ${ing.unit}'.trim(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF8C5A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Add to Grocery Shopping List Action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0x1AFF6B35),
                    side: const BorderSide(color: Color(0x66FF6B35)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    appState.addIngredientsToGrocery(recipe, factor);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🛒 Added ingredients to Grocery Shopping List!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFFF8C5A), size: 18),
                  label: const Text(
                    '+ Add to Grocery Shopping List',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF8C5A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Step-by-Step Instructions
              const Text(
                'Step-by-Step Instructions',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFFBF5),
                ),
              ),
              const SizedBox(height: 12),

              ...recipe.instructions.map((step) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161D2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A344D)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B35),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${step.step}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFFFBF5)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                step.title,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFFBF5),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x26FF6B35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x4DFF6B35)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer, size: 12, color: Color(0xFFFF8C5A)),
                                const SizedBox(width: 4),
                                Text(
                                  step.time,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFF8C5A)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.text,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFC5D1E0), height: 1.5),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),

              // Chef Tips Card
              if (recipe.chefTips.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFF6B35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x4DFF6B35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('👨‍🍳', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(
                            'Chef\'s Pro Tips',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF8C5A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...recipe.chefTips.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: Color(0xFFFF8C5A), fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(tip, style: const TextStyle(fontSize: 12, color: Color(0xFFC5D1E0), height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill(IconData icon, String label, String val, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 14, color: color ?? const Color(0xFF8E9BAE)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF8E9BAE), fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color ?? const Color(0xFFFFFBF5))),
      ],
    );
  }

  Widget _buildRemixChip(BuildContext context, AppState appState, String label, String remixType) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: const Color(0xFF0E131F),
        side: const BorderSide(color: Color(0xFF2A344D)),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFFFBF5))),
        onPressed: () => appState.remixActiveRecipe(remixType),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color, double percent) {
    final clamped = percent.clamp(0.0, 1.0);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8E9BAE), fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 4,
                backgroundColor: const Color(0xFF2A344D),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
