import 'package:flutter/material.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/chat_service.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/message_model.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/chat_screen.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/utils/image_helper.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  List<MessageModel> _conversations = [];
  bool _isLoading = true;

  // Mock conversations for offline mode
  final List<Map<String, dynamic>> _mockConversations = [
    {
      'id': 1,
      'worker_name': 'John Reyes',
      'worker_id': 1,
      'last_message': 'Hello! I need a house cleaning service.',
      'time': '10:30 AM',
      'unread': 2,
      'image': 'https://picsum.photos/seed/john/200',
    },
    {
      'id': 2,
      'worker_name': 'Joseph Santos',
      'worker_id': 2,
      'last_message': 'When are you available?',
      'time': '9:15 AM',
      'unread': 0,
      'image': 'https://picsum.photos/seed/joseph/200',
    },
    {
      'id': 3,
      'worker_name': 'Henry Cruz',
      'worker_id': 3,
      'last_message': 'The repair is done!',
      'time': 'Yesterday',
      'unread': 1,
      'image': 'https://picsum.photos/seed/henry/200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (AppConfig.offlineMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isLoading = false);
      return;
    }

    final conversations = await ChatService.getConversations();
    setState(() {
      _conversations = conversations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child:  Text(
                          'Chat & Calls',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Conversation list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: AppConfig.offlineMode
                        ? _mockConversations.length
                        : _conversations.length,
                    itemBuilder: (context, index) {
                      if (AppConfig.offlineMode) {
                        return _buildMockConversationTile(
                          _mockConversations[index],
                        );
                      }
                      return _buildConversationTile(_conversations[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Offline mode tile
  Widget _buildMockConversationTile(Map<String, dynamic> data) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              workerId: data['worker_id'],
              workerName: data['worker_name'],
              workerImage: data['image'],
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: safeNetworkImage(data['image'] as String?),
          ),
          // Online indicator
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        data['worker_name'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        data['last_message'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            data['time'],
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          if (data['unread'] > 0)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${data['unread']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Online mode tile
  Widget _buildConversationTile(MessageModel message) {
    final firstName = message.receiver?['first_name'] ?? '';
    final lastName = message.receiver?['last_name'] ?? '';
    final combined = '$firstName $lastName'.trim();
    final workerName = combined.isNotEmpty ? combined : 'Worker';
    final workerPhoto = message.receiver?['profile_photo'] as String?;
    final minute = message.createdAt.minute.toString().padLeft(2, '0');

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              workerId: message.receiverId,
              workerName: workerName,
              workerImage: workerPhoto,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: safeNetworkImage(workerPhoto),
        child: (workerPhoto == null || workerPhoto.isEmpty)
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(
        workerName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        message.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Text(
        '${message.createdAt.hour}:$minute',
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: Colors.grey[500]),
      ),
    );
  }
}
