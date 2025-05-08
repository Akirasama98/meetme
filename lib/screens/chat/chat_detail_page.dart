import 'package:flutter/material.dart';
import 'package:meetme/models/chat_contact.dart';
import 'package:meetme/models/chat_message.dart';
import 'package:meetme/repositories/chat_repository.dart';
import 'package:meetme/services/auth_service.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatContact contact;

  const ChatDetailPage({super.key, required this.contact});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserRole;
  String? _currentUserAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMessages();
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    if (_authService.currentUser != null) {
      // Subscribe to real-time updates
      _chatRepository.subscribeToChat(_authService.currentUser!.id);

      // Listen for new messages
      _chatRepository.messageStream.listen((message) {
        // Only add messages from the current chat contact
        if (message.senderId == widget.contact.id) {
          setState(() {
            _messages.add(message);
          });

          // Mark message as read
          _chatRepository.markMessagesAsRead(
            widget.contact.id,
            _authService.currentUser!.id,
          );

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    if (_authService.currentUser != null) {
      _currentUserId = _authService.currentUser!.id;

      // Get current user data
      final userData = await _authService.getUserData(_currentUserId!);
      if (userData != null) {
        _currentUserName = userData['name'] ?? '';

        // Check if user is mahasiswa or dosen
        final mahasiswa = await _authService.getCurrentMahasiswa();
        if (mahasiswa != null) {
          _currentUserRole = 'mahasiswa';
          _currentUserAvatar = mahasiswa.profileImageUrl;
        } else {
          final dosenData = await _authService.getDosenData(_currentUserId!);
          if (dosenData != null) {
            _currentUserRole = 'dosen';
            _currentUserAvatar = dosenData['profile_image_url'];
          }
        }
      }
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_currentUserId != null) {
        // Mark messages as read
        await _chatRepository.markMessagesAsRead(
          widget.contact.id,
          _currentUserId!,
        );

        // Get messages
        final messages = await _chatRepository.getChatMessages(
          _currentUserId!,
          widget.contact.id,
        );

        setState(() {
          _messages = messages;
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentUserId == null) return;

    _messageController.clear();

    try {
      final sentMessage = await _chatRepository.sendMessage(
        senderId: _currentUserId!,
        receiverId: widget.contact.id,
        message: message,
        senderName: _currentUserName,
        senderRole: _currentUserRole,
        senderAvatar: _currentUserAvatar,
      );

      if (sentMessage != null) {
        setState(() {
          _messages.add(sentMessage);
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tambahkan resizeToAvoidBottomInset untuk menghindari overflow
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal.shade200,
              backgroundImage:
                  widget.contact.avatar != null
                      ? NetworkImage(widget.contact.avatar!)
                      : null,
              radius: 18,
              child:
                  widget.contact.avatar == null
                      ? Text(
                        widget.contact.name.isNotEmpty
                            ? widget.contact.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      )
                      : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.name,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.contact.role == 'dosen' ? 'Dosen' : 'Mahasiswa',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(
                        red: 255,
                        green: 255,
                        blue: 255,
                        alpha: 204,
                      ), // 0.8 alpha
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // Gunakan SafeArea untuk menghindari notch dan bottom bar
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _messages.isEmpty
                      ? const Center(child: Text('Belum ada pesan'))
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == _currentUserId;

                          return _buildMessageItem(message, isMe);
                        },
                      ),
            ),
            _buildMessageInput(),
            // Tambahkan padding untuk keyboard
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.teal.shade200,
              backgroundImage:
                  message.senderAvatar != null
                      ? NetworkImage(message.senderAvatar!)
                      : null,
              child:
                  message.senderAvatar == null
                      ? Text(
                        message.senderName != null &&
                                message.senderName!.isNotEmpty
                            ? message.senderName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.teal.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // Gunakan withValues untuk menghindari warning
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
      // Batasi tinggi input untuk menghindari overflow
      constraints: const BoxConstraints(maxHeight: 150),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                // Batasi padding untuk menghindari overflow
                isDense: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4, // Batasi jumlah baris
              // Tambahkan keyboardType untuk menangani keyboard dengan lebih baik
              keyboardType: TextInputType.multiline,
              // Tambahkan textInputAction untuk menangani keyboard dengan lebih baik
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
              // Tambahkan padding untuk menghindari overflow
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatRepository.unsubscribeFromChat();
    super.dispose();
  }
}
