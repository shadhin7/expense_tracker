import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Replace these with your actual credentials from Step 2 & 3
  static const String _cloudName = ''; // From dashboard
  static const String _uploadPreset = 'expense_tracker_unsigned'; // From step 3

  // Method to upload receipt image
  Future<String> uploadReceiptImage({
    required XFile imageFile,
    required String userId,
    required String transactionId,
  }) async {
    try {
      print('Starting image upload...');

      // Create the upload URL
      final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

      // Create the request
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = 'expense_tracker/$userId/receipts'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      print('Sending request to Cloudinary...');

      // Send the request
      var response = await request.send();

      // Check if upload was successful
      if (response.statusCode == 200) {
        print('Upload successful! Getting response...');

        // Get the response data
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        // Get the image URL
        String imageUrl = jsonResponse['secure_url'];
        print('Image uploaded successfully: $imageUrl');

        return imageUrl;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Helper method to pick image from gallery
  Future<XFile?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Helper method to take photo with camera
  Future<XFile?> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      return photo;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }
}
