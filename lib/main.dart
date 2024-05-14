import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'custom_button.dart';
import 'pattern_recognition.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PeakDetectionNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapOut SOS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    requestGeoPermissions();
    MicPage listener = MicPage();
  }

  @override
  Widget build(BuildContext context) {
    final isPatternDetected =
        context.watch<PeakDetectionNotifier>().isPatternDetected;

    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: const Text('Tap Out SOS'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Help action
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AvatarGlow(
                  duration: const Duration(milliseconds: 1500),
                  endRadius: 300,
                  glowColor: isPatternDetected ? Colors.red : Colors.blue,
                  curve: Curves.fastOutSlowIn,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 150,
                        color: isPatternDetected ? Colors.red : Colors.blue,
                      ),
                      Icon(
                        Icons.circle_outlined,
                        size: 350,
                        color: isPatternDetected ? Colors.red : Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    StyledElevatedButton(
                      text: isPatternDetected ? 'Active' : 'Activate',
                      textColor: isPatternDetected ? Colors.white : Colors.red,
                      onPressed: () {
                        context
                            .read<PeakDetectionNotifier>()
                            .updatePatternDetection(true);
                      },
                    ),
                    SizedBox(width: 20),
                    StyledElevatedButton(
                      text: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              deactivateSessionCallback: () {
                                context
                                    .read<PeakDetectionNotifier>()
                                    .resetPatternDetection();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          MicPage(), // Adding MicPage to the widget tree to ensure it's properly initialized
        ],
      ),
    );
  }

  Future<void> requestGeoPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Handle the permanent denial of permissions
      return;
    }

    if (permission == LocationPermission.denied) {
      // Handle the temporary denial of permissions
      return;
    }
  }
}
