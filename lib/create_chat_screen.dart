// Path: lib/create_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:try_1/community/createcomm.dart'; // Import for CreateCommunityScreen
import 'package:try_1/private_msgs.dart'; // Import your private_msgs.dart file

// Define a simple Contact model to represent your Firestore documents
class Contact {
  final String id; // The document ID from Firestore
  final String name; // The 'name' field from your Firestore document

  Contact({required this.id, required this.name});

  // Factory constructor to create a Contact object from a Firestore DocumentSnapshot
  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] ?? 'Unknown Contact', // Provide a default if 'name' is null
    );
  }
}

class CreateChatPage extends StatefulWidget {
  const CreateChatPage({super.key});

  @override
  State<CreateChatPage> createState() => _CreateChatPageState();
}

class _CreateChatPageState extends State<CreateChatPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true; // Added loading state
  String? _errorMessage; // Added error message state

  @override
  void initState() {
    super.initState();
    _fetchContactsFromFirestore(); // Start fetching data
    _searchController.addListener(_filterContacts);
  }

  // Function to fetch contacts from Firestore
  Future<void> _fetchContactsFromFirestore() async {
    // Set loading state at the very beginning of the async operation
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Clear previous error
      });
    }

    try {
      // Confirmed: collection name is 'contacts' (lowercase)
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('contacts').get();

      List<Contact> fetchedContacts = [];
      if (querySnapshot.docs.isNotEmpty) { // Only process if there are documents
        fetchedContacts = querySnapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();

        // Sort alphabetically by name
        fetchedContacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        // If no documents are found in the 'contacts' collection
        _errorMessage = "No documents found in 'contacts' collection. Check your Firestore data.";
      }

      // Update state once data is processed
      if (mounted) {
        setState(() {
          _allContacts = fetchedContacts;
          _isLoading = false; // Finished loading
          _filterContacts(); // Apply initial filter (empty query will show all)
        });
      }
    } catch (e) {
      print("Error fetching contacts from Firestore: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Finished loading even on error
          _errorMessage = 'Failed to load contacts: ${e.toString()}'; // Store error message
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: ${e.toString()}')),
        );
      }
    }
  }

  void _filterContacts() {
    // Only update filtered contacts if _allContacts is not empty
    if (_allContacts.isEmpty) {
      setState(() {
        _filteredContacts = [];
      });
      return;
    }

    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredContacts = _allContacts; // Show all contacts if search is empty
      } else {
        _filteredContacts = _allContacts
            .where((contact) => contact.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts); // Important: remove listener
    _searchController.dispose();
    super.dispose();
  }

  void _createCommunity() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateCommunityScreen(),
      ),
    );
  }

  void _addNewContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new contact tapped')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Start a New Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar - REVISED DESIGN HERE
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search', // Changed hintText
                prefixIcon: const Icon(Icons.search),
                // Removed filled and fillColor to simplify as per your request
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100), // Rounded corners
                  borderSide: const BorderSide(color: Colors.grey), // Grey border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100), // Rounded corners for focused state
                  borderSide: const BorderSide(color: Color(0xFFB00000), width: 2), // Red border when focused
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _addNewContact,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB00000),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createCommunity,
                  icon: const Icon(Icons.group_add),
                  label: const Text('New Community'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              "Suggested Contacts",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                      : _filteredContacts.isEmpty && _searchController.text.isEmpty
                          ? const Center(child: Text("No contacts found in Firestore."))
                          : _filteredContacts.isEmpty && _searchController.text.isNotEmpty
                              ? const Center(child: Text("No contacts match your search."))
                              : ListView.separated(
                                  itemCount: _filteredContacts.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    final contact = _filteredContacts[index];

                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFFB00000),
                                        child: Icon(Icons.person, color: Colors.white),
                                      ),
                                      title: Text(contact.name),
                                      trailing: const Icon(Icons.chat_outlined),
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
                                    );
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }
}