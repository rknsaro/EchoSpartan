// top_forums_page.dart
import 'package:flutter/material.dart';

// Enum to keep track of the vote status for each post
enum VoteStatus {
  upvoted,
  downvoted,
  none,
}

// --- _PostOption class ---
// This widget is used to display interaction options like comments and share.
// It remains stateless as its display doesn't change based on user interaction.
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
  final int initialUpvotes; // The starting number of upvotes for the post

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
                        // Change color to blue if currently upvoted, otherwise black
                        color: _voteStatus == VoteStatus.upvoted
                            ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Display the current upvote count
                    Text('$_currentUpvotes'),
                    const SizedBox(width: 4),
                    // Downvote arrow with GestureDetector for tap detection
                    GestureDetector(
                      onTap: _downvote, // Calls the _downvote method on tap
                      child: Icon(
                        Icons.arrow_downward,
                        size: 16,
                        // Change color to blue if currently downvoted, otherwise black
                        color: _voteStatus == VoteStatus.downvoted
                            ? Colors.red : Colors.black,
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
        // Post 1: BSCS Forum - Merge Sort
        _PostCard(
          username: '[BSCS Forum]',
          title: 'Need Help Understanding Merge Sort Recursion 😭',
          time: 'Posted 1hr ago',
          subtitle:
              'Okay legit, I thought I got it... until I tried tracing it manually. Can someone explain merge sort recursion in the simplest way possible? Like pang Grade 5 explanation haha.\n#BSCS #DataStructures #CodingHelp #BatStateU',
          initialUpvotes: 7400, // Initial upvote count
        ),
        SizedBox(height: 12),

        // Post 2: BSAIS Forum - Auditing and Assurance
        _PostCard(
          username: '[BSAIS Forum]',
          title: 'What\'s the Difference Between Auditing and Assurance?',
          time: 'Posted 2hr ago',
          subtitle:
              'Our prof explained it kanina, pero medyo sabog pa rin ako 😅 Anyone got a simple comparison or cheat sheet for this?\n#BSAIS #Auditing101 #AccountingHelp #BatStateU',
          initialUpvotes: 6200, // Initial upvote count
        ),
        SizedBox(height: 12),

        // Post 3: BSME Forum - Thermodynamics Quiz
        _PostCard(
          username: '[BSME Forum]',
          title: 'Thermodynamics Quiz Was Brutal 😩',
          time: 'Posted 3hr ago',
          subtitle:
              'Walang reviewer na nakatulong. Sino pa nandito na feeling drained after that quiz? Share your reviewer links pls.\n#BSME #ThermoStruggles #EngineeringLife #BatStateU',
          initialUpvotes: 5800, // Initial upvote count
        ),
        SizedBox(height: 12),

        // Post 4: BSN Forum - Drug Classifications
        _PostCard(
          username: '[BSN Forum]',
          title: 'Best Way to Memorize Drug Classifications?',
          time: 'Posted 4hr ago',
          subtitle:
              'Mga ka-nursing, paano niyo minimemorize ang pharma classifications without crying? I need hacks, songs, mnemonics... anything.\n#BSN #Pharmacology #StudyTips #BatStateU',
          initialUpvotes: 6700, // Initial upvote count
        ),
        SizedBox(height: 12),

        // Post 5: BSIT Forum - Capstone Title Suggestions
        _PostCard(
          username: '[BSIT Forum]',
          title: 'Capstone Title Suggestions? 👀',
          time: 'Posted 5hr ago',
          subtitle:
              'Wala pa rin kaming finalized title. Anyone here doing something about local businesses or mobile apps? Let’s share ideas and help each other.\n#BSIT #Capstone2025 #CICS #ProjectIdeas #BatStateU',
          initialUpvotes: 7900, // Initial upvote count
        ),
        SizedBox(height: 12),
      ],
    );
  }
}