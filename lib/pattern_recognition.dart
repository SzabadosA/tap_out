import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class PeakDetectionNotifier extends ChangeNotifier {
  bool _isPatternDetected = false;

  bool get isPatternDetected => _isPatternDetected;

  void updatePatternDetection(bool value) {
    _isPatternDetected = value;
    notifyListeners();
  }

  void resetPatternDetection() {
    _isPatternDetected = false;
    notifyListeners();
  }
}

class MicPage extends StatefulWidget {
  const MicPage({Key? key}) : super(key: key);

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  Record micListener = Record();
  Timer? timer;

  double volume = 0.0;
  double minVolume = -45.0;
  List<double> volumeBuffer = [];
  List<int> peakTimes = [];
  final int maxVolumeToDisplay = 100;

  @override
  void initState() {
    super.initState();
    _initializeMicrophone();
  }

  Future<void> _initializeMicrophone() async {
    if (await micListener.hasPermission()) {
      print("Microphone permission granted");
      await micListener.start();
      startTimer();
    } else {
      print("Microphone permission denied");
    }
  }

  void startTimer() {
    timer ??= Timer.periodic(
        const Duration(milliseconds: 50), (timer) => updateVolume());
  }

  void _vibrateForTwoSeconds() {
    Vibration.vibrate(pattern: [500, 500, 500, 1000, 500, 2000]);
  }

  Future<void> updateVolume() async {
    Amplitude ampl = await micListener.getAmplitude();
    if (ampl.current > minVolume) {
      setState(() {
        volume = (ampl.current - minVolume) / -minVolume;
        volumeBuffer.add(volume);
        if (volumeBuffer.length > 20) {
          volumeBuffer.removeAt(0);
        }
        detectPeaks();
      });
    }
  }

  void detectPeaks() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (volume > 0.8) {
      if (peakTimes.isEmpty || now - peakTimes.last > 300) {
        peakTimes.add(now);
        print("Peak detected at $now");
        if (peakTimes.length > 3) {
          peakTimes.removeAt(0);
        }
      }
    }
    if (peakTimes.length == 3) {
      if (peakTimes[2] - peakTimes[0] < 2000) {
        print("Pattern detected!");
        peakTimes.clear();
        context.read<PeakDetectionNotifier>().updatePatternDetection(true);
        _vibrateForTwoSeconds();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Return an empty container as this widget is not meant to display UI.
  }

  @override
  void dispose() {
    timer?.cancel();
    micListener.stop();
    super.dispose();
  }
}
