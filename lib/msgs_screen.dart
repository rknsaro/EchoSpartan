import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:try_1/create_chat_screen.dart';
import 'package:try_1/private_msgs.dart';
import 'package:try_1/community/homepage_comm.dart';
import 'package:try_1/community/community_provider.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting

// A class to represent a user that can be a contact or chat participant
class AppUser {
  final String uid;
  final String name;

  AppUser({required this.uid, required this.name});

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? 'Unknown User',
    );
  }
}

// Represents an overview of an active private chat for the current user
class ChatOverview {
  final String chatRoomId; // The ID of the document in 'private_chats'
  final String otherParticipantId; // The UID of the other person in the chat
  final String otherParticipantName; // The display name of the other person
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatOverview({
    required this.chatRoomId,
    required this.otherParticipantId,
    required this.otherParticipantName,
    this.lastMessage,
    this.lastMessageTime,
  });
}

// The existing Contact model (if 'contacts' collection represents a list of users)
// This model will primarily be for the 'Suggested Contacts' section.
class Contact {
  final String id; // This should be the UID of the contact
  final String name;

  Contact({
    required this.id,
    required this.name,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id, // Assuming doc.id is the user UID for the contact
      name: data['name'] ?? 'Unknown Contact', // Assuming a 'name' field in your 'contacts' doc
    );
  }
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  List<Contact> _allAvailableContacts = []; // List of all users from 'contacts' or 'users'
  List<Contact> _filteredSuggestedContacts = []; // Contacts not already in a chat

  List<ChatOverview> _privateChatOverviews = []; // Actual ongoing private chats
  List<ChatOverview> _filteredPrivateChatOverviews = [];

