import 'package:flutter/material.dart';
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
      // Get the chat provider
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initialize(widget.ownerId);

      // Hardcoded users for testing
      final List<User> users = [
        User(
            id: 1,
            name: 'John Doe',
            email: 'john@example.com',
            password: '',
            role: 'User',
            contact_No: '1234567890'),
        User(
            id: 2,
            name: 'Jane Smith',
            email: 'jane@example.com',
            password: '',
            role: 'User',
            contact_No: '2345678901'),
        User(
            id: 3,
            name: 'Mike Johnson',
            email: 'mike@example.com',
            password: '',
            role: 'User',
            contact_No: '3456789012'),
        User(
            id: 4,
            name: 'Sarah Williams',
            email: 'sarah@example.com',
            password: '',
            role: 'User',
            contact_No: '4567890123'),
        User(
            id: 5,
            name: 'Alex Brown',
            email: 'alex@example.com',
            password: '',
            role: 'User',
            contact_No: '5678901234'),
      ];

      if (mounted) {
        setState(() {
          _chatUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading chat users: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
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
