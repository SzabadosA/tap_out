import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Page'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Deactivate Session'),
            onTap: () {
              // Deactivate session
            },
          ),
          SwitchListTile(
            title: Text('Continuous Mode On'),
            value: false,
            onChanged: (bool value) {
              // Handle change
            },
          ),
          ListTile(
            title: Text('Edit Contacts'),
            onTap: () {
              // Navigate to edit contacts page
            },
          ),
          ListTile(
            title: Text('Edit Message'),
            onTap: () {
              // Navigate to edit message page
            },
          ),
          ...List.generate(
              5, (index) => ListTile(title: Text('Contact $index'))),
        ],
      ),
    );
  }
}
