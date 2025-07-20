import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'package:try_1/community/community_provider.dart'; // <--- CORRECTED IMPORT PATH
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'newsfeed_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Wrap your entire app with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => CommunityProvider(), // Create an instance of your CommunityProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EchoSpartan',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/newsfeed': (context) => const NewsFeedScreen(),
      },
    );
  }
}