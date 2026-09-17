import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/grocery_item.dart';

class GroceryListModal extends StatefulWidget {
  const GroceryListModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GroceryListModal(),
    );
  }

  @override
  State<GroceryListModal> createState() => _GroceryListModalState();
}

class _GroceryListModalState extends State<GroceryListModal> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _shareList(BuildContext context, List<GroceryItem> items) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grocery list is empty')),
      );
      return;
    }
    final buffer = StringBuffer('🛒 Cooksy Family Grocery Shopping List:\n\n');
    for (final item in items) {
      if (!item.isChecked) {
        buffer.writeln('• [ ] ${item.name} ${item.amount.isNotEmpty ? '(${item.amount} ${item.unit})' : ''}');
      }
    }
    buffer.writeln('\nShared via Cooksy Mobile App 🍳');
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 Shopping list copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final items = appState.groceryList;
    final unbought = items.where((i) => !i.isChecked).toList();
    final bought = items.where((i) => i.isChecked).toList();

    // Group unbought items by aisle
    final Map<String, List<GroceryItem>> grouped = {};
    for (final item in unbought) {
      grouped.putIfAbsent(item.aisleName, () => []).add(item);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF161D2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF2A344D), width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🛒', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Text(
                    'Grocery Shopping List',
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
          const SizedBox(height: 12),

          // Action Summary Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0E131F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2A344D)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${unbought.length} to buy (${bought.length} done)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFBF5),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _shareList(context, items),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x26FF6B35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x4DFF6B35)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.share, size: 12, color: Color(0xFFFF8C5A)),
                            SizedBox(width: 4),
                            Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8C5A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => appState.clearGroceryList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E9BAE),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Add Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  style: const TextStyle(color: Color(0xFFFFFBF5), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '+ Add custom item (e.g. Olive Oil)...',
                    hintStyle: const TextStyle(color: Color(0xFF5A667A), fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0E131F),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      appState.addQuickGroceryItem(val);
                      _itemController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: const Color(0xFFFFFBF5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  if (_itemController.text.trim().isNotEmpty) {
                    appState.addQuickGroceryItem(_itemController.text);
                    _itemController.clear();
                  }
                },
                child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items List
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🛒', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 8),
                        Text(
                          'Your shopping list is empty',
                          style: TextStyle(color: Color(0xFF8E9BAE), fontSize: 14),
                        ),
                        Text(
                          'Add items from recipes or type above!',
                          style: TextStyle(color: Color(0xFF5A667A), fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      // Grouped Unbought
                      ...grouped.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: Color(0xFFFF8C5A),
                                  ),
                                ),
                              ),
                              ...entry.value.map((item) => _buildItemTile(context, appState, item)),
                            ],
                          ),
                        );
                      }),

                      // Completed Items
                      if (bought.isNotEmpty) ...[
                        const Divider(color: Color(0xFF2A344D), height: 24),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '✅ COMPLETED ITEMS (${bought.length})',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Color(0xFF8E9BAE),
                            ),
                          ),
                        ),
                        ...bought.map((item) => _buildItemTile(context, appState, item, isDone: true)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, AppState appState, GroceryItem item, {bool isDone = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDone ? const Color(0x330E131F) : const Color(0xFF0E131F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDone ? Colors.transparent : const Color(0xFF2A344D)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => appState.toggleGroceryItem(item.id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: item.isChecked ? const Color(0xFFFF6B35) : const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.isChecked ? const Color(0xFFFF6B35) : const Color(0xFF5A667A),
                ),
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, size: 14, color: Color(0xFFFFFBF5))
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => appState.toggleGroceryItem(item.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: item.isChecked ? const Color(0xFF5A667A) : const Color(0xFFFFFBF5),
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item.recipeTitle.isNotEmpty)
                    Text(
                      'For: ${item.recipeTitle}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF5A667A)),
                    ),
                ],
              ),
            ),
          ),
          if (item.amount.isNotEmpty && !item.isChecked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x26FF6B35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.amount} ${item.unit}'.trim(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF8C5A),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF5A667A)),
            onPressed: () => appState.removeGroceryItem(item.id),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }
}
