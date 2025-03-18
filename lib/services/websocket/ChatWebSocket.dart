import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:homesphere/models/ChatMessage.dart';

typedef StompUnsubscribe = void Function();

class ChatWebSocket {
  static const String baseUrl = 'http://10.0.2.2:8090';
  static const String wsUrl = 'ws://10.0.2.2:8090/ws';

  // STOMP Endpoints
  static const String publicChatEndpoint = '/app/chat.sendMessage';
  static const String privateChatEndpoint = '/app/chat.sendPrivateMessage';
  static const String addUserEndpoint = '/app/chat.addUser';

  // Subscribe Topics
  static const String publicTopic = '/topic/public';
  static const String privateTopic = '/user/queue/messages'; // Fixed endpoint

  static ChatWebSocket? _instance;
  late StompClient stompClient;

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  bool _isConnected = false;
  String? _currentUserId;
  final Map<String, StompUnsubscribe> _subscriptions = {};

  ChatWebSocket._() {
    _initializeWebSocket();
  }

  static ChatWebSocket getInstance() {
    _instance ??= ChatWebSocket._();
    return _instance!;
  }

  void _initializeWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer your-auth-token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer your-auth-token'},
      ),
    );
  }

  void connect(String userId) {
    _currentUserId = userId;
    if (!_isConnected) {
      stompClient.activate();
    }
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    print('Connected to WebSocket');

    // Subscribe to public messages
    _subscriptions['public'] = stompClient.subscribe(
      destination: publicTopic,
      callback: (frame) {
        if (frame.body != null) {
          final message = ChatMessage.fromJson(json.decode(frame.body!));
          _messageController.add(message);
        }
      },
    );

    // Subscribe to private messages
    if (_currentUserId != null) {
      _subscriptions['private'] = stompClient.subscribe(
        destination: privateTopic,
        callback: (frame) {
          if (frame.body != null) {
            final message = ChatMessage.fromJson(json.decode(frame.body!));
            _messageController.add(message);
          }
        },
      );

      // Notify server about user joining
      sendUserJoined(_currentUserId!);
    }
  }

  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
    print('Disconnected from WebSocket');
  }

  void sendMessage(ChatMessage message) {
    if (!_isConnected) return;

    final destination =
        message.recipient == null ? publicChatEndpoint : privateChatEndpoint;

    stompClient.send(
      destination: destination,
      body: json.encode(message.toJson()),
    );
  }

  void sendUserJoined(String userId) {
    if (!_isConnected) return;

    final message = ChatMessage(
      sender: userId,
      type: MessageType.JOIN,
      timestamp: DateTime.now(),
    );

    stompClient.send(
      destination: addUserEndpoint,
      body: json.encode(message.toJson()),
    );
  }

  void disconnect() {
    _subscriptions.forEach((_, subscription) => subscription());
    _subscriptions.clear();
    stompClient.deactivate();
    _isConnected = false;
    _currentUserId = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
