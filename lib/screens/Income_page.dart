import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/Provider/image_capture.dart';
import 'package:expense_track/Transaction/TransactionForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  String? _capturedImagePath;

  void _handleCaptureImage() async {
    final path = await captureImageFromCamera();
    if (path != null) {
      setState(() {
        _capturedImagePath = path;
      });
    }
  }

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedWallet;
  bool isRepeat = false;
  bool _isSubmitting = false; // Added loading state

  final List<String> _categories = ['Salary', 'Freelance', 'Bonus'];
  final List<String> _wallets = ['Cash', 'Bank', 'Card'];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitIncome(double amount) async {
    if (_isSubmitting) return; // Prevent multiple submissions

    // Validate required fields
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedWallet == null || _selectedWallet!.isEmpty) {
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
      await Provider.of<BalanceProvider>(context, listen: false).addIncome(
        amount,
        _selectedCategory!,
        _descriptionController.text.trim(),
        _selectedWallet!,
        _capturedImagePath,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Income added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home page
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding income: $e'),
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
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: const Text('Income'),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
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
              controller: _amountController,
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
                buttonColor: Colors.green,
                imagePath: _capturedImagePath,
                onCaptureImage: _handleCaptureImage,
                onSubmit: (amount) async {
                  await _submitIncome(amount);
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
                amountController: _amountController,
                descriptionController: _descriptionController,
                isLoading: _isSubmitting, // Pass loading state to form
              ),
            ),
          ),
        ],
      ),
    );
  }
}
