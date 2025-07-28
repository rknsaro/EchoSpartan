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
import 'package:try_1/class_chat_screen.dart';

class Contact {
  final String id;
  final String name;

  Contact({required this.id, required this.name});

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] ?? 'Unknown Contact',
    );
  }
}

class MessagesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;  // Callback for back button

  const MessagesPage({super.key, this.onBackToHome});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  List<Contact> _allAvailableContacts = [];
  List<Contact> _filteredSuggestedContacts = [];

  final List<Map<String, String>> _allChannels = [
    {'name': 'Class SM-4102', 'description': 'hello ! we’re hiring encoder po! no registration fee, hawak mo oras mo, dollar rate, daily payout! if interested just kindly message me lang po!', 'time': '1:11 PM'},
  ];
  List<Map<String, String>> _filteredChannels = [];

  List<CommunityPreviewData> _filteredCommunities = [];
  late CommunityProvider _communityProvider;

  bool _isLoadingData = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;

    if (_currentUser == null) {
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
      await _fetchAvailableContacts();
      await _fetchCommunitiesFromFirestore();

      if (mounted) {
        setState(() {
          _isLoadingData = false;
          _filterResults();
        });
      }
    } catch (e) {
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

  Future<void> _fetchAvailableContacts() async {
    try {
      QuerySnapshot userSnapshot = await _firestore.collection('users')
          .where(FieldPath.documentId, isNotEqualTo: _currentUser!.uid)
          .get();

      List<Contact> fetchedContacts = userSnapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
      fetchedContacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (mounted) {
        setState(() {
          _allAvailableContacts = fetchedContacts;
          _filterResults();
        });
      }
    } catch (e) {
      _errorMessage = "Failed to load available contacts.";
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load communities: ${e.toString()}')),
      );
    }
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredSuggestedContacts = _allAvailableContacts.where((contact) {
        return contact.name.toLowerCase().contains(query);
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
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else {
              Navigator.pop(context);
            }
          },
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
                          }),

                          if (_filteredChannels.isNotEmpty)
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
                                    if (channel['name'] == 'Class SM-4102') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ClassChatScreen()),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Tapped on channel: ${channel['name']}')),
                                      );
                                    }
                                  },
                                ),
                                const Divider(height: 1, indent: 72, endIndent: 16),
                              ],
                            );
                          }).toList(),

                          if (_filteredCommunities.isNotEmpty)
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
                                return community.name.toLowerCase().contains(query) ||
                                    community.intro.toLowerCase().contains(query);
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
                              _filteredCommunities.isEmpty)
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
