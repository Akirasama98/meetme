import 'package:flutter/material.dart';
import 'package:meetme/screens/dosen/dosen_profile_page.dart';
import 'package:meetme/services/auth_service.dart';

class DosenHomePage extends StatefulWidget {
  const DosenHomePage({super.key});

  @override
  State<DosenHomePage> createState() => _DosenHomePageState();
}

class _DosenHomePageState extends State<DosenHomePage> {
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

  // Widget untuk kartu menu
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, {String? badge}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // Menghilangkan AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header dengan profil
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Gunakan CircleAvatar dengan AssetImage atau NetworkImage
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: _dosenData?['profile_image_url'] != null
                              ? Image.network(
                                  _dosenData!['profile_image_url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 30, color: Colors.blue);
                                  },
                                )
                              : const Icon(Icons.person, size: 30, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dosenData?['universitas'] ?? 'Universitas',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _dosenData?['nama'] ?? 'Nama Dosen',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _dosenData?['nip'] ?? 'NIP',
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Konten utama
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jadwal Bimbingan Hari Ini
                        const Text(
                          'Jadwal Bimbingan Hari Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Jika tidak ada jadwal
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Tidak ada jadwal bimbingan hari ini',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Menu Utama
                        const Text(
                          'Menu Utama',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: [
                            _buildMenuCard(context, 'Jadwal Bimbingan', Icons.calendar_today),
                            _buildMenuCard(context, 'Permintaan Bimbingan', Icons.notifications, badge: '5'),
                            _buildMenuCard(context, 'Riwayat Bimbingan', Icons.history),
                            _buildMenuCard(context, 'Pengaturan', Icons.settings),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Mahasiswa Bimbingan
                        const Text(
                          'Mahasiswa Bimbingan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Jika tidak ada mahasiswa bimbingan
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Belum ada mahasiswa bimbingan',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.calendar_today, 'Jadwal', false),
              _buildNavItem(Icons.chat_bubble_outline, 'Chat', false),
              _buildNavItem(Icons.person_outline, 'Profil', false, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DosenProfilePage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

