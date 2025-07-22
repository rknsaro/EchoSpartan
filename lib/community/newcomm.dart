// Path: lib/community/newcomm.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:try_1/community/prevcomm.dart'; // Import prevcomm.dart (Adjust path if needed)

class NewCommunityScreen extends StatefulWidget {
  const NewCommunityScreen({super.key});

  @override
  State<NewCommunityScreen> createState() => _NewCommunityScreenState();
}

class _NewCommunityScreenState extends State<NewCommunityScreen> {
  File? _communityImage;
  Uint8List? _communityImageBytes;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  final int _nameLimit = 75;
  final int _introLimit = 250;

  bool _requestApproval = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _introController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _communityImageBytes = bytes;
          _communityImage = null;
        });
      } else {
        setState(() {
          _communityImage = File(pickedFile.path);
          _communityImageBytes = null; // Ensure bytes are null for non-web
        });
      }
    }
  }

  void _showAboutCommunityDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'About this community',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'The community is visible to anyone on\nEchoSpartan, but only members can see who\'s in it\nand messages they send',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'This community may be shown as a suggestion to\nanyone in EchoSpartan',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Admins can delete content and suspend or remove\ncommunity members',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    children: [
                      const TextSpan(
                        text: 'To help members feel safe and welcome, we review\nchats againts our ',
                      ),
                      TextSpan(
                        text: 'Community Standards',
                        style: const TextStyle(
                          color: Color(0xFFB00000),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB00000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Community',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              Uint8List? imageBytesToPass;
              if (kIsWeb) {
                imageBytesToPass = _communityImageBytes;
              } else if (_communityImage != null) {
                imageBytesToPass = await _communityImage!.readAsBytes();
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreviewCommunityScreen(
                    communityImageBytes: imageBytesToPass,
                    communityName: _nameController.text.isEmpty ? 'Untitled Community' : _nameController.text, // Provide a default if empty
                    communityIntro: _introController.text.isEmpty ? 'No introduction provided.' : _introController.text, // Provide a default
                    requestApproval: _requestApproval,
                  ),
                ),
              );
            },
            child: const Text(
              'Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFB00000), width: 2),
                  ),
                  child: (_communityImage != null && !kIsWeb)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _communityImage!,
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                          ),
                        )
                      : (_communityImageBytes != null && kIsWeb)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _communityImageBytes!,
                                fit: BoxFit.cover,
                                width: 150,
                                height: 150,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'IMAGE HERE',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _pickImage,
                child: const Text(
                  'Update image.',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Name your community',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: _nameLimit,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'BFA',
                hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFB00000), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFB00000), width: 2.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFB00000), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                counterText: '',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_nameController.text.length}/$_nameLimit',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Community intro',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _introController,
              maxLength: _introLimit,
              maxLines: 5,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Welcome, everyone. This community is for\nmembers to chat and share important updates.',
                hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFB00000), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFB00000), width: 2.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFB00000), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                counterText: '',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_introController.text.length}/$_introLimit',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Request approval to join',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'New members don\'t need to be approved. You can change this anytime in community settings.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                Switch(
                  value: _requestApproval,
                  onChanged: (bool value) {
                    setState(() {
                      _requestApproval = value;
                    });
                  },
                  activeColor: const Color(0xFFB00000),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  _showAboutCommunityDialog(context);
                },
                child: const Text(
                  'Who can see this community?',
                  style: TextStyle(
                    color: Color(0xFFB00000),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}