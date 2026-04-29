import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get or create a chat room between two users
  Future<String> getOrCreateChat({
    required String buyerId,
    required String sellerId,
    required String buyerName,
    required String sellerName,
    String? buyerAvatar,
    String? sellerAvatar,
  }) async {
    // Check if chat exists
    final snapshot = await _db.collection('chats')
        .where('participants', arrayContains: buyerId)
        .get();

    for (var doc in snapshot.docs) {
      List participants = doc['participants'];
      if (participants.contains(sellerId)) {
        return doc.id;
      }
    }

    // Create new chat
    final docRef = _db.collection('chats').doc();
    final chat = ChatModel(
      id: docRef.id,
      participants: [buyerId, sellerId],
      lastMessage: 'Start a conversation',
      lastMessageTime: DateTime.now(),
      lastMessageSenderId: '',
      participantNames: {buyerId: buyerName, sellerId: sellerName},
      participantAvatars: {buyerId: buyerAvatar ?? '', sellerId: sellerAvatar ?? ''},
    );

    await docRef.set(chat.toJson());
    return docRef.id;
  }

  /// Send a message
  Future<void> sendMessage(String chatId, String senderId, String text, {MessageType type = MessageType.text, String? imageUrl, double? latitude, double? longitude}) async {
    final message = MessageModel(
      id: '',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      type: type,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
    );

    await _db.collection('chats').doc(chatId).collection('messages').add(message.toJson());

    // Update last message in chat room
    String lastMsgText = text;
    if (type == MessageType.image) lastMsgText = '📷 Photo';
    if (type == MessageType.location) lastMsgText = '📍 Location';

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': lastMsgText,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
    });
  }

  /// Get messages stream
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db.collection('chats').doc(chatId).collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Get user chats stream
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _db.collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
