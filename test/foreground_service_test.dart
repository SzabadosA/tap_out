import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tap_out/foreground_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'foreground_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('ForegroundLocationService', () {
    late ForegroundLocationService service;

    setUp(() {
      service = ForegroundLocationService();
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
  });
}
