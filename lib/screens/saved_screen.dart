import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/recipe.dart';
import '../widgets/add_recipe_modal.dart';
import '../widgets/grocery_list_modal.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final saved = appState.savedRecipes;

    final categories = {'All', ...saved.map((r) => r.category)}.toList();
    final filtered = _selectedCategory == 'All'
        ? saved
        : saved.where((r) => r.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    final aiCount = saved.where((r) => r.isAiGenerated).length;
    final catCount = saved.map((r) => r.category).toSet().length;

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
                        'MY COOKBOOK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Color(0xFFFF8C5A),
                        ),
                      ),
                      Text(
                        'Saved Favorites',
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
                        icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFF8E9BAE)),
                        onPressed: () {
                          if (saved.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF161D2E),
                                title: const Text('Clear Cookbook?', style: TextStyle(color: Color(0xFFFFFBF5))),
                                content: const Text(
                                  'Are you sure you want to remove all saved recipes?',
                                  style: TextStyle(color: Color(0xFF8E9BAE)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E9BAE))),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () {
                                      appState.clearAllSaved();
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Clear All'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Family Recipe Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: const Color(0xFFFFFBF5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => AddRecipeModal.show(context),
                  icon: const Icon(Icons.post_add),
                  label: const Text(
                    '+ Add My Own Family Recipe',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  _buildStatCard('SAVED', '${saved.length}', const Color(0xFFFF6B35)),
                  const SizedBox(width: 8),
                  _buildStatCard('CATEGORIES', '$catCount', const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _buildStatCard('AI CREATED', '$aiCount', const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 18),

              // Category Filters
              if (categories.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: const Color(0xFFFF6B35),
                          backgroundColor: const Color(0xFF161D2E),
                          labelStyle: TextStyle(
                            color: isSel ? const Color(0xFFFFFBF5) : const Color(0xFF8E9BAE),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF2A344D),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),

              // Saved Recipe Cards
              filtered.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Text('📖', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 12),
                          Text(
                            'Your Cookbook is empty',
                            style: TextStyle(color: Color(0xFFFFFBF5), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Save recipes you love or create your own above!',
                            style: TextStyle(color: Color(0xFF8E9BAE), fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final recipe = filtered[index];
                        return _buildSavedTile(context, appState, recipe);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161D2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A344D)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF8E9BAE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedTile(BuildContext context, AppState appState, Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161D2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A344D)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => appState.setActiveRecipe(recipe),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E131F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: recipe.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          recipe.image,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Center(
                            child: Text(recipe.imageIcon, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(recipe.imageIcon, style: const TextStyle(fontSize: 28)),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFFBF5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x26FF6B35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recipe.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF8C5A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${recipe.prepTime} · ${recipe.servings} Servings',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF8E9BAE)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined, color: Color(0xFF8E9BAE)),
                onPressed: () => appState.removeSavedRecipe(recipe.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
