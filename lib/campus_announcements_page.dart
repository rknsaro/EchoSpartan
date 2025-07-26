

import 'package:flutter/material.dart';

class _PostOption extends StatefulWidget {
  final IconData icon;
  final String label;

  const _PostOption({required this.icon, required this.label});

  @override
  State<_PostOption> createState() => _PostOptionState();
}

class _PostOptionState extends State<_PostOption> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(widget.icon, color: Colors.red, size: 24),
        const SizedBox(height: 4),
        Text(widget.label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PostCard extends StatefulWidget {
  final String username;
  final String title;
  final String time;
  final String subtitle;
  final int initialUpvotes;

  const _PostCard({
    required this.username,
    required this.title,
    required this.time,
    this.subtitle = '',
    this.initialUpvotes = 0,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

enum _VoteStatus {
  upvoted,
  downvoted,
  none,
}

class _PostCardState extends State<_PostCard> {
  late int _currentUpvotes;
  _VoteStatus _voteStatus = _VoteStatus.none;

  @override
  void initState() {
    super.initState();
    _currentUpvotes = widget.initialUpvotes;
  }

  void _upvote() {
    setState(() {
      if (_voteStatus == _VoteStatus.upvoted) {
        _currentUpvotes--;
        _voteStatus = _VoteStatus.none;
      } else if (_voteStatus == _VoteStatus.downvoted) {
        _currentUpvotes += 2; // Undo downvote and add upvote
        _voteStatus = _VoteStatus.upvoted;
      } else {
        _currentUpvotes++;
        _voteStatus = _VoteStatus.upvoted;
      }
    });
  }

  void _downvote() {
    setState(() {
      if (_voteStatus == _VoteStatus.downvoted) {
        _currentUpvotes++;
        _voteStatus = _VoteStatus.none;
      } else if (_voteStatus == _VoteStatus.upvoted) {
        _currentUpvotes -= 2; // Undo upvote and add downvote
        _voteStatus = _VoteStatus.downvoted;
      } else {
        _currentUpvotes--;
        _voteStatus = _VoteStatus.downvoted;
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
                    GestureDetector(
                      onTap: _upvote,
                      child: Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: _voteStatus == _VoteStatus.upvoted ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('$_currentUpvotes'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _downvote,
                      child: Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: _voteStatus == _VoteStatus.downvoted ? Colors.red : Colors.black,
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


class CampusAnnouncementsPage extends StatelessWidget {
  const CampusAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: const [
        // Announcement 1: Enrollment for First Semester A.Y. 2025–2026 Now Open
        _PostCard(
          username: '[Registrar\'s Office]',
          title: 'Enrollment for First Semester A.Y. 2025–2026 Now Open 📝',
          time: 'Posted July 25, 2025', // Adjusted time based on current date
          subtitle:
              'Online enrollment starts July 22 via the BatStateU Student Portal. Make sure to finalize your advising and clear any outstanding balances before enrolling. Deadline is August 2, so don’t wait until the last minute!\n#Enrollment2025 #StudentPortal #BatStateU #RegistrarUpdate',
          initialUpvotes: 450,
        ),
        SizedBox(height: 12),

        // Announcement 2: Call for Volunteers: Red Spartan Blood Drive
        _PostCard(
          username: '[Red Cross Youth BatStateU]',
          title: 'Call for Volunteers: Red Spartan Blood Drive ❤️',
          time: 'Posted July 23, 2025',
          subtitle:
              'The Red Cross Youth BatStateU Chapter is looking for volunteers and donors for the upcoming blood donation drive on August 12, 2025. Hosted in partnership with the Health Services Office.\n#RedSpartanBloodDrive #RCYBatStateU #HealthOffice #VolunteerNow',
          initialUpvotes: 180,
        ),
        SizedBox(height: 12),

        // Announcement 3: New Library E-Resources Now Accessible
        _PostCard(
          username: '[University Library]',
          title: 'New Library E-Resources Now Accessible 📚',
          time: 'Posted July 22, 2025',
          subtitle:
              'The University Library has expanded its digital collection! Students now have access to JSTOR, ScienceDirect, and updated e-book subscriptions through the E-Library portal.\n#BatStateULibrary #ELearning #RGO #StudentResources',
          initialUpvotes: 270,
        ),
        SizedBox(height: 12),
      ],
    );
  }
}