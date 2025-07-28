import 'package:flutter/material.dart';
import 'editprof_details.dart';
import 'profile_data.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "Samuel Garcia";
  String _course = "Bachelor of Science in Information Technology";
  String _major = "Major in Service Management";
  String _bio = "";

  // Function to navigate to edit page and receive result
  void _editProfileDetails() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfDetailsPage(
          initialName: _name,
          initialCourse: "$_course $_major", 
          initialBio: _bio,
        ),
      ),
    );

    if (updatedData != null && updatedData is ProfileData) {
      setState(() {
        _name = updatedData.name;
        _course = updatedData.course;
        _major = "";
        _bio = updatedData.bio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00000),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 175, 1, 1)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Use state variable
                        const SizedBox(height: 5),
                        Text(_course),
                        if (_major.isNotEmpty) Text(_major),
                        const SizedBox(height: 10),
                        const Text("Bio:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_bio),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Column( 
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                          ),
                          child: Image.asset(
                            'assets/profile2.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8), 
                        GestureDetector(
                          onTap: _editProfileDetails,
                          child: const Text(
                            "Edit Details",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold, 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 15.0,
                          runSpacing: 10.0,
                          alignment: WrapAlignment.start,
                          children: [
                            friendBox("Jemina"),
                            friendBox("Rachel"),
                            friendBox("Leica"),
                            friendBox("Gina"),
                            friendBox("Mariella"),
                            friendBox("Hannah"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("View all", style: TextStyle(fontWeight: FontWeight.w500)),
                              Text("Edit Featured Friends", style: TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 100),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("10 Friend requests"),
                        SizedBox(height: 10),
                        Text("214 Recent Views"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(
                'assets/ghibli.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget friendBox(String name) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              shape: BoxShape.rectangle,
            ),
            child: Image.asset(
              'assets/profile_red.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}