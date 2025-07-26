import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Uncomment this line if you're using Firebase Auth

class ChatScreen extends StatefulWidget {
  final String chatTitle; // Can be community name, private chat partner, or channel name
  final String chatRoomId; // This will be the communityId, or a generated private chat ID
  final String chatType; // 'community', 'private', 'channel' - useful for future logic

  const ChatScreen({
    super.key,
    required this.chatTitle,
    required this.chatRoomId,
    this.chatType = 'community', // Default to community chat
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This will be the reference to the specific messages collection
  late CollectionReference _messagesCollection;

  @override
  void initState() {
    super.initState();
    // Initialize the messages collection based on chatType
    _initializeMessagesCollection();
  }

  void _initializeMessagesCollection() {
    if (widget.chatType == 'community' || widget.chatType == 'announcements') {
      // For communities and announcements within a community, messages are under 'communities'
      _messagesCollection = _firestore
          .collection('communities')
          .doc(widget.chatRoomId)
          .collection(widget.chatType == 'announcements' ? 'announcements' : 'messages');
      // Note: If 'announcements' should be a subcollection of 'communities' like 'messages',
      // this setup works. If 'announcements' is a separate top-level concept, adjust this.
    } else if (widget.chatType == 'private') {
      _messagesCollection = _firestore
          .collection('privateChats') // A new collection for private chats
          .doc(widget.chatRoomId)
          .collection('messages');
    } else if (widget.chatType == 'channel') {
      _messagesCollection = _firestore
          .collection('channels') // A new collection for channels
          .doc(widget.chatRoomId)
          .collection('messages');
    } else {
      ('Warning: Unknown chat type provided: ${widget.chatType}. Defaulting to community messages path.');
      _messagesCollection = _firestore
          .collection('communities') // Default fallback
          .doc(widget.chatRoomId)
          .collection('messages');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    try {
      const String currentUserId = 'test_user_id';
      const String currentUserName = 'Test User'; 
      // --- End of Auth placeholder ---

      if (currentUserId == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      await _messagesCollection.add({
        'text': _messageController.text.trim(),
        'senderId': currentUserId,
        'senderName': currentUserName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
        backgroundColor: const Color(0xFFB00000),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Use the initialized _messagesCollection for the stream
              stream: _messagesCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Firestore Stream Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet. Be the first to say hi!'));
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true, // Show most recent messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final messageText = messageData['text'] as String? ?? 'No text';
                    final senderName = messageData['senderName'] as String? ?? 'Unknown User';
                    final timestamp = messageData['timestamp'] as Timestamp?;

                    String timeString = '';
                    if (timestamp != null) {
                      final dateTime = timestamp.toDate();
                      timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                    }

                    // IMPORTANT: Replace 'test_user_id' with the actual authenticated user's ID
                    // This determines if the message is from the current user.
                    // If using Firebase Auth: final bool isMe = messageData['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                    const String currentUserId = 'test_user_id'; // Make sure this matches the senderId used in _sendMessage
                    final bool isMe = messageData['senderId'] == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFB00000) : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isMe ? const Radius.circular(15) : const Radius.circular(0),
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              messageText,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            if (timestamp != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  timeString,
                                  style: TextStyle(
                                    color: isMe ? Colors.white60 : Colors.black45,
                                    fontSize: 10,
                                  ),
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
          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (value) => _sendMessage(), // Allows sending on keyboard enter
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: const Color(0xFFB00000),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}