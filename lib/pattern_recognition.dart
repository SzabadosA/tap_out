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
  const MicPage({super.key});

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  Record micListener = Record();
  Timer? timer;
  bool isRecordingStopped = false;

  double volume = 0.0;
  double minVolume = -45.0;
  List<double> volumeBuffer = [];
  List<int> peakTimes = [];
  final int maxVolumeToDisplay = 100;

  @override
  void initState() {
    super.initState();
    _initializeMicrophone();
    _startListeningForPatternReset();
  }

  void _startListeningForPatternReset() {
    // Listen for pattern reset changes
    context.read<PeakDetectionNotifier>().addListener(() {
      if (!context.read<PeakDetectionNotifier>().isPatternDetected) {
        // Restart microphone when pattern detection is reset
        restartMicrophone();
      }
    });
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
    timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) => updateVolume(),
    );
  }

  void _vibrateForTwoSeconds() {
    Vibration.vibrate(pattern: [0, 500, 500, 1000, 500, 2000]);
  }

  Future<void> updateVolume() async {
    if (isRecordingStopped) return;

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
    if (volume > 0.94) {
      if (peakTimes.isEmpty || now - peakTimes.last > 400) {
        peakTimes.add(now);
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
        stopRecording();
      }
    }
  }

  Future<void> stopRecording() async {
    if (!isRecordingStopped) {
      isRecordingStopped = true;
      await micListener.stop();
      timer?.cancel();
      print('Stop recording');
    }
  }

  Future<void> restartMicrophone() async {
    if (await micListener.hasPermission()) {
      setState(() {
        isRecordingStopped = false;
      });
      await micListener.start();
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPatternDetected =
        context.watch<PeakDetectionNotifier>().isPatternDetected;

    if (!isPatternDetected && isRecordingStopped) {
      restartMicrophone();
    }

    return Container(); // Return an empty container as this widget is not meant to display UI.
  }

  @override
  void dispose() {
    timer?.cancel();
    micListener.stop();
    super.dispose();
  }
}
