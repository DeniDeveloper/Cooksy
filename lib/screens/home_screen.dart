import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/recipe_database.dart';
import '../models/recipe.dart';
import '../widgets/grocery_list_modal.dart';
import '../widgets/api_key_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Filipino', 'Chicken', 'Fried Rice', 'Gourmet'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allRecipes = [
      ...appState.savedRecipes,
      ...RecipeDatabase.initialRecipes.where(
        (dbR) => !appState.savedRecipes.any((s) => s.id == dbR.id),
      ),
    ];

    final filtered = allRecipes.where((r) {
      final matchesCat = _selectedCategory == 'All' || r.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.ingredients.any((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0E131F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161D2E),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2A344D)),
                        ),
                        child: const Center(
                          child: Text('🍳', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good evening, Chef',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8E9BAE),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'What are we cooking?',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFFFBF5),
                            ),
                          ),
                        ],
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

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A344D)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search Adobo, Sinigang, Chicken, Rice...',
                    hintStyle: const TextStyle(color: Color(0xFF5A667A), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8E9BAE)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF8E9BAE), size: 18),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Hero AI Generator Banner
              InkWell(
                onTap: () => appState.setTabIndex(1),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF231422), Color(0xFF17132B), Color(0xFF161D2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x66FF6B35)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1AFF6B35),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x33FF6B35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x66FF6B35)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 12, color: Color(0xFFFF8C5A)),
                            SizedBox(width: 4),
                            Text(
                              'AI Recipe Studio',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8C5A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Cook with what you already have in your fridge',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFFBF5),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap pantry staples & let AI craft a family meal in seconds.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8E9BAE), height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Generate Recipe',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFFBF5),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 14, color: Color(0xFFFFFBF5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
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
              const SizedBox(height: 20),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Family Recipes',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFFBF5),
                    ),
                  ),
                  Text(
                    '${filtered.length} dishes',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recipe Cards Grid
              filtered.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Text('🔍', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 8),
                          Text(
                            'No recipes match your filter',
                            style: TextStyle(color: Color(0xFF8E9BAE), fontSize: 14),
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
                        final isSaved = appState.isRecipeSaved(recipe.id);
                        return _buildRecipeCard(context, appState, recipe, isSaved);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, AppState appState, Recipe recipe, bool isSaved) {
    return InkWell(
      onTap: () => appState.setActiveRecipe(recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161D2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A344D)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Banner with Badges & Bookmark
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFF0E131F),
                  child: recipe.image.isNotEmpty
                      ? Image.network(
                          recipe.image,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Center(
                            child: Text(recipe.imageIcon, style: const TextStyle(fontSize: 48)),
                          ),
                        )
                      : Center(
                          child: Text(recipe.imageIcon, style: const TextStyle(fontSize: 48)),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xD90E131F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF8C5A),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => appState.toggleSaveRecipe(recipe),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xD90E131F),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? const Color(0xFFFF6B35) : const Color(0xFFFFFBF5),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFFBF5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE), height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFFF8C5A)),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime} prep · ${recipe.cookTime} cook',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E9BAE), fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.group_outlined, size: 14, color: Color(0xFF8E9BAE)),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.servings} Servings',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E9BAE), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
