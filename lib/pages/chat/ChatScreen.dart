import 'package:flutter/material.dart';
import 'package:homesphere/models/ChatMessage.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/services/websocket/ChatWebSocket.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Property property;
  final String currentUserId;
  final String propertyOwnerId;

  const ChatScreen({
    super.key,
    required this.property,
    required this.currentUserId,
    required this.propertyOwnerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late final ChatWebSocket _chatWebSocket;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    // Initialize WebSocket connection
    _chatWebSocket = ChatWebSocket.getInstance();
    _chatWebSocket.connect(widget.currentUserId);

    // Listen for new messages
    _chatWebSocket.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });

    // Load previous messages
    try {
      final previousMessages = await _loadPreviousMessages();
      setState(() {
        _messages.addAll(previousMessages);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load previous messages');
    }
  }

  Future<List<ChatMessage>> _loadPreviousMessages() async {
    // Implement loading previous messages from your API
    return [];
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      content: _messageController.text.trim(),
      sender: widget.currentUserId,
      recipient: widget.propertyOwnerId,
      type: MessageType.CHAT,
      timestamp: DateTime.now(),
    );

    try {
      _chatWebSocket.sendMessage(message);
      _messageController.clear();
      _scrollToBottom(); // Ensure new message is visible
    } catch (e) {
      _showError('Failed to send message');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.property.title),
            Text(
              widget.property.location,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Property Summary Card
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: FutureBuilder(
                future: null, // Add property image loading here
                builder: (context, snapshot) {
                  return const Icon(Icons.home);
                },
              ),
              title: Text(
                "₹${widget.property.price.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                widget.property.type == "rent" ? "per month" : "buy",
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.sender == widget.currentUserId;
                      final showTimestamp = index == 0 ||
                          _shouldShowTimestamp(
                            _messages[index],
                            _messages[index - 1],
                          );

                      return Column(
                        children: [
                          if (showTimestamp)
                            _buildTimestampDivider(message.timestamp),
                          _MessageBubble(
                            message: message,
                            isMe: isMe,
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(ChatMessage current, ChatMessage previous) {
    return current.timestamp.difference(previous.timestamp).inMinutes >= 5;
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        _formatMessageDate(timestamp),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Today ${DateFormat('HH:mm').format(date)}";
    } else if (messageDate == yesterday) {
      return "Yesterday ${DateFormat('HH:mm').format(date)}";
    } else {
      return DateFormat('MMM d, HH:mm').format(date);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

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
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.JOIN)
              Text(
                "${message.sender} joined the chat",
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              )
            else if (message.type == MessageType.LEAVE)
              Text(
                "${message.sender} left the chat",
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                message.content ?? "",
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
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
      ),
    );
  }
}
