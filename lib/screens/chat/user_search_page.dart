import 'package:flutter/material.dart';
import 'package:meetme/models/chat_contact.dart';
import 'package:meetme/repositories/user_repository.dart';
import 'package:meetme/screens/chat/chat_detail_page.dart';
import 'package:meetme/screens/debug/debug_menu_page.dart';
import 'package:meetme/services/auth_service.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String _selectedRole = 'all'; // 'all', 'dosen', or 'mahasiswa'

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = _authService.currentUser?.id;
      print('Current user ID: $currentUserId');

      if (currentUserId != null) {
        print('Mencari pengguna dengan:');
        print('- searchQuery: ${_searchController.text}');
        print('- role: ${_selectedRole == 'all' ? 'semua' : _selectedRole}');
        print('- excludeUserId: $currentUserId');

        final users = await _userRepository.searchUsers(
          searchQuery: _searchController.text,
          role: _selectedRole == 'all' ? null : _selectedRole,
          excludeUserId: currentUserId,
        );

        print('Hasil pencarian: ${users.length} pengguna ditemukan');
        if (users.isEmpty) {
          print('Tidak ada pengguna yang ditemukan');

          // Coba tampilkan semua pengguna tanpa filter untuk debugging
          print('Mencoba mendapatkan semua pengguna tanpa filter');
          final allUsers = await _userRepository.searchUsers();
          print('Total pengguna tanpa filter: ${allUsers.length}');
          print('Data pengguna: $allUsers');
        }

        setState(() {
          _users = users;
        });
      } else {
        print('Tidak ada user yang login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login terlebih dahulu')),
        );
      }
    } catch (e) {
      print('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat daftar pengguna: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startChat(Map<String, dynamic> user) {
    final contact = ChatContact(
      id: user['id'],
      name: user['name'] ?? 'Pengguna',
      role: user['role'] ?? 'unknown',
      avatar: user['avatar'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailPage(contact: contact)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Pengguna'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugMenuPage()),
              );
            },
            tooltip: 'Debug Menu',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama pengguna...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    // Debounce search
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (value == _searchController.text) {
                        _loadUsers();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleFilter('Semua', 'all'),
                      const SizedBox(width: 8),
                      _buildRoleFilter('Dosen', 'dosen'),
                      const SizedBox(width: 8),
                      _buildRoleFilter('Mahasiswa', 'mahasiswa'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                    ? const Center(child: Text('Tidak ada pengguna ditemukan'))
                    : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return _buildUserItem(user);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter(String label, String role) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
        _loadUsers();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final name = user['name'] ?? 'Pengguna';
    final role = user['role'] == 'dosen' ? 'Dosen' : 'Mahasiswa';
    final avatar = user['avatar'];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal.shade200,
        backgroundImage: avatar != null ? NetworkImage(avatar) : null,
        child:
            avatar == null
                ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                )
                : null,
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(role),
      trailing: ElevatedButton(
        onPressed: () => _startChat(user),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Chat'),
      ),
      onTap: () => _startChat(user),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
