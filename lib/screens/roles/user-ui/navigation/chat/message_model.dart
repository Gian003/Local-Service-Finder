class MessageModel {
  final int id;
  final int senderId;
  final String? senderType;
  final int receiverId;
  final String? receiverType;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;
  // True for a message queued locally while offline, not yet confirmed sent.
  final bool isPending;

  const MessageModel({
    required this.id,
    required this.senderId,
    this.senderType,
    required this.receiverId,
    this.receiverType,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.sender,
    this.receiver,
    this.isPending = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:           json['id'],
      senderId:     json['sender_id'],
      senderType:   json['sender_type']?.toString(),
      receiverId:   json['receiver_id'],
      receiverType: json['receiver_type']?.toString(),
      content:      json['content'],
      isRead:       json['is_read'] ?? false,
      createdAt:    DateTime.parse(json['created_at']),
      sender:       json['sender'],
      receiver:     json['receiver'],
    );
  }
}