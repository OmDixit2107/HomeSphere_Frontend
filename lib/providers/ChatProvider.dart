import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homesphere/models/ChatMessage.dart';
import 'package:homesphere/models/User.dart';
import 'package:homesphere/services/websocket/ChatWebSocket.dart';
import 'package:homesphere/services/api/AuthService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ChatProvider to manage all chat-related state and operations
class ChatProvider with ChangeNotifier {
  // Simplify the state to just store messages between users
  final Map<int, List<ChatMessage>> _userMessages = {};
  bool _isLoading = false;
  String? _error;
  int? _currentUserId;
  final ChatWebSocket _chatWebSocket = ChatWebSocket.getInstance();
  StreamSubscription<ChatMessage>? _messageSubscription;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the provider with the current user
  Future<void> initialize(int userId) async {
    if (_isInitialized && _currentUserId == userId) return;

    try {
      _currentUserId = userId;
      _isInitialized = true;
      await _connectToWebSocket();
    } catch (e) {
      print('Error initializing ChatProvider: $e');
      _setError('Failed to initialize chat: $e');
    }
  }

  // Helper method to get auth headers for API calls
  Future<Map<String, String>> _getAuthHeaders() async {
    // Use the WebSocket's method to get auth headers
    return await _chatWebSocket.getAuthHeaders();
  }

  // Connect to WebSocket and listen for new messages
  Future<void> _connectToWebSocket() async {
    if (_currentUserId == null) return;

    await _chatWebSocket.connect(_currentUserId!);

    // Cancel existing subscription if any
    await _messageSubscription?.cancel();

    // Listen for new messages
    _messageSubscription = _chatWebSocket.messageStream.listen((message) {
      // Add message to the appropriate property chat
      if (message.content != null) {
        final conversationKey =
            _getConversationKey(message.sender.id, message.recipient.id);
        _addMessageToConversation(conversationKey, message);
        // Use post-frame callback to avoid build issues
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });
  }

  // Simplified method to load chat messages between two users
  Future<List<ChatMessage>> loadUserChat(int user1Id, int user2Id) async {
    try {
      _setLoading(true);
      final headers = await _getAuthHeaders();

      // Get messages from both directions
      final url1 = Uri.parse(
          '${ChatWebSocket.baseUrl}${ChatWebSocket.getPrivateMessagesEndpoint}/$user1Id/$user2Id');
      final url2 = Uri.parse(
          '${ChatWebSocket.baseUrl}${ChatWebSocket.getPrivateMessagesEndpoint}/$user2Id/$user1Id');

      final response1 = await http.get(url1, headers: headers);
      final response2 = await http.get(url2, headers: headers);

      List<ChatMessage> messages = [];

      if (response1.statusCode == 200) {
        final List<dynamic> data1 = jsonDecode(response1.body);
        messages.addAll(data1.map((json) => ChatMessage.fromJson(json)));
      }

      if (response2.statusCode == 200) {
        final List<dynamic> data2 = jsonDecode(response2.body);
        messages.addAll(data2.map((json) => ChatMessage.fromJson(json)));
      }

      // Sort messages by timestamp
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Store in cache using a unique key for the conversation
      final conversationKey = _getConversationKey(user1Id, user2Id);
      _userMessages[conversationKey] = messages;

      notifyListeners();
      return messages;
    } catch (e) {
      print('Error loading chat: $e');
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to get a unique key for a conversation between two users
  int _getConversationKey(int user1Id, int user2Id) {
    // Ensure consistent key regardless of user order
    return [user1Id, user2Id].reduce((a, b) => a < b ? a : b);
  }

  // Simplified method to send a message
  void sendMessage(ChatMessage message) {
    if (_currentUserId == null) return;

    try {
      print(
          'Sending message from ${message.sender.id} to ${message.recipient.id}');
      _chatWebSocket.sendMessage(message);

      // Add to local cache
      final conversationKey =
          _getConversationKey(message.sender.id, message.recipient.id);
      if (!_userMessages.containsKey(conversationKey)) {
        _userMessages[conversationKey] = [];
      }
      _userMessages[conversationKey]!.add(message);
      _userMessages[conversationKey]!
          .sort((a, b) => a.timestamp.compareTo(b.timestamp));

      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      _setError(e.toString());
    }
  }

  // Get messages for a conversation
  List<ChatMessage> getMessagesForConversation(int user1Id, int user2Id) {
    final conversationKey = _getConversationKey(user1Id, user2Id);
    return _userMessages[conversationKey] ?? [];
  }

  // Add a message to the conversation cache
  void _addMessageToConversation(int conversationKey, ChatMessage message) {
    if (!_userMessages.containsKey(conversationKey)) {
      _userMessages[conversationKey] = [];
    }

    // Add message if it doesn't already exist
    if (!_userMessages[conversationKey]!.any((m) =>
        m.timestamp == message.timestamp &&
        m.content == message.content &&
        m.sender.id == message.sender.id)) {
      _userMessages[conversationKey]!.add(message);
      _userMessages[conversationKey]!
          .sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
  }

  // Helper method to set loading state with post-frame callback
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Helper method to set error and notify with post-frame callback
  void _setError(String errorMsg) {
    _error = errorMsg;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Cleanup
  @override
  void dispose() {
    _messageSubscription?.cancel();
    _chatWebSocket.disconnect();
    super.dispose();
  }
}
