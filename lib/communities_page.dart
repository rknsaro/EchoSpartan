import 'package:flutter/material.dart';
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
        _currentUpvotes += 2; 
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
        _currentUpvotes -= 2; 
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


class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: const [
        // Post 1: CICS Week 2025 Hype!!
        _PostCard(
          username: '[CICS Community]',
          title: 'CICS Week 2025 Hype!! 🔴⚫',
          time: 'Posted 1hr ago',
          subtitle:
              'May nakita na akong teaser sa org GC... and yes, mukhang may hackathon, cosplay contest, at free food?! CICS Week never disappoints. Sino excited?\n#CICS #CICSWeek2025 #OrgLife #BatStateU',
          initialUpvotes: 350,
        ),
        SizedBox(height: 12),

        // Post 2: CICS Hall = Sleepless Zone
        _PostCard(
          username: '[CICS Community]',
          title: 'CICS Hall = Sleepless Zone 😬',
          time: 'Posted 2hr ago',
          subtitle:
              'Walked past the 4th floor kanina, may nagde-debug, may umiiyak sa capstone, may group work sa sahig. Mahal ko kayo mga ka-CICS. Tuloy lang ang laban.\n#CICS #CapstoneGrind #CodingTill3AM #StudentLife',
          initialUpvotes: 280,
        ),
        SizedBox(height: 12),

        // Post 3: Any Org Accepting New Members?
        _PostCard(
          username: '[CICS Community]',
          title: 'Any Org Accepting New Members?',
          time: 'Posted 3hr ago',
          subtitle:
              'Incoming 2nd year here! Curious about orgs sa CICS na chill but active. Hindi ko kaya yung super loaded schedule, pero gusto ko pa rin maging involved. Recommendations?\n#CICS #FreshieFeels #OrgJoiner #CollegeCommunity',
          initialUpvotes: 150,
        ),
        SizedBox(height: 12),

        // Post 4: Fastest SIM in Malvar campus for hotspotting?
        _PostCard(
          username: '[CICS Community]',
          title: 'Fastest SIM in Malvar campus for hotspotting? 📶',
          time: 'Posted 4hr ago',
          subtitle:
              'Legit tanong: ano pinaka okay na SIM for hotspot sa Malvar? Globe minsan okay, minsan wala. Smart? DITO? I need stable data lalo na sa CICS labs.\n#CICS #WiFiAlternatives #MalvarCampus #BatStateU #HotspotLife',
          initialUpvotes: 210,
        ),
        SizedBox(height: 12),
      ],
    );
  }
}