import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';

class SensorManager {
  late StreamSubscription<UserAccelerometerEvent> accelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> gyroscopeSubscription;
  double _volumeListenerValue = 1;
  bool isPlaying; // audio playing status
  String chosenSound; // Alarm ses dosyası yolu
  bool batteryStatusWork;
  int switchValue; // guard off
  double xValue; // acceleration cookie value
  double xGvalue;
  bool secValueUpdate; // pass info updated
  AudioPlayer assetAudioPlayer;
  SensorManager(
      {required this.assetAudioPlayer, required this.chosenSound, required this.xValue,
        required this.batteryStatusWork, required this.switchValue,
        required this.secValueUpdate, required this.isPlaying, required this.xGvalue,
      });


  // Play sound if shake or movement device recently
  // this function work into sensor function
  void playAlarmSound () async {
    if (batteryStatusWork) {
      if (!isPlaying && switchValue == 1) {
        isPlaying = true;
        await assetAudioPlayer.play(AssetSource(chosenSound));
        assetAudioPlayer.setReleaseMode(ReleaseMode.loop);
      }
    }
    if (!batteryStatusWork) {
      if (!isPlaying && switchValue == 1 ) {
        isPlaying = true;
        await assetAudioPlayer.play(AssetSource(chosenSound));
        assetAudioPlayer.setReleaseMode(ReleaseMode.loop);
      }
    }
  }


  void stopAlarmSound() {
    if (isPlaying) {
      assetAudioPlayer.stop();
        isPlaying = false;
    }
  }

  void listenToSensors() {
    VolumeController().listener((volume) {
      VolumeController().getVolume().then((value) {
        if (value <= 0.7) {
          VolumeController().setVolume(1);
        }
      });
    });
    gyroscopeSubscription = gyroscopeEvents.listen((event) {
      //TODO:SUBS CANCEL ROUTERLARDA CALISMIYOR
      //print("Gyroscope event X : ${event.x.abs()}");
      //print("Gyroscope event Y : ${event.y.abs()}");
      if (event.x.abs() > xGvalue || event.y.abs() > xGvalue) {
        if(!isPlaying && switchValue == 1  && secValueUpdate) {
          playAlarmSound();

        }
      }
    });
    accelerometerSubscription = userAccelerometerEvents.listen((event) {
      //TODO:SUBS CANCEL ROUTERLARDA CALISMIYOR
      //print("Accelerometer event X : ${event.x.abs()}");
      //print("Accelerometer event Y : ${event.y.abs()}");
      if (event.x.abs()> xValue || event.y.abs() > xValue) {
        if(!isPlaying && switchValue == 1  && secValueUpdate) {
          playAlarmSound();
        }
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
    gyroscopeSubscription.cancel();
    assetAudioPlayer.dispose();
    VolumeController().removeListener();
  }
}
