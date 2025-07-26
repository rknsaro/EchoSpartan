import 'package:flutter/material.dart';
import 'package:try_1/class_chat_screen.dart';
import 'package:try_1/msgs_screen.dart';
import 'package:try_1/profile_screen.dart' hide MessagesPage;
import 'package:try_1/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:try_1/login_screen.dart';
import 'package:try_1/newsfeed_screen.dart';


// Enum to represent the selectable sections in the drawer
enum _DrawerSection {
  profile,
  messages,
  saved,
  bfa,
  malvarCampus,
  classBFA4102,
  studyBuddies,
  dramaClub,
  settings,
  logout,
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // State variable to track the currently hovered drawer item
  _DrawerSection? _hoveredSection;

  // --- START: Code to define and change icons using asset paths ---
  // A map to store the String asset paths for each drawer section's icon
  static const Map<_DrawerSection, String> _drawerIcons = {
    // IMPORTANT: Replace these with the actual paths to your icons in your assets folder!
    // Example: 'assets/my_custom_profile_icon.png'
    _DrawerSection.profile: 'assets/profile.png',
    _DrawerSection.messages: 'assets/message.png',
    _DrawerSection.saved: 'assets/saved.png',

    _DrawerSection.bfa: 'assets/communities.png',
    _DrawerSection.malvarCampus: 'assets/communities.png',

    _DrawerSection.classBFA4102: 'assets/channels.png',
    _DrawerSection.studyBuddies: 'assets/channels.png',
    _DrawerSection.dramaClub: 'assets/channels.png',

    _DrawerSection.settings: 'assets/settings.png',
    _DrawerSection.logout: 'assets/logout.png',
  };
  // --- END: Code to define and change icons using asset paths ---

  // Helper function to build a drawer item with a custom hover effect (text only)
  Widget _buildDrawerItem({
    required String title,
    required _DrawerSection section,
    VoidCallback? onTap,
  }) {
    // Get the asset icon path from the centralized map
    final String? iconPath = _drawerIcons[section];
    if (iconPath == null) {
      debugPrint('Warning: Icon asset path not defined for _DrawerSection.$section');
      return const SizedBox.shrink(); // Return an empty widget if no icon path is found
    }

    bool isHovered = _hoveredSection == section;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSection = section),
      onExit: (_) => setState(() => _hoveredSection = null),
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            Navigator.of(context).pop();
            onTap();
          }
        },
        child: Container(
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use Image.asset for custom icons
              Image.asset(
                iconPath,
                width: 24.0, // Standard icon size
                height: 24.0, // Standard icon size
                color: Colors.white, // Tint the image white to match the theme
              ),
              const SizedBox(width: 32),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isHovered ? Colors.white : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isHovered ? Colors.black : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFB00000),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color.fromARGB(255, 179, 0, 0),
              child: Image.asset('assets/EchoSpartan.png',
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text("EchoSpartan", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const Divider(color: Colors.white54),

            _buildDrawerItem(
              title: "Profile",
              section: _DrawerSection.profile,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            _buildDrawerItem(
              title: "Messages",
              section: _DrawerSection.messages,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MessagesPage()),
                );
              },
            ),
            _buildDrawerItem(
              title: "Saved",
              section: _DrawerSection.saved,
              onTap: () {
                // Add navigation or action for Saved
              },
            ),
            const Divider(color: Colors.white70),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Communities", style: TextStyle(color: Colors.white70)),
            ),
            _buildDrawerItem(
            title: "CICS Community",
            section: _DrawerSection.bfa,
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const NewsFeedScreen(initialTabIndex: 3),
                ),
              );
            },
          ),
            const Divider(color: Colors.white70),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Channels", style: TextStyle(color: Colors.white70)),
            ),
            _buildDrawerItem(
              title: "Class SM-4102",
              section: _DrawerSection.classBFA4102,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ClassChatScreen()),
                );
              },
            ),
            // _buildDrawerItem(
            //   title: "Drama Club",
            //   section: _DrawerSection.dramaClub,
            //   onTap: () {
            //     // Add navigation or action for Drama Club channel
            //   },
            // ),
            const Divider(color: Colors.white70),
            _buildDrawerItem(
              title: "Settings",
              section: _DrawerSection.settings,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            _buildDrawerItem(
            title: "Logout",
            section: _DrawerSection.logout,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFB00000),   
                          foregroundColor: Colors.white,     
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ],
        ),
      ),
    );
  }
}