// ignore_for_file: use_build_context_synchronously

import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/Provider/category_provider.dart';
import 'package:expense_track/Transaction/TransactionForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _cloudinaryImageUrl; // ONLY Cloudinary URL

  String? _selectedCategory;
  String? _selectedWallet;
  bool isRepeat = false;
  bool _isSubmitting = false;

  final List<String> _defaultCategories = [
    'Food',
    'Grocery',
    'Rent',
    'Taxi',
    '1 to 10',
    'Transfer',
  ];

  final List<String> _wallets = ['Cash', 'Bank', 'Card', 'Credit Card'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).loadUserCategories('expense');
    });
  }

  @override
  void dispose() {
    _expenseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // UPDATED: Image capture methods - ONLY CLOUD OPTIONS
  void _handleCaptureImage() async {
    final balanceProvider = Provider.of<BalanceProvider>(
      context,
      listen: false,
    );

    // Show simplified options dialog - ONLY CLOUD
    final option = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Receipt'),
        content: Text('Upload receipt to cloud:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 1), // Camera + Cloudinary
            child: Text('📷 Take Photo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 2), // Gallery + Cloudinary
            child: Text('🖼️ Choose from Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 0), // Cancel
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    if (option == null || option == 0) return;

    try {
      String? imageUrl;

      switch (option) {
        case 1: // Camera + Cloudinary
          imageUrl = await balanceProvider.takePhotoAndUpload();
          break;
        case 2: // Gallery + Cloudinary
          imageUrl = await balanceProvider.pickFromGalleryAndUpload();
          break;
      }

      if (imageUrl != null) {
        setState(() {
          _cloudinaryImageUrl = imageUrl; // Store Cloudinary URL
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Receipt uploaded to cloud!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Upload failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // UPDATED: Remove image method
  void _removeImage() {
    setState(() {
      _cloudinaryImageUrl = null;
    });
  }

  // UPDATED: Submit expense with Cloudinary support ONLY
  Future<void> _submitExpense(double amount) async {
    if (_isSubmitting) return;

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedWallet == null || _selectedWallet!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wallet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // UPDATED: Only Cloudinary URL, no local path
      await Provider.of<BalanceProvider>(context, listen: false).addExpense(
        amount,
        _selectedCategory!,
        _descriptionController.text.trim(),
        _selectedWallet!,
        _cloudinaryImageUrl, // ONLY Cloudinary URL
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding expense: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final balanceProvider = Provider.of<BalanceProvider>(context);

    // Combine default + user categories + Add Category button
    final allCategories = [
      ..._defaultCategories,
      ...categoryProvider.expenseCategories,
      '+ Add Category',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth >= 600 && screenWidth < 1000;
        final isDesktop = screenWidth >= 1000;
        final double topPadding = isTablet ? 40 : 30;
        final double amountFontSize = isTablet ? 38 : 30;
        final horizontalPadding = isDesktop ? screenWidth * 0.2 : 20.0;

        return Scaffold(
          backgroundColor: Colors.red,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            title: Text(
              'Expense',
              style: TextStyle(fontSize: isTablet ? 24 : 20),
            ),
            centerTitle: true,
            leading: const BackButton(color: Colors.white),
          ),
          body: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: topPadding),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Text(
                          'How Much?',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isTablet ? 20 : 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: TextFormField(
                          controller: _expenseController,
                          cursorColor: Colors.white,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: TextStyle(
                            fontSize: amountFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'AED 0',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: amountFontSize,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: TransactionForm(
                            buttonColor: Colors.red,
                            imagePath:
                                _cloudinaryImageUrl, // ONLY Cloudinary URL
                            onCaptureImage: _handleCaptureImage,
                            onRemoveImage: _removeImage,
                            onSubmit: (amount) async =>
                                await _submitExpense(amount),
                            selectedCategory: _selectedCategory,
                            selectedWallet: _selectedWallet,
                            isRepeat: isRepeat,
                            categories: allCategories,
                            wallets: _wallets,
                            onCategoryChanged: (value) async {
                              if (value == '+ Add Category') {
                                final newCategory = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    final controller = TextEditingController();
                                    return AlertDialog(
                                      title: const Text('Add Expense Category'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter new category name',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            controller.text.trim(),
                                          ),
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (newCategory != null &&
                                    newCategory.isNotEmpty) {
                                  await Provider.of<CategoryProvider>(
                                    context,
                                    listen: false,
                                  ).addUserCategory(newCategory, 'expense');

                                  setState(() {
                                    _selectedCategory = newCategory;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Category "$newCategory" added!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                setState(() => _selectedCategory = value);
                              }
                            },
                            onWalletChanged: (value) =>
                                setState(() => _selectedWallet = value),
                            onRepeatChanged: (value) =>
                                setState(() => isRepeat = value),
                            amountController: _expenseController,
                            descriptionController: _descriptionController,
                            isLoading: _isSubmitting,
                            showImageUploadProgress:
                                balanceProvider.isUploadingImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Upload progress overlay
              if (balanceProvider.isUploadingImage)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Uploading to cloud...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
