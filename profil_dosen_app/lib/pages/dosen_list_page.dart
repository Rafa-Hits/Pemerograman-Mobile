import 'package:flutter/material.dart';
import '../models/dosen_model.dart';
import '../widgets/dosen_card.dart';
import 'dosen_detail_page.dart';

class DosenListPage extends StatelessWidget {
  DosenListPage({Key? key}) : super(key: key);

  // Data dummy dosen
  final List<Dosen> daftarDosen = [
    Dosen(
      id: '1',
      nama: 'Ahmad Nasukha, S.Hum, M.Si.',
      nip: '1988072220171009',
      email: 'Ahmadnasukha@uinjambi.ac.id',
      jabatan: 'Dosen Tetap',
      bidang: 'Artificial Intelligence',
      foto: 'assets/images/dosen1.png',
      deskripsi:
          'Spesialis dalam bidang Artificial Intelligence dan Machine Learning dengan pengalaman lebih dari 10 tahun.',
      mataKuliah: [
        'Pemrograman Mobile',
        'Analisis Perancangan Sistem Informasi',
        'Manajemen Proyek Sistem Informasi'
      ],
    ),
    Dosen(
      id: '2',
      nama: 'M Theo Ari Bangsa, S.Kom, M.Cs',
      nip: '19922080720201031',
      email: 'Theoaribangsa@uinjambi.ac.id',
      jabatan: 'Dosen Luar Biasa',
      bidang: 'Backend Developer',
      foto: 'assets/images/dosen2.png',
      deskripsi:
          'Ahli dalam pengembangan software dan mobile application development.',
      mataKuliah: [
        'Rekayasa Perangkat Lunak',
        'Pemrogaraman Web',
        'Basis Data',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Dosen',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: ListView.builder(
          itemCount: daftarDosen.length,
          itemBuilder: (context, index) {
            final dosen = daftarDosen[index];
            return DosenCard(
              dosen: dosen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DosenDetailPage(dosen: dosen),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
