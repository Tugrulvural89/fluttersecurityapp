import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';

class SensorManager {
  late AudioPlayer assetAudioPlayer;
  late StreamSubscription<UserAccelerometerEvent> accelerometerSubscription;
  bool isPlaying = false;

  SensorManager(this.assetAudioPlayer);


  void listenToSensors(double xValue, Function playAlarmSound) {
    accelerometerSubscription = userAccelerometerEvents.listen((event) {
      if (event.x.abs() > xValue || event.y.abs() > xValue || event.z.abs() > xValue) {
        playAlarmSound();
      }
    });

    assetAudioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      if (event == PlayerState.playing) {
        isPlaying = true;
      }
      if (event == PlayerState.stopped) {
        isPlaying = false;
      }
    });
  }

  void dispose() {
    accelerometerSubscription.cancel();
    assetAudioPlayer.dispose();
  }
}
