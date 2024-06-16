import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tap_out/foreground_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'mock_geolocator_platform.dart';
import 'foreground_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Ensure bindings are initialized

  const MethodChannel wakeLockChannel =
      MethodChannel('com.example.app/wakelock');

  group('ForegroundLocationService', () {
    late ForegroundLocationService service;
    late MockClient mockClient;
    late MockGeolocatorPlatform mockGeolocatorPlatform;

    setUp(() {
      service = ForegroundLocationService();
      mockClient = MockClient();
      mockGeolocatorPlatform = MockGeolocatorPlatform();
      GeolocatorPlatform.instance = mockGeolocatorPlatform;

      // Mock MethodChannel for wake lock
      wakeLockChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'acquireWakeLock') {
          return null; // Simulate successful wake lock acquisition
        } else if (methodCall.method == 'releaseWakeLock') {
          return null; // Simulate successful wake lock release
        }
        return null;
      });
    });

    tearDown(() {
      wakeLockChannel.setMockMethodCallHandler(null);
    });

    test('generateUUID returns a valid UUID', () {
      var uuid = service.generateUUID();
      expect(uuid, isA<String>());
      expect(uuid.length, 36); // UUID length is 36 characters
    });

    test('onStart initializes timer', () {
      final sendPort = IsolateNameServer.lookupPortByName('test_send_port');
      service.onStart(DateTime.now(), sendPort);
      expect(service.timer, isNotNull);
    });

    test('onDestroy cancels timer', () {
      service.timer = Timer.periodic(Duration(seconds: 2), (_) {});
      service.onDestroy(DateTime.now(), null);
      expect(service.timer, isNull);
    });

    test('startSession starts session and initializes timer', () async {
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"status": "success"}', 200));

      await service.startSession();
      expect(service.locationUpdateTimer, isNotNull);
      expect(service.geoLink, contains(service.userId));
    });

    test('sendLocation does not send location if service is disabled',
        () async {
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      await service.sendLocation();
      verifyNever(mockClient.post(any,
          headers: anyNamed('headers'), body: anyNamed('body')));
    });

    test('sendLocation does not send location if permission is denied',
        () async {
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      await service.sendLocation();
      verifyNever(mockClient.post(any,
          headers: anyNamed('headers'), body: anyNamed('body')));
    });
  });
}
