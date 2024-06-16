import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const <Widget>[
            Text(
              'Welcome to TapOut SOS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'TapOut SOS is a safety application designed to help you in '
              'emergency situations by sending your real-time location to '
              'your emergency contacts by tapping your phone 4 times. Here, we will '
              'guide you through the app\'s features, how to use them '
              'effectively, and provide important information regarding '
              'the app\'s service and warranty.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'How to Use the App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '\nGrant Permissions:\nWhen '
              'you first open the app, you will be prompted to grant '
              'various permissions. These include access to your microphone, '
              'geolocation, and SMS. These permissions are crucial for the '
              'app to function correctly. Please ensure all requested '
              'permissions are granted. If you encounter any problems, please '
              'check manually that the app has all necessary permissions.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Main Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Sending Emergency Alerts\n\nAutomatic Detection:\nWhen the app '
              'detects a pattern of 4 taps, '
              'it will automatically send an SMS with your current location '
              'to your predefined emergency contacts.\nPlease give this a try'
              ' so you know how to use it in a dangerous situation.'
              '\n\nManual Trigger:\n'
              'You can manually trigger an emergency alert by tapping the '
              '"Activate" button.'
              '\n\nDeactivating SOS Mode:\nTap the '
              '"Deactivate" button in the settings page to turn off the SOS mode.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Managing Emergency Contacts\n\nAdd/Edit Contacts:\nGo to the '
              'settings page and select "Edit Contacts". Here, you can add, '
              'edit, or remove emergency contacts. Ensure that your contacts '
              'are correctly saved as they will be notified during an emergency.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Customizing Emergency Message\n\nSet Emergency Message:\nIn the '
              'settings page, tap on "Edit Message". Enter your personalized '
              'emergency message. This message will be sent along with your '
              'location to your emergency contacts during an alert.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Important Information\n\nPermissions Required\n\nMicrophone:\n'
              'Needed to detect specific voice patterns that trigger the '
              'emergency alert.\n\nLocation:\nRequired to send your real-time '
              'location to your emergency contacts.\n\nSMS:\nNeeded to send '
              'out the emergency messages to your contacts.\n\nForeground '
              'Service\n\nTapOut SOS runs as a foreground service to ensure '
              'it continues to monitor for emergencies even when the app is '
              'not actively in use. You will see a persistent notification '
              'indicating that the app is running in the background.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Exclusion of Guarantee and Warranty\n\nNo Guarantee of Service:\n'
              'TapOut SOS is provided as-is, without any guarantees of '
              'performance. While we strive to provide accurate and reliable '
              'service, we cannot guarantee that the app will function without '
              'errors or interruptions.\n\nNo Warranty:\nWe make no warranties, '
              'whether express or implied, about the reliability, suitability, '
              'or availability of TapOut SOS for any purpose. Use of the app '
              'is at your own risk.\n\nLimitation of Liability:\nIn no event '
              'shall the developers of TapOut SOS be liable for any damages '
              'or losses arising from the use of the app, including but not '
              'limited to direct, indirect, incidental, punitive, or consequential '
              'damages.\n\nUser Responsibility:\nUsers are responsible for '
              'ensuring their emergency contacts are correct and that the '
              'app is set up correctly on their device. Always test the app '
              'after installation to ensure it is working as expected.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '\n\nThank you for using TapOut SOS and stay safe!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
