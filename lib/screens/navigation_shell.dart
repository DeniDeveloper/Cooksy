import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';
import 'generate_screen.dart';
import 'recipe_screen.dart';
import 'saved_screen.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentIndex = appState.currentTabIndex;

    const List<Widget> screens = [
      HomeScreen(),
      GenerateScreen(),
      RecipeScreen(),
      SavedScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161D2E),
          border: Border(
            top: BorderSide(color: Color(0xFF2A344D), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, appState, 0, Icons.home_rounded, 'Home'),
                _buildGenerateNavItem(context, appState, 1),
                _buildNavItem(context, appState, 2, Icons.restaurant_menu_rounded, 'Recipe'),
                _buildNavItem(context, appState, 3, Icons.bookmark_rounded, 'Saved'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, AppState appState, int index, IconData icon, String label) {
    final isSel = appState.currentTabIndex == index;
    return InkWell(
      onTap: () => appState.setTabIndex(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF8E9BAE),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF8E9BAE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateNavItem(BuildContext context, AppState appState, int index) {
    final isSel = appState.currentTabIndex == index;
    return InkWell(
      onTap: () => appState.setTabIndex(index),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 22,
              color: Color(0xFFFFFBF5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Generate',
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
              color: isSel ? const Color(0xFFFF6B35) : const Color(0xFF8E9BAE),
            ),
          ),
        ],
      ),
    );
  }
}
