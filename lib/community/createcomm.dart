// Path: community/createcomm.dart
import 'package:flutter/material.dart';
// import 'package:try_1/drawer.dart'; // No longer needed
import 'package:try_1/community/newcomm.dart'; // Import for NewCommunityScreen

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final Set<String> _selectedCommunityTypes = {};
  final List<String> _communityTypes = [
    'Campus',
    'Gaming',
    'Social',
    'Organizations and groups',
    'Anime',
    'Fitness and sports',
    'Wellness',
    'Travel',
    'Career and Learning',
    'Pets',
    'Music, Movies and TV',
    'Food and drinks',
    'Other',
  ];

  // Helper method to check if the continue button should be enabled
  bool _isContinueButtonEnabled() {
    return _selectedCommunityTypes.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB00000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "What's your community about?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select any options that describe what you'll chat about with your community.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: _communityTypes.map((type) {
                final bool isSelected = _selectedCommunityTypes.contains(type);

                Color bgColor;
                Color textColor;
                Color borderColor;

                if (isSelected) {
                  bgColor = Colors.white;
                  textColor = Colors.black;
                  borderColor = Colors.white;
                } else if (type == 'Other') {
                  bgColor = Colors.grey[400]!;
                  textColor = Colors.black;
                  borderColor = Colors.grey[400]!;
                } else {
                  bgColor = const Color.fromARGB(255, 140, 0, 0);
                  textColor = Colors.white;
                  borderColor = Colors.white54;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCommunityTypes.remove(type);
                      } else {
                        _selectedCommunityTypes.add(type);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                // Disable the button if no community types are selected
                onPressed: _isContinueButtonEnabled()
                    ? () {
                        // Navigate to NewCommunityScreen when 'Continue' is clicked
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NewCommunityScreen(),
                          ),
                        );
                      }
                    : null, // Set to null to disable the button
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isContinueButtonEnabled() ? Colors.white : Colors.grey[300], // Change color when disabled
                  foregroundColor: _isContinueButtonEnabled() ? Colors.black : Colors.grey[600], // Change text color when disabled
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}