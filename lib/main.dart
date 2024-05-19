import 'package:avatar_glow/avatar_glow.dart'; // Import for glowing avatar effect.
import 'package:flutter/material.dart'; // Import for Flutter UI components.
import 'package:geolocator/geolocator.dart'; // Import for geolocation services.
import 'package:google_fonts/google_fonts.dart'; // Import for custom Google fonts.
import 'package:provider/provider.dart'; // Import for state management using Provider.
import 'settings_page.dart'; // Import for settings page.
import 'custom_button.dart'; // Import for custom styled button.
import 'pattern_recognition.dart'; // Import for pattern recognition logic.
import 'contacts.dart'; // Import for managing emergency contacts.
import 'package:shared_preferences/shared_preferences.dart'; // Import for persistent storage.
import 'package:permission_handler/permission_handler.dart'; // Import for handling permissions.
import 'package:flutter_sms/flutter_sms.dart'; // Import for sending SMS.
import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // Import for foreground service.
import 'foreground_service.dart'; // Import for foreground location service.

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          PeakDetectionNotifier(), // Initialize the state notifier for peak detection.
      child: const MyApp(), // Wrap MyApp with the ChangeNotifierProvider.
    ),
  );
}

// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapOut SOS',
      theme: ThemeData(
        useMaterial3: true, // Use Material 3 design.
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
      home: const MainPage(), // Set MainPage as the home widget.
    );
  }
}

// Stateful widget for the main page of the app.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late ForegroundLocationService locationService;
  String geoLink = '';
  String emergencyMessage = 'Your emergency message here'; // Default message.
  bool isSessionActive = false;
  bool permissionsGranted = false;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _initForegroundTask(); // Initialize foreground task.
    _requestPermissions(); // Request necessary permissions.
    locationService =
        ForegroundLocationService(); // Initialize the foreground location service.
    _loadEmergencyMessage(); // Load saved emergency message.
    _loadContacts(); // Load saved contacts.
  }

  // Initialize foreground task with notification options and settings.
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        foregroundServiceType: AndroidForegroundServiceType
            .DATA_SYNC, // Set foreground service type.
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // Request necessary permissions from the user.
  Future<void> _requestPermissions() async {
    bool micGranted = await _requestMicPermission();
    if (micGranted) {
      bool geoGranted = await _requestGeoPermission();
      if (geoGranted) {
        bool smsGranted = await _requestSmsPermission();
        if (smsGranted) {
          setState(() {
            permissionsGranted = true;
            _initializeListeners(); // Initialize listeners for pattern detection.
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

  // Request microphone permission.
  Future<bool> _requestMicPermission() async {
    if (await Permission.microphone.request().isGranted) {
      return true;
    } else {
      print("Microphone permission denied");
      return false;
    }
  }

  // Request geolocation permission.
  Future<bool> _requestGeoPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    } else {
      print("Geolocation permission denied");
      return false;
    }
  }

  // Request SMS permission.
  Future<bool> _requestSmsPermission() async {
    if (await Permission.sms.request().isGranted) {
      print("SMS permission granted");
      return true;
    } else {
      print("SMS permission denied");
      return false;
    }
  }

  // Show a dialog informing the user that a permission is denied.
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
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Initialize listeners for pattern detection.
  void _initializeListeners() {
    Provider.of<PeakDetectionNotifier>(context, listen: false)
        .addListener(_handlePatternDetection);
  }

  // Send an SMS message to the list of recipients.
  void _sendSMS(String message, List<String> recipients) async {
    String result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(result);
  }

  // Load the emergency message from shared preferences.
  Future<void> _loadEmergencyMessage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyMessage = prefs.getString('emergency_message') ??
          "I am in danger. Please get help. I am at this location: ";
    });
  }

  // Load the list of contacts from shared preferences.
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

  // Handle pattern detection events and start/stop sessions accordingly.
  void _handlePatternDetection() async {
    final isPatternDetected =
        Provider.of<PeakDetectionNotifier>(context, listen: false)
            .isPatternDetected;

    if (isPatternDetected && !isSessionActive) {
      await locationService.startSession(); // Start the location session.
      await _loadContacts();
      await _loadEmergencyMessage();
      setState(() {
        geoLink = locationService.geoLink;
        isSessionActive = true;
      });
      String message = "$emergencyMessage\n\nLocation: $geoLink";
      List<String> recipients =
          contacts.map((contact) => contact.phoneNumber).toList();

      String result = await sendSMS(
          message: message, recipients: recipients, sendDirect: true);
      print(result);
      print(recipients);
      print(message);

      _startForegroundTask(); // Start the foreground task.
    } else if (!isPatternDetected && isSessionActive) {
      locationService.endSession(); // End the location session.
      setState(() {
        isSessionActive = false;
      });
      print('Session ended');

      _stopForegroundTask(); // Stop the foreground task.
    }
  }

  // Start the foreground task with specified notification options.
  Future<void> _startForegroundTask() async {
    await FlutterForegroundTask.startService(
      notificationTitle: 'Foreground Service is running',
      notificationText: 'Tap to return to the app',
      callback: startCallback,
    );
  }

  // Stop the foreground task.
  Future<void> _stopForegroundTask() async {
    await FlutterForegroundTask.stopService();
  }

  @override
  void dispose() {
    locationService
        .endSession(); // End the location session when disposing the widget.
    Provider.of<PeakDetectionNotifier>(context, listen: false)
        .removeListener(_handlePatternDetection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
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
                  const MicPage(), // Ensure MicPage is included in the widget tree for microphone functionality.
                ],
              )
            : const Center(
                child:
                    CircularProgressIndicator()), // Show loading indicator while permissions are being requested.
      ),
    );
  }
}

// Callback function for starting the foreground task.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundLocationService());
}
