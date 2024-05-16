import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'custom_button.dart';
import 'pattern_recognition.dart';
import 'gps_service.dart';
import 'emergency_message.dart';
import 'contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms/flutter_sms.dart';

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
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late LocationService locationService;
  String geoLink = '';
  String emergencyMessage = 'Your emergency message here'; // default message
  bool isSessionActive = false;
  bool permissionsGranted = false;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    locationService = LocationService();
    _loadEmergencyMessage();
    _loadContacts();
  }

  Future<void> _requestPermissions() async {
    bool micGranted = await _requestMicPermission();
    if (micGranted) {
      bool geoGranted = await _requestGeoPermission();
      if (geoGranted) {
        bool smsGranted = await _requestSmsPermission();
        if (smsGranted) {
          setState(() {
            permissionsGranted = true;
            _initializeListeners();
          });
        } else {
          _showPermissionDeniedDialog('SMS');
        }
      } else {
        _showPermissionDeniedDialog('Geolocation');
      }
    } else {
      _showPermissionDeniedDialog('Microphone');
    }
  }

  Future<bool> _requestMicPermission() async {
    if (await Permission.microphone.request().isGranted) {
      return true;
    } else {
      // Handle the denial of microphone permission
      print("Microphone permission denied");
      return false;
    }
  }

  Future<bool> _requestGeoPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    } else {
      // Handle the denial of geolocation permissions
      print("Geolocation permission denied");
      return false;
    }
  }

  Future<bool> _requestSmsPermission() async {
    if (await Permission.sms.request().isGranted) {
      print("SMS permission granted");
      return true;
    } else {
      print("SMS permission denied");
      return false;
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$permission Permission Denied"),
          content: Text(
              "This permission is required for the app to function properly. Please grant the $permission permission in your device settings."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally, navigate the user to app settings
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _initializeListeners() {
    // Add a listener to start/stop the geo session based on pattern detection
    Provider.of<PeakDetectionNotifier>(context, listen: false)
        .addListener(_handlePatternDetection);
  }

  void _sendSMS(String message, List<String> recipients) async {
    String _result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  Future<void> _loadEmergencyMessage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyMessage = prefs.getString('emergency_message') ??
          "I am in danger. Please get help. I am at this location: ";
    });
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactData = prefs.getStringList('contacts') ?? [];
    setState(() {
      contacts = contactData.map((contact) {
        final parts = contact.split('|');
        return Contact(name: parts[0], phoneNumber: parts[1]);
      }).toList();
    });
  }

  void _handlePatternDetection() async {
    final isPatternDetected =
        Provider.of<PeakDetectionNotifier>(context, listen: false)
            .isPatternDetected;

    if (isPatternDetected && !isSessionActive) {
      await locationService.startSession();
      await _loadContacts(); // Load the contacts again to ensure they are up-to-date
      await _loadEmergencyMessage(); // Reload emergency message to ensure it is up-to-date
      setState(() {
        geoLink = locationService.getGeoLink();
        isSessionActive = true;
      });
      String message = "$emergencyMessage\n\nLocation: $geoLink";
      List<String> recipients =
          contacts.map((contact) => contact.phoneNumber).toList();

      //String _result = await sendSMS(
      //        message: message, recipients: recipients, sendDirect: true)
      //    .catchError((onError) {
      //  print(onError);
      //});
      // TODO Enable to test SMS service
      print(recipients); // Print the recipients list to ensure it is updated
      print(message);
    } else if (!isPatternDetected && isSessionActive) {
      locationService.endSession();
      setState(() {
        isSessionActive = false;
      });
      print('Session ended');
    }
  }

  @override
  void dispose() {
    locationService.endSession();
    Provider.of<PeakDetectionNotifier>(context, listen: false)
        .removeListener(_handlePatternDetection);
    super.dispose();
  }

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
      body: permissionsGranted
          ? Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AvatarGlow(
                          duration: const Duration(milliseconds: 1500),
                          endRadius: 300,
                          glowColor: context
                                  .watch<PeakDetectionNotifier>()
                                  .isPatternDetected
                              ? Colors.red
                              : Colors.blue,
                          curve: Curves.fastOutSlowIn,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 150,
                                color: context
                                        .watch<PeakDetectionNotifier>()
                                        .isPatternDetected
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              Icon(
                                Icons.circle_outlined,
                                size: 350,
                                color: context
                                        .watch<PeakDetectionNotifier>()
                                        .isPatternDetected
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: StyledElevatedButton(
                                text: context
                                        .watch<PeakDetectionNotifier>()
                                        .isPatternDetected
                                    ? 'Active'
                                    : 'Activate',
                                textColor: context
                                        .watch<PeakDetectionNotifier>()
                                        .isPatternDetected
                                    ? Colors.red
                                    : Colors.white,
                                onPressed: () {
                                  context
                                      .read<PeakDetectionNotifier>()
                                      .updatePatternDetection(true);
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: StyledElevatedButton(
                                text: 'Settings',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage(),
                                    ),
                                  ).then((_) {
                                    // Reload emergency message and contacts when returning from settings
                                    _loadEmergencyMessage();
                                    _loadContacts();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const MicPage(), // Adding MicPage to the widget tree to ensure it's properly initialized
              ],
            )
          : const Center(
              child:
                  CircularProgressIndicator()), // Show loading indicator while requesting permissions
    );
  }
}
