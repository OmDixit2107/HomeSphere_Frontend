import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homesphere/models/ChatMessage.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/models/User.dart';
import 'package:homesphere/services/websocket/ChatWebSocket.dart';
import 'package:homesphere/services/api/UserApi.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:homesphere/providers/ChatProvider.dart';

class ChatScreen extends StatefulWidget {
  final Property? property; // Make property nullable
  final int currentUserId;
  final int otherUserId;
  final bool isPropertyOwner;

  const ChatScreen({
    Key? key,
    this.property, // Remove required
    required this.currentUserId,
    required this.otherUserId,
    required this.isPropertyOwner,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  User? _currentUser;
  User? _otherUser;

  @override
  void initState() {
    print('🔄 ChatScreen - initState');
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 ChatScreen - Post frame callback');
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    print('📱 ChatScreen - Starting initialization');
    print('👤 Current user ID: ${widget.currentUserId}');
    print('👥 Other user ID: ${widget.otherUserId}');

    if (!mounted) {
      print('❌ ChatScreen - Widget not mounted during initialization');
      return;
    }

    try {
      print('🔍 Loading current user details...');
      _currentUser = await UserApi.getUserById(widget.currentUserId);
      print(
          '👤 Current user loaded: ${_currentUser?.name} (ID: ${_currentUser?.id})');

      print('🔍 Loading other user details...');
      _otherUser = await UserApi.getUserById(widget.otherUserId);
      print(
          '👥 Other user loaded: ${_otherUser?.name} (ID: ${_otherUser?.id})');

      if (_currentUser == null || _otherUser == null) {
        throw Exception('Failed to load user details');
      }

      print('🔄 Initializing chat provider...');
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initialize(widget.currentUserId);
      print('✅ Chat provider initialized');

      print('📥 Loading chat messages...');
      await chatProvider.loadUserChat(widget.currentUserId, widget.otherUserId);
      print('✅ Chat messages loaded');

      if (mounted) {
        setState(() {
          _isInitialized = true;
          print('✅ Chat screen initialized');
        });
        _scrollToBottom();
      }
    } catch (e, stackTrace) {
      print('❌ Error in _initializeChat: $e');
      print('📚 Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading chat: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    print('📤 Attempting to send message: $text');

    if (text.isEmpty) {
      print('⚠️ Message text is empty');
      return;
    }
    if (_currentUser == null) {
      print('❌ Current user is null');
      return;
    }
    if (_otherUser == null) {
      print('❌ Other user is null');
      return;
    }

    print('📤 Creating message object...');
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final message = ChatMessage(
      content: text,
      sender: _currentUser!, // Current user is the sender
      recipient: _otherUser!, // Other user is the recipient
      type: MessageType.CHAT,
      timestamp: DateTime.now(),
    );
    print('📤 Sending message to: ${_otherUser!.name} (ID: ${_otherUser!.id})');

    chatProvider.sendMessage(message);
    print('✅ Message sent to provider');

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _otherUser?.name ?? 'Chat',
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.property !=
                null) // Only show property title if available
              Text(
                'About ${widget.property!.title}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (widget.property !=
              null) // Only show property info button if available
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showPropertyDetails,
            ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.property != null) _buildPropertyBanner(),
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildPropertyBanner() {
    if (widget.property == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Image.network(
            widget.property!.mainImage,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.property!.location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    print('🔄 Building message list');
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.getMessagesForConversation(
          widget.currentUserId,
          widget.otherUserId,
        );
        print('📊 Total messages: ${messages.length}');

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.sender.id == widget.currentUserId;

            print(
                '💬 Message ${index + 1}/${messages.length}: ${message.content}');
            print(
                '👤 Sender ID: ${message.sender.id}, Current User ID: ${widget.currentUserId}');
            print('📍 Alignment: ${isMe ? 'Right' : 'Left'}');

            return Padding(
              padding: EdgeInsets.only(
                left: isMe ? 64.0 : 8.0,
                right: isMe ? 8.0 : 64.0,
                bottom: 8.0,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _MessageBubble(
                    message: message,
                    isMe: isMe,
                  ),
                  if (index < messages.length - 1 &&
                      messages[index + 1].sender.id != message.sender.id)
                    const SizedBox(
                        height:
                            12), // Add extra space between different senders
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showPropertyDetails() {
    // Implement the logic to show property details
  }

  @override
  void dispose() {
    print('🔄 ChatScreen - dispose');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Update the _MessageBubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[600] : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.content ?? '',
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: isMe ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
