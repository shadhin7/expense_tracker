import 'package:expense_track/Provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load categories for both tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      provider.loadUserCategories('expense');
      provider.loadUserCategories('income');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _addCategory(String type) async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    await Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).addUserCategory(name, type);
    _newCategoryController.clear();
  }

  Future<void> _deleteCategory(String type, String name) async {
    // Optional: Implement deletion in Firestore
    await Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).deleteUserCategory(name, type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Manage Categories'),
        bottom: TabBar(
          indicatorColor: Colors.blue,
          unselectedLabelColor: Colors.blueGrey,
          labelColor: Colors.blue,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCategoryTab('expense'), _buildCategoryTab('income')],
      ),
    );
  }

  Widget _buildCategoryTab(String type) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final categories = type == 'expense'
            ? provider.expenseCategories
            : provider.incomeCategories;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Add new category
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCategoryController,
                      decoration: InputDecoration(
                        hintText: 'New $type category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: type == 'expense'
                          ? Colors.red
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _addCategory(type),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // List of categories
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Text(
                          'No $type categories added yet.',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return ListTile(
                            title: Text(cat),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _deleteCategory(type, cat);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
