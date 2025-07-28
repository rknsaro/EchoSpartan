import 'package:flutter/material.dart';
import 'package:try_1/drawer.dart';
// Remove imports for SearchScreen, MessagesScreen, ProfileScreen as they are now top-level
import 'package:try_1/search_screen.dart'; // REMOVE
import 'package:try_1/discussions_page.dart'; // KEEP
import 'package:try_1/top_forums_page.dart'; // KEEP
import 'package:try_1/communities_page.dart'; // KEEP
import 'package:try_1/campus_announcements_page.dart'; // KEEP
import 'package:try_1/create_post_card.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// These lists are likely used by SearchScreen, they can stay global if needed by other files
List<String> allAppContacts = [
  'John Doe', 'Jane Smith', 'Alice Johnson', 'Bob Williams',
  'Charlie Brown', 'Diana Prince', 'Bruce Wayne', 'Clark Kent',
];

List<String> allAppChannels = [
  'Class SM-4102',
];

class NewsFeedScreen extends StatefulWidget {
  final int initialTabIndex;

  const NewsFeedScreen({super.key, this.initialTabIndex = 0});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // int _selectedBottomNavBarIndex = 0; // REMOVE: Managed by HomeScreenContainer

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB00000),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            // This search bar tap will still navigate to SearchScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  allContacts: allAppContacts,
                  allChannels: allAppChannels,
                ),
              ),
            );
          },
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Newsfeed'),
            Tab(text: 'Discussions'),
            Tab(text: 'Top Forums'),
            Tab(text: 'Communities'),
            Tab(text: 'Campus Announcements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // The children here are the content for each tab within the Newsfeed screen
        children: [
          _DefaultNewsfeedContent(),
          DiscussionsPage(),
          TopForumsPage(),
          CommunitiesPage(),
          CampusAnnouncementsPage(),
        ],
      ),
    );
  }
}

// Keep _DefaultNewsfeedContent as is, as it manages the actual posts
class _DefaultNewsfeedContent extends StatefulWidget {
  const _DefaultNewsfeedContent();

  @override
  State<_DefaultNewsfeedContent> createState() => _DefaultNewsfeedContentState();
}

class _DefaultNewsfeedContentState extends State<_DefaultNewsfeedContent> {
  final List<_PostCard> _posts = [
    const _PostCard(
      username: 'Jane Doe',
      title: 'BatStateU Music Enthusiasts 🎶 – Songwriting Collab?',
      time: 'Posted 2hr ago',
      subtitle:
          'Looking for someone who writes lyrics! I’ve got melody + instrumental na. Let’s collab for the open mic night next month. DM me!\n#MusicGroup #BatStateUtalent #OpenMicNight',
      initialUpvotes: 0,
    ),
    const _PostCard(
      username: 'BSCE Study Group',
      title: 'Group Study Sesh – Saturday at Library Garden Tables!',
      time: 'Posted 3hr ago',
      subtitle:
          'Hi sa mga nasa BSCE Study Group! Let’s review together for Structural Analysis. Bring your notes, reviewers, and snacks. Start tayo ng 1PM sharp.\n#BSCE #StudyGroup #StudyTogether',
      initialUpvotes: 190,
    ),
    const _PostCard(
      username: 'From CICS Community',
      title: 'Fastest SIM in Malvar campus for hotspotting? 📶',
      time: 'Posted 5hr ago',
      subtitle:
          'Legit tanong: ano pinaka okay na SIM for hotspot sa Malvar? Globe minsan okay, minsan wala. Smart? DITO? I need stable data lalo na sa CICS labs.',
      initialUpvotes: 234,
    ),
  ];

