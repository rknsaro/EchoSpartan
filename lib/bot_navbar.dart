import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFFB00000),
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home_red.png',
            color: selectedIndex == 0 ? const Color(0xFFB00000) : Colors.grey,
            height: 24,
            width: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/search_red.png',
            color: selectedIndex == 1 ? const Color(0xFFB00000) : Colors.grey,
            height: 24,
            width: 24,
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/create_red.png',
            color: selectedIndex == 2 ? const Color(0xFFB00000) : Colors.grey,
            height: 24,
            width: 24,
          ),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/messages_red.png',
            color: selectedIndex == 3 ? const Color(0xFFB00000) : Colors.grey,
            height: 24,
            width: 24,
          ),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/profile_red.png',
            color: selectedIndex == 4 ? const Color(0xFFB00000) : Colors.grey,
            height: 24,
            width: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}