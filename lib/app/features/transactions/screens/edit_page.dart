import 'package:expense_track/app/core/models/transaction_model.dart';
import 'package:expense_track/app/core/providers/balance_provider.dart';
import 'package:expense_track/app/core/providers/category_provider.dart';
import 'package:expense_track/app/core/providers/currency_provider.dart';
import 'package:expense_track/app/core/services/cloudinary_service.dart';
import 'package:expense_track/app/features/transactions/widgets/TransactionForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionModel transaction;
  final String transactionId;

  const EditTransactionPage({
    super.key,
    required this.transaction,
    required this.transactionId,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  String? selectedCategory;
  String? selectedWallet;
  String? cloudinaryImageUrl; // ONLY Cloudinary URL
  bool isRepeat = false;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  // Date selection variables
  DateTime _selectedDate = DateTime.now();
  bool _useCustomDate = false;

  final List<String> wallets = ['Cash', 'Card', 'Bank', 'Credit Card'];

  // Default categories based on transaction type
  final List<String> _defaultIncomeCategories = [
    'Salary',
    'Freelance',
    'Bonus',
  ];
  final List<String> _defaultExpenseCategories = [
    'Food',
    'Grocery',
    'Rent',
    'Taxi',
    '1 to 10',
    'Transfer',
  ];

  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    descriptionController = TextEditingController(
      text: widget.transaction.description,
    );

    selectedWallet = wallets.contains(widget.transaction.wallet)
        ? widget.transaction.wallet
        : wallets.first;

    selectedCategory = widget.transaction.category;

    // UPDATED: Only Cloudinary URL
    cloudinaryImageUrl = widget.transaction.receiptImageUrl;

    // Initialize date from transaction
    _selectedDate = widget.transaction.date;
    _useCustomDate = true; // Since we're editing, show the actual date

    // Load user categories based on transaction type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryType = widget.transaction.isIncome ? 'income' : 'expense';
      Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).loadUserCategories(categoryType);
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Get user ID from Firebase Auth
  String _getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Generate temporary transaction ID for upload
  String _generateTempTransactionId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Date selection method

  // Get categories based on transaction type - FIXED: Remove duplicates
  List<String> _getCategories(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final isIncome = widget.transaction.isIncome;

    final defaultCategories = isIncome
        ? _defaultIncomeCategories
        : _defaultExpenseCategories;

    final userCategories = isIncome
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    // Combine and remove duplicates
    final allCategories = [...defaultCategories, ...userCategories];

    // Remove duplicates while preserving order
    final uniqueCategories = <String>[];
    for (final category in allCategories) {
      if (!uniqueCategories.contains(category)) {
        uniqueCategories.add(category);
      }
    }

    // Add "Add Category" option at the end
    uniqueCategories.add('+ Add Category');

    return uniqueCategories;
  }

  // Handle category selection with custom category creation
  Future<void> _handleCategoryChange(String? value) async {
    if (value == '+ Add Category') {
      final newCategory = await _showAddCategoryDialog();
      if (newCategory != null && newCategory.isNotEmpty) {
        // Add the new category to user categories
        final categoryType = widget.transaction.isIncome ? 'income' : 'expense';
        await Provider.of<CategoryProvider>(
          context,
          listen: false,
        ).addUserCategory(newCategory, categoryType);

        // Update the selected category
        setState(() {
          selectedCategory = newCategory;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "$newCategory" added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() {
        selectedCategory = value;
      });
    }
  }

  // Show dialog to add new category
  Future<String?> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    final isIncome = widget.transaction.isIncome;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Add ${isIncome ? 'Income' : 'Expense'} Category',
          style: const TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: isIncome ? Colors.green : Colors.red,
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Build date selector widget

  // UPDATED: Image capture methods - Web compatible Cloudinary
  Future<void> _pickImage() async {
    // Show simplified options dialog - ONLY CLOUD
    final option = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small drag handle
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    onTap: () => Navigator.pop(context, 1),
                  ),
                  _buildOption(
                    icon: Icons.image,
                    label: "Image",
                    onTap: () => Navigator.pop(context, 2),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    if (option == null || option == 0) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      String? newImageUrl;
      final userId = _getUserId();

      switch (option) {
        case 1: // Camera + Cloudinary
          newImageUrl = await _cloudinaryService.takePhotoAndUpload(
            userId: userId,
            transactionId: _generateTempTransactionId(),
          );
          break;
        case 2: // Gallery + Cloudinary
          newImageUrl = await _cloudinaryService.pickFromGalleryAndUpload(
            userId: userId,
            transactionId: _generateTempTransactionId(),
          );
          break;
        case 3: // Remove image
          setState(() {
            cloudinaryImageUrl = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt removed'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
      }

      if (newImageUrl != null) {
        setState(() {
          cloudinaryImageUrl = newImageUrl; // Store Cloudinary URL
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Receipt updated in cloud!'),
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
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // UPDATED: Remove image method
  void _removeImage() {
    setState(() {
      cloudinaryImageUrl = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // UPDATED: Submit form with Cloudinary support and custom date
  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    final amount = double.tryParse(amountController.text) ?? 0;

    // Validation
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedWallet == null || selectedWallet!.isEmpty) {
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
      // Use custom date if enabled, otherwise use current date
      final transactionDate = _useCustomDate ? _selectedDate : DateTime.now();

      // UPDATED: Only Cloudinary URL, no local path with custom date
      await Provider.of<BalanceProvider>(
        context,
        listen: false,
      ).editTransaction(
        widget.transactionId,
        amount,
        selectedCategory!,
        descriptionController.text.trim(),
        selectedWallet!,
        cloudinaryImageUrl, // ONLY Cloudinary URL
        date: transactionDate, // Pass the selected date
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating transaction: $e'),
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
    final isIncome = widget.transaction.isIncome;
    final categories = _getCategories(context);

    // Ensure selected category exists in the current categories list
    // If not, set it to the first available category
    if (selectedCategory != null &&
        !categories.contains(selectedCategory) &&
        categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedCategory = categories.firstWhere(
            (category) => category != '+ Add Category',
            orElse: () => categories.isNotEmpty ? categories.first : 'Other',
          );
        });
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth >= 600 && screenWidth < 1000;
        final isDesktop = screenWidth >= 1000;
        final double topPadding = isTablet ? 40 : 30;
        final double amountFontSize = isTablet ? 38 : 30;
        final horizontalPadding = isDesktop ? screenWidth * 0.18 : 20.0;

        return Scaffold(
          backgroundColor: isIncome ? Colors.green : Colors.red,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(
              'Edit ${isIncome ? 'Income' : 'Expense'}',
              style: TextStyle(fontSize: isTablet ? 24 : 20),
            ),
            centerTitle: true,
            backgroundColor: isIncome ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
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
                          'Edit Amount',
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
                        child: Consumer<CurrencyProvider>(
                          builder: (context, currencyProvider, child) {
                            return TextFormField(
                              controller: amountController,
                              cursorColor: Colors.white,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: TextStyle(
                                fontSize: amountFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    '${currencyProvider.selectedCurrencySymbol} 0',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            );
                          },
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
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Date selector added here
                                TransactionForm(
                                  buttonColor: isIncome
                                      ? Colors.green
                                      : Colors.red,
                                  amountController: amountController,
                                  descriptionController: descriptionController,
                                  selectedCategory: selectedCategory,
                                  selectedWallet: selectedWallet,
                                  isRepeat: isRepeat,
                                  categories: categories,
                                  wallets: wallets,
                                  onCategoryChanged: _handleCategoryChange,
                                  onWalletChanged: (val) =>
                                      setState(() => selectedWallet = val),
                                  onRepeatChanged: (val) =>
                                      setState(() => isRepeat = val),
                                  imagePath: cloudinaryImageUrl,
                                  onCaptureImage: _pickImage,
                                  onRemoveImage: _removeImage,
                                  onSubmit: (_) => _submitForm(),
                                  isLoading: _isSubmitting,
                                  showImageUploadProgress: _isUploadingImage,
                                  selectedDate: _selectedDate,
                                  useCustomDate: _useCustomDate,
                                  onDateChanged: (date) =>
                                      setState(() => _selectedDate = date),
                                  onUseCustomDateChanged: (value) =>
                                      setState(() => _useCustomDate = value),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Upload progress overlay
              if (_isUploadingImage)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Uploading Receipt...',
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

Widget _buildOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(52, 33, 149, 243),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
