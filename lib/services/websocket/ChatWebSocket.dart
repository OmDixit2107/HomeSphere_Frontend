import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:homesphere/models/ChatMessage.dart';
import 'package:http/http.dart' as http;
import 'package:homesphere/models/User.dart';
import 'package:homesphere/services/api/AuthService.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef StompUnsubscribe = void Function();

class ChatWebSocket {
  // Backend URLs
  static const String baseUrl = 'http://10.0.2.2:8090';
  static const String wsUrl = kDebugMode
      ? 'ws://10.0.2.2:8090/ws'
      : 'wss://your-production-domain.com/ws';

  // STOMP Endpoints
  static const String publicChatEndpoint = '/app/chat.sendMessage';
  static const String privateChatEndpoint = '/app/chat.sendPrivateMessage';
  static const String addUserEndpoint = '/app/chat.addUser';

  // Subscribe Topics
  static const String publicTopic = '/topic/public';
  static const String privateTopicPrefix = '/user/';
  static const String privateTopicSuffix = '/topic/private';

  // REST API endpoints
  static const String getPrivateMessagesEndpoint = '/private';
  static const String getPublicMessagesEndpoint = '/api/chat/messages/public';
  static const String getPropertyOwnerChatsEndpoint =
      '/api/chat/property-owner';

  static ChatWebSocket? _instance;
  late StompClient stompClient;
  bool _isInitialized = false;

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  bool _isConnected = false;
  int? _currentUserId;
  final Map<String, StompUnsubscribe> _subscriptions = {};

  ChatWebSocket._();

  static ChatWebSocket getInstance() {
    _instance ??= ChatWebSocket._();
    return _instance!;
  }

  Future<void> _initializeWebSocket() async {
    if (_isInitialized) return;

    // Get JSESSIONID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final jsessionId = prefs.getString('JSESSIONID');
    print('WebSocket: Using JSESSIONID: ${jsessionId != null ? 'yes' : 'no'}');

    // Prepare connect headers with JSESSIONID if available
    Map<String, String> connectHeaders = {};
    if (jsessionId != null) {
      connectHeaders['Cookie'] = jsessionId;
      print('Using JSESSIONID for authentication: $jsessionId');
    } else {
      print('Warning: No JSESSIONID available for authentication');
    }

    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (dynamic error) {
          print('WebSocket Error: $error');
          _reconnect();
        },
        onStompError: (dynamic error) {
          print('STOMP Error: $error');
          _reconnect();
        },
        stompConnectHeaders: connectHeaders,
        webSocketConnectHeaders: connectHeaders,
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _isInitialized = true;
  }

  void _reconnect() {
    if (!_isConnected && _currentUserId != null) {
      Future.delayed(const Duration(seconds: 5), () {
        print('Attempting to reconnect...');
        connect(_currentUserId!);
      });
    }
  }

  Future<void> connect(int userId) async {
    _currentUserId = userId;
    print('WebSocket: Connecting user $userId');

    try {
      await _initializeWebSocket();
      stompClient.activate();
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _reconnect();
    }
  }

  void disconnect() {
    if (_isConnected) {
      print('WebSocket: Disconnecting');
      stompClient.deactivate();
      _isConnected = false;
    }
  }

  void _onConnect(StompFrame frame) {
    print('Connected to WebSocket: ${frame.command}');
    _isConnected = true;

    // Subscribe to public topic
    _subscribeToPublicTopic();

    // Subscribe to private topic for the current user
    if (_currentUserId != null) {
      _subscribeToPrivateTopic(_currentUserId!);
    }
  }

  void _onDisconnect(StompFrame frame) {
    print('Disconnected from WebSocket: ${frame.command}');
    _isConnected = false;
    _reconnect();
  }

