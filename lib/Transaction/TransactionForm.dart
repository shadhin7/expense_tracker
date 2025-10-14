import 'dart:io';
import 'package:expense_track/widgets/CustomDropdown.dart';
import 'package:expense_track/widgets/RepeatToggle.dart';
import 'package:flutter/material.dart';

class TransactionForm extends StatelessWidget {
  final Color buttonColor;
  final TextEditingController amountController;
  final String? selectedCategory;
  final String? selectedWallet;
  final bool isRepeat;
  final List<String> categories;
  final List<String> wallets;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onWalletChanged;
  final ValueChanged<bool> onRepeatChanged;
  final ValueChanged<double> onSubmit;
  final TextEditingController descriptionController;
  final String? imagePath;
  final VoidCallback onCaptureImage;
  final bool isLoading; // ADD THIS

  const TransactionForm({
    super.key,
    required this.buttonColor,
    required this.amountController,
    required this.selectedCategory,
    required this.selectedWallet,
    required this.isRepeat,
    required this.categories,
    required this.wallets,
    required this.onCategoryChanged,
    required this.onWalletChanged,
    required this.onRepeatChanged,
    required this.onSubmit,
    required this.descriptionController,
    required this.imagePath,
    required this.onCaptureImage,
    this.isLoading = false, // ADD THIS with default value
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description Field
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black12, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            CustomDropdown(
              label: 'Category',
              value: selectedCategory,
              items: categories,
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 20),

            // Wallet Dropdown
            CustomDropdown(
              label: 'Wallet',
              value: selectedWallet,
              items: wallets,
              onChanged: onWalletChanged,
            ),
            const SizedBox(height: 20),

            // Repeat Toggle
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Repeat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Repeat transaction'),
              trailing: RepeatToggle(
                value: isRepeat,
                onChanged: onRepeatChanged,
              ),
            ),
            const SizedBox(height: 10),

            // Image Attachment
            TextButton.icon(
              onPressed: isLoading
                  ? null
                  : onCaptureImage, // Disable when loading
              label: Text(
                'Add attachment',
                style: TextStyle(
                  color: isLoading ? Colors.grey : Colors.blueGrey,
                ),
              ),
              icon: Icon(
                Icons.attach_file_rounded,
                color: isLoading ? Colors.grey : Colors.blueGrey,
              ),
            ),

            // Display selected image
            if (imagePath != null && imagePath!.isNotEmpty)
              FutureBuilder<bool>(
                future: _checkImageExists(imagePath!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasData && snapshot.data == true) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(imagePath!),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                Text('Image not available'),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 40, color: Colors.grey),
                          Text('No image selected'),
                        ],
                      ),
                    );
                  }
                },
              ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),

            // Submit Button - UPDATED with loading state
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      // Disable when loading
                      final amountText = amountController.text.trim();
                      final amount = double.tryParse(amountText);

                      // Validation
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid amount'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (selectedCategory == null ||
                          selectedCategory!.isEmpty) {
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

                      // All validations passed, submit the form
                      onSubmit(amount);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to check if image file exists
  Future<bool> _checkImageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
