import 'package:flutter/material.dart';

class TopForumsPage extends StatelessWidget {
  const TopForumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Forums"),
        backgroundColor: Color(0xFFB00000),
      ),
      body: const Center(
        child: Text("Welcome to Top Forums!"),
      ),
    );
  }
}