  final List<Map<String, String>> _allChannels = [
    {'name': 'Class BFA-4102', 'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 'time': '10:00 AM'},
    {'name': 'Flutter Devs', 'description': 'Discussions about Flutter development.', 'time': 'Yesterday'},
  ];
  List<Map<String, String>> _filteredChannels = [];

  List<CommunityPreviewData> _filteredCommunities = [];
  late CommunityProvider _communityProvider;

  bool _isLoadingData = true; // Unified loading state
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;

    if (_currentUser == null) {
      // Handle not logged in case
      _errorMessage = "Please log in to view messages.";
      _isLoadingData = false;
    } else {
      _fetchInitialData();
    }

    _searchController.addListener(_filterResults);
    _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    _communityProvider.addListener(_onCommunityListChanged);
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      await _fetchAvailableContacts(); // Fetch all potential chat users
      await _listenToPrivateChats(); // Start listening to active chats

      // Fetch communities (existing logic)
      await _fetchCommunitiesFromFirestore();

      if (mounted) {
        setState(() {
          _isLoadingData = false;
          _filterResults();
        });
      }
    } catch (e) {
      print("Error fetching initial data: $e");
      if (mounted) {
        setState(() {
          _isLoadingData = false;
          _errorMessage = 'Failed to load messages: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${e.toString()}')),
        );
      }
    }
  }

  // Fetches all users who can be contacts/chat partners
  Future<void> _fetchAvailableContacts() async {
    try {
      // Assuming 'users' collection contains all user profiles
      QuerySnapshot userSnapshot = await _firestore.collection('users')
          .where(FieldPath.documentId, isNotEqualTo: _currentUser!.uid) // Exclude current user
          .get();

      List<Contact> fetchedContacts = userSnapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
      fetchedContacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (mounted) {
        setState(() {
          _allAvailableContacts = fetchedContacts;
          _filterResults(); // Update filtered contacts
        });
      }
    } catch (e) {
      print("Error fetching available contacts: $e");
      _errorMessage = "Failed to load available contacts.";
    }
  }

  // Listens to real-time updates for private chats involving the current user
  Future<void> _listenToPrivateChats() async {
    if (_currentUser == null) return;

    _firestore
        .collection('private_chats')
        .where('participants', arrayContains: _currentUser!.uid)
        .snapshots()
        .listen((snapshot) async {
      List<ChatOverview> fetchedOverviews = [];
      for (var doc in snapshot.docs) {
        List<dynamic> participants = doc['participants'] ?? [];
        String otherParticipantId = participants.firstWhere((id) => id != _currentUser!.uid, orElse: () => '');

        if (otherParticipantId.isNotEmpty) {
          // Fetch the other participant's name from the 'users' collection
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(otherParticipantId).get();
          String otherParticipantName = (userDoc.exists && userDoc.data() != null)
              ? (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown User'
              : 'Unknown User';

          fetchedOverviews.add(ChatOverview(
            chatRoomId: doc.id,
            otherParticipantId: otherParticipantId,
            otherParticipantName: otherParticipantName,
            lastMessage: doc['lastMessage'] ?? 'No messages yet.',
            lastMessageTime: (doc['lastMessageTime'] as Timestamp?)?.toDate(),
          ));
        }
      }
      fetchedOverviews.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1; // Put null timestamps at the end
        if (b.lastMessageTime == null) return -1; // Put null timestamps at the end
        return b.lastMessageTime!.compareTo(a.lastMessageTime!); // Most recent first
      });

      if (mounted) {
        setState(() {
          _privateChatOverviews = fetchedOverviews;
          _filterResults(); // Re-filter when chat overviews update
        });
      }
    }, onError: (error) {
      print("Error listening to private chats: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chats: ${error.toString()}')),
        );
      }
    });
  }

  Future<void> _fetchCommunitiesFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('communities').get();
      List<CommunityPreviewData> fetchedCommunities = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String? imageBase64 = data['image'];
        Uint8List? imageBytes;
        if (imageBase64 != null) {
          imageBytes = base64Decode(imageBase64);
        }
        fetchedCommunities.add(CommunityPreviewData(
          id: doc.id,
          name: data['name'] ?? 'Untitled Community',
          imageBytes: imageBytes,
          intro: data['intro'] ?? '',
          memberCount: (data['members'] as List?)?.length ?? 0,
        ));
      }
      _communityProvider.setCommunities(fetchedCommunities);
    } catch (e) {
      print("Error fetching communities from Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load communities: ${e.toString()}')),
      );
    }
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      // Filter existing private chats
      _filteredPrivateChatOverviews = _privateChatOverviews.where((chat) {
        return chat.otherParticipantName.toLowerCase().contains(query) ||
               (chat.lastMessage?.toLowerCase().contains(query) ?? false);
      }).toList();

      // Filter suggested contacts (those not in an active chat)
      _filteredSuggestedContacts = _allAvailableContacts.where((contact) {
        bool isAlreadyInChat = _privateChatOverviews.any((chat) => chat.otherParticipantId == contact.id);
        return !isAlreadyInChat && contact.name.toLowerCase().contains(query);
      }).toList();

      _filteredChannels = _allChannels.where((channel) {
        final bool nameMatches = channel['name']?.toLowerCase().contains(query) ?? false;
        final bool descriptionMatches = channel['description']?.toLowerCase().contains(query) ?? false;
        return nameMatches || descriptionMatches;
      }).toList();

      _filteredCommunities = _communityProvider.communities.where((community) {
        final bool nameMatches = community.name.toLowerCase().contains(query);
        final bool introMatches = community.intro.toLowerCase().contains(query);
        return nameMatches || introMatches;
      }).toList();
    });
  }

  String _formatLastMessageTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay.isAtSameMomentAs(today)) {
      return DateFormat('jm').format(time); // e.g., 1:30 PM
    } else if (messageDay.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      return DateFormat('EEE').format(time); // e.g., Mon, Tue
    } else {
      return DateFormat('MM/dd/yy').format(time); // e.g., 07/20/24
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterResults);
    _searchController.dispose();
    _communityProvider.removeListener(_onCommunityListChanged);
    super.dispose();
  }

  void _onCommunityListChanged() {
    setState(() {
      _filterResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFB00000),
          title: const Text('Messages', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Text(
            _errorMessage ?? 'User not logged in.',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: Color(0xFFB00000), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    : ListView(
                        children: [
                          // Display existing private chats first
                          if (_searchController.text.isEmpty || _filteredPrivateChatOverviews.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'My Conversations',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                            ),
                          ..._filteredPrivateChatOverviews.map((chat) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFB00000),
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text(chat.otherParticipantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(chat.lastMessage ?? 'No messages yet.'),
                                  trailing: Text(_formatLastMessageTime(chat.lastMessageTime)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrivateMessagesScreen(
                                          recipientName: chat.otherParticipantName,
                                          recipientId: chat.otherParticipantId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1, indent: 72, endIndent: 16),
                              ],
                            );
                          }).toList(),
                          if (_filteredPrivateChatOverviews.isNotEmpty) const SizedBox(height: 20),


                          // Display Suggested Contacts (users you can initiate a chat with)
                          if (_searchController.text.isEmpty || _filteredSuggestedContacts.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Suggested Contacts',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                            ),
                          ..._filteredSuggestedContacts.map((contact) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFB00000),
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: const Text('Start a new conversation'),
                                  trailing: const Text(''),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrivateMessagesScreen(
                                          recipientName: contact.name,
                                          recipientId: contact.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1, indent: 72, endIndent: 16),
                              ],
                            );
                          }).toList(),
                          if (_filteredSuggestedContacts.isNotEmpty) const SizedBox(height: 20),

                          // Channels and Communities remain largely the same
                          if (_searchController.text.isEmpty || _filteredChannels.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Channels',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                            ),
                          ..._filteredChannels.map((channel) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFB00000),
                                    child: Icon(Icons.chat_bubble, color: Colors.white),
                                  ),
                                  title: Text(channel['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(channel['description']!),
                                  trailing: Text(channel['time']!),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tapped on channel: ${channel['name']}')),
                                    );
                                  },
                                ),
                                const Divider(height: 1, indent: 72, endIndent: 16),
                              ],
                            );
                          }).toList(),
                          if (_filteredChannels.isNotEmpty) const SizedBox(height: 20),

                          if (_searchController.text.isEmpty || _filteredCommunities.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Communities',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                            ),
                          Consumer<CommunityProvider>(
                            builder: (context, communityProvider, child) {
                              final currentFilteredCommunities = communityProvider.communities.where((community) {
                                final query = _searchController.text.toLowerCase();
                                final bool nameMatches = community.name.toLowerCase().contains(query);
                                final bool introMatches = community.intro.toLowerCase().contains(query);
                                return nameMatches || introMatches;
                              }).toList();

                              return Column(
                                children: currentFilteredCommunities.map((community) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB00000),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: community.imageBytes != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.memory(community.imageBytes!, fit: BoxFit.cover),
                                                )
                                              : const Icon(Icons.group, color: Colors.white),
                                        ),
                                        title: Text(community.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('${community.memberCount} members • ${community.intro}'),
                                        trailing: const Text(''),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomepageComm(
                                                communityName: community.name,
                                                communityImageBytes: community.imageBytes,
                                                showAnnouncements: true,
                                                initialMembers: {},
                                                communityIntro: community.intro,
                                                communityId: community.id,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const Divider(height: 1, indent: 72, endIndent: 16),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          if (_searchController.text.isNotEmpty &&
                              _filteredSuggestedContacts.isEmpty &&
                              _filteredChannels.isEmpty &&
                              _filteredCommunities.isEmpty &&
                              _filteredPrivateChatOverviews.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No results found.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB00000),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateChatPage()),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}