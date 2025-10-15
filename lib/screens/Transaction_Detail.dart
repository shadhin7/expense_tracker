// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/screens/edit_page.dart';
import 'package:expense_track/screens/image_page.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ADD THIS

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transaction;
  final String transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isIncome ? Colors.green : Colors.red,
        title: Text(
          "Transaction Details",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Transaction'),
                  content: const Text(
                    'Are you sure you want to delete this transaction? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await Provider.of<BalanceProvider>(
                    context,
                    listen: false,
                  ).deleteTransaction(transactionId);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting transaction: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isTablet = width >= 600 && width < 1000;
          final isDesktop = width >= 1000;
          final imageHeight = isTablet ? 260.0 : (isDesktop ? 320.0 : 200.0);

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.only(
                        top: 30,
                        left: 16,
                        right: 16,
                        bottom: 40,
                      ),
                      decoration: BoxDecoration(
                        color: isIncome ? Colors.green : Colors.red,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'AED ${transaction.amount.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  transaction.category,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: ${DateFormat.yMMMd().add_jm().format(transaction.date)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),

                    // Info Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoColumn(
                                  "Type",
                                  transaction.type[0].toUpperCase() +
                                      transaction.type.substring(1),
                                ),
                                _buildInfoColumn(
                                  "Category",
                                  transaction.category,
                                ),
                                _buildInfoColumn("Wallet", transaction.wallet),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Description
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  transaction.description.isNotEmpty
                                      ? transaction.description
                                      : 'No description provided',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // UPDATED: Image Section with Cloudinary support
                    if (transaction.hasImage) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Receipt",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: isTablet ? 16 : 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // ADD THIS: Cloudinary badge
                                  // if (transaction.receiptImageUrl != null)
                                  //   Container(
                                  //     padding: EdgeInsets.symmetric(
                                  //       horizontal: 6,
                                  //       vertical: 2,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.green,
                                  //       borderRadius: BorderRadius.circular(6),
                                  //     ),
                                  //     child: Row(
                                  //       mainAxisSize: MainAxisSize.min,
                                  //       children: [
                                  //         Icon(
                                  //           Icons.cloud,
                                  //           color: Colors.white,
                                  //           size: 12,
                                  //         ),
                                  //         SizedBox(width: 4),
                                  //         Text(
                                  //           'Cloud',
                                  //           style: TextStyle(
                                  //             color: Colors.white,
                                  //             fontSize: 10,
                                  //             fontWeight: FontWeight.bold,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                            _buildImagePreview(imageHeight, context),
                          ],
                        ),
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'No receipt attached',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Edit Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isIncome
                                ? Colors.green
                                : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditTransactionPage(
                                transaction: transaction,
                                transactionId: transactionId,
                              ),
                            ),
                          ),
                          child: Text(
                            "Edit Transaction",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ADD THIS: Build image preview for both Cloudinary and local images
  // REPLACE the _buildImagePreview method with this:
  Widget _buildImagePreview(double imageHeight, BuildContext context) {
    // ADD context parameter
    // Use displayImage getter which prioritizes Cloudinary URL
    final displayImage = transaction.displayImage;

    if (displayImage == null) {
      return Container(
        height: imageHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('No image available'),
            ],
          ),
        ),
      );
    }

    // Check if it's a network image (Cloudinary)
    final isNetworkImage = displayImage.startsWith('http');

    if (isNetworkImage) {
      // Cloudinary image
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              imagePath: displayImage,
              isNetworkImage: true,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: displayImage,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: imageHeight,
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: imageHeight,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Failed to load image'),
                    ],
                  ),
                ),
              ),
              // Cloudinary badge overlay
              // Positioned(
              //   top: 8,
              //   right: 8,
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: Colors.black54,
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(Icons.cloud_upload, color: Colors.white, size: 12),
              //         SizedBox(width: 4),
              //         Text(
              //           'Cloud',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 10,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      );
    } else {
      // Local image
      return FutureBuilder<bool>(
        future: _checkImageExists(displayImage),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: imageHeight,
              color: Colors.grey[200],
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    imagePath: displayImage,
                    isNetworkImage: false,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(displayImage),
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }

          return Container(
            height: imageHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image not found'),
              ],
            ),
          );
        },
      );
    }
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

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
