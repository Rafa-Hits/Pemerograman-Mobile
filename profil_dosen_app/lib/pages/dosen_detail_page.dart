import 'package:flutter/material.dart';
import '../models/dosen_model.dart';

class DosenDetailPage extends StatelessWidget {
  final Dosen dosen;

  const DosenDetailPage({Key? key, required this.dosen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Dosen',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan foto
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(dosen.foto),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dosen.nama,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dosen.jabatan,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Informasi detail
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bidang Keahlian
                  _buildInfoCard(
                    icon: Icons.work_outline,
                    title: 'Bidang Keahlian',
                    content: dosen.bidang,
                  ),

                  const SizedBox(height: 16),

                  // Informasi Kontak
                  _buildInfoCard(
                    icon: Icons.contact_mail,
                    title: 'Informasi Kontak',
                    children: [
                      _buildInfoRow('NIP', dosen.nip),
                      _buildInfoRow('Email', dosen.email),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Deskripsi
                  _buildInfoCard(
                    icon: Icons.description,
                    title: 'Deskripsi',
                    content: dosen.deskripsi,
                  ),

                  const SizedBox(height: 16),

                  // Mata Kuliah
                  _buildInfoCard(
                    icon: Icons.menu_book,
                    title: 'Mata Kuliah yang Diampu',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dosen.mataKuliah.map((mk) {
                          return Chip(
                            label: Text(
                              mk,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: Colors.blue[50],
                            side: BorderSide(color: Colors.blue[100]!),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? content,
    List<Widget>? children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (content != null)
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}
