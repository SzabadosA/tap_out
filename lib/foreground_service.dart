import 'dart:async';
import 'dart:isolate';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/services.dart';

class ForegroundLocationService extends TaskHandler {
  final String serverUrl = 'https://tapout.bit-bowl.com:3040';
  late String userId;
  Timer? timer;
  Timer? locationUpdateTimer;
  String geoLink = '';
  final MethodChannel _methodChannel =
      const MethodChannel('com.example.app/wakelock');

  ForegroundLocationService() {
    userId =
        generateUUID(); // Generate a unique user ID when the service is instantiated
  }

  // Generate a unique UUID
  String generateUUID() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  // Start a new session by acquiring a wake lock and starting location updates
  Future<void> startSession() async {
    try {
      await _methodChannel.invokeMethod('acquireWakeLock');
      print('Wake lock acquired in startSession');
      var response = await http.post(
        Uri.parse('$serverUrl/start-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      geoLink = '$serverUrl/track/$userId'; // Set the tracking link
      print('Session start response: ${response.body}');
      startLocationUpdates(); // Start periodic location updates
    } catch (e) {
      print('Failed to start session: $e');
    }
  }

  // Start periodic location updates
  void startLocationUpdates() {
    locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 2), (Timer t) => sendLocation());
  }

  // End the current session by releasing the wake lock and stopping location updates
  Future<void> endSession() async {
    try {
      await _methodChannel.invokeMethod('releaseWakeLock');
      print('Wake lock released in endSession');
      locationUpdateTimer?.cancel(); // Stop the location update timer
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

  // Stop location updates without ending the session
  void stopLocationUpdates() {
    locationUpdateTimer?.cancel();
  }

  // Send the current location to the server
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

  // Called when the foreground task starts
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    print('Foreground task started at $timestamp');
    timer = Timer.periodic(
        const Duration(seconds: 45), (Timer t) => _logTime(sendPort));
  }

  // Log the current time and send it through the send port
  void _logTime(SendPort? sendPort) {
    final currentTime = DateTime.now();
    print('Wake app at: $currentTime');
    sendPort?.send('Wake app at: $currentTime');
  }

  // Called on each repeat event, logging the timestamp
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    print('onRepeatEvent called at $timestamp');
    sendPort?.send('onRepeatEvent called at $timestamp');
  }

  // Called when the foreground task is destroyed
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    print('Foreground task destroyed at $timestamp');
    timer?.cancel(); // Cancel the periodic timer
    locationUpdateTimer?.cancel(); // Cancel the location update timer
    timer = null; // Explicitly set timer to null
  }

  // No action needed when notification button is pressed as buttons are removed
  @override
  void onNotificationButtonPressed(String id) {}

  // Log when the notification is pressed
  @override
  void onNotificationPressed() {
    print('Notification pressed');
  }
}
