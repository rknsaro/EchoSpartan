import 'package:flutter/material.dart';

class CampusAnnouncementsPage extends StatelessWidget {
  const CampusAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Announcements"),
        backgroundColor: Color(0xFFB00000),
      ),
      body: const Center(
        child: Text("Welcome to Campus Announcements!"),
      ),
    );
  }
}
