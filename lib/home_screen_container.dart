import 'package:flutter/material.dart';
import 'package:try_1/newsfeed_screen.dart';
import 'package:try_1/search_screen.dart';
import 'package:try_1/create_post_card.dart';
import 'package:try_1/profile_screen.dart'; 
import 'package:try_1/bot_navbar.dart'; 
import 'package:try_1/msgs_screen.dart';


// Define dummy lists for SearchScreen, if not already global
List<String> allAppContacts = [
  'John Doe', 'Jane Smith', 'Alice Johnson', 'Bob Williams',
  'Charlie Brown', 'Diana Prince', 'Bruce Wayne', 'Clark Kent',
];

List<String> allAppChannels = [
  'Class BFA-4102',
];


class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key});

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  int _selectedBottomNavBarIndex = 0;

  // List of top-level screens for the BottomNavBar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const NewsFeedScreen(),
      SearchScreen(allContacts: allAppContacts, allChannels: allAppChannels),
      Container(), 
      const MessagesPage(), 
      const ProfilePage(), 
    ];
  }

  void _onBottomNavBarItemTapped(int index) {
    if (index == 2) { // 'Create' button
      _showCreatePostBottomSheet(context);
    } else {
      setState(() {
        _selectedBottomNavBarIndex = index;
      });
    }
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bc).viewInsets.bottom,
          ),
          child: CreatePostCard(onPostCreated: (postData) {
            Navigator.of(context).pop(); // Close the bottom sheet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post creation initiated from here!')),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedBottomNavBarIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedBottomNavBarIndex,
        onItemTapped: _onBottomNavBarItemTapped,
      ),
    );
  }
}