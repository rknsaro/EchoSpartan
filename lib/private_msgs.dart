import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Message Model ---
class Message {
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isMe = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isMe: data['senderId'] == currentUserId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

// --- PrivateMessagesScreen ---
class PrivateMessagesScreen extends StatefulWidget {
  final String recipientName;
  final String recipientId;

  const PrivateMessagesScreen({
    Key? key,
    required this.recipientName,
    required this.recipientId,
  }) : super(key: key);

  @override
  State<PrivateMessagesScreen> createState() => _PrivateMessagesScreenState();

  /// Static helper method to start or get chat room and navigate to this screen
  static Future<void> startPrivateChat(
      BuildContext context, String recipientName, String recipientId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // Create consistent chatRoomId using sorted UIDs
    final sortedIds = [currentUserId, recipientId]..sort();
    final chatRoomId = "${sortedIds[0]}_${sortedIds[1]}";

    final chatDocRef =
        FirebaseFirestore.instance.collection('private_chats').doc(chatRoomId);

    final chatDoc = await chatDocRef.get();

    if (!chatDoc.exists) {
      await chatDocRef.set({
        'participants': sortedIds,
        'createdAt': Timestamp.now(),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivateMessagesScreen(
          recipientName: recipientName,
          recipientId: recipientId,
        ),
      ),
    );
  }
}

class _PrivateMessagesScreenState extends State<PrivateMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _currentUserId;
  String? _chatRoomId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserAndChatRoom();
  }

  Future<void> _getCurrentUserAndChatRoom() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;

      // Use the same logic as startPrivateChat to create chatRoomId
      final sortedIds = [_currentUserId!, widget.recipientId]..sort();
      _chatRoomId = "${sortedIds[0]}_${sortedIds[1]}";

      // Check if chat room exists, if not create it
      final chatDocRef =
          _firestore.collection('private_chats').doc(_chatRoomId);

      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists) {
        await chatDocRef.set({
          'participants': sortedIds,
          'createdAt': Timestamp.now(),
        });
      }

      setState(() {});
    } else {
      print("User not logged in!");
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _currentUserId == null ||
        _chatRoomId == null) {
      return;
    }

    try {
      String messageContent = _messageController.text.trim();
      _messageController.clear();

      await _firestore
          .collection('private_chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
        'senderId': _currentUserId,
        'content': messageContent,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('private_chats').doc(_chatRoomId).update({
        'lastMessage': messageContent,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        elevation: 0,
        title: Text(
          widget.recipientName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatRoomId == null || _currentUserId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('private_chats')
                        .doc(_chatRoomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('Say hello! No messages yet.'));
                      }

                      List<Message> messages = snapshot.data!.docs.map((doc) {
                        return Message.fromFirestore(doc, _currentUserId!);
                      }).toList();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return Align(
                            alignment: message.isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: message.isMe
                                    ? const Color(0xFFB00000)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: message.isMe
                                      ? const Radius.circular(12)
                                      : const Radius.circular(0),
                                  bottomRight: message.isMe
                                      ? const Radius.circular(0)
                                      : const Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: message.isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: message.isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${message.timestamp.hour % 12 == 0 ? 12 : message.timestamp.hour % 12}:${message.timestamp.minute.toString().padLeft(2, '0')} ${message.timestamp.hour >= 12 ? 'PM' : 'AM'}',
                                    style: TextStyle(
                                      color:
                                          message.isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFFB00000),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () {
                    // TODO: attachments
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message here',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
