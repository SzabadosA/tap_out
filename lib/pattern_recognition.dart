import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

// Notifier class to manage pattern detection state
class PeakDetectionNotifier extends ChangeNotifier {
  bool _isPatternDetected =
      false; // Private variable to hold the pattern detection state

  bool get isPatternDetected =>
      _isPatternDetected; // Getter for pattern detection state

  // Method to update the pattern detection state
  void updatePatternDetection(bool value) {
    _isPatternDetected = value;
    notifyListeners(); // Notify listeners about the state change
  }

  // Method to reset the pattern detection state
  void resetPatternDetection() {
    _isPatternDetected = false;
    notifyListeners(); // Notify listeners about the state change
  }
}

// Widget to handle microphone input and detect specific patterns
class MicPage extends StatefulWidget {
  const MicPage({super.key});

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  Record micListener =
      Record(); // Instance of the Record plugin to manage microphone input
  Timer? timer; // Timer to periodically check microphone input
  bool isRecordingStopped = false; // Flag to track recording state

  double volume = 0.0; // Current volume level
  double minVolume = -45.0; // Minimum volume threshold
  List<double> volumeBuffer = []; // Buffer to store recent volume levels
  List<int> peakTimes = []; // List to store timestamps of detected peaks
  final int maxVolumeToDisplay = 100; // Maximum volume to display

  @override
  void initState() {
    super.initState();
    _initializeMicrophone(); // Initialize the microphone on widget creation
    _startListeningForPatternReset(); // Start listening for pattern reset events
  }

  // Method to start listening for pattern reset events
  void _startListeningForPatternReset() {
    context.read<PeakDetectionNotifier>().addListener(() {
      if (!context.read<PeakDetectionNotifier>().isPatternDetected) {
        // Restart microphone when pattern detection is reset
        restartMicrophone();
      }
    });
  }

  // Method to initialize the microphone
  Future<void> _initializeMicrophone() async {
    if (await micListener.hasPermission()) {
      print("Microphone permission granted");
      await micListener.start(); // Start recording
      startTimer(); // Start the timer to check microphone input periodically
    } else {
      print("Microphone permission denied");
    }
  }

  // Method to start a timer that periodically checks microphone input
  void startTimer() {
    timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) => updateVolume(), // Update volume every 50 milliseconds
    );
  }

  // Method to trigger a vibration pattern
  void _vibrateForTwoSeconds() {
    Vibration.vibrate(pattern: [0, 500, 500, 1000, 500, 2000]);
  }

  // Method to update the current volume level
  Future<void> updateVolume() async {
    if (isRecordingStopped) return;

    Amplitude ampl =
        await micListener.getAmplitude(); // Get the current amplitude
    if (ampl.current > minVolume) {
      setState(() {
        volume = (ampl.current - minVolume) / -minVolume;
        volumeBuffer.add(volume);
        if (volumeBuffer.length > 20) {
          volumeBuffer
              .removeAt(0); // Keep the volume buffer size to a maximum of 20
        }
        detectPeaks(); // Detect peaks in the volume levels
      });
    }
  }

  // Method to detect peaks in the volume levels
  void detectPeaks() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final double averageVolume =
        volumeBuffer.reduce((a, b) => a + b) / volumeBuffer.length;
    final double threshold = averageVolume + 0.5; // Adaptive threshold

    if (volume > threshold) {
      if (peakTimes.isEmpty || now - peakTimes.last > 400) {
        peakTimes.add(now);
        print("Peak detected!");
        if (peakTimes.length > 4) {
          peakTimes.removeAt(0); // Keep the peak times list to a maximum of 4
        }
      }
    }
    if (peakTimes.length == 4) {
      if (peakTimes[3] - peakTimes[0] < 3000) {
        print("Pattern detected!");
        peakTimes.clear();
        context
            .read<PeakDetectionNotifier>()
            .updatePatternDetection(true); // Update pattern detection state
        _vibrateForTwoSeconds(); // Trigger vibration
        stopRecording(); // Stop recording
      }
    }
  }

  // Method to stop recording
  Future<void> stopRecording() async {
    if (!isRecordingStopped) {
      isRecordingStopped = true;
      await micListener.stop(); // Stop the microphone
      timer?.cancel(); // Cancel the timer
      print('Stop recording');
    }
  }

  // Method to restart the microphone
  Future<void> restartMicrophone() async {
    if (await micListener.hasPermission()) {
      setState(() {
        isRecordingStopped = false;
      });
      await micListener.start(); // Start recording
      startTimer(); // Start the timer to check microphone input periodically
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPatternDetected =
        context.watch<PeakDetectionNotifier>().isPatternDetected;

    if (!isPatternDetected && isRecordingStopped) {
      restartMicrophone(); // Restart the microphone if pattern is not detected and recording is stopped
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
