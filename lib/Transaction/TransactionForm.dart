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
  final bool isLoading;

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
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;
    final isDesktop = screenWidth >= 1000;

    // dynamic spacing and font scaling
    final labelFontSize = isTablet ? 18.0 : (isDesktop ? 20.0 : 16.0);
    final fieldVerticalPadding = isTablet ? 20.0 : 16.0;
    final horizontalPadding = isDesktop
        ? screenWidth * 0.25
        : isTablet
        ? screenWidth * 0.15
        : 21.0;

    final buttonPadding = EdgeInsets.symmetric(
      horizontal: isTablet ? 36 : 30,
      vertical: isTablet ? 18 : 14,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 💬 Description Field
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: labelFontSize,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: fieldVerticalPadding,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 📂 Category Dropdown
                CustomDropdown(
                  label: 'Category',
                  value: selectedCategory,
                  items: categories,
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(height: 20),

                // 💼 Wallet Dropdown
                CustomDropdown(
                  label: 'Wallet',
                  value: selectedWallet,
                  items: wallets,
                  onChanged: onWalletChanged,
                ),
                const SizedBox(height: 20),

                // 🔁 Repeat Toggle
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Repeat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  subtitle: const Text('Repeat transaction'),
                  trailing: RepeatToggle(
                    value: isRepeat,
                    onChanged: onRepeatChanged,
                  ),
                ),
                const SizedBox(height: 10),

                // 📎 Image Attachment
                TextButton.icon(
                  onPressed: isLoading ? null : onCaptureImage,
                  icon: Icon(
                    Icons.attach_file_rounded,
                    color: isLoading ? Colors.grey : Colors.blueGrey,
                    size: isTablet ? 24 : 20,
                  ),
                  label: Text(
                    'Add attachment',
                    style: TextStyle(
                      color: isLoading ? Colors.grey : Colors.blueGrey,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),

                // 🖼️ Display selected image (responsive)
                if (imagePath != null && imagePath!.isNotEmpty)
                  FutureBuilder<bool>(
                    future: _checkImageExists(imagePath!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 150,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data == true) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(imagePath!),
                            height: isTablet
                                ? 240
                                : isDesktop
                                ? 280
                                : 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return Container(
                          height: isTablet ? 240 : 150,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No image selected'),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                const SizedBox(height: 24),

                // 🟢 Submit Button
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final amountText = amountController.text.trim();
                          final amount = double.tryParse(amountText);

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

                          if (selectedWallet == null ||
                              selectedWallet!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a wallet'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          onSubmit(amount);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: buttonPadding,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: TextStyle(fontSize: isTablet ? 18 : 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _checkImageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (_) {
      return false;
    }
  }
}
