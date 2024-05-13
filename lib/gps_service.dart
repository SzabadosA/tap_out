import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:url_launcher/url_launcher.dart';

class ClickableTextLink extends StatelessWidget {
  final String url;
  final String text;

  ClickableTextLink({required this.url, required this.text});

  void _launchURL() async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launchURL,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue, // Makes it look like a hyperlink
          decoration: TextDecoration.underline, // Underlines the text
        ),
      ),
    );
  }
}

class LocationSession extends StatefulWidget {
  @override
  _LocationSessionState createState() => _LocationSessionState();
}

class _LocationSessionState extends State<LocationSession> {
  String serverUrl = 'https://tapout.bit-bowl.com:3040';
  late String userId;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    userId = generateUUID();
    startSession();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => sendLocation());
  }

  @override
  void dispose() {
    timer?.cancel();
    endSession();
    super.dispose();
  }

  String generateUUID() {
    var uuid = Uuid();
    return uuid.v4();
  }

  Future<void> startSession() async {
    try {
      var response = await http.post(
        Uri.parse('$serverUrl/start-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      print('Session start response: ${response.body}');
    } catch (e) {
      print('Failed to start session: $e');
    }
  }

  Future<void> sendLocation() async {
    try {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var location = {'lat': position.latitude, 'lng': position.longitude};
      var response = await http.post(
        Uri.parse('$serverUrl/update-location'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'location': location}),
      );
      print('Location update response: ${response.body}');
    } catch (e) {
      print('Failed to send location: $e');
    }
  }

  Future<void> endSession() async {
    try {
      var response = await http.post(
        Uri.parse('$serverUrl/end-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      print('Session end response: ${response.body}');
    } catch (e) {
      print('Failed to end session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Session'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => startSession(),
              child: Text('Start Session'),
            ),
            ElevatedButton(
              onPressed: () => endSession(),
              child: Text('End Session'),
            ),
            Text('Session is running for user'),
            ClickableTextLink(
              url: '$serverUrl/track/$userId',
              text: 'GEOLINK',
            ),
          ],
        ),
      ),
    );
  }
}
