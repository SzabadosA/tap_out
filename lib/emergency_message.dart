import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Stateful widget for managing the emergency message
class EmergencyMessageWidget extends StatefulWidget {
  const EmergencyMessageWidget({super.key});

  @override
  _EmergencyMessageWidgetState createState() => _EmergencyMessageWidgetState();
}

class _EmergencyMessageWidgetState extends State<EmergencyMessageWidget> {
  final TextEditingController _controller =
      TextEditingController(); // Controller to manage text input
  String _currentMessage = "No message set."; // Default message to display

  @override
  void initState() {
    super.initState();
    _loadMessage(); // Load the saved message when the widget is initialized
  }

  // Load the saved emergency message from shared preferences
  Future<void> _loadMessage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentMessage = prefs.getString('emergency_message') ??
          "I am in danger. Please get help. I am at this location: "; // Default message if none is saved
      _controller.text =
          _currentMessage; // Ensure the controller text is updated
    });
  }

  // Save the entered emergency message to shared preferences
  Future<void> _saveMessage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_message', _controller.text);
    setState(() {
      _currentMessage = _controller.text; // Update the current message display
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Message"), // App bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for the body content
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller, // Controller for managing text input
              decoration: const InputDecoration(
                labelText: 'Enter your emergency message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3, // Allow multiple lines of text
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _saveMessage, // Save the message when the button is pressed
              child: const Text('Save Message'),
            ),
            const SizedBox(height: 20),
            Text(
              "Current Message: \n\n $_currentMessage \n <Link to location>", // Display the current saved message
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
