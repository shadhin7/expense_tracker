import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/Transaction/TransactionForm.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String? imagePath;
  bool isRepeat = false;
  bool _isSubmitting = false; // Added loading state

  final List<String> wallets = ['Cash', 'Card', 'Bank', 'Credit Card'];
  final List<String> categories = [
    'Food',
    'Grocery',
    'Rent',
    'Taxi',
    '1 to 10',
    'Salary',
    'Freelance',
    'Bonus',
  ];

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

    selectedCategory = categories.contains(widget.transaction.category)
        ? widget.transaction.category
        : categories.first;

    imagePath = widget.transaction.imagePath;
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return; // Prevent multiple submissions

    final amount = double.tryParse(amountController.text) ?? 0;

    // Validation
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedWallet == null || selectedWallet!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      await Provider.of<BalanceProvider>(
        context,
        listen: false,
      ).editTransaction(
        widget.transactionId,
        amount,
        selectedCategory!,
        descriptionController.text.trim(),
        selectedWallet!,
        imagePath,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
            title: const Text('Edit Transaction'),
            centerTitle: true,
            backgroundColor: isIncome ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
            leading: BackButton(color: Colors.white),
          ),
          body: Center(
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
                    child: TextFormField(
                      controller: amountController,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: amountFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'AED 0',
                        hintStyle: TextStyle(color: Colors.white),
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
                        buttonColor: isIncome ? Colors.green : Colors.red,
                        amountController: amountController,
                        descriptionController: descriptionController,
                        selectedCategory: selectedCategory,
                        selectedWallet: selectedWallet,
                        isRepeat: isRepeat,
                        categories: categories,
                        wallets: wallets,
                        onCategoryChanged: (val) =>
                            setState(() => selectedCategory = val),
                        onWalletChanged: (val) =>
                            setState(() => selectedWallet = val),
                        onRepeatChanged: (val) =>
                            setState(() => isRepeat = val),
                        imagePath: imagePath,
                        onCaptureImage: _pickImage,
                        onSubmit: (_) => _submitForm(),
                        isLoading: _isSubmitting,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
