import 'package:flutter/material.dart';
import 'package:meetme/services/auth_service.dart';
import 'package:meetme/screens/auth/login_page.dart';
import 'package:meetme/models/mahasiswa.dart';
import 'package:meetme/screens/mahasiswa/mahasiswa_home_page.dart';

class MahasiswaProfilePage extends StatefulWidget {
  const MahasiswaProfilePage({super.key});

  @override
  State<MahasiswaProfilePage> createState() => _MahasiswaProfilePageState();
}

class _MahasiswaProfilePageState extends State<MahasiswaProfilePage> {
  final AuthService _authService = AuthService();
  Mahasiswa? _mahasiswa;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMahasiswaData();
  }

  Future<void> _loadMahasiswaData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mendapatkan data mahasiswa
      final mahasiswa = await _authService.getCurrentMahasiswa();
      setState(() {
        _mahasiswa = mahasiswa;
      });
    } catch (e) {
      print('Error loading mahasiswa data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      
      // Kembali ke halaman login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
    }
  }

  // Widget untuk item navigasi bawah
  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.teal : Colors.grey,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.teal : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _mahasiswa?.profileImageUrl != null
                              ? NetworkImage(_mahasiswa!.profileImageUrl!)
                              : null,
                          child: _mahasiswa?.profileImageUrl == null
                              ? const Icon(Icons.person, size: 60, color: Colors.teal)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _mahasiswa?.nama ?? 'Nama Mahasiswa',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _mahasiswa?.nim ?? 'NIM: -',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Informasi mahasiswa
                  const Text(
                    'Informasi Mahasiswa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(Icons.school, 'Universitas', _mahasiswa?.universitas ?? '-'),
                  _buildInfoItem(Icons.business, 'Jurusan', _mahasiswa?.jurusan ?? '-'),
                  _buildInfoItem(Icons.calendar_today, 'Semester', _mahasiswa?.semester?.toString() ?? '-'),
                  
                  const SizedBox(height: 32),
                  
                  // Tombol logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', false, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MahasiswaHomePage()),
                );
              }),
              _buildNavItem(Icons.calendar_today, 'Jadwal', false),
              _buildNavItem(Icons.chat_bubble_outline, 'Chat', false),
              _buildNavItem(Icons.person_outline, 'Profil', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

