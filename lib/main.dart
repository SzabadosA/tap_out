import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';

void main() {
  runApp(TapOutApp());
}

class TapOutApp extends StatefulWidget {
  @override
  _TapOutAppState createState() => _TapOutAppState();
}

class _TapOutAppState extends State<TapOutApp> {
  Stream<List<int>>? stream;
  List<int> currentSamples = [];
  double threshold = 0.1; // Set threshold for peak detection

  @override
  void initState() {
    super.initState();
    initStream();
  }

  void initStream() {
    stream = MicStream.microphone(
      audioFormat: AudioFormat.ENCODING_PCM_8BIT,
    );
    stream!.listen((samples) {
      double currentPeak = _calculatePeak(samples);
      if (currentPeak > threshold) {
        print("Peak detected!");
      }
      setState(() {
        currentSamples = samples;
      });
    });
  }

  double _calculatePeak(List<int> samples) {
    double maxAmplitude = 0.0;
    for (var sample in samples) {
      double currentAmplitude =
          sample as double; // Adjust range to 0-255 then normalize
      print(currentAmplitude);
      if (currentAmplitude > maxAmplitude) {
        maxAmplitude = currentAmplitude;
      }
    }
    return maxAmplitude;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Mic Peak Detector'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Microphone Peak Detection'),
              if (currentSamples.isNotEmpty)
                Text('Current Peak Level: ${_calculatePeak(currentSamples)}')
            ],
          ),
        ),
      ),
    );
  }
}
