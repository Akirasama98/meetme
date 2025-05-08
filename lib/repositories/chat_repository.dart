import 'dart:async';
import 'package:meetme/models/chat_message.dart';
import 'package:meetme/models/chat_contact.dart';
import 'package:meetme/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final _chatTable = SupabaseService.client.from('chat_messages');
  final _uuid = Uuid();

  // Stream controllers for real-time updates
  final StreamController<ChatMessage> _messageStreamController =
      StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  // Subscribe to real-time chat updates
  StreamSubscription? _chatSubscription;

  // Get chat contacts for a user
  Future<List<ChatContact>> getChatContacts(String userId) async {
    try {
      final response = await SupabaseService.client.rpc(
        'get_chat_contacts',
        params: {'user_id_param': userId},
      );

      return List<ChatContact>.from(
        response.map((contact) => ChatContact.fromJson(contact)),
      );
    } catch (e) {
      print('Error getting chat contacts: $e');
      return [];
    }
  }

  // Get chat messages between two users
  Future<List<ChatMessage>> getChatMessages(
    String senderId,
    String receiverId,
  ) async {
    try {
      final response = await _chatTable
          .select()
          .or('sender_id.eq.$senderId,sender_id.eq.$receiverId')
          .or('receiver_id.eq.$senderId,receiver_id.eq.$receiverId')
          .order('created_at');

      return List<ChatMessage>.from(
        response.map((message) => ChatMessage.fromJson(message)),
      );
    } catch (e) {
      print('Error getting chat messages: $e');
      return [];
    }
  }

  // Send a message
  Future<ChatMessage?> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? senderName,
    String? senderRole,
    String? senderAvatar,
  }) async {
    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final chatMessage = ChatMessage(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        createdAt: now,
        isRead: false,
        senderName: senderName,
        senderRole: senderRole,
        senderAvatar: senderAvatar,
      );

      await _chatTable.insert(chatMessage.toJson());
      return chatMessage;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    try {
      await _chatTable
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Subscribe to real-time chat updates for a specific user
  void subscribeToChat(String userId) {
    // Cancel any existing subscription
    _chatSubscription?.cancel();

    // Subscribe to chat_messages table changes
    _chatSubscription = SupabaseService.client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            // Convert to ChatMessage and add to stream
            final message = ChatMessage.fromJson(data.first);
            _messageStreamController.add(message);
          }
        });
  }

  // Unsubscribe from real-time updates
  void unsubscribeFromChat() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
  }

  // Dispose resources
  void dispose() {
    unsubscribeFromChat();
    _messageStreamController.close();
  }
}
