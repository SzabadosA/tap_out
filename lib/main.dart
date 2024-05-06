import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_page.dart';
import 'custom_button.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapOut SOS',
      theme: ThemeData(
        useMaterial3: true,

        // default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          // ···
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          // ···
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
  bool isActivated = false;

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AvatarGlow(
                duration: const Duration(milliseconds: 1500),
                endRadius: 300,
                glowColor: isActivated ? Colors.red : Colors.blue,
                curve: Curves.fastOutSlowIn,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 150,
                      color: isActivated ? Colors.red : Colors.blue,
                    ),
                    Icon(
                      Icons.circle_outlined,
                      size: 350,
                      color: isActivated ? Colors.red : Colors.blue,
                    ),
                  ],
                )),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StyledElevatedButton(
                  text: isActivated ? 'Active' : 'Activate',
                  textColor: isActivated ? Colors.white : Colors.red,
                  onPressed: () {
                    setState(() {
                      isActivated = true;
                    });
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
                            setState(() {
                              isActivated = false; // Ensures deactivation
                            });
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
    );
  }
}
