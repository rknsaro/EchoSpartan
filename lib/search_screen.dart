// Path: lib/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:try_1/community/community_provider.dart';
import 'package:try_1/community/homepage_comm.dart'; // To navigate to community details
import 'package:try_1/profile_screen.dart'; // Example for contact navigation
import 'package:try_1/class_chat_screen.dart'; // Example for channel navigation


class SearchScreen extends StatefulWidget {
  // We'll pass all necessary data to this screen from where it's launched
  final List<String> allContacts; // Your list of contact names
  final List<String> allChannels; // Your list of channel names (e.g., "Class BFA-4102", "Study Buddies")

  const SearchScreen({
    Key? key,
    required this.allContacts,
    required this.allChannels,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = []; // Can hold CommunityPreviewData or String (for contacts/channels)

  @override
  void initState() {
    super.initState();
    // Listen for changes in the text field to perform real-time search
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = []; // Clear results if query is empty
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    List<dynamic> currentResults = [];

    // Access CommunityProvider for communities
    // We use listen: false because we don't need to rebuild SearchScreen when communities change,
    // only read the current list.
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    // --- Search Communities ---
    final filteredCommunities = communityProvider.communities.where((community) {
      return community.name.toLowerCase().contains(lowerCaseQuery) ||
             community.intro.toLowerCase().contains(lowerCaseQuery); // Search in intro too
    }).toList();
    currentResults.addAll(filteredCommunities);

    // --- Search Contacts (using the list passed to this widget) ---
    final filteredContacts = widget.allContacts.where((contact) {
      return contact.toLowerCase().contains(lowerCaseQuery);
    }).toList();
    currentResults.addAll(filteredContacts);

    // --- Search Channels (using the list passed to this widget) ---
    final filteredChannels = widget.allChannels.where((channel) {
      return channel.toLowerCase().contains(lowerCaseQuery);
    }).toList();
    currentResults.addAll(filteredChannels);

    setState(() {
      _searchResults = currentResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search contacts, communities, channels...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none, // Remove default TextField border
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          autofocus: true, // Automatically focus the search field when screen opens
          cursorColor: Colors.white,
        ),
        backgroundColor: const Color(0xFFB00000), // Your app's primary color
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
      ),
      body: Container(
        color: const Color(0xFFB00000), // Match background color
        child: _searchController.text.isEmpty
            ? const Center(
                child: Text(
                  'Start typing to search...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];

                      if (item is CommunityPreviewData) {
                        // It's a community
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: item.imageBytes != null
                                  ? MemoryImage(item.imageBytes!)
                                  : null,
                              child: item.imageBytes == null
                                  ? const Icon(Icons.group, color: Color(0xFFB00000))
                                  : null,
                            ),
                            title: Text(item.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            subtitle: Text('Community - ${item.memberCount} members', style: const TextStyle(color: Colors.black54)),
                            onTap: () {
                              // Navigate to the specific community's homepage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomepageComm(
                                    communityName: item.name,
                                    communityImageBytes: item.imageBytes,
                                    showAnnouncements: true, // You might need to derive this from 'item' if it's dynamic
                                    initialMembers: {}, // You'll likely need to fetch actual members here
                                    communityIntro: item.intro,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (item is String) {
                        // It's either a contact or a channel
                        String type = '';
                        Widget icon = const SizedBox.shrink();
                        VoidCallback? onTap;

                        if (widget.allContacts.contains(item)) {
                          type = 'Contact';
                          icon = const Icon(Icons.person, color: Color(0xFFB00000));
                          onTap = () {
                            // Example: Navigate to contact profile or direct message chat
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                          };
                        } else if (widget.allChannels.contains(item)) {
                          type = 'Channel';
                          icon = const Icon(Icons.forum, color: Color(0xFFB00000));
                          onTap = () {
                            // Example: Navigate to channel chat screen
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ClassChatScreen()));
                          };
                        }

                        if (type.isNotEmpty) {
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: icon,
                              ),
                              title: Text(item, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                              subtitle: Text(type, style: const TextStyle(color: Colors.black54)),
                              onTap: onTap,
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink(); // Fallback for unexpected types
                    },
                  ),
      ),
    );
  }
}