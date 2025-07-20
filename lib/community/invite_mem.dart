// Path: lib/community/invite_mem.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:try_1/community/homepage_comm.dart'; // Corrected import path

// Define a Contact model suitable for selection, including the 'isSelected' state.
class SelectableContact {
  final String id;
  final String name;
  bool isSelected; // Add isSelected for UI state management

  SelectableContact({required this.id, required this.name, this.isSelected = false});

  // Factory constructor to create a SelectableContact from a Firestore DocumentSnapshot
  factory SelectableContact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SelectableContact(
      id: doc.id,
      name: data['name'] ?? 'Unknown Contact', // Fetch the 'name' field
      isSelected: false, // Default to not selected when fetched
    );
  }
}

class InviteNewMembersScreen extends StatefulWidget {
  final String communityName;
  final Uint8List? communityImageBytes;
  final bool showAnnouncements;
  final bool isInitialCreation;
  final Set<String> existingMembers;
  final String communityIntro; // Add communityIntro to the constructor

  const InviteNewMembersScreen({
    super.key,
    required this.communityName,
    this.communityImageBytes,
    required this.showAnnouncements,
    this.isInitialCreation = false,
    Set<String>? existingMembers,
    this.communityIntro = '', // Initialize with a default value
  }) : existingMembers = existingMembers ?? const {};

  @override
  State<InviteNewMembersScreen> createState() => _InviteNewMembersScreenState();
}

class _InviteNewMembersScreenState extends State<InviteNewMembersScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // This will now be populated from Firestore
  List<SelectableContact> _allFirestoreContacts = [];
  List<SelectableContact> _displaySuggestedFriends = []; // This will hold the filtered contacts

  final List<String> _newlySelectedNames = [];

  bool _isLoadingContacts = true; // Loading state for Firestore contacts
  String? _contactsErrorMessage; // Error message for Firestore contacts

  @override
  void initState() {
    super.initState();
    _fetchContactsFromFirestore(); // Start fetching contacts
    _searchController.addListener(_filterAndPrepareLists);
  }

  Future<void> _fetchContactsFromFirestore() async {
    if (mounted) {
      setState(() {
        _isLoadingContacts = true;
        _contactsErrorMessage = null;
      });
    }

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('contacts').get();

      List<SelectableContact> fetchedContacts = [];
      if (querySnapshot.docs.isNotEmpty) {
        fetchedContacts = querySnapshot.docs.map((doc) => SelectableContact.fromFirestore(doc)).toList();
        // Sort alphabetically by name
        fetchedContacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        _contactsErrorMessage = "No contacts found in Firestore.";
      }

      if (mounted) {
        setState(() {
          _allFirestoreContacts = fetchedContacts;
          _isLoadingContacts = false;
          _filterAndPrepareLists(); // Apply initial filter after loading
        });
      }
    } catch (e) {
      print("Error fetching contacts from Firestore: $e");
      if (mounted) {
        setState(() {
          _isLoadingContacts = false;
          _contactsErrorMessage = 'Failed to load contacts: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: ${e.toString()}')),
        );
      }
    }
  }

  void _filterAndPrepareLists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Filter Firestore contacts
      _displaySuggestedFriends = _allFirestoreContacts.where((friend) {
        final String friendName = friend.name; // Access name from Contact object
        final bool isAlreadyMember = widget.existingMembers.contains(friendName);
        final bool matchesQuery = friendName.toLowerCase().contains(query);
        return !isAlreadyMember && matchesQuery;
      }).toList();

      _updateNewlySelectedNames();
    });
  }

  void _updateNewlySelectedNames() {
    _newlySelectedNames.clear();
    // Iterate over _allFirestoreContacts (SelectableContact objects)
    for (var friend in _allFirestoreContacts) {
      if (friend.isSelected == true && !widget.existingMembers.contains(friend.name)) {
        _newlySelectedNames.add(friend.name);
      }
    }
  }

  // Removed _toggleChannelSelection as channels are removed

  void _toggleFriendSelection(int index) {
    setState(() {
      final selectedFriendName = _displaySuggestedFriends[index].name;
      final originalFriendIndex = _allFirestoreContacts.indexWhere((f) => f.name == selectedFriendName);
      if (originalFriendIndex != -1) {
        _allFirestoreContacts[originalFriendIndex].isSelected = !_allFirestoreContacts[originalFriendIndex].isSelected;
        _updateNewlySelectedNames();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.removeListener(_filterAndPrepareLists);
    _searchController.dispose();
    super.dispose();
  }

  void _sendInvitation() {
    if (widget.isInitialCreation) {
      Set<String> initialTotalMembers = {'Community Creator'}; // Placeholder for creator
      initialTotalMembers.addAll(_newlySelectedNames);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomepageComm(
            communityName: widget.communityName,
            communityImageBytes: widget.communityImageBytes,
            showAnnouncements: widget.showAnnouncements,
            initialMembers: initialTotalMembers,
            communityIntro: widget.communityIntro, // Pass communityIntro here
          ),
        ),
      );
    } else {
      Navigator.pop(context, _newlySelectedNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.isInitialCreation) {
              Navigator.pop(context); // Go back to prevcomm
            } else {
              Navigator.pop(context, []); // Pop with empty list if back button is pressed
            }
          },
        ),
        title: const Text(
          'Invite new members',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _sendInvitation,
            child: Text(
              'Send (${_newlySelectedNames.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'People will be added or invited to this community\nand it\'s main chat, depending on privacy rules.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Write a message here...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            TextField(
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
            const SizedBox(height: 20),

            // Suggested Friends section - now the primary scrollable content
            Expanded( // Use Expanded to allow the ListView.builder to take available space
              child: _isLoadingContacts
                  ? const Center(child: CircularProgressIndicator())
                  : _contactsErrorMessage != null
                      ? Center(child: Text(_contactsErrorMessage!, style: const TextStyle(color: Colors.red)))
                      : Column( // Wrap ListView.builder in a Column to add the title
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_displaySuggestedFriends.isNotEmpty || _searchController.text.isEmpty) // Show title if there are friends or search is empty
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10.0), // Add some spacing below the title
                                child: Text(
                                  'Suggested Friends',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ),
                            Expanded( // Allow this inner ListView to take remaining space
                              child: _displaySuggestedFriends.isEmpty && _searchController.text.isNotEmpty
                                  ? const Center(
                                      child: Text(
                                        'No friends match your search.',
                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      // Remove shrinkWrap and NeverScrollableScrollPhysics for the main scrollable list
                                      itemCount: _displaySuggestedFriends.length,
                                      itemBuilder: (context, index) {
                                        final friend = _displaySuggestedFriends[index];
                                        final bool isSelected = friend.isSelected;
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: const CircleAvatar(
                                                backgroundColor: Color(0xFFB00000),
                                                child: Icon(Icons.person, color: Colors.white),
                                              ),
                                              title: Text(friend.name),
                                              trailing: Icon(
                                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                                color: isSelected ? const Color(0xFFB00000) : Colors.grey,
                                              ),
                                              onTap: () => _toggleFriendSelection(index),
                                            ),
                                            const Divider(height: 1, indent: 72, endIndent: 16),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
            ),
            // "No results found" for overall search if no friends are found and search is active
            if (_searchController.text.isNotEmpty && _displaySuggestedFriends.isEmpty && !_isLoadingContacts)
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
    );
  }
}