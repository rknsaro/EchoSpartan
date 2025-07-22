import 'package:flutter/material.dart';

class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Communities"),
        backgroundColor: Color(0xFFB00000),
      ),
      body: const Center(
        child: Text("Welcome to Communities!"),
      ),
    );
  }
}
