// discussions_page.dart
import 'package:flutter/material.dart';

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
        ),
        SizedBox(height: 12), // Spacer between cards

        // Post 3: Prof Who Posts at 11:59 PM
        _PostCard(
          username: 'Anonymous ECE', // Example username
          title: 'Prof Who Posts at 11:59 PM, Let\'s Talk.',
          time: 'Posted 3hr ago', // Example time
          subtitle:
              'Walang hate, just curious—do other departments also have profs who drop quizzes or reminders literally 1 minute before midnight? What’s the wildest deadline drop you\'ve experienced?\n#BSECE #LateNightDrops #ProfChronicles #StudentVoices',
          initialUpvotes: 210, // Use initialUpvotes
        ),
        SizedBox(height: 12), // Spacer between cards

        // Post 4: Budget-friendly lunch?
        _PostCard(
          username: 'BSAIS Broke', // Example username
          title: 'Budget-friendly lunch?',
          time: 'Posted 4hr ago', // Example time
          subtitle:
              'Siomai-rice has been the go-to for weeks now, pero guys... hindi ko na kaya 😅 Help a broke student out with some affordable options near campus!\n#SawaNaAkoSaSiomaiRice #BatStateUEats #BSAIS #TipidTips',
          initialUpvotes: 95, // Use initialUpvotes
        ),
        SizedBox(height: 12), // Spacer for the last card
      ],
    );
  }
}

// --- _PostOption remains the same ---
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

// --- MODIFIED _PostCard to be Stateful ---
class _PostCard extends StatefulWidget {
  final String username;
  final String title;
  final String time;
  final String subtitle;
  final int initialUpvotes; // Changed to initialUpvotes

  const _PostCard({
    required this.username,
    required this.title,
    required this.time,
    this.subtitle = '',
    this.initialUpvotes = 0, // Default to 0
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _currentUpvotes; // State variable for upvotes
  VoteStatus _voteStatus = VoteStatus.none; // To track current vote

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
                        color: _voteStatus == VoteStatus.upvoted ? Colors.red : Colors.black, // Highlight if upvoted
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
                        color: _voteStatus == VoteStatus.downvoted ? Colors.red : Colors.black, // Highlight if downvoted
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

// Enum to keep track of the vote status
enum VoteStatus {
  upvoted,
  downvoted,
  none,
}