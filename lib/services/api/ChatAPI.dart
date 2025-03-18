import 'dart:convert';
import 'package:homesphere/models/ChatMessage.dart';
import 'package:http/http.dart' as http;

class ChatApi {
  static const String baseUrl = 'http://10.0.2.2:8090';

  // Get public chat messages
  static Future<List<ChatMessage>> getPublicMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/messages/public'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load public messages');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get private chat messages between two users
  static Future<List<ChatMessage>> getPrivateMessages({
    required String sender,
    required String recipient,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/chat/messages/private?sender=$sender&recipient=$recipient',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load private messages');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get all messages for a user (both public and private)
  static Future<List<ChatMessage>> getAllMessages({
    required String sender,
    String? recipient,
  }) async {
    if (recipient != null) {
      return getPrivateMessages(sender: sender, recipient: recipient);
    } else {
      return getPublicMessages();
    }
  }

  // Send a new message
  static Future<void> sendMessage(ChatMessage message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> markMessageAsRead(String messageId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/messages/$messageId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isRead': true}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark message as read');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get unread message count
  static Future<int> getUnreadMessageCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/unread/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] as int;
      } else {
        throw Exception('Failed to get unread message count');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
