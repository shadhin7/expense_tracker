import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html; // Use only this for web
import 'package:path_provider/path_provider.dart'; // For mobile save
import 'package:permission_handler/permission_handler.dart'; // For permissions
import 'dart:io'; // For mobile

class CloudinaryService {
  // Your credentials
  static const String _cloudName = 'defb6qmew';
  static const String _apiKey = '396116621233937';
  static const String _uploadPreset = 'expene_tracker';

  // Upload image to Cloudinary (Web & Mobile compatible)
  Future<String> uploadImageToCloudinary({
    required XFile imageFile,
    required String userId,
    required String transactionId,
  }) async {
    try {
      print('Starting Cloudinary upload for user: $userId');

      final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

      // For web, we need to handle file differently
      if (_isWeb()) {
        return await _uploadImageWeb(imageFile, userId, transactionId);
      } else {
        return await _uploadImageMobile(imageFile, userId, transactionId);
      }
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Mobile upload implementation
  Future<String> _uploadImageMobile(
    XFile imageFile,
    String userId,
    String transactionId,
  ) async {
    final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'expense_tracker/$userId/receipts'
      ..fields['public_id'] =
          'receipt_${transactionId}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      String imageUrl = jsonResponse['secure_url'];
      print('✅ Image uploaded to Cloudinary: $imageUrl');
      return imageUrl;
    } else {
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }

  // Web upload implementation
  Future<String> _uploadImageWeb(
    XFile imageFile,
    String userId,
    String transactionId,
  ) async {
    final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

    // Convert XFile to bytes for web
    final bytes = await imageFile.readAsBytes();

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'expense_tracker/$userId/receipts'
      ..fields['public_id'] =
          'receipt_${transactionId}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'receipt_$transactionId.jpg',
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      String imageUrl = jsonResponse['secure_url'];
      print('✅ Image uploaded to Cloudinary (Web): $imageUrl');
      return imageUrl;
    } else {
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }

  // Check if running on web
  bool _isWeb() {
    return identical(0, 0.0);
  }

  // OPTION 1: Take photo with camera
  Future<String?> takePhotoAndUpload({
    required String userId,
    required String transactionId,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null) {
        print('📸 Photo taken, uploading to Cloudinary...');
        String cloudinaryUrl = await uploadImageToCloudinary(
          imageFile: photo,
          userId: userId,
          transactionId: transactionId,
        );
        return cloudinaryUrl;
      }
      return null;
    } catch (e) {
      print('❌ Camera error: $e');
      return null;
    }
  }

  // OPTION 2: Pick from gallery
  Future<String?> pickFromGalleryAndUpload({
    required String userId,
    required String transactionId,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        print('🖼️ Image selected from gallery, uploading to Cloudinary...');
        String cloudinaryUrl = await uploadImageToCloudinary(
          imageFile: image,
          userId: userId,
          transactionId: transactionId,
        );
        return cloudinaryUrl;
      }
      return null;
    } catch (e) {
      print('❌ Gallery error: $e');
      return null;
    }
  }

  // NEW: Save image to device (Mobile & Web compatible)
  Future<bool> saveImageToDevice(String imageUrl, String fileName) async {
    try {
      if (_isWeb()) {
        return await _saveImageWeb(imageUrl, fileName);
      } else {
        return await _saveImageMobile(imageUrl, fileName);
      }
    } catch (e) {
      print('❌ Save image error: $e');
      return false;
    }
  }

  // Save image on mobile
  Future<bool> _saveImageMobile(String imageUrl, String fileName) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        return false;
      }

      // Download image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Get downloads directory
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          return false;
        }

        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);

        print('✅ Image saved to: ${file.path}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Mobile save error: $e');
      return false;
    }
  }

  // Save image on web - UPDATED to use only universal_html
  Future<bool> _saveImageWeb(String imageUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..download = fileName
          ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print('✅ Image saved on web: $fileName');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Web save error: $e');
      return false;
    }
  }

  // NEW: Get image from URL as bytes (for preview/saving)
  Future<Uint8List?> getImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('❌ Get image bytes error: $e');
      return null;
    }
  }
}
