import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class ChatRepository {
  final FirebaseService _firebaseService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  ChatRepository({
    required FirebaseService firebaseService,
    required StorageService storageService,
  })  : _firebaseService = firebaseService,
        _storageService = storageService;

  /// Get or create chat between two users
  Future<ChatModel> getOrCreateChat({
    required String userId1,
    required String userId2,
  }) async {
    try {
      // Check if chat already exists
      final participants = [userId1, userId2]..sort();
      final chatId = _generateChatId(participants);

      final snapshot = await _firebaseService.getDocument(
        collection: _firebaseService.chatsCollection(),
        docId: chatId,
      );

      if (snapshot.exists) {
        return ChatModel.fromMap(snapshot.id, snapshot.data()!);
      }

      // Create new chat
      final chat = ChatModel(
        id: chatId,
        participants: participants,
        lastUpdated: DateTime.now(),
      );

      await _firebaseService.setDocument(
        collection: _firebaseService.chatsCollection(),
        docId: chat.id,
        data: chat.toMap(),
        merge: false,
      );

      return chat;
    } catch (e) {
      throw Exception('Failed to get or create chat: $e');
    }
  }

  /// Get all chats for a user
  Future<List<ChatModel>> getChatsForUser(String userId) async {
    try {
      final snapshot = await _firebaseService.queryCollection(
        collection: _firebaseService.chatsCollection(),
        builder: (query) => query.where('participants', arrayContains: userId),
      );

      return snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  /// Stream chats for a user (real-time updates)
  Stream<List<ChatModel>> watchChatsForUser(String userId) {
    try {
      return _firebaseService
          .watchCollection(
            collection: _firebaseService.chatsCollection(),
            builder: (query) => query.where('participants', arrayContains: userId),
          )
          .map((snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.id, doc.data()))
              .toList());
    } catch (e) {
      throw Exception('Failed to watch chats: $e');
    }
  }

  /// Send text message
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      final messageId = _uuid.v4();
      final message = ChatMessage(
        id: messageId,
        senderId: senderId,
        text: text,
        timestamp: DateTime.now(),
      );

      await _firebaseService
          .chatsCollection()
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      // Update chat lastMessage and lastUpdated
      await _updateChatLastMessage(chatId, text);

      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send image message
  Future<ChatMessage> sendImage({
    required String chatId,
    required String senderId,
    required File imageFile,
  }) async {
    try {
      final messageId = _uuid.v4();

      // Upload image
      final imageUrl = await _storageService.uploadChatImage(
        chatId: chatId,
        messageId: messageId,
        file: imageFile,
      );

      final message = ChatMessage(
        id: messageId,
        senderId: senderId,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      await _firebaseService
          .chatsCollection()
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      // Update chat lastMessage and lastUpdated
      await _updateChatLastMessage(chatId, '📷 Image');

      return message;
    } catch (e) {
      throw Exception('Failed to send image: $e');
    }
  }

  /// Stream messages for a chat (real-time updates)
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    try {
      return _firebaseService
          .chatsCollection()
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
              .toList());
    } catch (e) {
      throw Exception('Failed to watch messages: $e');
    }
  }

  /// Update chat last message
  Future<void> _updateChatLastMessage(String chatId, String lastMessage) async {
    try {
      await _firebaseService.chatsCollection().doc(chatId).update({
        'lastMessage': lastMessage,
        'lastUpdated': DateTime.now(),
      });
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Generate consistent chat ID from sorted participant IDs
  String _generateChatId(List<String> participants) {
    return participants.join('_');
  }
}

