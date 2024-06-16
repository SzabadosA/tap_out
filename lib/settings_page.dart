import 'package:flutter/material.dart';
import 'contacts.dart';
import 'emergency_message.dart';
import 'package:provider/provider.dart';
import 'pattern_recognition.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Settings'), // Title of the app bar
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          const SizedBox(height: 20), // Add spacing at the top of the list
          ListTile(
            title: const Text('Deactivate Session'),
            onTap: () {
              // Deactivate session by resetting the pattern detection state
              context.read<PeakDetectionNotifier>().resetPatternDetection();
            },
          ),
          ListTile(
            title: const Text('Edit Contacts'),
            onTap: () {
              // Navigate to the ContactsPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Edit Message'),
            onTap: () {
              // Navigate to the EmergencyMessageWidget
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EmergencyMessageWidget()),
              );
            },
          ),
        ],
      ),
    );
  }
}
