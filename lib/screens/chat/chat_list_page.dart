import 'package:flutter/material.dart';
import 'package:meetme/models/chat_contact.dart';
import 'package:meetme/repositories/chat_repository.dart';
import 'package:meetme/services/auth_service.dart';
import 'package:meetme/screens/chat/chat_detail_page.dart';
import 'package:meetme/screens/chat/user_search_page.dart';
import 'package:meetme/screens/mahasiswa/mahasiswa_home_page.dart';
import 'package:meetme/screens/mahasiswa/mahasiswa_profile_page.dart';
import 'package:meetme/screens/dosen/dosen_home_page.dart';
import 'package:meetme/screens/dosen/dosen_profile_page.dart';
import 'package:meetme/screens/debug/debug_menu_page.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthService _authService = AuthService();
  List<ChatContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authService.currentUser != null) {
        print('Loading contacts for user: ${_authService.currentUser!.id}');
        final contacts = await _chatRepository.getChatContacts(
          _authService.currentUser!.id,
        );
        print('Contacts loaded: ${contacts.length}');
        setState(() {
          _contacts = contacts;
        });
      } else {
        print('Current user is null');
      }
    } catch (e) {
      print('Error loading contacts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Tidak perlu menambahkan kontak dummy lagi
    // Jika tidak ada kontak, tampilkan pesan kosong
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.teal : Colors.grey, size: 24),
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

  Future<bool> _isUserDosen() async {
    if (_authService.currentUser != null) {
      final dosenData = await _authService.getDosenData(
        _authService.currentUser!.id,
      );
      return dosenData != null;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _contacts.isEmpty
              ? const Center(child: Text('Belum ada percakapan'))
              : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return _buildContactItem(contact);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserSearchPage()),
          ).then((_) => _loadContacts());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.message, color: Colors.white),
      ),
      bottomNavigationBar: FutureBuilder<bool>(
        future: _isUserDosen(),
        builder: (context, snapshot) {
          final isDosen = snapshot.data ?? false;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(
                    red: 128,
                    green: 128,
                    blue: 128,
                    alpha: 51,
                  ), // 0.2 alpha
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
                  _buildNavItem(
                    Icons.home,
                    'Home',
                    false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  isDosen
                                      ? const DosenHomePage()
                                      : const MahasiswaHomePage(),
                        ),
                      );
                    },
                  ),
                  _buildNavItem(Icons.calendar_today, 'Jadwal', false),
                  _buildNavItem(Icons.chat_bubble_outline, 'Chat', true),
                  _buildNavItem(
                    Icons.person_outline,
                    'Profil',
                    false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  isDosen
                                      ? const DosenProfilePage()
                                      : const MahasiswaProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactItem(ChatContact contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal.shade200,
        backgroundImage:
            contact.avatar != null ? NetworkImage(contact.avatar!) : null,
        child:
            contact.avatar == null
                ? Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                )
                : null,
      ),
      title: Text(
        contact.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle:
          contact.lastMessage != null
              ? Text(
                contact.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (contact.lastMessageTime != null)
            Text(
              DateFormat('HH:mm').format(contact.lastMessageTime!),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          const SizedBox(height: 4),
          if (contact.hasUnreadMessages)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: const Text('', style: TextStyle(fontSize: 8)),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(contact: contact),
          ),
        ).then((_) => _loadContacts());
      },
    );
  }
}
