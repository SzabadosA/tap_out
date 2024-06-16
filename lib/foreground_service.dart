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
    userId = generateUUID();
  }

  String generateUUID() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Future<void> startSession() async {
    try {
      await _methodChannel.invokeMethod('acquireWakeLock');
      print('Wake lock acquired in startSession');
      var response = await http.post(
        Uri.parse('$serverUrl/start-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      geoLink = '$serverUrl/track/$userId';
      print('Session start response: ${response.body}');
      startLocationUpdates();
    } catch (e) {
      print('Failed to start session: $e');
    }
  }

  void startLocationUpdates() {
    locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 2), (Timer t) => sendLocation());
  }

  Future<void> endSession() async {
    try {
      await _methodChannel.invokeMethod('releaseWakeLock');
      print('Wake lock released in endSession');
      locationUpdateTimer?.cancel();
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

  void stopLocationUpdates() {
    locationUpdateTimer?.cancel();
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
    print('Foreground task started at $timestamp');
    timer = Timer.periodic(
        const Duration(seconds: 45), (Timer t) => _logTime(sendPort));
  }

  void _logTime(SendPort? sendPort) {
    final currentTime = DateTime.now();
    print('Wake app at: $currentTime');
    sendPort?.send('Wake app at: $currentTime');
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    print('onRepeatEvent called at $timestamp');
    sendPort?.send('onRepeatEvent called at $timestamp');
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    print('Foreground task destroyed at $timestamp');
    timer?.cancel();
    locationUpdateTimer?.cancel();
    timer = null; // Explicitly set timer to null
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('Notification button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    print('Notification pressed');
  }
}
