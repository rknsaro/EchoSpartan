// top_forums_page.dart
import 'package:flutter/material.dart';

enum VoteStatus {
  upvoted,
  downvoted,
  none,
}

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

// --- _PostCard: A StatefulWidget for interactive posts ---
// This widget now manages its own state for upvotes and downvotes.
class _PostCard extends StatefulWidget {
  final String username;
  final String title;
  final String time;
  final String subtitle;
  final int initialUpvotes; // Still an int for calculations

  const _PostCard({
    required this.username,
    required this.title,
    required this.time,
    this.subtitle = '',
    this.initialUpvotes = 0, // Default to 0 if not provided
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _currentUpvotes; // The current, changeable number of upvotes
  VoteStatus _voteStatus =
      VoteStatus.none; // Tracks if the user has upvoted, downvoted, or neither

  @override
  void initState() {
    super.initState();
    // Initialize the current upvotes with the value passed from the parent widget
    _currentUpvotes = widget.initialUpvotes;
  }

  // Helper to format large numbers with 'K'
  String _formatUpvotes(int upvotes) {
    if (upvotes >= 1000) {
      // Divide by 1000 and format to one decimal place if needed, then add 'K'
      return '${(upvotes / 1000.0).toStringAsFixed(upvotes % 1000 == 0 ? 0 : 1)}K';
    }
    return upvotes.toString();
  }


  // Handles the logic when the upvote arrow is tapped
  void _upvote() {
    setState(() {
      if (_voteStatus == VoteStatus.upvoted) {
        // If already upvoted, tapping again "un-upvotes" it
        _currentUpvotes--;
        _voteStatus = VoteStatus.none;
      } else if (_voteStatus == VoteStatus.downvoted) {
        // If previously downvoted, tapping upvote reverses the downvote and adds an upvote
        _currentUpvotes += 2; // +1 to negate downvote, +1 for new upvote
        _voteStatus = VoteStatus.upvoted;
      } else {
        // If no vote, simply upvote
        _currentUpvotes++;
        _voteStatus = VoteStatus.upvoted;
      }
    });
  }

  // Handles the logic when the downvote arrow is tapped
  void _downvote() {
    setState(() {
      if (_voteStatus == VoteStatus.downvoted) {
        // If already downvoted, tapping again "un-downvotes" it
        _currentUpvotes++;
        _voteStatus = VoteStatus.none;
      } else if (_voteStatus == VoteStatus.upvoted) {
        // If previously upvoted, tapping downvote reverses the upvote and adds a downvote
        _currentUpvotes -= 2; // -1 to negate upvote, -1 for new downvote
        _voteStatus = VoteStatus.downvoted;
      } else {
        // If no vote, simply downvote
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

            // Optional subtitle, only displayed if not empty
            if (widget.subtitle.isNotEmpty)
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

            const SizedBox(height: 12),

            // Row for username and time posted
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

            // Interaction Row: Upvote/Downvote, Comments, Share, More options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Upvote arrow with GestureDetector for tap detection
                    GestureDetector(
                      onTap: _upvote, // Calls the _upvote method on tap
                      child: Icon(
                        Icons.arrow_upward,
                        size: 16,
                        // Change color to red if currently upvoted, otherwise black
                        color: upArrowColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Display the current upvote count using the formatter
                    Text(_formatUpvotes(_currentUpvotes)), // <--- USING FORMATTER HERE
                    const SizedBox(width: 4),
                    // Downvote arrow with GestureDetector for tap detection
                    GestureDetector(
                      onTap: _downvote, // Calls the _downvote method on tap
                      child: Icon(
                        Icons.arrow_downward,
                        size: 16,
                        // Change color to red if currently downvoted, otherwise black
                        color: downArrowColor,
                      ),
                    ),
                  ],
                ),
                // Comments section (static for now)
                const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 16),
                    SizedBox(width: 4),
                    Text('Comments'),
                  ],
                ),
                // Share section (static for now)
                const Row(
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 4),
                    Text('Share'),
                  ],
                ),
                // More options icon
                const Icon(Icons.more_vert),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TopForumsPage extends StatelessWidget {
  const TopForumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: const [
        // Post 1: BSIT Forum - Firebase Authentication
        _PostCard(
          username: '[BSIT Forum]',
          title: 'Need Help sa Firebase Authentication 😭',
          time: 'Posted 1hr ago',
          subtitle:
              'Sinunod ko na ‘yung tutorial pero ayaw pa rin mag-login! May nagsucceed na ba dito? Baka may checklist kayo ng dapat i-double check?\n#BSIT #FirebaseFail #HelpPo #BatStateU',
          initialUpvotes: 7200, // Passed as raw number
        ),
        SizedBox(height: 12),

        // Post 2: BSPSY Forum - Sigmund Freud
        _PostCard(
          username: '[BSPSY Forum]',
          title: 'Sigmund Freud o Chismis King? 🤯',
          time: 'Posted 2hr ago',
          subtitle:
              'Legit question: Napapaisip ako if Freud was genius or just wild AF. ‘Yung mga theory niya minsan parang soap opera. Thoughts?\n#BSPSY #FreudFeels #PsychTalk #BatStateU',
          initialUpvotes: 6800, // Passed as raw number
        ),
        SizedBox(height: 12),

        // Post 3: BSIT Forum - OOP Concepts
        _PostCard(
          username: '[BSIT Forum]',
          title: 'OOP Concepts Na Mas Masakit Pa sa Breakup 💔',
          time: 'Posted 3hr ago',
          subtitle:
              'Encapsulation? Polymorphism? Inheritance? Bro, minsan ‘di ko alam kung programming pa ba ‘to o pang-MMK.\n#BSIT #OOPHeartbreak #AralMuna #BatStateU',
          initialUpvotes: 6300, // Passed as raw number
        ),
        SizedBox(height: 12),

        // Post 4: BSIT Forum - Debugging
        _PostCard(
          username: '[BSIT Forum]',
          title: 'Debugging Until 3AM Club, Asan Na Kayo?',
          time: 'Posted 4hr ago',
          subtitle:
              'Yung tipong simple semicolon lang pala kulang pero inabot ka ng dalawang oras hanapin. Share niyo worst bug experience niyo 😭\n#BSIT #DebuggingDiaries #SleeplessCoders #BatStateU',
          initialUpvotes: 7600, // Passed as raw number
        ),
        SizedBox(height: 12),
      ],
    );
  }
}