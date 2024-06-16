import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() {
    return super.noSuchMethod(Invocation.method(#isLocationServiceEnabled, []),
        returnValue: Future.value(true)) as Future<bool>;
  }

  @override
  Future<LocationPermission> checkPermission() {
    return super.noSuchMethod(Invocation.method(#checkPermission, []),
            returnValue: Future.value(LocationPermission.always))
        as Future<LocationPermission>;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    return super.noSuchMethod(
      Invocation.method(
          #getCurrentPosition, [], {#locationSettings: locationSettings}),
      returnValue: Future.value(Position(
        latitude: 37.4219983,
        longitude: -122.084,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 5.0,
        headingAccuracy: 5.0,
      )),
    ) as Future<Position>;
  }
}
