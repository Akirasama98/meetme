import 'package:flutter/material.dart';
import 'package:meetme/services/auth_service.dart';
import 'package:meetme/screens/auth/login_page.dart';
import 'package:meetme/screens/dosen/dosen_home_page.dart';
import 'package:meetme/screens/chat/chat_list_page.dart';

class DosenProfilePage extends StatefulWidget {
  const DosenProfilePage({super.key});

  @override
  State<DosenProfilePage> createState() => _DosenProfilePageState();
}

class _DosenProfilePageState extends State<DosenProfilePage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _dosenData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDosenData();
  }

  Future<void> _loadDosenData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser?.id;
      if (userId != null) {
        // Ambil data dosen dari database
        final userData = await _authService.getUserData(userId);
        if (userData != null && userData['role'] == 'dosen') {
          // Ambil data detail dosen
          final dosenData = await _authService.getDosenData(userId);
          setState(() {
            _dosenData = dosenData;
          });
        }
      }
    } catch (e) {
      print('Error loading dosen data: $e');
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
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

  // Widget untuk item navigasi bawah
  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey,
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
        title: const Text('Profil Dosen'),
        backgroundColor: Colors.blue,
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
                          backgroundImage: _dosenData?['profile_image_url'] != null
                              ? NetworkImage(_dosenData!['profile_image_url'])
                              : null,
                          child: _dosenData?['profile_image_url'] == null
                              ? const Icon(Icons.person, size: 60, color: Colors.blue)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _dosenData?['nama'] ?? 'Nama Dosen',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _dosenData?['nip'] ?? 'NIP: -',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Informasi dosen
                  const Text(
                    'Informasi Dosen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(Icons.school, 'Universitas', _dosenData?['universitas'] ?? '-'),
                  _buildInfoItem(Icons.business, 'Jurusan', _dosenData?['jurusan'] ?? '-'),
                  _buildInfoItem(Icons.psychology, 'Bidang Keahlian', _dosenData?['bidang_keahlian'] ?? '-'),
                  
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
                  MaterialPageRoute(builder: (context) => const DosenHomePage()),
                );
              }),
              _buildNavItem(Icons.calendar_today, 'Jadwal', false),
              _buildNavItem(Icons.chat_bubble_outline, 'Chat', false, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatListPage()),
                );
              }),
              _buildNavItem(Icons.person_outline, 'Profil', true),
            ],
          ),
        ),
      ),
    );
  }
}


