import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:try_1/community/invite_mem.dart';
import 'package:try_1/chat_screen.dart'; // Import the new ChatScreen
import 'package:try_1/msgs_screen.dart'; // This is your messages list screen
import 'community_provider.dart';
import 'dart:convert';
import 'package:try_1/create_chat_screen.dart'; // Add this line

class HomepageComm extends StatefulWidget {
  final String communityName;
  final Uint8List? communityImageBytes;
  final bool showAnnouncements;
  final Set<String> initialMembers;
  final String communityIntro;

  final String? communityId; // Make it nullable initially

  const HomepageComm({
    super.key,
    required this.communityName,
    this.communityImageBytes,
    required this.showAnnouncements,
    required this.initialMembers,
    this.communityIntro = '',
    this.communityId, // Pass existing ID if navigating back to an existing community
  });

  @override
  State<HomepageComm> createState() => _HomepageCommState();
}

class _HomepageCommState extends State<HomepageComm> {
  late Set<String> _currentMembers;
  late CommunityProvider _communityProvider;
  String? _currentCommunityId; // Store the ID once generated/received

  @override
  void initState() {
    super.initState();
    _currentMembers = Set.from(widget.initialMembers);
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    _currentCommunityId = widget.communityId;

    _saveCommunityToFirestore(); // Call this function to save/update community in Firestore
  }

  Future<void> _saveCommunityToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    CollectionReference communities = firestore.collection('communities');

    String? imageBase64;
    if (widget.communityImageBytes != null) {
      imageBase64 = base64Encode(widget.communityImageBytes!);
    }

    Map<String, dynamic> communityData = {
      'name': widget.communityName,
      'image': imageBase64,
      'showAnnouncements': widget.showAnnouncements,
      'intro': widget.communityIntro,
      'members': _currentMembers.toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (_currentCommunityId == null) {
      DocumentReference docRef = await communities.add(communityData);
      setState(() {
        _currentCommunityId = docRef.id;
      });
      print('New community added to Firestore with ID: $_currentCommunityId');
    } else {
      await communities.doc(_currentCommunityId).update(communityData);
      print('Community $_currentCommunityId updated in Firestore.');
    }

    // Ensure _currentCommunityId is not null before adding to provider
    if (_currentCommunityId != null) {
      _communityProvider.addCommunity(
        CommunityPreviewData(
          id: _currentCommunityId!,
          name: widget.communityName,
          imageBytes: widget.communityImageBytes,
          intro: widget.communityIntro,
          memberCount: _currentMembers.length,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant HomepageComm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentMembers.length != oldWidget.initialMembers.length ||
        widget.communityName != oldWidget.communityName ||
        widget.communityIntro != oldWidget.communityIntro ||
        widget.communityImageBytes != oldWidget.communityImageBytes) {
      _saveCommunityToFirestore();
    }
  }

  void _navigateToInviteMembers() async {
    final List<String>? newlyAddedNames = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => InviteNewMembersScreen(
          communityName: widget.communityName,
          communityImageBytes: widget.communityImageBytes,
          showAnnouncements: widget.showAnnouncements,
          isInitialCreation: false,
          existingMembers: _currentMembers,
          communityIntro: widget.communityIntro,
        ),
      ),
    );

    if (newlyAddedNames != null && newlyAddedNames.isNotEmpty) {
      setState(() {
        _currentMembers.addAll(newlyAddedNames);
        _saveCommunityToFirestore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB00000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MessagesPage()),
          );
        },
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: _navigateToInviteMembers,
          ),
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.white),
            onPressed: () {
              // Handle star icon press, e.g., favorite community
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: widget.communityImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              widget.communityImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.group,
                            size: 60,
                            color: Color(0xFFB00000),
                          ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.communityName,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invite people to your new community',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Good start! Your community has ${_currentMembers.length} new member${_currentMembers.length == 1 ? '' : 's'}. Invite more people so your community can thrive.',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToInviteMembers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB00000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Invite',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.chat_bubble,
                    color: Color(0xFFB00000),
                    size: 28,
                  ),
                ),
                title: const Text('Main GC', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text('${_currentMembers.length} members', style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.push_pin, color: Colors.white),
                onTap: () {
                  print('Navigating to Main GC');
                  if (_currentCommunityId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen( // Navigate to ChatScreen
                          chatTitle: widget.communityName,
                          chatRoomId: _currentCommunityId!, // Pass the Firestore document ID
                          chatType: 'community', // Specify chat type
                        ),
                      ),
                    );
                  } else {
                    print('Error: Community ID not available for Main GC.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Community not fully loaded or saved yet. Please try again.')),
                    );
                  }
                },
              ),
              const Divider(color: Colors.white54, indent: 72, endIndent: 16),
              const SizedBox(height: 20),
              const Text(
                'Other Chats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              if (widget.showAnnouncements)
                Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.campaign,
                          color: Color(0xFFB00000),
                          size: 28,
                        ),
                      ),
                      title: const Text('Announcements', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('${_currentMembers.length} members', style: const TextStyle(color: Colors.white70)),
                      onTap: () {
                        print('Navigating to Announcements');
                        if (_currentCommunityId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen( // Navigate to ChatScreen
                                chatTitle: '${widget.communityName} Announcements',
                                chatRoomId: _currentCommunityId!, // Using the same community ID for announcements for now
                                chatType: 'announcements', // You might handle 'announcements' differently in ChatScreen (e.g., read-only)
                              ),
                            ),
                          );
                        } else {
                          print('Error: Community ID not available for Announcements.');
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Community not fully loaded or saved yet. Please try again.')),
                          );
                        }
                      },
                    ),
                    const Divider(color: Colors.white54, indent: 72, endIndent: 16),
                  ],
                ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: Color(0xFFB00000), size: 30),
                ),
                title: const Text('Create Chat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                onTap: () {
                  print('Navigating to a pre-defined chat screen');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(
                        chatTitle: 'Community Lounge', // Example pre-defined title
                        chatRoomId: 'community_lounge_id', // Example pre-defined ID from Firestore
                        chatType: 'channel', // Or 'community' if it's a general community chat
                      ),
                    ),
                  );
                },  
              ),
              const Divider(color: Colors.white54, indent: 72, endIndent: 16),
            ],
          ),
        ),
      ),
    );
  }
}