  void _addNewPost(Map<String, dynamic> postData) {
    setState(() {
      _posts.insert(
        0,
        _PostCard(
          username: 'You',
          title: postData['title']!,
          time: 'Just now',
          subtitle: postData['content']!,
          initialUpvotes: postData['upvotes'] ?? 0,
          imageFile: kIsWeb ? null : postData['imageFile'],
          imageBytes: kIsWeb ? postData['imageBytes'] : null,
          pollOptions: postData['pollOptions'],
          pollEndsInDays: postData['pollEndsInDays'],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        CreatePostCard(onPostCreated: _addNewPost),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  _posts[index],
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

enum _VoteStatus {
  none,
  upvoted,
  downvoted,
}

class _PostCard extends StatefulWidget {
  final String username;
  final String title;
  final String time;
  final String subtitle;
  final int initialUpvotes;
  final File? imageFile; 
  final Uint8List? imageBytes; 
  final List<String>? pollOptions;
  final int? pollEndsInDays; 

  const _PostCard({
    required this.username,
    required this.title,
    required this.time,
    this.subtitle = '',
    this.initialUpvotes = 0,
    this.imageFile,
    this.imageBytes,
    this.pollOptions, 
    this.pollEndsInDays, 
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _currentUpvotes;
  _VoteStatus _voteStatus = _VoteStatus.none; 
  int? _selectedPollOptionIndex; 

  @override
  void initState() {
    super.initState();
    _currentUpvotes = widget.initialUpvotes;
  }

  void _upvote() {
    setState(() {
      if (_voteStatus == _VoteStatus.none) {
        _currentUpvotes++;
        _voteStatus = _VoteStatus.upvoted;
      } else if (_voteStatus == _VoteStatus.downvoted) {
        _currentUpvotes += 2; 
        _voteStatus = _VoteStatus.upvoted;
      } else if (_voteStatus == _VoteStatus.upvoted) {
        _currentUpvotes--;
        _voteStatus = _VoteStatus.none;
      }
    });
  }

  void _downvote() {
    setState(() {
      if (_voteStatus == _VoteStatus.none) {
        _currentUpvotes--;
        _voteStatus = _VoteStatus.downvoted;
      } else if (_voteStatus == _VoteStatus.upvoted) {
        _currentUpvotes -= 2; 
        _voteStatus = _VoteStatus.downvoted;
      } else if (_voteStatus == _VoteStatus.downvoted) {
        _currentUpvotes++; 
        _voteStatus = _VoteStatus.none;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color upArrowColor = _voteStatus == _VoteStatus.upvoted ? Colors.red : Colors.black;
    Color downArrowColor = _voteStatus == _VoteStatus.downvoted ? Colors.red : Colors.black;

    final bool isPollPost = widget.pollOptions != null && widget.pollOptions!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Display image if available
            if (widget.imageFile != null || widget.imageBytes != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: kIsWeb && widget.imageBytes != null
                      ? Image.memory(
                          widget.imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        )
                      : Image.file(
                          widget.imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                ),
              ),

            // Display poll if available
            if (isPollPost)
              _PollDisplay(
                options: widget.pollOptions!,
                pollEndsInDays: widget.pollEndsInDays,
                selectedOptionIndex: _selectedPollOptionIndex,
                onOptionSelected: (index) {
                  setState(() {
                    _selectedPollOptionIndex = index;
                  });
                },
              ),

            // Optional subtitle (the post body)
            if (widget.subtitle.isNotEmpty)
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

            const SizedBox(height: 12),

            // Username and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.username,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700),
                ),
                Text(
                  widget.time,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Interaction Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _upvote,
                      child: Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: upArrowColor, // Use dynamic color
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('$_currentUpvotes'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _downvote,
                      child: Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: downArrowColor, // Use dynamic color
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 16),
                    SizedBox(width: 4),
                    Text('Comments'),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 4),
                    Text('Share'),
                  ],
                ),
                const Icon(Icons.more_vert),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PollDisplay extends StatelessWidget {
  final List<String> options;
  final int? pollEndsInDays;
  final int? selectedOptionIndex;
  final ValueChanged<int> onOptionSelected;

  const _PollDisplay({
    required this.options,
    required this.pollEndsInDays,
    this.selectedOptionIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pollEndsInDays != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Poll ends in $pollEndsInDays day${pollEndsInDays! > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling for nested list
          itemCount: options.length,
          itemBuilder: (context, index) {
            final bool isSelected = selectedOptionIndex == index;
            return GestureDetector(
              onTap: () => onOptionSelected(index),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_off,
                      color: isSelected ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}