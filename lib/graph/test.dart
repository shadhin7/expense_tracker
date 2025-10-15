// test_cloudinary_screen.dart
import 'package:expense_track/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TestCloudinaryScreen extends StatefulWidget {
  final String userId;

  TestCloudinaryScreen({required this.userId});

  @override
  _TestCloudinaryScreenState createState() => _TestCloudinaryScreenState();
}

class _TestCloudinaryScreenState extends State<TestCloudinaryScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  String? _imageUrl;
  bool _isUploading = false;

  Future<void> _testUpload() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Pick an image
      final XFile? image = await _cloudinaryService.pickImage();

      if (image != null) {
        // Upload the image
        String imageUrl = await _cloudinaryService.uploadReceiptImage(
          imageFile: image,
          userId: widget.userId,
          transactionId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        );

        setState(() {
          _imageUrl = imageUrl;
        });

        print('✅ SUCCESS! Image URL: $imageUrl');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cloudinary Test')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUploading) CircularProgressIndicator(),

            if (_imageUrl != null) ...[
              Text('✅ Upload Successful!', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Image.network(_imageUrl!, height: 200),
              SizedBox(height: 10),
              SelectableText(_imageUrl!, style: TextStyle(fontSize: 12)),
            ],

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isUploading ? null : _testUpload,
              child: Text(_isUploading ? 'Uploading...' : 'Test Image Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
