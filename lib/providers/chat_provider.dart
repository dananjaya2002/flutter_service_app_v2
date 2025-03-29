import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatModel> _chats = [];
  final Map<String, List<MessageModel>> _messages = {};
  bool _isLoading = false;
  String? _activeChatId;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get activeChatId => _activeChatId;

  // Get messages for a specific chat
  List<MessageModel> getMessagesForChat(String chatId) {
    return _messages[chatId] ?? [];
  }

  // Get user's chats stream
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _chatService.getUserChats(userId);
  }

  // Load user's chats
  Future<void> loadUserChats(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _chatService.getUserChats(userId).listen((chats) {
        _chats = chats;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading chats: $e');
    }
  }

  // Load messages for a chat
  Future<void> loadChatMessages(String chatId) async {
    try {
      _chatService.getChatMessages(chatId).listen((messages) {
        _messages[chatId] = messages;
        notifyListeners();
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // Send a message
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String content,
  ) async {
    try {
      await _chatService.sendMessage(chatId, senderId, content);
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId) async {
    try {
      await _chatService.markChatAsRead(chatId);
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  // Get unread message count
  Stream<int> getUnreadMessageCount(String userId) {
    return _chatService.getUnreadMessageCount(userId);
  }

  // Create or get existing chat
  Future<String> createOrGetChat(
    String shopId,
    String customerId,
    String serviceProviderId,
  ) async {
    try {
      final chat = await _chatService.createOrGetChat(shopId, customerId);
      return chat.id;
    } catch (e) {
      print('Error creating or getting chat: $e');
      rethrow;
    }
  }

  void addMessageLocally(String chatId, MessageModel message) {
    if (_messages.containsKey(chatId)) {
      _messages[chatId]!.add(message);
    } else {
      _messages[chatId] = [message];
    }
    notifyListeners();
  }

  // Set active chat
  void setActiveChat(String chatId) {
    _activeChatId = chatId;
    notifyListeners();
  }

  // Get personal chats stream
  Stream<List<ChatModel>> getPersonalChats(String userId) {
    return _chatService.getPersonalChats(userId);
  }

  // Get shop chats stream
  Stream<List<ChatModel>> getShopChats(String userId) {
    return _chatService.getShopChats(userId);
  }

  // Load personal chats
  Future<void> loadPersonalChats(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _chatService.getPersonalChats(userId).listen((chats) {
        _chats = chats;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading personal chats: $e');
    }
  }

  // Load shop chats
  Future<void> loadShopChats(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _chatService.getShopChats(userId).listen((chats) {
        _chats = chats;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading shop chats: $e');
    }
  }
}
