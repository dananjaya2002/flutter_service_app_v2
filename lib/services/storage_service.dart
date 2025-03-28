import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Upload user profile image
  Future<String> uploadUserImage(File imageFile, String userId) async {
    try {
      String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
      Reference reference = _storage.ref().child(
        'users/$userId/profile/$fileName',
      );

      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading user image: $e');
      rethrow;
    }
  }

  // Upload shop image
  Future<String> uploadShopImage(File imageFile, String shopId) async {
    try {
      String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
      Reference reference = _storage.ref().child('shops/$shopId/$fileName');

      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading shop image: $e');
      rethrow;
    }
  }

  // Upload category image
  Future<String> uploadCategoryImage(File imageFile, String categoryId) async {
    try {
      String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
      Reference reference = _storage.ref().child(
        'categories/$categoryId/$fileName',
      );

      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading category image: $e');
      rethrow;
    }
  }

  // Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference reference = _storage.refFromURL(imageUrl);
      await reference.delete();
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }
}
