/// A single chat message between two users.
class Message {
  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.sentAt,
  });

  factory Message.fromMap(Map<String, dynamic> m) => Message(
    id: m['id'] as String,
    senderId: m['senderId'] as String,
    receiverId: m['receiverId'] as String,
    text: m['text'] as String,
    sentAt: DateTime.parse(m['sentAt'] as String),
  );

  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime sentAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'sentAt': sentAt.toIso8601String(),
  };
}
