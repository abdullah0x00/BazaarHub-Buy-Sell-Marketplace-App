import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for uploading images to Cloudinary
class CloudinaryService {
  // CONFIGURATION: Replace these with your own Cloudinary credentials
  static const String _cloudName = 'dvkq6q7qv'; // Default placeholder
  static const String _uploadPreset = 'marketplace_app'; // Default placeholder
  
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  /// Uploads a file to Cloudinary and returns the secure URL
  Future<String> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseString);
        return jsonResponse['secure_url'];
      } else {
        debugPrint('Cloudinary Error: ${response.statusCode} - $responseString');
        return '';
      }
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
      return '';
    }
  }

  /// Uploads multiple images and returns a list of URLs
  Future<List<String>> uploadMultipleImages(List<File> images) async {
    List<String> urls = [];
    for (var image in images) {
      final url = await uploadImage(image);
      if (url.isNotEmpty) urls.add(url);
    }
    return urls;
  }
}
