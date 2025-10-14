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
        : wallets.first; // Default to first if not found

    selectedCategory = categories.contains(widget.transaction.category)
        ? widget.transaction.category
        : categories.first; // Default to first if not found

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

    return Scaffold(
      backgroundColor: isIncome ? Colors.green : Colors.red,
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        centerTitle: true,
        backgroundColor: isIncome ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        leading: BackButton(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Edit Amount', style: TextStyle(color: Colors.white70)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              controller: amountController,
              cursorColor: Colors.white,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 30,
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
                onWalletChanged: (val) => setState(() => selectedWallet = val),
                onRepeatChanged: (val) => setState(() => isRepeat = val),
                imagePath: imagePath,
                onCaptureImage: _pickImage,
                onSubmit: (_) => _submitForm(),
                isLoading: _isSubmitting, // Pass loading state to form
              ),
            ),
          ),
        ],
      ),
    );
  }
}
