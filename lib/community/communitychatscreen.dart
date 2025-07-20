// community_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityChatScreen extends StatelessWidget {
  final String communityId;
  final String communityName;

  const CommunityChatScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(communityName),
        backgroundColor: const Color(0xFFB00000),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('communities')
                  .doc(communityId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error loading messages'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) return const Center(child: Text('No messages yet.'));

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final sender = data['sender'] ?? 'Unknown';
                    final text = data['text'] ?? '';
                    final time = (data['timestamp'] as Timestamp?)?.toDate();

                    return ListTile(
                      title: Text(sender, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(text),
                      trailing: Text(
                        time != null ? '${time.hour}:${time.minute.toString().padLeft(2, '0')}' : '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFB00000)),
                  onPressed: () async {
                    final text = messageController.text.trim();
                    if (text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('communities')
                          .doc(communityId)
                          .collection('messages')
                          .add({
                        'text': text,
                        'sender': 'Anonymous', // Replace with actual user later
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      messageController.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
