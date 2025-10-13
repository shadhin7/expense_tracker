import 'package:expense_track/Provider/balance_provider.dart'; // Updated import
import 'package:expense_track/Provider/image_capture.dart';
import 'package:expense_track/Transaction/TransactionForm.dart';
import 'package:expense_track/screens/home_page.dart'; // Fixed case
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final TextEditingController _expenseController =
      TextEditingController(); // Fixed naming
  final TextEditingController _descriptionController = TextEditingController();
  String? _capturedImagePath;

  void _handleCaptureImage() async {
    final path = await captureImageFromCamera();
    if (path != null) {
      setState(() {
        _capturedImagePath = path;
      });
    }
  }

  String? _selectedCategory;
  String? _selectedWallet;
  bool isRepeat = false;
  bool _isLoading = true;

  final List<String> _categories = [
    'Food',
    'Grocery', // Fixed case
    'Rent',
    'Taxi',
    '1 to 10',
    'Transfer',
  ];
  final List<String> _wallets = ['Cash', 'Bank', 'Card', 'Credit Card'];

  @override
  void dispose() {
    _expenseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        title: const Text('Expense'),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('How Much?', style: TextStyle(color: Colors.white70)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              controller: _expenseController,
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
                buttonColor: Colors.red,
                imagePath: _capturedImagePath,
                onCaptureImage: _handleCaptureImage,
                onSubmit: (amount) async {
                  try {
                    await Provider.of<BalanceProvider>(
                      context,
                      listen: false,
                    ).addExpense(
                      amount,
                      _selectedCategory ?? 'Other',
                      _descriptionController.text.trim(),
                      _selectedWallet ?? 'Cash',
                      _capturedImagePath,
                    );

                    // Navigate back to home page
                    Navigator.of(context);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Expense added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding expense: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                selectedCategory: _selectedCategory,
                selectedWallet: _selectedWallet,
                isRepeat: isRepeat,
                categories: _categories,
                wallets: _wallets,
                onCategoryChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                onWalletChanged: (value) {
                  setState(() => _selectedWallet = value);
                },
                onRepeatChanged: (value) {
                  setState(() => isRepeat = value);
                },
                amountController: _expenseController,
                descriptionController: _descriptionController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
