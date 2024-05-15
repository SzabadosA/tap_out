import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class LocationService {
  final String serverUrl = 'https://tapout.bit-bowl.com:3040';
  late String userId;
  Timer? timer;
  String geoLink = '';

  LocationService() {
    userId = generateUUID();
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
      geoLink = '$serverUrl/track/$userId';
      timer =
          Timer.periodic(Duration(seconds: 15), (Timer t) => sendLocation());
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
    } catch (e) {
      print('Failed to send location: $e');
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
    } catch (e) {
      print('Failed to end session: $e');
    }
  }

  String getGeoLink() {
    return geoLink;
  }
}
