class MessageModel {
  final String  id;
  final String  conversationId;
  final String  senderId;
  final String  content;
  final String  type;
  final double? amount;
  final bool    isRead;
  final String  createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    this.amount,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:             json['id']             as String,
      conversationId: json['conversationId'] as String,
      senderId:       json['senderId']       as String,
      content:        json['content']        as String,
      type:           json['type']           as String,
      amount:         json['amount'] != null
                        ? double.tryParse(json['amount'].toString())
                        : null,
      isRead:         json['isRead']         as bool,
      createdAt:      json['createdAt']      as String,
    );
  }
}
