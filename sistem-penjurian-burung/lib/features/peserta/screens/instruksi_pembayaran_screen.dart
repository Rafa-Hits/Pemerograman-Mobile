import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/services/cloudinary_service.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:flutter/foundation.dart';


class InstruksiPembayaranScreen extends ConsumerStatefulWidget {
  final PendaftaranModel pendaftaran;
  final String infoPembayaran;

  const InstruksiPembayaranScreen({
    super.key,
    required this.pendaftaran,
    required this.infoPembayaran,
  });

  @override
  ConsumerState<InstruksiPembayaranScreen> createState() => _InstruksiPembayaranScreenState();
}

class _InstruksiPembayaranScreenState extends ConsumerState<InstruksiPembayaranScreen> {
  Uint8List? _imageBytes;
  String? _fileName;

  bool _isLoading = false;

Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // 🔥 WAJIB UNTUK WEB
    );

    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

Future<void> _uploadBuktiPembayaran() async {
    if (_imageBytes == null || _fileName == null) return;

    setState(() => _isLoading = true);

    try {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      String url;

      if (kIsWeb) {
        // 🌐 WEB
        url = await cloudinary.uploadBuktiPembayaranWeb(
          _imageBytes!,
          _fileName!,
          widget.pendaftaran.id,
        );
      } else {
        // 📱 MOBILE (tidak akan masuk ke sini di web)
        throw Exception('Upload mobile tidak didukung di screen ini');
      }

      await ref
          .read(firestoreServiceProvider)
          .uploadBuktiPembayaran(widget.pendaftaran.id, url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti pembayaran berhasil diunggah')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI widget build tetap sama, tidak ada perubahan di sini)
    return Scaffold(
      appBar: AppBar(title: const Text('Instruksi Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Langkah Pembayaran:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('1. Lakukan transfer sejumlah:'),
          Text('Rp ${widget.pendaftaran.totalBayar}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
          Text('(Termasuk kode unik ${widget.pendaftaran.kodeUnik})', style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          const Text('2. Ke rekening berikut:'),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            child: Text(widget.infoPembayaran, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          const Text('3. Ambil screenshot bukti transfer Anda.'),
          const SizedBox(height: 16),
          const Text('4. Unggah bukti transfer di bawah ini:'),
          const SizedBox(height: 8),
          _imageBytes != null
              ? Image.memory(_imageBytes!, height: 200)
              : Container(height: 200, color: Colors.grey.shade300, child: const Icon(Icons.image, size: 50)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Pilih Gambar dari Galeri'),
            onPressed: _pickImage,
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Unggah Bukti Pembayaran'),
                  onPressed: _imageBytes != null ? _uploadBuktiPembayaran : null,
                ),
        ],
      ),
    );
  }
}
