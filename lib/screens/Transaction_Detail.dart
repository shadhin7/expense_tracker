// ignore_for_file: use_build_context_synchronously

import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/screens/Image_page.dart';
import 'package:expense_track/screens/edit_page.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        scrolledUnderElevation: 0,
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

                    // UPDATED: Image Section - ONLY CLOUDINARY
                    if (transaction.receiptImageUrl != null) ...[
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
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            _buildCloudinaryImagePreview(imageHeight, context),
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

  // UPDATED: Build image preview for Cloudinary images only
  Widget _buildCloudinaryImagePreview(
    double imageHeight,
    BuildContext context,
  ) {
    final cloudinaryUrl = transaction.receiptImageUrl;

    if (cloudinaryUrl == null) {
      return Container(
        height: imageHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
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

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imagePath: cloudinaryUrl,
            isNetworkImage: true,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: cloudinaryUrl,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: imageHeight,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: imageHeight,
                color: Colors.grey[300],
                child: const Column(
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
          ],
        ),
      ),
    );
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
