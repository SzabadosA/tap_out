import 'package:flutter_test/flutter_test.dart';
import 'package:tap_out/pattern_recognition.dart';

void main() {
  group('PeakDetectionNotifier', () {
    test('initial state should be false', () {
      final notifier = PeakDetectionNotifier();
      expect(notifier.isPatternDetected, false);
    });

    test('updatePatternDetection should update state', () {
      final notifier = PeakDetectionNotifier();
      notifier.updatePatternDetection(true);
      expect(notifier.isPatternDetected, true);
    });

    test('resetPatternDetection should reset state to false', () {
      final notifier = PeakDetectionNotifier();
      notifier.updatePatternDetection(true);
      notifier.resetPatternDetection();
      expect(notifier.isPatternDetected, false);
    });
  });
}
