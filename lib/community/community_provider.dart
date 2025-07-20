import 'package:flutter/material.dart';
import 'dart:typed_data';

class CommunityPreviewData {
  final String id;
  final String name;
  final Uint8List? imageBytes;
  final String intro;
  final int memberCount;

  CommunityPreviewData({
    required this.id,
    required this.name,
    this.imageBytes,
    this.intro = '',
    this.memberCount = 0,
  });

  CommunityPreviewData copyWith({
    String? id,
    String? name,
    Uint8List? imageBytes,
    String? intro,
    int? memberCount,
  }) {
    return CommunityPreviewData(
      id: id ?? this.id,
      name: name ?? this.name,
      imageBytes: imageBytes ?? this.imageBytes,
      intro: intro ?? this.intro,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}

class CommunityProvider with ChangeNotifier {
  List<CommunityPreviewData> _communities = [];

  List<CommunityPreviewData> get communities => _communities;

  void setCommunities(List<CommunityPreviewData> communities) {
    _communities = communities;
    notifyListeners(); // Notify listeners when the entire list is set
  }

  void addCommunity(CommunityPreviewData community) {
    // Check if the community already exists by ID to avoid duplicates
    int existingIndex = _communities.indexWhere((c) => c.id == community.id);
    if (existingIndex != -1) {
      // Update existing community
      _communities[existingIndex] = community;
    } else {
      // Add new community
      _communities.add(community);
    }
    notifyListeners(); // Notify listeners when a community is added or updated
  }

  void removeCommunity(String communityId) {
    _communities.removeWhere((community) => community.id == communityId);
    notifyListeners();
  }
}