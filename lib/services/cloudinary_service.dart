import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Your credentials
  static const String _cloudName = 'defb6qmew';
  // ignore: unused_field
  static const String _apiKey = '396116621233937';
  static const String _uploadPreset = 'expene_tracker';

  // Upload image to Cloudinary
  Future<String> uploadImageToCloudinary({
    required XFile imageFile,
    required String userId,
    required String transactionId,
  }) async {
    try {
      print('Starting Cloudinary upload for user: $userId');

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
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // OPTION 1: Take photo with camera and upload directly to Cloudinary
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

  // OPTION 2: Pick from gallery and upload to Cloudinary
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

  // REMOVED: pickImageLocalOnly() - No local storage
  // REMOVED: takePhotoLocalOnly() - No local storage
}
