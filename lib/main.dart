import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task_platform_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'custom_button.dart';
import 'pattern_recognition.dart';
import 'contacts.dart';
import 'help_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'foreground_service.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PeakDetectionNotifier(),
      child: const TapOutApp(),
    ),
  );
}

class TapOutApp extends StatelessWidget {
  const TapOutApp({super.key});

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
          titleLarge: GoogleFonts.nunitoSans(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.lato(),
          displaySmall: GoogleFonts.lato(),
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

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late ForegroundLocationService locationService;
  String geoLink = '';
  String emergencyMessage = 'Your emergency message here';
  bool isSessionActive = false;
  bool permissionsGranted = false;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Add observer for app lifecycle changes
    _initForegroundTask();
    _requestPermissions(); // Request necessary permissions
    locationService = ForegroundLocationService();
    _loadEmergencyMessage(); // Load saved emergency message
    _loadContacts(); // Load saved contacts
    _startForegroundTask();
  }

  // Initialize the foreground task
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service_channel',
        channelName: 'Foreground Service',
        channelDescription: 'This channel is used for important notifications.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        interval: 10000,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // Start the foreground task
  Future<void> _startForegroundTask() async {
    await FlutterForegroundTask.startService(
      notificationTitle: 'Service is Running',
      notificationText: 'Tap to return to the app',
      callback: startCallback,
    );
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    bool micGranted = await _requestMicPermission();
    if (micGranted) {
      bool geoGranted = await _requestGeoPermission();
      if (geoGranted) {
        bool smsGranted = await _requestSmsPermission();
        if (smsGranted) {
          setState(() {
            permissionsGranted = true;
            _initializeListeners(); // Initialize listeners if all permissions are granted
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

  // Request microphone permission
  Future<bool> _requestMicPermission() async {
    if (await Permission.microphone.request().isGranted) {
      return true;
    } else {
      print("Microphone permission denied");
      return false;
    }
  }

  // Request geolocation permission
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

  // Request SMS permission
  Future<bool> _requestSmsPermission() async {
    if (await Permission.sms.request().isGranted) {
      print("SMS permission granted");
      return true;
    } else {
      print("SMS permission denied");
      return false;
    }
  }

  // Show a dialog if a permission is denied
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

  // Initialize pattern detection listeners
  void _initializeListeners() {
    Provider.of<PeakDetectionNotifier>(context, listen: false)
        .addListener(_handlePatternDetection);
  }

  // Send SMS with emergency message
  void _sendSMS(String message, List<String> recipients) async {
    String result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(result);
  }

  // Load the emergency message from shared preferences
  Future<void> _loadEmergencyMessage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyMessage = prefs.getString('emergency_message') ??
          "I am in danger. Please get help. I am at this location: ";
    });
  }

  // Load the contacts from shared preferences
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

  // Handle pattern detection events
  void _handlePatternDetection() async {
    final isPatternDetected =
        Provider.of<PeakDetectionNotifier>(context, listen: false)
            .isPatternDetected;

    if (isPatternDetected && !isSessionActive) {
      await locationService.startSession();
      locationService.startLocationUpdates();
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
    } else if (!isPatternDetected && isSessionActive) {
      locationService.endSession();
      locationService.stopLocationUpdates();
      setState(() {
        isSessionActive = false;
      });
      print('Session ended');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    locationService.endSession();
    Provider.of<PeakDetectionNotifier>(context, listen: false)
        .removeListener(_handlePatternDetection);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.detached) {
      // Stop foreground service and clear data when app is detached
      FlutterForegroundTaskPlatform.instance.stopService();
      FlutterForegroundTask.stopService();
      FlutterForegroundTask.clearAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalHeight = screenHeight;

    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          elevation: 8,
          title: const Text('Tap Out SOS'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: permissionsGranted
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0x0056008e), // Dark purple color at the top
                      Theme.of(context)
                          .scaffoldBackgroundColor, // Current color at the bottom
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[],
                        ),
                      ),
                    ),
                    Positioned(
                      top: (totalHeight - appBarHeight * 2) / 2 -
                          screenWidth * 0.4,
                      left: 0,
                      right: 0,
                      child: AvatarGlow(
                        duration: const Duration(milliseconds: 2000),
                        endRadius: screenWidth * 0.4,
                        glowColor: context
                                .watch<PeakDetectionNotifier>()
                                .isPatternDetected
                            ? Colors.red
                            : Colors.indigoAccent,
                        curve: Curves.decelerate,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: screenWidth * 0.4,
                              color: context
                                      .watch<PeakDetectionNotifier>()
                                      .isPatternDetected
                                  ? Colors.red
                                  : Colors.indigoAccent,
                            ),
                            Icon(
                              Icons.circle_outlined,
                              size: screenWidth * 0.8,
                              color: context
                                      .watch<PeakDetectionNotifier>()
                                      .isPatternDetected
                                  ? Colors.red
                                  : Colors.indigoAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: screenHeight * 0.075,
                      left: 15,
                      right: 15,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
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
                                    : Colors.cyan,
                                onPressed: () {
                                  context
                                      .read<PeakDetectionNotifier>()
                                      .updatePatternDetection(true);
                                  Vibration.vibrate(
                                      pattern: [0, 500, 500, 1000, 500, 2000]);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StyledElevatedButton(
                                text: 'Settings',
                                textColor: Colors.cyan,
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
                      ),
                    ),
                    const MicPage(),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundLocationService());
}
