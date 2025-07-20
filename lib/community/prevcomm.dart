// Path: lib/community/prevcomm.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:try_1/community/invite_mem.dart'; // Corrected import path
import 'package:try_1/community/homepage_comm.dart'; // Already imported

class PreviewCommunityScreen extends StatefulWidget {
  final Uint8List? communityImageBytes;
  final String communityName;
  final String communityIntro;
  final bool requestApproval;

  const PreviewCommunityScreen({
    super.key,
    this.communityImageBytes,
    required this.communityName,
    required this.communityIntro, // Ensure this is available
    required this.requestApproval,
  });

  @override
  State<PreviewCommunityScreen> createState() => _PreviewCommunityScreenState();
}

class _PreviewCommunityScreenState extends State<PreviewCommunityScreen> {
  bool _isMainChatChecked = true;
  bool _isAnnouncementsChecked = true;
  bool _isCollaborationChecked = false;
  bool _isLeadershipTeamChecked = false;

  Widget _buildChatOption(
      String title, String subtitle, bool isChecked, ValueChanged<bool?>? onChanged) {
    return InkWell(
      onTap: onChanged != null ? () => onChanged(!isChecked) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(
              isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isChecked ? const Color(0xFFB00000) : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: const Color(0xFFB00000),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.communityImageBytes != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.3,
                            child: Image.memory(
                              widget.communityImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: widget.communityImageBytes != null
                                  ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          widget.communityImageBytes!,
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                        ),
                                      )
                                  : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'IMAGE HERE',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.communityName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Members only • Visible',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.communityIntro,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select chats to start with',
                        style: TextStyle(
                          color: Color(0xFFB00000),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildChatOption(
                        'Main Chat',
                        'Get to know more your community',
                        _isMainChatChecked,
                        null,
                      ),
                      const Divider(color: Colors.grey, height: 25),
                      _buildChatOption(
                        'Announcements',
                        'Share important news and updates',
                        _isAnnouncementsChecked,
                        (bool? newValue) {
                          setState(() {
                            _isAnnouncementsChecked = newValue ?? false;
                          });
                        },
                      ),
                      const Divider(color: Colors.grey, height: 25),
                      _buildChatOption(
                        'Collaboration',
                        'Discuss projects and find partners',
                        _isCollaborationChecked,
                        (bool? newValue) {
                          setState(() {
                            _isCollaborationChecked = newValue ?? false;
                          });
                        },
                      ),
                      const Divider(color: Colors.grey, height: 25),
                      _buildChatOption(
                        'Leadership Team',
                        'A space for leaders to chat',
                        _isLeadershipTeamChecked,
                        (bool? newValue) {
                          setState(() {
                            _isLeadershipTeamChecked = newValue ?? false;
                          });
                        },
                      ),
                      const Divider(color: Colors.grey, height: 25),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Selected chats will be automatically created. You\ncan add or modify chats at any time.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InviteNewMembersScreen(
                                  communityName: widget.communityName,
                                  communityImageBytes: widget.communityImageBytes,
                                  showAnnouncements: _isAnnouncementsChecked,
                                  isInitialCreation: true,
                                  existingMembers: {},
                                  communityIntro: widget.communityIntro, // Pass communityIntro here
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB00000),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Create Community',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40.0,
            left: 16.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}