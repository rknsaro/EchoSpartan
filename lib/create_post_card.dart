import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb

class CreatePostCard extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onPostCreated;

  const CreatePostCard({super.key, required this.onPostCreated});

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage; // For non-web platforms
  Uint8List? _selectedImageBytes; // For web platforms
  List<TextEditingController> _pollOptionControllers = [];
  int? _pollEndsInDays = 2; // Default to 2 days
  bool _showPollEditor = false; // Control visibility of poll editor

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (var controller in _pollOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(StateSetter modalSetState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        modalSetState(() {
          _selectedImageBytes = bytes;
          _selectedImage = null;
          _showPollEditor = false;
        });
      } else {
        modalSetState(() {
          _selectedImage = File(image.path);
          _selectedImageBytes = null;
          _showPollEditor = false;
        });
      }
    }
  }

  void _removeImage(StateSetter modalSetState) {
    modalSetState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
    });
  }

  void _addPollOption(StateSetter modalSetState) {
    modalSetState(() {
      _pollOptionControllers.add(TextEditingController());
    });
  }

  void _removePollOption(StateSetter modalSetState, int index) {
    modalSetState(() {
      _pollOptionControllers[index].dispose();
      _pollOptionControllers.removeAt(index);
    });
  }

  void _togglePollEditor(StateSetter modalSetState) {
    modalSetState(() {
      _showPollEditor = !_showPollEditor;
      if (_showPollEditor && _pollOptionControllers.isEmpty) {
        _pollOptionControllers.add(TextEditingController());
        _pollOptionControllers.add(TextEditingController());
      }
      // If poll editor is shown, hide image
      if (_showPollEditor) {
        _selectedImage = null;
        _selectedImageBytes = null;
      }
    });
  }

  // Modified function to show the discard confirmation dialog with new styling
  Future<bool?> _showDiscardConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          title: const Text(
            'Discard post submission?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20, // Adjusted font size
            ),
            textAlign: TextAlign.center, // Centered title
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          actionsAlignment: MainAxisAlignment.center, // Center the buttons
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Do not discard
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB00000), // Red text for Cancel
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded corners for button
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16), // Adjusted font size
              ),
            ),
            const SizedBox(width: 10), // Space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Discard
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00000), // Red background
                foregroundColor: Colors.white, // White text
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded corners for button
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Discard',
                style: TextStyle(fontSize: 16), // Adjusted font size
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePostModal(BuildContext context) async {
    _titleController.clear();
    _contentController.clear();
    _selectedImage = null;
    _selectedImageBytes = null;
    _pollOptionControllers.clear();
    _pollEndsInDays = 2;
    _showPollEditor = false;

    final Map<String, dynamic>? result =
        await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.95,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () async {
                            final shouldDiscard = await _showDiscardConfirmationDialog(context);
                            if (shouldDiscard == true) {
                              Navigator.of(context).pop(); // Pop the bottom sheet
                            }
                          },
                        ),
                        const Text(
                          'Create Post',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_titleController.text.isEmpty &&
                                !_showPollEditor) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post title cannot be empty!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (_showPollEditor) {
                              // Validate poll options if poll editor is active
                              final List<String> pollOptions =
                                  _pollOptionControllers
                                      .map((controller) =>
                                          controller.text.trim())
                                      .where((text) => text.isNotEmpty)
                                      .toList();
                              if (pollOptions.length < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('A poll needs at least two options!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              Navigator.of(context).pop({
                                'title': _titleController.text.isNotEmpty
                                    ? _titleController.text
                                    : 'Poll',
                                'content': _contentController.text,
                                'pollOptions': pollOptions,
                                'pollEndsInDays': _pollEndsInDays,
                              });
                            } else {
                              Navigator.of(context).pop({
                                'title': _titleController.text,
                                'content': _contentController.text,
                                'imageFile': _selectedImage,
                                'imageBytes': _selectedImageBytes,
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                          ),
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text('Title',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Add a title',
                              hintStyle: TextStyle(
                                  color: Colors.grey[600], fontSize: 20),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _contentController,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'body text (optional)',
                              hintStyle: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 20),
                          // Display selected image if available
                          if (_selectedImage != null ||
                              _selectedImageBytes != null)
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: kIsWeb &&
                                              _selectedImageBytes != null
                                          ? MemoryImage(_selectedImageBytes!)
                                          : FileImage(_selectedImage!)
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        color: Colors.black, size: 20),
                                    onPressed: () {
                                      _removeImage(modalSetState);
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                          255, 255, 255, 0.7),
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // Display poll editor if _showPollEditor is true
                          if (_showPollEditor)
                            _PollEditor(
                              pollOptionControllers: _pollOptionControllers,
                              addPollOption: () => _addPollOption(modalSetState),
                              removePollOption: (index) =>
                                  _removePollOption(modalSetState, index),
                              pollEndsInDays: _pollEndsInDays,
                              onPollEndsInDaysChanged: (newValue) {
                                modalSetState(() {
                                  _pollEndsInDays = newValue;
                                });
                              },
                              onRemovePollEditor: () {
                                modalSetState(() {
                                  _showPollEditor = false;
                                  _pollOptionControllers.clear();
                                });
                              },
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // Bottom action bar with Link, Image, Video, and Poll icons
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB00000),
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey[300]!, width: 0.5)), // Lighter border
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.link,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            onPressed: () {}),
                        IconButton(
                            icon: const Icon(Icons.image_outlined,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            onPressed: () {
                              _pickImage(modalSetState);
                            }),
                        IconButton(
                            icon: const Icon(Icons.bar_chart,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            onPressed: () {
                              _togglePollEditor(modalSetState);
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && result['title']!.isNotEmpty) {
      widget.onPostCreated(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: const Color(0xFFF0F2F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showCreatePostModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "What's on your mind?",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.person, 'Create Post', () {
                  _showCreatePostModal(context);
                }),
                _buildActionButton(Icons.link, 'Link', () {
                  // Handle link functionality
                }),
                _buildActionButton(Icons.bar_chart, 'Poll', () {
                  _showCreatePostModal(context); // This will open the modal and then you can click the poll icon inside
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(height: 4.0),
            Text(label, style: const TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}

// New widget for Poll Editor
class _PollEditor extends StatelessWidget {
  final List<TextEditingController> pollOptionControllers;
  final VoidCallback addPollOption;
  final Function(int) removePollOption;
  final int? pollEndsInDays;
  final ValueChanged<int?> onPollEndsInDaysChanged;
  final VoidCallback onRemovePollEditor;

  const _PollEditor({
    required this.pollOptionControllers,
    required this.addPollOption,
    required this.removePollOption,
    required this.pollEndsInDays,
    required this.onPollEndsInDaysChanged,
    required this.onRemovePollEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<int>(
              value: pollEndsInDays,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onChanged: onPollEndsInDaysChanged,
              // New: Customize the displayed item when an item is selected
              selectedItemBuilder: (BuildContext context) {
                return List.generate(7, (index) => index + 1).map<Widget>((int value) {
                  return Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Poll ends in ',
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                            text: '$value Day${value > 1 ? 's' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
              items: List.generate(7, (index) => index + 1)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  // Changed: Only show "Day(s)" in the dropdown list
                  child: Text('${value} Day${value > 1 ? 's' : ''}'),
                );
              }).toList(),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: onRemovePollEditor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(pollOptionControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pollOptionControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  if (pollOptionControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => removePollOption(index),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: addPollOption,
          icon: const Icon(Icons.add, color: Colors.red),
          label: const Text(
            'Add poll option',
            style: TextStyle(color: Colors.red),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }
}