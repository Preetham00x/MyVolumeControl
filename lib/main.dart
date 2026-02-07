import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VolumeControlApp());
}

class VolumeControlApp extends StatelessWidget {
  const VolumeControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Volume Control',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success indicator
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x20673AB7),
                  border: Border.all(color: const Color(0x60673AB7), width: 2),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Volume Control Ready!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              
              const Text(
                'A notification has been added to your\nnotification panel.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xB3FFFFFF),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0x15FFFFFF),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.swipe_down,
                      color: Color(0xFFFFD54F),
                      size: 32,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Swipe down from the top',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the "Volume Control" notification\nto show the volume slider',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0x99FFFFFF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'You can close this app now.\nThe notification will stay active.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x66FFFFFF),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
