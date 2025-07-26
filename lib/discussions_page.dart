// discussions_page.dart
// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'dart:io'; // Required for File class for non-web platforms
import 'dart:typed_data'; // Required for Uint8List for web platforms
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb


class DiscussionsPage extends StatelessWidget {
  const DiscussionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: const [
        // Post 1: Thesis in Midterms Week
        _PostCard(
          username: 'BSIT Student', // Example username
          title: 'Kaya pa ba ang Thesis sa Midterms Week??',
          time: 'Posted 1hr ago', // Example time
          subtitle:
              'Feeling overwhelmed juggling deadlines, group chats, and thesis revisions all at once. Midterms pa lang, pero parang finals stress na? 😭 Any tips from upperclassmen on time management or balancing thesis + exams?\n#CICS #BSIT #ThesisLife #MidtermMadness',
          initialUpvotes: 85, // Use initialUpvotes
          assetImagePath: 'assets/thesis_stress.jpeg', // <--- ADDED FOR THE IMAGE
        ),
        SizedBox(height: 12), // Spacer between cards

        // Post 2: Kanin or Kape?
        _PostCard(
          username: 'BSME Warrior', // Example username
          title: 'Kanin or Kape? 🥲',
          time: 'Posted 2hr ago', // Example time
          subtitle:
              'Seryoso, if you had to choose only one: full lunch break or one strong coffee before a 3-hour lab class? Let\'s settle this once and for all.\n#CollegeStruggles #BSME #SurvivalPriorities',
          initialUpvotes: 120, // Use initialUpvotes
          // No assetImagePath for this post
        ),
        SizedBox(height: 12),
        // Post 3: Budget-friendly lunch?
        _PostCard(
          username: 'BSAIS Broke', // Example username
          title: 'Budget-friendly lunch?',
          time: 'Posted 4hr ago', // Example time
          subtitle:
              'Siomai-rice has been the go-to for weeks now, pero guys... hindi ko na kaya 😅 Help a broke student out with some affordable options near campus!\n#SawaNaAkoSaSiomaiRice #BatStateUEats #BSAIS #TipidTips',
          initialUpvotes: 95, // Use initialUpvotes
          assetImagePath: 'assets/siomai_rice.jpeg',
        ),
        SizedBox(height: 12), // Spacer for the last card
      ],
    );
  }
}

// --- _PostOption remains the same ---
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

// Enum to keep track of the vote status
enum VoteStatus {
  upvoted,
  downvoted,
  none,
}

// --- MODIFIED _PostCard to include image functionality ---
class _PostCard extends StatefulWidget {
  final String username;
  final String title;
  final String time;
  final String subtitle;
  final int initialUpvotes;
  final File? imageFile; // For non-web (for dynamically uploaded images)
  final Uint8List? imageBytes; // For web (for dynamically uploaded images)
  final String? assetImagePath; // <--- ADDED: For static images from assets
  final List<String>? pollOptions; // Added for poll feature
  final int? pollEndsInDays; // Added for poll feature


  const _PostCard({
    super.key, // Add super.key
    required this.username,
    required this.title,
    required this.time,
    this.subtitle = '',
    this.initialUpvotes = 0, // Default to 0
    this.imageFile,
    this.imageBytes,
    this.assetImagePath, // <--- ADDED TO CONSTRUCTOR
    this.pollOptions, // Initialize
    this.pollEndsInDays, // Initialize
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _currentUpvotes; // State variable for upvotes
  VoteStatus _voteStatus = VoteStatus.none; // To track current vote
  int? _selectedPollOptionIndex; // Track the selected poll option for polls


  @override
  void initState() {
    super.initState();
    _currentUpvotes = widget.initialUpvotes; // Initialize with the passed value
  }

  void _upvote() {
    setState(() {
      if (_voteStatus == VoteStatus.upvoted) {
        // Already upvoted, un-upvote
        _currentUpvotes--;
        _voteStatus = VoteStatus.none;
      } else if (_voteStatus == VoteStatus.downvoted) {
        // Was downvoted, now upvote (undo downvote and add upvote)
        _currentUpvotes += 2;
        _voteStatus = VoteStatus.upvoted;
      } else {
        // No vote, now upvote
        _currentUpvotes++;
        _voteStatus = VoteStatus.upvoted;
      }
    });
  }

  void _downvote() {
    setState(() {
      if (_voteStatus == VoteStatus.downvoted) {
        // Already downvoted, un-downvote
        _currentUpvotes++;
        _voteStatus = VoteStatus.none;
      } else if (_voteStatus == VoteStatus.upvoted) {
        // Was upvoted, now downvote (undo upvote and add downvote)
        _currentUpvotes -= 2;
        _voteStatus = VoteStatus.downvoted;
      } else {
        // No vote, now downvote
        _currentUpvotes--;
        _voteStatus = VoteStatus.downvoted;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine arrow colors based on vote status
    Color upArrowColor = _voteStatus == VoteStatus.upvoted ? Colors.red : Colors.black;
    Color downArrowColor = _voteStatus == VoteStatus.downvoted ? Colors.red : Colors.black;

    final bool isPollPost = widget.pollOptions != null && widget.pollOptions!.isNotEmpty;


    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Display image if available
            if (widget.assetImagePath != null) // Check for asset image path first
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset( // Use Image.asset
                    widget.assetImagePath!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              )
            else if (widget.imageFile != null || widget.imageBytes != null) // Then check for dynamically uploaded images
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: kIsWeb && widget.imageBytes != null
                      ? Image.memory(
                          widget.imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        )
                      : Image.file(
                          widget.imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                ),
              ),

            // Display poll if available
            if (isPollPost)
              _PollDisplay(
                options: widget.pollOptions!,
                pollEndsInDays: widget.pollEndsInDays,
                selectedOptionIndex: _selectedPollOptionIndex,
                onOptionSelected: (index) {
                  setState(() {
                    _selectedPollOptionIndex = index;
                    // You might want to add logic here to actually record the vote
                    // and disable further voting on the poll.
                  });
                },
              ),


            // Optional subtitle
            if (widget.subtitle.isNotEmpty)
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

            const SizedBox(height: 12),

            // Username and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.username,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700),
                ),
                Text(
                  widget.time,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Interaction Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector( // Make up arrow clickable
                      onTap: _upvote,
                      child: Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: upArrowColor, // Highlight if upvoted
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('$_currentUpvotes'), // Display current upvotes
                    const SizedBox(width: 4),
                    GestureDetector( // Make down arrow clickable
                      onTap: _downvote,
                      child: Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: downArrowColor, // Highlight if downvoted
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 16),
                    SizedBox(width: 4),
                    Text('Comments'),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 4),
                    Text('Share'),
                  ],
                ),
                const Icon(Icons.more_vert),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// _PollDisplay widget (assuming it's in the same file or imported)
class _PollDisplay extends StatelessWidget {
  final List<String> options;
  final int? pollEndsInDays;
  final int? selectedOptionIndex;
  final ValueChanged<int> onOptionSelected;

  const _PollDisplay({
    super.key,
    required this.options,
    required this.pollEndsInDays,
    this.selectedOptionIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pollEndsInDays != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Poll ends in $pollEndsInDays day${pollEndsInDays! > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling for nested list
          itemCount: options.length,
          itemBuilder: (context, index) {
            final bool isSelected = selectedOptionIndex == index;
            return GestureDetector(
              onTap: () => onOptionSelected(index),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_off,
                      color: isSelected ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}