  void _subscribeToPublicTopic() {
    if (_subscriptions.containsKey(publicTopic)) {
      _subscriptions[publicTopic]!();
    }

    _subscriptions[publicTopic] = stompClient.subscribe(
      destination: publicTopic,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final message = ChatMessage.fromJson(json.decode(frame.body!));
            _messageController.add(message);
          } catch (e) {
            print('Error parsing public message: $e');
          }
        }
      },
    );
  }

  void _subscribeToPrivateTopic(int userId) {
    final destination = '$privateTopicPrefix$userId$privateTopicSuffix';
    print('WebSocket: Subscribing to private destination: $destination');

    if (_subscriptions.containsKey(destination)) {
      _subscriptions[destination]!();
    }

    _subscriptions[destination] = stompClient.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final message = ChatMessage.fromJson(json.decode(frame.body!));
            _messageController.add(message);
          } catch (e) {
            print('Error parsing private message: $e');
          }
        }
      },
    );
  }

  void sendUserJoined(int userId, {int? recipientId}) {
    if (!_isConnected) {
      print('WebSocket: Cannot send message, not connected');
      return;
    }

    try {
      // Create a JOIN message
      final joinMessage = {
        'content': 'User joined the chat',
        'senderId': userId,
        'recipientId':
            recipientId ?? 1, // Default to admin (1) if no recipient specified
        'type': 'JOIN',
      };

      print('Sending JOIN message: $joinMessage');

      // Send the message to the public topic
      stompClient.send(
        destination: publicChatEndpoint,
        body: json.encode(joinMessage),
      );
    } catch (e) {
      print('Error sending JOIN message: $e');
    }
  }

  void sendMessage(ChatMessage message) {
    if (!_isConnected) {
      print('WebSocket: Cannot send message, not connected');
      return;
    }

    try {
      // Create a message map
      final messageMap = {
        'content': message.content,
        'senderId': message.sender.id,
        'recipientId': message.recipient.id,
        'type': message.type.toString().split('.').last,
      };

      print('Sending message: $messageMap');

      // Send the message to the appropriate endpoint
      if (message.type == MessageType.CHAT) {
        stompClient.send(
          destination: privateChatEndpoint,
          body: json.encode(messageMap),
        );
      } else {
        stompClient.send(
          destination: publicChatEndpoint,
          body: json.encode(messageMap),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Get private messages between two users
  Future<List<ChatMessage>> getPrivateMessages(int user1Id, int user2Id) async {
    try {
      final authToken = await AuthService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final url1 =
          Uri.parse('$baseUrl$getPrivateMessagesEndpoint/$user1Id/$user2Id');
      final url2 =
          Uri.parse('$baseUrl$getPrivateMessagesEndpoint/$user2Id/$user1Id');

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

      return messages;
    } catch (e) {
      print('Error getting private messages: $e');
      return [];
    }
  }

  // Get property owner chats
  Future<Map<int, List<ChatMessage>>> getPropertyOwnerChats(int ownerId) async {
    try {
      final authToken = await AuthService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final url = Uri.parse('$baseUrl$getPropertyOwnerChatsEndpoint/$ownerId');
      print('Fetching property owner chats from: $url');

      final response = await http.get(url, headers: headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data == null || (data is List && data.isEmpty)) {
          return {};
        }

        final Map<int, List<ChatMessage>> result = {};

        if (data is Map) {
          for (var entry in data.entries) {
            final propertyId = int.parse(entry.key);
            final List<dynamic> messagesList = entry.value as List<dynamic>;

            result[propertyId] = messagesList
                .map((json) => ChatMessage.fromJson(json))
                .toList()
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          }
        }

        return result;
      } else if (response.statusCode == 404) {
        // No chats found, return empty map
        return {};
      } else {
        throw Exception(
            'Failed to load property owner chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting property owner chats: $e');
      return {};
    }
  }

  // Helper method to get auth headers for HTTP requests
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsessionId = prefs.getString('JSESSIONID');

    return {
      'Content-Type': 'application/json',
      if (jsessionId != null) 'Cookie': jsessionId,
    };
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
