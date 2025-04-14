import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesphere/models/ChatMessage.dart';
import 'package:homesphere/models/User.dart';

void main() {
  group('ChatMessage Model Tests', () {
    late User testSender;
    late User testRecipient;
    late DateTime testTimestamp;

    setUp(() {
      // Initialize test data
      testSender = User(
        id: 1,
        name: 'Sender',
        email: 'sender@example.com',
        password: 'password123',
        contact_No: '1234567890',
        role: 'User',
      );
      
      testRecipient = User(
        id: 2,
        name: 'Recipient',
        email: 'recipient@example.com',
        password: 'password123',
        contact_No: '0987654321',
        role: 'Property Owner',
      );
      
      testTimestamp = DateTime(2023, 5, 15, 10, 30, 0); // Fixed timestamp for testing
    });

    test('ChatMessage creates from full JSON correctly', () {
      final Map<String, dynamic> messageData = {
        'id': 1,
        'content': 'Hello, this is a test message',
        'sender': testSender.toJson(),
        'recipient': testRecipient.toJson(),
        'type': 'CHAT',
        'timestamp': testTimestamp.toIso8601String(),
      };

      final ChatMessage message = ChatMessage.fromJson(messageData);

      expect(message.id, equals(1));
      expect(message.content, equals('Hello, this is a test message'));
      expect(message.sender.id, equals(testSender.id));
      expect(message.sender.name, equals(testSender.name));
      expect(message.recipient.id, equals(testRecipient.id));
      expect(message.recipient.name, equals(testRecipient.name));
      expect(message.type, equals(MessageType.CHAT));
      expect(message.timestamp, equals(testTimestamp));
    });

    test('ChatMessage creates from JSON with sender/recipient IDs', () {
      final Map<String, dynamic> messageData = {
        'id': 2,
        'content': 'Message with sender/recipient IDs',
        'senderId': 1,
        'recipientId': 2,
        'type': 'CHAT',
        'timestamp': testTimestamp.toIso8601String(),
      };

      final ChatMessage message = ChatMessage.fromJson(messageData);

      expect(message.id, equals(2));
      expect(message.content, equals('Message with sender/recipient IDs'));
      expect(message.sender.id, equals(1));
      expect(message.recipient.id, equals(2));
      expect(message.type, equals(MessageType.CHAT));
      expect(message.timestamp, equals(testTimestamp));
    });

    test('ChatMessage converts to JSON correctly', () {
      final ChatMessage message = ChatMessage(
        id: 3,
        content: 'Test serialization',
        sender: testSender,
        recipient: testRecipient,
        type: MessageType.CHAT,
        timestamp: testTimestamp,
      );

      final Map<String, dynamic> json = message.toJson();

      expect(json['id'], equals(3));
      expect(json['content'], equals('Test serialization'));
      expect(json['sender'], isA<Map<String, dynamic>>());
      expect(json['sender']['id'], equals(testSender.id));
      expect(json['recipient'], isA<Map<String, dynamic>>());
      expect(json['recipient']['id'], equals(testRecipient.id));
      expect(json['type'], equals('CHAT'));
      expect(json['timestamp'], equals(testTimestamp.toIso8601String()));
    });

    test('ChatMessage handles different message types', () {
      // Test JOIN message type
      final ChatMessage joinMessage = ChatMessage(
        id: 4,
        content: 'User joined',
        sender: testSender,
        recipient: testRecipient,
        type: MessageType.JOIN,
        timestamp: testTimestamp,
      );

      expect(joinMessage.type, equals(MessageType.JOIN));
      expect(joinMessage.toJson()['type'], equals('JOIN'));

      // Test LEAVE message type
      final ChatMessage leaveMessage = ChatMessage(
        id: 5,
        content: 'User left',
        sender: testSender,
        recipient: testRecipient,
        type: MessageType.LEAVE,
        timestamp: testTimestamp,
      );

      expect(leaveMessage.type, equals(MessageType.LEAVE));
      expect(leaveMessage.toJson()['type'], equals('LEAVE'));
    });

    test('ChatMessage.toSendJson creates simplified JSON for sending', () {
      final ChatMessage message = ChatMessage(
        id: 6,
        content: 'Test for sending',
        sender: testSender,
        recipient: testRecipient,
        type: MessageType.CHAT,
        timestamp: testTimestamp,
      );

      final Map<String, dynamic> sendJson = message.toSendJson();

      // Verify simplified format
      expect(sendJson['content'], equals('Test for sending'));
      expect(sendJson['senderId'], equals(testSender.id));
      expect(sendJson['recipientId'], equals(testRecipient.id));
      expect(sendJson['type'], equals('CHAT'));
      
      // Verify that full user objects and timestamps are not included
      expect(sendJson.containsKey('sender'), isFalse);
      expect(sendJson.containsKey('recipient'), isFalse);
      expect(sendJson.containsKey('timestamp'), isFalse);
    });
  });
} 