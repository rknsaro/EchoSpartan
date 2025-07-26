import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ClassChatScreen extends StatefulWidget {
  const ClassChatScreen({super.key});

  @override
  State<ClassChatScreen> createState() => _ClassChatScreenState();
}

class _ClassChatScreenState extends State<ClassChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  final ImagePicker _picker = ImagePicker();

  void _sendMessage({String? text, XFile? image}) {
    if ((text == null || text.trim().isEmpty) && image == null) return;

    setState(() {
      _messages.add({
        'sender': 'You',
        'text': text,
        'image': image,
        'time': TimeOfDay.now().format(context),
      });
    });

    _messageController.clear();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendMessage(image: pickedFile);
    }
  }

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      {
        'sender': 'Jane Doe',
        'text':
            'hello ! we’re hiring encoder po! no registration fee, hawak mo oras mo, dollar rate, daily payout! if interested just kindly message me lang po!',
        'time': '1:11 PM',
      },
      // {
      //   'sender': 'Lucas',
      //   'text': 'Nulla suscipit, nunc ut pretium imperdiet Lorem ipsum...',
      //   'time': '1:13 PM',
      // },
      // {
      //   'sender': 'You',
      //   'text': 'Lorem ipsum dolor sit amet...',
      //   'time': '1:30 PM',
      // },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: const Color(0xFFB00000),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Channels',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'Class SM-4102',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'You';

                if (msg['image'] != null) {
                  return _ImageBubble(
                    isUser: isUser,
                    imageData: msg['image'],
                    time: msg['time'],
                  );
                } else if (isUser) {
                  return _MyChatBubble(
                    message: msg['text'],
                    time: msg['time'],
                  );
                } else {
                  return _ChatBubble(
                    username: msg['sender'],
                    message: msg['text'],
                    time: msg['time'],
                  );
                }
              },
            ),
          ),
          _ChatInputField(
            controller: _messageController,
            onSend: () => _sendMessage(text: _messageController.text),
            onImagePressed: _pickImage,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String username;
  final String message;
  final String time;

  const _ChatBubble({
    required this.username,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFB00000),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFB00000), width: 1),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _MyChatBubble extends StatelessWidget {
  final String message;
  final String time;

  const _MyChatBubble({required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFB00000),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  final bool isUser;
  final XFile? imageData;
  final String time;

  const _ImageBubble({
    required this.isUser,
    required this.imageData,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageData == null) {
      imageWidget = const Text('Image not available');
    } else if (kIsWeb) {
      imageWidget = FutureBuilder<Uint8List>(
        future: imageData!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          } else if (snapshot.hasError) {
            return const Center(child: Icon(Icons.error, color: Colors.red));
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      try {
        imageWidget = Image.file(
          File(imageData!.path),
          fit: BoxFit.cover,
        );
      } catch (e) {
        imageWidget = Center(child: Text('Error loading image: $e'));
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isUser ? const Color(0xFFB00000) : Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageWidget,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:
                Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class _ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImagePressed;

  const _ChatInputField({
    required this.controller,
    required this.onSend,
    required this.onImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      color: const Color(0xFF8B0000),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: onImagePressed,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter your message here',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}