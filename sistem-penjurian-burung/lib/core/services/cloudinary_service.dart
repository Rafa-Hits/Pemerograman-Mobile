import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      dotenv.env['CLOUDINARY_CLOUD_NAME']!,
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
      cache: false,
    );
  }

  // ======================
  // 📱 MOBILE (Android / iOS)
  // ======================
  Future<String> uploadBuktiPembayaranMobile(
    File file,
    String pendaftaranId,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'bukti_pembayaran/$pendaftaranId',
          publicId: '$pendaftaranId-$timestamp',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception('Gagal upload (mobile): $e');
    }
  }

  // ======================
  // 🌐 WEB (Chrome)
  // ======================
  Future<String> uploadBuktiPembayaranWeb(
    Uint8List bytes,
    String fileName,
    String pendaftaranId,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: '$pendaftaranId-$timestamp-$fileName',
          folder: 'bukti_pembayaran/$pendaftaranId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception('Gagal upload (web): $e');
    }
  }
}

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (ref) => CloudinaryService(),
);
