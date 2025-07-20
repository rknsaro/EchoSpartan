import 'package:flutter/material.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB00000),
      drawer: const _AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Container(
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFFB00000),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _TopTab(title: "Discussions"),
                  _TopTab(title: "Top Forums"),
                  _TopTab(title: "Communities"),
                  _TopTab(title: "Campus Announcements", selected: true),
                ],
              ),
            ),
          ),

          // Campus Announcements Box
          Expanded(
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Moved this class OUTSIDE the build method and body:
class _TopTab extends StatelessWidget {
  final String title;
  final bool selected;

  const _TopTab({required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          decoration:
              selected ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFB00000),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.account_circle, size: 50, color: Colors.red),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "EchoSpartan",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const Divider(color: Colors.white54),
            const ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text("Profile", style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.message, color: Colors.white),
              title: Text("Messages", style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.bookmark, color: Colors.white),
              title: Text("Saved", style: TextStyle(color: Colors.white)),
            ),
            const Divider(color: Colors.white70),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Communities", style: TextStyle(color: Colors.white70)),
            ),
            const ListTile(
              leading: Icon(Icons.group, color: Colors.white),
              title: Text("BFA", style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.location_city, color: Colors.white),
              title: Text("Malvar Campus", style: TextStyle(color: Colors.white)),
            ),
            const Divider(color: Colors.white70),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Channels", style: TextStyle(color: Colors.white70)),
            ),
            const ListTile(
              leading: Icon(Icons.class_, color: Colors.white),
              title: Text("Class BFA-4102", style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.group_work, color: Colors.white),
              title: Text("Study Buddies", style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.person_pin, color: Colors.white),
              title: Text("Sana ako nalang", style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.theater_comedy, color: Colors.white),
              title: Text("Drama Club", style: TextStyle(color: Colors.white)),
            ),
            const Divider(color: Colors.white70),
            const ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text("Settings", style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Optional Widgets (still valid) ---
// ignore: unused_element
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

// ignore: unused_element
class _PostCard extends StatelessWidget {
  final String username;
  final String title;
  final String time;

  const _PostCard({
    required this.username,
    required this.title,
    required this.time,
  });

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
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.arrow_upward, size: 16),
                    SizedBox(width: 4),
                    Text('50'),
                    Icon(Icons.arrow_downward, size: 16),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.chat_bubble_outline, size: 16),
                    SizedBox(width: 4),
                    Text('Comments'),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 4),
                    Text('Share'),
                  ],
                ),
                const Icon(Icons.more_vert),
              ],
            )
          ],
        ),
      ),
    );
  }
}
