import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetme/models/mahasiswa.dart';
import 'package:meetme/services/auth_service.dart';
import 'package:meetme/repositories/mahasiswa_repository.dart';
import 'package:meetme/screens/mahasiswa/mahasiswa_profile_page.dart';

class MahasiswaHomePage extends StatefulWidget {
  const MahasiswaHomePage({super.key});

  @override
  State<MahasiswaHomePage> createState() => _MahasiswaHomePageState();
}

class _MahasiswaHomePageState extends State<MahasiswaHomePage> {
  final AuthService _authService = AuthService();
  final MahasiswaRepository _mahasiswaRepository = MahasiswaRepository();
  
  Mahasiswa? _mahasiswa;
  List<Map<String, dynamic>> _jadwalBimbingan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mendapatkan data mahasiswa
      final mahasiswa = await _authService.getCurrentMahasiswa();
      
      if (mahasiswa != null) {
        // Mendapatkan jadwal bimbingan
        final jadwal = await _mahasiswaRepository.getJadwalBimbingan(mahasiswa.id);
        
        setState(() {
          _mahasiswa = mahasiswa;
          _jadwalBimbingan = jadwal;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
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

  // Widget untuk kolom hari dalam kalender mini
  Widget _buildDayColumn(String day, String date, bool isToday) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isToday ? Colors.teal : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                color: isToday ? Colors.white : Colors.black,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tanggal saat ini
    final now = DateTime.now();
    final currentMonth = DateFormat('MMM, yyyy').format(now);
    
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
                    color: Colors.teal.shade200,
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
                          child: _mahasiswa?.profileImageUrl != null
                              ? Image.network(
                                  _mahasiswa!.profileImageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 30, color: Colors.teal);
                                  },
                                )
                              : Image.asset(
                                  'assets/images/profile_placeholder.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 30, color: Colors.teal);
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mahasiswa?.universitas ?? 'Universitas Jember',
                              style: TextStyle(
                                color: Colors.teal.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _mahasiswa?.nama ?? 'DWI RIFQI NOFRIANTO',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _mahasiswa?.nim ?? '232410102021',
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
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Jadwal
                          const Text(
                            'Jadwal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Kalender mini
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bulan dan tahun
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  currentMonth,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Hari-hari dalam seminggu
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildDayColumn('Sen', '29', false),
                                  _buildDayColumn('Sel', '30', false),
                                  _buildDayColumn('Rab', '1', true),
                                  _buildDayColumn('Kam', '2', false),
                                  _buildDayColumn('Jum', '3', false),
                                  _buildDayColumn('Sab', '4', false),
                                  _buildDayColumn('Min', '5', false),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Jadwal hari ini
                          const Text(
                            'Jadwal Hari Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Jadwal bimbingan
                          _jadwalBimbingan.isEmpty
                              ? const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Text(
                                      'Tidak ada jadwal bimbingan hari ini',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _jadwalBimbingan.length,
                                  itemBuilder: (context, index) {
                                    final jadwal = _jadwalBimbingan[index];
                                    final dosen = jadwal['dosen'] as Map<String, dynamic>? ?? {};
                                    final tanggal = DateTime.parse(jadwal['tanggal'] ?? DateTime.now().toString());
                                    final waktuMulai = jadwal['waktu_mulai'] ?? '';
                                    final waktuSelesai = jadwal['waktu_selesai'] ?? '';
                                    
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: Colors.blue.shade100,
                                                  child: const Icon(Icons.person, color: Colors.blue),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        dosen['nama'] ?? 'Nama Dosen',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      Text(
                                                        jadwal['judul'] ?? 'Judul Bimbingan',
                                                        style: TextStyle(
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                                const SizedBox(width: 8),
                                                Text(
                                                  DateFormat('dd MMMM yyyy').format(tanggal),
                                                  style: TextStyle(color: Colors.grey.shade600),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '$waktuMulai - $waktuSelesai',
                                                  style: TextStyle(color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () {},
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: Colors.teal,
                                                      side: const BorderSide(color: Colors.teal),
                                                    ),
                                                    child: const Text('Detail'),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {},
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.teal,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    child: const Text('Mulai'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom navigation
                Container(
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
                            MaterialPageRoute(builder: (context) => const MahasiswaProfilePage()),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}


