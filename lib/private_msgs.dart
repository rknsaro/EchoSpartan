// private_msgs.dart

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
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isMe: data['senderId'] == currentUserId,
    );
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

  static Future<void> startPrivateChat(BuildContext context, String recipientName, String recipientId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;
    final sortedIds = [currentUserId, recipientId]..sort();
    final chatRoomId = "${sortedIds[0]}_${sortedIds[1]}";

    final chatRef = FirebaseFirestore.instance.collection('private_chats').doc(chatRoomId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': sortedIds,
        'createdAt': Timestamp.now(),
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateMessagesScreen(
          recipientName: recipientName,
          recipientId: recipientId,
        ),
      ),
    );
  }

  @override
  State<PrivateMessagesScreen> createState() => _PrivateMessagesScreenState();
}

class _PrivateMessagesScreenState extends State<PrivateMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _currentUserId;
  String? _chatRoomId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  Future<void> _setupChat() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _currentUserId = user.uid;
    final sortedIds = [_currentUserId!, widget.recipientId]..sort();
    _chatRoomId = "${sortedIds[0]}_${sortedIds[1]}";

    final chatRef = _firestore.collection('private_chats').doc(_chatRoomId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': sortedIds,
        'createdAt': Timestamp.now(),
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
      });
    }

    setState(() {});
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatRoomId == null || _currentUserId == null || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final msgData = {
      'senderId': _currentUserId,
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final chatRef = _firestore.collection('private_chats').doc(_chatRoomId);
    final messagesRef = chatRef.collection('messages');

    try {
      await messagesRef.add(msgData);
      await chatRef.update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Send failed: $e")),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        title: Text(widget.recipientName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatRoomId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('private_chats')
                        .doc(_chatRoomId)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final messages = snapshot.data!.docs
                          .map((doc) => Message.fromFirestore(doc, _currentUserId!))
                          .toList();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(10),
                        itemCount: messages.length,
                        itemBuilder: (_, index) {
                          final msg = messages[index];
                          return Align(
                            alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: msg.isMe ? const Color(0xFFB00000) : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.content,
                                    style: TextStyle(color: msg.isMe ? Colors.white : Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${msg.timestamp.hour % 12 == 0 ? 12 : msg.timestamp.hour % 12}:${msg.timestamp.minute.toString().padLeft(2, '0')} ${msg.timestamp.hour >= 12 ? 'PM' : 'AM'}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: msg.isMe ? Colors.white70 : Colors.black54,
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _messageController.text.trim().isNotEmpty ? Colors.white : Colors.white54,
                  ),
                  onPressed: _messageController.text.trim().isNotEmpty ? _sendMessage : null,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
