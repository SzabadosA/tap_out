import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyMessageWidget extends StatefulWidget {
  const EmergencyMessageWidget({super.key});

  @override
  _EmergencyMessageWidgetState createState() => _EmergencyMessageWidgetState();
}

class _EmergencyMessageWidgetState extends State<EmergencyMessageWidget> {
  final TextEditingController _controller = TextEditingController();
  String _currentMessage = "No message set.";

  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentMessage = prefs.getString('emergency_message') ??
          "I am in danger. Please get help. I am at this location: ";
      _controller.text =
          _currentMessage; // Ensure the controller text is updated
    });
  }

  Future<void> _saveMessage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_message', _controller.text);
    setState(() {
      _currentMessage = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Message"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter your emergency message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMessage,
              child: const Text('Save Message'),
            ),
            const SizedBox(height: 20),
            Text(
              "Current Message: $_currentMessage",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
