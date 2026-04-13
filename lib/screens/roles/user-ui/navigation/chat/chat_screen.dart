// lib/screens/navigation/chat/chat_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lsffend/config/app_config.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/chat/chat_service.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/chat/message_model.dart';
import 'package:lsffend/services/api_service.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/chat/chat_screen.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ChatScreen extends StatefulWidget {
  final int workerId;
  final String workerName;
  final String? workerImage;

  const ChatScreen({
    super.key,
    required this.workerId,
    required this.workerName,
    this.workerImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int _currentUserId = 0;

  // Mock messages for offline mode
  final List<Map<String, dynamic>> _mockMessages = [
    {
      'id': 1,
      'sender_id': 2, // current user
      'content': 'Hello! I need a house cleaning service.',
      'is_read': true,
      'created_at': '2026-03-17T10:30:00.000Z',
    },
    {
      'id': 2,
      'sender_id': 1, // worker
      'content': 'Hi! Sure, when would you like it done?',
      'is_read': true,
      'created_at': '2026-03-17T10:31:00.000Z',
    },
    {
      'id': 3,
      'sender_id': 2,
      'content': 'This Saturday morning would be great!',
      'is_read': true,
      'created_at': '2026-03-17T10:32:00.000Z',
    },
    {
      'id': 4,
      'sender_id': 1,
      'content': 'Perfect! I am available at 9AM. See you then!',
      'is_read': false,
      'created_at': '2026-03-17T10:33:00.000Z',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    if (!AppConfig.offlineMode) {
      _initPusher();
    }
  }

  Future<void> _loadCurrentUser() async {
    final response = await ApiService.getRequest('/auth/me', auth: true);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() => _currentUserId = data['id']);
    }
  }

  Future<void> _loadMessages() async {
    if (AppConfig.offlineMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _currentUserId = 2; // mock current user id
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    final messages = await ChatService.getConversation(widget.workerId);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<void> _initPusher() async {
    try {
      await _pusher.init(
        apiKey: AppConfig.pusherKey,
        cluster: AppConfig.pusherCluster,
      );

      await _pusher.connect();

      // Subscribe to private channel
      final ids = [_currentUserId, widget.workerId]..sort();
      final channelName = 'private-chat.${ids[0]}.${ids[1]}';

      await _pusher.subscribe(
        channelName: channelName,
        onEvent: (event) {
          if (event.eventName == 'App\\Events\\MessageSent') {
            final data = jsonDecode(event.data);
            final newMessage = MessageModel.fromJson(data);
            setState(() => _messages.add(newMessage));
            _scrollToBottom();
          }
        },
      );
    } catch (e) {
      debugPrint('Pusher error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    if (AppConfig.offlineMode) {
      // Add mock message locally
      setState(() {
        _mockMessages.add({
          'id': _mockMessages.length + 1,
          'sender_id': 2,
          'content': content,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      });
      _scrollToBottom();
      return;
    }

    setState(() => _isSending = true);

    final message = await ChatService.sendMessage(
      receiverId: widget.workerId,
      content: content,
    );

    if (message != null) {
      setState(() => _messages.add(message));
      _scrollToBottom();
    }

    setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (!AppConfig.offlineMode) {
      _pusher.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          children: [
            // Worker avatar
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.workerImage != null
                  ? NetworkImage(widget.workerImage!)
                  : null,
              child: widget.workerImage == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.workerName,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Online status
                Text(
                  'Online',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: AppConfig.offlineMode
                        ? _mockMessages.length
                        : _messages.length,
                    itemBuilder: (context, index) {
                      if (AppConfig.offlineMode) {
                        final msg = _mockMessages[index];
                        final isMe = msg['sender_id'] == _currentUserId;
                        return _buildMessageBubble(
                          content: msg['content'],
                          isMe: isMe,
                          isRead: msg['is_read'],
                          time: DateTime.parse(msg['created_at']),
                        );
                      }
                      final msg = _messages[index];
                      final isMe = msg.senderId == _currentUserId;
                      return _buildMessageBubble(
                        content: msg.content,
                        isMe: isMe,
                        isRead: msg.isRead,
                        time: msg.createdAt,
                      );
                    },
                  ),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String content,
    required bool isMe,
    required bool isRead,
    required DateTime time,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 3),

            // Time + read receipt
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead ? AppColors.primaryColor : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
