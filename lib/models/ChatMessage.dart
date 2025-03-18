enum MessageType { CHAT, JOIN, LEAVE }

class ChatMessage {
  final String? content;
  final String sender;
  final String? recipient;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    this.content,
    required this.sender,
    this.recipient,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'],
      sender: json['sender'],
      recipient: json['recipient'],
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.CHAT,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'recipient': recipient,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
