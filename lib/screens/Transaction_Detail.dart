// ignore_for_file: use_build_context_synchronously

import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/screens/Image_page.dart';
import 'package:expense_track/screens/edit_page.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:expense_track/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TransactionDetailPage extends StatefulWidget {
  final TransactionModel transaction;
  final String transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.transactionId,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isSaving = false;

  // void _showImageOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => SafeArea(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Text(
  //               'Receipt Options',
  //               style: GoogleFonts.poppins(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //           if (widget.transaction.receiptImageUrl != null) ...[
  //             ListTile(
  //               leading: const Icon(Icons.download, color: Colors.orange),
  //               title: Text('Save to Device', style: GoogleFonts.poppins()),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _saveImageToDevice();
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.visibility, color: Colors.blue),
  //               title: Text('View Full Screen', style: GoogleFonts.poppins()),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _viewFullScreen();
  //               },
  //             ),
  //             const Divider(),
  //           ],
  //           ListTile(
  //             leading: const Icon(Icons.info, color: Colors.grey),
  //             title: Text(
  //               'Receipt management available in edit page',
  //               style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
  //             ),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _navigateToEditPage();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _saveImageToDevice() async {
    if (widget.transaction.receiptImageUrl == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final fileName =
          'receipt_${widget.transactionId}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.jpg';

      final success = await _cloudinaryService.saveImageToDevice(
        widget.transaction.receiptImageUrl!,
        fileName,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt saved to device!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save receipt. Please check permissions.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving receipt: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _viewFullScreen() {
    if (widget.transaction.receiptImageUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imagePath: widget.transaction.receiptImageUrl!,
            isNetworkImage: true,
          ),
        ),
      );
    }
  }

  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionPage(
          transaction: widget.transaction,
          transactionId: widget.transactionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.isIncome;

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
          // Save to Device Button - Only show if receipt exists
          if (widget.transaction.receiptImageUrl != null)
            IconButton(
              color: Colors.white,
              onPressed: _isSaving ? null : _saveImageToDevice,
              icon: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.download),
              tooltip: 'Save to Device',
            ),

          // More Options Button
          // IconButton(
          //   color: Colors.white,
          //   onPressed: _showImageOptions,
          //   icon: Icon(Icons.more_vert),
          //   tooltip: 'More Options',
          // ),

          // Delete Button
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
                  ).deleteTransaction(widget.transactionId);

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
            tooltip: 'Delete Transaction',
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
                                  'AED ${widget.transaction.amount.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.transaction.category,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: ${DateFormat.yMMMd().add_jm().format(widget.transaction.date)}',
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
                          PhysicalModel(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildInfoColumn(
                                    "Type",
                                    widget.transaction.type[0].toUpperCase() +
                                        widget.transaction.type.substring(1),
                                  ),
                                  _buildInfoColumn(
                                    "Category",
                                    widget.transaction.category,
                                  ),
                                  _buildInfoColumn(
                                    "Wallet",
                                    widget.transaction.wallet,
                                  ),
                                ],
                              ),
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
                                  widget.transaction.description.isNotEmpty
                                      ? widget.transaction.description
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

                    // Image Section
                    if (widget.transaction.receiptImageUrl != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Receipt",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: isTablet ? 16 : 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildCloudinaryImagePreview(imageHeight, context),
                          ],
                        ),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Receipt",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Center(
                                child: Text(
                                  'No receipt attached\n(Add receipt in edit page)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          onPressed: _navigateToEditPage,
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

  Widget _buildCloudinaryImagePreview(
    double imageHeight,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: _viewFullScreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.transaction.receiptImageUrl!,
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

            // Overlay with save button
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
