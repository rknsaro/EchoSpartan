import 'package:flutter/material.dart';
import 'profile_data.dart';  // Adjust path if necessary

class EditProfDetailsPage extends StatefulWidget {
  // We can pass initial data if needed, but for now, it's just for output
  final String initialName;
  final String initialCourse;
  final String initialBio;

  const EditProfDetailsPage({
    super.key,
    this.initialName = 'Mark', // Default initial values
    this.initialCourse = 'Bachelor of Fine Arts',
    this.initialBio = 'Bio is empty.',
  });

  @override
  State<EditProfDetailsPage> createState() => _EditProfDetailsPageState();
}

class _EditProfDetailsPageState extends State<EditProfDetailsPage> {
  int _currentStep = 0;

  // Text editing controllers
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  // Selected values for dropdowns
  String? _selectedCourse;
  String? _selectedProgram;

  // List of courses
  final List<String> _courses = [
    'College of Industrial Technology (CIT)',
    'College Of Teacher Education (CTE)',
    'College of Informatics and Computing Sciences (CICS)',
    'College of Arts and Sciences (CAS)',
    'College of Accountancy, Business, Economics and International Hospitality Management (CABEIHM)',
  ];

  // Map of programs based on selected course
  Map<String, List<String>> _programs = {
    'College Of Teacher Education (CTE)': [
      'BS Elementary Education',
      'BS Secondary Education major in English',
      'BS Secondary Education major in Filipino',
      'BS Secondary Education major in Mathematics',
      'BS Secondary Education major in Sciences',
      'BS Secondary Education major in Social Studies',
      'BS Physical Education',
    ],
    'College of Industrial Technology (CIT)': [
      'BS Mechatronics Engineering',
      'BS Industrial Engineering',
    ],
    'College of Informatics and Computing Sciences (CICS)': [
      'BSIT Major in Business Analytics',
      'BSIT Major in Service Management',
      'BSIT Major in Networking Technology',
    ],
    'College of Arts and Sciences (CAS)': [
      'BS Criminology',
      'BS Psychology',
    ],
    'College of Accountancy, Business, Economics and International Hospitality Management (CABEIHM)': [
      'BS Management Accounting',
      'BS Tourism Management',
      'BS Hospitality Management',
      'BS Business Administration major in Financial Management',
      'BS Business Administration major in Human Resource Management',
      'BS Business Administration major in Marketing Management',
    ],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  List<Step> get _steps => [
        Step(
          title: const Text('Basic Information'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Name:',
                  counterText: '', 
                ),
              ),
              const SizedBox(height: 16),
              const Text('Course(s):', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                hint: const Text('Choose one course only'),
                isExpanded: true,
                items: _courses.map((String course) {
                  return DropdownMenuItem<String>(
                    value: course,
                    child: Expanded(
                      child: Text(
                        course,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                    _selectedProgram = null; 
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ],
          ),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Program Selection'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Program:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedProgram,
                hint: const Text('Select a program'),
                isExpanded: true,
                items: _selectedCourse != null
                    ? _programs[_selectedCourse!]?.map((String program) {
                        return DropdownMenuItem<String>(
                          value: program,
                          child: Expanded(
                            child: Text(
                              program,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProgram = newValue;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ],
          ),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Bio Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _bioController,
                maxLength: 50, 
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type your bio here (max 50 characters)',
                ),
              ),
            ],
          ),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
      ];

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
          'Edit Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/profile2.jpeg'), // Your profile image asset
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Update Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: () {
                  final isLastStep = _currentStep == _steps.length - 1;
                  if (isLastStep) {
                    final updatedProfile = ProfileData(
                      name: _nameController.text,
                      course: _selectedProgram ?? widget.initialCourse,
                      bio: _bioController.text,
                    );
                    Navigator.pop(context, updatedProfile);
                  } else {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                steps: _steps,
                controlsBuilder: (context, details) {
                  final isLastStep = _currentStep == _steps.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB00000),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(isLastStep ? 'Save Changes' : 'Continue'),
                        ),
                        const SizedBox(width: 10),
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFB00000),
                            ),
                            child: const Text('Back'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}