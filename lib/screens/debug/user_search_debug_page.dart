import 'package:flutter/material.dart';
import 'package:meetme/repositories/user_repository.dart';
import 'package:meetme/services/auth_service.dart';

class UserSearchDebugPage extends StatefulWidget {
  const UserSearchDebugPage({super.key});

  @override
  State<UserSearchDebugPage> createState() => _UserSearchDebugPageState();
}

class _UserSearchDebugPageState extends State<UserSearchDebugPage> {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String _selectedRole = 'all'; // 'all', 'dosen', or 'mahasiswa'
  String _error = '';
  String _logs = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _logs = '';
    });

    try {
      final currentUserId = _authService.currentUser?.id;
      _addLog('Current user ID: $currentUserId');

      _addLog('Mencari pengguna dengan:');
      _addLog('- searchQuery: ${_searchController.text}');
      _addLog('- role: ${_selectedRole == 'all' ? 'semua' : _selectedRole}');
      _addLog('- excludeUserId: $currentUserId');

      final users = await _userRepository.searchUsers(
        searchQuery: _searchController.text,
        role: _selectedRole == 'all' ? null : _selectedRole,
        excludeUserId:
            null, // Tidak mengecualikan user saat ini untuk debugging
      );

      _addLog('Hasil pencarian: ${users.length} pengguna ditemukan');

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      _addLog('Error loading users: $e');
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _addLog(String log) {
    setState(() {
      _logs += '$log\n';
    });
    print(log);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Search Debug'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadUsers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cari Pengguna'),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                    ? Center(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: 'Hasil Pencarian'),
                              Tab(text: 'Logs'),
                            ],
                            labelColor: Colors.teal,
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Tab 1: Hasil Pencarian
                                _users.isEmpty
                                    ? const Center(
                                      child: Text(
                                        'Tidak ada pengguna ditemukan',
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: _users.length,
                                      itemBuilder: (context, index) {
                                        final user = _users[index];
                                        return _buildUserItem(user);
                                      },
                                    ),

                                // Tab 2: Logs
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(_logs),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(role), Text('ID: ${user['id']}')],
      ),
      isThreeLine: true,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
