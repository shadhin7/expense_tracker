import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/Transaction/TransactionForm.dart';
import 'package:expense_track/models/transaction_model.dart';
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
  String? imagePath;
  String? cloudinaryImageUrl; // ADD THIS: Cloudinary URL
  bool isRepeat = false;
  bool _isSubmitting = false;

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

    // UPDATED: Initialize both image paths
    imagePath = widget.transaction.localImagePath;
    cloudinaryImageUrl = widget.transaction.receiptImageUrl;
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // UPDATED: Image capture methods with Cloudinary options
  Future<void> _pickImage() async {
    final balanceProvider = Provider.of<BalanceProvider>(
      context,
      listen: false,
    );

    // Show options dialog
    final option = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Receipt'),
        content: Text('Choose how to update receipt image:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 1), // Camera + Cloudinary
            child: Text('📸 Camera + Cloud'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 2), // Gallery + Cloudinary
            child: Text('🖼️ Gallery + Cloud'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 3), // Local only
            child: Text('📱 Local Only'),
          ),
          if (cloudinaryImageUrl != null ||
              imagePath != null) // ADD THIS: Remove option
            TextButton(
              onPressed: () => Navigator.pop(context, 4), // Remove image
              child: Text('🗑️ Remove Receipt'),
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
      String? newImageUrl;
      String? newLocalPath;

      switch (option) {
        case 1: // Camera + Cloudinary
          newImageUrl = await balanceProvider.takePhotoAndUpload();
          break;
        case 2: // Gallery + Cloudinary
          newImageUrl = await balanceProvider.pickFromGalleryAndUpload();
          break;
        case 3: // Local only
          newLocalPath = await balanceProvider.getLocalImagePath();
          break;
        case 4: // Remove image
          setState(() {
            cloudinaryImageUrl = null;
            imagePath = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Receipt removed'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
      }

      if (newImageUrl != null || newLocalPath != null) {
        setState(() {
          cloudinaryImageUrl = newImageUrl; // Store Cloudinary URL
          imagePath = newLocalPath; // Store local path
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newImageUrl != null
                  ? '✅ Receipt updated in cloud!'
                  : '📱 Receipt updated locally',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ADD THIS: Remove image method
  void _removeImage() {
    setState(() {
      cloudinaryImageUrl = null;
      imagePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // UPDATED: Submit form with Cloudinary support
  Future<void> _submitForm() async {
    if (_isSubmitting) return;

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
      // UPDATED: Use both Cloudinary URL and local path
      await Provider.of<BalanceProvider>(
        context,
        listen: false,
      ).editTransaction(
        widget.transactionId,
        amount,
        selectedCategory!,
        descriptionController.text.trim(),
        selectedWallet!,
        cloudinaryImageUrl, // Cloudinary URL (priority)
        imagePath, // Local path (backup)
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
    final balanceProvider = Provider.of<BalanceProvider>(context); // ADD THIS

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
                            // UPDATED: Show Cloudinary URL first
                            imagePath: cloudinaryImageUrl ?? imagePath,
                            onCaptureImage: _pickImage,
                            onRemoveImage: _removeImage, // ADD THIS
                            onSubmit: (_) => _submitForm(),
                            isLoading: _isSubmitting,
                            // ADD THIS: Show upload progress
                            showImageUploadProgress:
                                balanceProvider.isUploadingImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ADD THIS: Show upload progress overlay
              if (balanceProvider.isUploadingImage)
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
                        SizedBox(height: 16),
                        Text(
                          'Uploading receipt to cloud...',
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
