import 'dart:async';
import 'dart:isolate';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundLocationService extends TaskHandler {
  final String serverUrl = 'https://tapout.bit-bowl.com:3040';
  late String userId;
  Timer? timer;
  String geoLink = '';

  ForegroundLocationService() {
    userId = generateUUID();
  }

  String generateUUID() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Future<void> startSession() async {
    try {
      var response = await http.post(
        Uri.parse('$serverUrl/start-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      geoLink = '$serverUrl/track/$userId';
      print('Session start response: ${response.body}');
      timer = Timer.periodic(
          const Duration(seconds: 2), (Timer t) => sendLocation());
    } catch (e) {
      print('Failed to start session: $e');
    }
  }

  Future<void> endSession() async {
    try {
      timer?.cancel();
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

  Future<void> sendLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permissions are denied.');
        return;
      }

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

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    timer = Timer.periodic(
        const Duration(seconds: 15), (Timer t) => sendLocation());
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    timer?.cancel();
    timer = null; // Explicitly set timer to null
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button pressed event
  }

  @override
  void onNotificationPressed() {
    // Handle notification pressed event
  }
}
