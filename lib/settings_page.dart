import 'package:flutter/material.dart';
import 'package:tap_out/custom_button.dart';
import 'contacts.dart';
import 'emergency_message.dart';
import 'package:geolocator/geolocator.dart';
import 'gps_service.dart';
import 'package:provider/provider.dart';
import 'pattern_recognition.dart';

class SettingsPage extends StatelessWidget {
  final Function deactivateSessionCallback;

  const SettingsPage({super.key, required this.deactivateSessionCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Reset Peak Detection'),
            onTap: () {
              context.read<PeakDetectionNotifier>().resetPatternDetection();
            },
          ),
          ListTile(
            title: const Text('Deactivate Session'),
            onTap: () {
              deactivateSessionCallback();
              Navigator.pop(
                  context); // Optionally pop the settings page after deactivating
            },
          ),
          SwitchListTile(
            title: const Text('Continuous Mode On'),
            value: false,
            onChanged: (bool value) {
              // Handle change
            },
          ),
          ListTile(
            title: const Text('Edit Contacts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Edit Message'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmergencyMessageWidget()),
              );
            },
          ),
          StyledElevatedButton(
            text: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LocationSession()),
              );
            },
          ),
        ],
      ),
    );
  }
}
