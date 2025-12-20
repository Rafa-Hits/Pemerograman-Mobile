import 'package:flutter/material.dart';
import 'pages/dosen_list_page.dart';

void main() {
  runApp(const ProfilDosenApp());
}

class ProfilDosenApp extends StatelessWidget {
  const ProfilDosenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Dosen App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: DosenListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
