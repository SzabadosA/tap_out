import 'package:flutter/material.dart';

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
              // Navigate to edit contacts page
            },
          ),
          ListTile(
            title: const Text('Edit Message'),
            onTap: () {
              // Navigate to edit message page
            },
          ),
          const SizedBox(height: 150),
          ...List.generate(
              5, (index) => ListTile(title: Text('Contact $index'))),
        ],
      ),
    );
  }
}
