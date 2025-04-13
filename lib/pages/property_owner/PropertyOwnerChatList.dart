import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:homesphere/models/User.dart';
import 'package:homesphere/providers/ChatProvider.dart';
import 'package:homesphere/services/api/UserApi.dart';
import 'package:homesphere/pages/chat/ChatScreen.dart';

class PropertyOwnerChatList extends StatefulWidget {
  final int ownerId;

  const PropertyOwnerChatList({
    super.key,
    required this.ownerId,
  });

  @override
  State<PropertyOwnerChatList> createState() => _PropertyOwnerChatListState();
}

class _PropertyOwnerChatListState extends State<PropertyOwnerChatList> {
  bool _isLoading = true;
  List<User> _chatUsers = [];

  @override
  void initState() {
    super.initState();
    _loadChatUsers();
  }

  Future<void> _loadChatUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('📱 Loading chat users for owner ID: ${widget.ownerId}');

      // Update URL to use 10.0.2.2 instead of localhost for Android emulator
      final url = Uri.parse(
          'http://10.0.2.2:8090/api/properties/users?ownerId=${widget.ownerId}');
      print('🌐 Making request to: $url');

      final response = await http.get(url);
      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final users = data.map((json) {
          final user = User.fromJson(json);
          print('👤 Loaded user: ${user.name} (ID: ${user.id})');
          return user;
        }).toList();

        print('👥 Total users loaded: ${users.length}');

        if (mounted) {
          setState(() {
            _chatUsers = users;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load chat users: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading chat users: $e');
      print('📚 Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadChatUsers,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChatUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatUsers.isEmpty
              ? _buildEmptyState()
              : _buildUserList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No active chats',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Users who message you about your properties\nwill appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _chatUsers.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final user = _chatUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openChatScreen(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 28,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'User ${user.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChatScreen(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          property: null, // Now this is valid since Property is nullable
          currentUserId: widget.ownerId,
          otherUserId: user.id,
          isPropertyOwner: true,
        ),
      ),
    ).then((_) => _loadChatUsers());
  }
}
