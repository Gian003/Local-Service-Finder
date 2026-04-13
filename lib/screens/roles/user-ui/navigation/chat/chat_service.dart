import 'dart:convert';
import 'package:lsffend/services/api_service.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/chat/message_model.dart';

class ChatService {
  // Get all conversations
  static Future<List<MessageModel>> getConversations() async {
    final response = await ApiService.getRequest('/conversations', auth: true);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get conversation with a specific worker
  static Future<List<MessageModel>> getConversation(int workerId) async {
    final response = await ApiService.getRequest(
      '/conversations/$workerId',
      auth: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    }
    return [];
  }

  // Send a message
  static Future<MessageModel?> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    final response = await ApiService.postRequest('/messages', {
      'receiver_id': receiverId,
      'content': content,
    }, auth: true);

    if (response.statusCode == 201) {
      return MessageModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
