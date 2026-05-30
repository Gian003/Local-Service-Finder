class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:         json['id'],
      senderId:   json['sender_id'],
      receiverId: json['receiver_id'],
      content:    json['content'],
      isRead:     json['is_read'] ?? false,
      createdAt:  DateTime.parse(json['created_at']),
      sender:     json['sender'],
      receiver:   json['receiver'],
    );
  }
}