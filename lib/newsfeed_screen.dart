import 'package:flutter/material.dart';
import 'package:try_1/drawer.dart';
import 'package:try_1/search_screen.dart'; // Import the new SearchScreen


List<String> allAppContacts = [
  'John Doe', 'Jane Smith', 'Alice Johnson', 'Bob Williams',
  'Charlie Brown', 'Diana Prince', 'Bruce Wayne', 'Clark Kent',
];

List<String> allAppChannels = [
  'Class BFA-4102', 'Study Buddies', 'Drama Club', 'Sports Enthusiasts',
  'Coding Challenges', 'Book Lovers', 'Gaming Hub', 'Art & Design Forum',
];
// --- End Dummy Data ---

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String selectedTab = "Newsfeed";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB00000),
      drawer: const AppDrawer(), // Use the extracted AppDrawer widget
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: GestureDetector( // Wrap the TextField in a GestureDetector
          onTap: () {
            // Navigate to the SearchScreen when the search bar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  allContacts: allAppContacts, // Pass your actual contacts data
                  allChannels: allAppChannels, // Pass your actual channels data
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
            child: const AbsorbPointer( // Prevents the TextField from being directly editable
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
            onPressed: () {}
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFFB00000),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TopTab(
                    title: "Newsfeed",
                    selected: selectedTab == "Newsfeed",
                    onTap: () => setState(() => selectedTab = "Newsfeed"),
                  ),
                  _TopTab(
                    title: "Discussions",
                    selected: selectedTab == "Discussions",
                    onTap: () => setState(() => selectedTab = "Discussions"),
                  ),
                  _TopTab(
                    title: "Top Forums",
                    selected: selectedTab == "Top Forums",
                    onTap: () => setState(() => selectedTab = "Top Forums"),
                  ),
                  _TopTab(
                    title: "Communities",
                    selected: selectedTab == "Communities",
                    onTap: () => setState(() => selectedTab = "Communities"),
                  ),
                  _TopTab(
                    title: "Campus Announcements",
                    selected: selectedTab == "Campus Announcements",
                    onTap: () => setState(() => selectedTab = "Campus Announcements"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: selectedTab == "Campus Announcements"
                ? const _CampusAnnouncements()
                : const _DefaultNewsfeedContent(),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TopTab({required this.title, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            decoration: selected ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _CampusAnnouncements extends StatelessWidget {
  const _CampusAnnouncements();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        child: SizedBox(
          width: 300,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'BatStateU Updates',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Divider(thickness: 1, indent: 30, endIndent: 30),
              SizedBox(height: 10),
              Text('+ See More', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultNewsfeedContent extends StatelessWidget {
  const _DefaultNewsfeedContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    hintText: "What’s on your mind?",
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _PostOption(icon: Icons.person, label: 'Create Post'),
                    _PostOption(icon: Icons.link, label: 'Link'),
                    _PostOption(icon: Icons.poll, label: 'Poll'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _PostCard(
                username: 'Jane Doe',
                title: 'How to prepare for Capstone Project?',
                time: 'Posted 1hr ago',
              ),
              SizedBox(height: 12),
              _PostCard(
                username: 'Hot Maria Clara',
                title: 'Best reference for Research Paper?',
                time: 'Posted 2hr ago',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PostOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.red, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final String username;
  final String title;
  final String time;

  const _PostCard({required this.username, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 16),
                    SizedBox(width: 4),
                    Text('50'),
                    Icon(Icons.arrow_downward, size: 16),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 16),
                    SizedBox(width: 4),
                    Text('Comments'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 4),
                    Text('Share'),
                  ],
                ),
                Icon(Icons.more_vert),
              ],
            )
          ],
        ),
      ),
    );
  }
}