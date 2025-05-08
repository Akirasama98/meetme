import 'package:flutter/material.dart';
import 'package:meetme/screens/debug/database_viewer_page.dart';
import 'package:meetme/screens/debug/user_search_debug_page.dart';

class DebugMenuPage extends StatelessWidget {
  const DebugMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDebugCard(
            context,
            title: 'Database Viewer',
            description: 'Lihat semua data dari tabel users, dosen, dan mahasiswa',
            icon: Icons.storage,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DatabaseViewerPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDebugCard(
            context,
            title: 'User Search Debug',
            description: 'Debug pencarian pengguna',
            icon: Icons.search,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserSearchDebugPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebugCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
