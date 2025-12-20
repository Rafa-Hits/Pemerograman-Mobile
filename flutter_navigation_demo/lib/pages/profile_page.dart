import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data profile yang bisa diubah
  Map<String, String> _profileData = {
    'name': 'Muhammad Fazial',
    'email': '701230055@student.uin.jambi.ac.id',
    'phone': '+62 822-8501-2956',
    'address': 'Riau, Indonesia',
  };

  // Function untuk update data profile
  void _updateProfile(Map<String, String> newData) {
    setState(() {
      _profileData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profileData['name']!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    _profileData['email']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(context, 'Nama', _profileData['name']!),
                    _buildInfoItem(context, 'Email', _profileData['email']!),
                    _buildInfoItem(context, 'Telepon', _profileData['phone']!),
                    _buildInfoItem(context, 'Alamat', _profileData['address']!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton(
                onPressed: () async {
                  // Navigate ke edit profile dan tunggu hasilnya
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        name: _profileData['name']!,
                        email: _profileData['email']!,
                        phone: _profileData['phone']!,
                        address: _profileData['address']!,
                      ),
                    ),
                  );

                  // Jika ada data yang dikembalikan, update profile
                  if (result != null && result is Map<String, String>) {
                    _updateProfile(result);

                    // Show snackbar notification
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profile berhasil diupdate!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
