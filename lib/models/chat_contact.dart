class ChatContact {
  final String id;
  final String name;
  final String role; // 'dosen' atau 'mahasiswa'
  final String? avatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool hasUnreadMessages;

  ChatContact({
    required this.id,
    required this.name,
    required this.role,
    this.avatar,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnreadMessages = false,
  });

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    return ChatContact(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      avatar: json['avatar'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null 
          ? DateTime.parse(json['last_message_time']) 
          : null,
      hasUnreadMessages: json['has_unread_messages'] ?? false,
    );
  }
}