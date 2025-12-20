import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State untuk pengaturan
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Indonesia';
  bool _privacyMode = false;
  double _fontSize = 16.0;

  final List<String> _languages = [
    'Indonesia',
    'English',
    '日本語',
    '中文',
  ];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Bahasa'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (BuildContext context, int index) {
                final language = _languages[index];
                return ListTile(
                  title: Text(language),
                  trailing: language == _selectedLanguage
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                    _showSnackBar('Bahasa diubah ke: $language');
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bantuan'),
          content: const SingleChildScrollView(
            child: Text(
              'Aplikasi Flutter Navigation Demo\n\n'
              'Fitur yang tersedia:\n'
              '• Navigasi antar halaman\n'
              '• Edit profile dengan validasi\n'
              '• Pengaturan yang dapat disesuaikan\n'
              '• Bottom Navigation Bar\n'
              '• Material Design 3\n\n'
              'Untuk pertanyaan lebih lanjut, hubungi support@example.com',
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kebijakan Privasi'),
          content: const SingleChildScrollView(
            child: Text(
              'Kebijakan Privasi Flutter Navigation Demo\n\n'
              '1. Data yang Kami Kumpulkan\n'
              'Kami hanya menyimpan data yang Anda input di aplikasi secara lokal.\n\n'
              '2. Penggunaan Data\n'
              'Data digunakan hanya untuk keperluan fungsionalitas aplikasi.\n\n'
              '3. Keamanan Data\n'
              'Kami menjaga keamanan data Anda dengan penyimpanan lokal yang aman.\n\n'
              '4. Perubahan Kebijakan\n'
              'Kebijakan privasi dapat berubah dari waktu ke waktu.',
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tentang Aplikasi'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Flutter Navigation Demo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Versi: 1.0.0'),
                Text('Build: 2024.01.001'),
                SizedBox(height: 16),
                Text(
                  'Aplikasi demo untuk menunjukkan berbagai teknik navigasi dan state management dalam Flutter.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Pengaturan'),
          content: const Text(
              'Apakah Anda yakin ingin mengembalikan semua pengaturan ke nilai default?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _notificationsEnabled = true;
                  _darkModeEnabled = false;
                  _selectedLanguage = 'Indonesia';
                  _privacyMode = false;
                  _fontSize = 16.0;
                });
                Navigator.pop(context);
                _showSnackBar('Pengaturan telah direset ke default');
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _showResetDialog,
            tooltip: 'Reset Pengaturan',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Section: Umum
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Umum',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifikasi'),
                  subtitle: const Text('Aktifkan notifikasi aplikasi'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _showSnackBar(value
                          ? 'Notifikasi diaktifkan'
                          : 'Notifikasi dimatikan');
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Bahasa'),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showLanguageDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Tema Gelap'),
                  subtitle: const Text('Ubah tampilan menjadi mode gelap'),
                  trailing: Switch(
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                      _showSnackBar(value
                          ? 'Mode gelap diaktifkan'
                          : 'Mode gelap dimatikan');
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.visibility_off),
                  title: const Text('Mode Privasi'),
                  subtitle: const Text('Sembunyikan data sensitif'),
                  trailing: Switch(
                    value: _privacyMode,
                    onChanged: (value) {
                      setState(() {
                        _privacyMode = value;
                      });
                      _showSnackBar(value
                          ? 'Mode privasi diaktifkan'
                          : 'Mode privasi dimatikan');
                    },
                  ),
                ),
              ],
            ),
          ),

          // Section: Tampilan
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tampilan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ukuran Font: ${_fontSize.toInt()}px'),
                      const SizedBox(height: 8),
                      Slider(
                        value: _fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 6,
                        label: _fontSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Section: Tentang
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Bantuan & Dukungan'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showHelpDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Kebijakan Privasi'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showPrivacyPolicy,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Tentang Aplikasi'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showAboutDialog,
                ),
              ],
            ),
          ),

          // Section: Aksi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Kembali ke halaman utama');
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Simpan & Kembali ke Home',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: _showResetDialog,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Reset Semua Pengaturan',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info status pengaturan
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pengaturan:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                    'Notifikasi: ${_notificationsEnabled ? 'Aktif' : 'Nonaktif'}'),
                Text('Bahasa: $_selectedLanguage'),
                Text('Tema Gelap: ${_darkModeEnabled ? 'Aktif' : 'Nonaktif'}'),
                Text('Mode Privasi: ${_privacyMode ? 'Aktif' : 'Nonaktif'}'),
                Text('Ukuran Font: ${_fontSize.toInt()}px'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
