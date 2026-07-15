import 'dart:convert';
import 'dart:math';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/services/local_db.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/message_model.dart';

class ChatService {
  // Get all conversations
  static Future<List<MessageModel>> getConversations() async {
    final response = await ApiService.getRequest('conversations', auth: true);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get conversation with a specific worker
  static Future<List<MessageModel>> getConversation(int workerId) async {
    final response = await ApiService.getRequest(
      'conversations/$workerId',
      auth: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    }
    return [];
  }

  // Send a message. If the request fails outright (no connectivity), the
  // message is queued in the outbox and a locally-rendered pending copy is
  // returned instead of null, so it still shows up in the thread; SyncService
  // sends it for real once the connection comes back.
  static Future<MessageModel?> sendMessage({
    required int receiverId,
    required String content,
    required int senderId,
  }) async {
    final body = {'receiver_id': receiverId, 'content': content};

    try {
      final response = await ApiService.postRequest('messages', body, auth: true);

      if (response.statusCode == 201) {
        return MessageModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      final idempotencyKey =
          '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

      await LocalDb.enqueue(
        endpoint: 'messages',
        method: 'POST',
        body: {...body, 'idempotency_key': idempotencyKey},
        idempotencyKey: idempotencyKey,
      );

      return MessageModel(
        id: -DateTime.now().millisecondsSinceEpoch,
        senderId: senderId,
        senderType: 'user',
        receiverId: receiverId,
        receiverType: 'worker',
        content: content,
        isRead: false,
        createdAt: DateTime.now(),
        isPending: true,
      );
    }
  }
}
