import 'package:expense_track/widgets/CustomDropdown.dart';
import 'package:expense_track/widgets/RepeatToggle.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final VoidCallback? onRemoveImage;
  final bool isLoading;
  final bool showImageUploadProgress;

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
    this.onRemoveImage,
    this.isLoading = false,
    this.showImageUploadProgress = false,
  });

  // REMOVED: _isLocalImage getter since we don't need local storage

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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

    // FIXED: Calculate image height here where we have context
    final double imageHeight = _getImageHeight(screenWidth, screenHeight);

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

                // 📎 Image Attachment Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image upload button
                    TextButton.icon(
                      onPressed: isLoading || showImageUploadProgress
                          ? null
                          : onCaptureImage,
                      icon: Icon(
                        Icons.attach_file_rounded,
                        color: (isLoading || showImageUploadProgress)
                            ? Colors.grey
                            : Colors.blueGrey,
                        size: isTablet ? 24 : 20,
                      ),
                      label: showImageUploadProgress
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blueGrey,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Uploading...',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Add receipt',
                              style: TextStyle(
                                color: (isLoading || showImageUploadProgress)
                                    ? Colors.grey
                                    : Colors.blueGrey,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                    ),

                    // 🖼️ Display selected image
                    if (imagePath != null && imagePath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                // FIXED: Pass imageHeight to _buildImagePreview
                                child: _buildImagePreview(imageHeight),
                              ),
                            ),

                            // Remove image button
                            if (onRemoveImage != null &&
                                !showImageUploadProgress)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: onRemoveImage,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🟢 Submit Button
                ElevatedButton(
                  onPressed: isLoading || showImageUploadProgress
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

  // FIXED: Accept imageHeight as parameter instead of using context
  // UPDATED: Removed local image handling
  Widget _buildImagePreview(double imageHeight) {
    // Only handle network images (cloud storage)
    if (imagePath != null &&
        (imagePath!.startsWith('http://') ||
            imagePath!.startsWith('https://'))) {
      // Cloudinary network image
      return CachedNetworkImage(
        imageUrl: imagePath!,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: imageHeight,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: imageHeight,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Failed to load image'),
            ],
          ),
        ),
      );
    } else {
      // Fallback - no local images, only cloud
      return Container(
        height: imageHeight,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('No image selected'),
          ],
        ),
      );
    }
  }

  // FIXED: Use screen dimensions instead of context
  double _getImageHeight(double screenWidth, double screenHeight) {
    if (screenWidth >= 1000) return screenHeight * 0.35;
    if (screenWidth >= 600) return screenHeight * 0.25;
    return screenHeight * 0.2;
  }

  // REMOVED: _checkImageExists method since we don't need to check local files
}
