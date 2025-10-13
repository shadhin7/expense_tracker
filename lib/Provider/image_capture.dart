import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

Future<String?> captureImageFromCamera() async {
  final picker = ImagePicker();
  final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

  if (pickedImage == null) return null;

  // Save to app directory
  final directory = await getApplicationDocumentsDirectory();
  final name = basename(pickedImage.path);
  final savedImage = await File(
    pickedImage.path,
  ).copy('${directory.path}/$name');

  return savedImage.path; // save this path in TransactionModel
}
