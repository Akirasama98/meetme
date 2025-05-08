class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? senderName;
  final String? senderRole; // 'dosen' atau 'mahasiswa'
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.senderName,
    this.senderRole,
    this.senderAvatar,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
      senderAvatar: json['sender_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'sender_name': senderName,
      'sender_role': senderRole,
      'sender_avatar': senderAvatar,
    };
  }
}