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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;

    try {
      _currentUser = await UserApi.getUserById(widget.currentUserId);
      _otherUser = await UserApi.getUserById(widget.otherUserId);

      if (_currentUser == null || _otherUser == null) {
        throw Exception('Failed to load user details');
      }

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initialize(widget.currentUserId);
      await chatProvider.loadUserChat(widget.currentUserId, widget.otherUserId);

      if (mounted) {
        setState(() => _isInitialized = true);
        _scrollToBottom();
      }
    } catch (e) {
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
    if (text.isEmpty || _currentUser == null || _otherUser == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final message = ChatMessage(
      content: text,
      sender: _currentUser!, // Current user is the sender
      recipient: _otherUser!, // Other user is the recipient
      type: MessageType.CHAT,
      timestamp: DateTime.now(),
    );

    chatProvider.sendMessage(message);
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
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.getMessagesForConversation(
          widget.currentUserId,
          widget.otherUserId,
        );

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            // Fix the isMe logic to correctly identify message sender
            final isMe = message.sender.id == widget.currentUserId;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _MessageBubble(
                message: message,
                isMe: isMe,
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
    return Align(
      // Align messages based on sender
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64.0 : 0.0,
          right: isMe ? 0.0 : 64.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[600] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
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
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
