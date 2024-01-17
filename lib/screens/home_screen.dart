import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
    late AudioPlayer assetAudioPlayer;
    late StreamSubscription<UserAccelerometerEvent> accelerometerSubscription;
    late StreamSubscription<GyroscopeEvent> gyroscopeSubscription;
    bool isPlaying = false;
    bool listIsPlaying = false;
    int listPlayIndex = 100;



    // AccelerationEvent
    double xValue = 0.0;
    // AccelerationEvent True False

    // GyroscopeEvent
    double xValueG = 0.0;
    // GyroscopeEvent True False


    bool batteryStatusWork = false;



    List<String> playList = [
      'audios/default_alarm.mp3',
      'audios/caralarm.mp3',
      'audios/ambulence.mp3',
      'audios/likeclock.mp3',
      'audios/phone.mp3',
      'audios/test1.mp3',
      'audios/test2.mp3',
      'audios/test3.mp3',
      'audios/test4.mp3',
      'audios/test5.mp3',
      'audios/tictac.mp3',
      'audios/police.mp3',
    ];

    String chosenSound = 'audios/default_alarm.mp3';

    _loadSettings () async {
      // Obtain shared preferences.
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        chosenSound = prefs.getString('chosenSound') ?? 'audios/default_alarm.mp3';
        xValue = prefs.getDouble('xValue') ?? 0.0;
        xValueG = prefs.getDouble('xValueG') ?? 0.0;
        batteryStatusWork =  prefs.getBool('batteryStatusWork') ?? false;
      });
    }

    _saveSettings () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('chosenSound', chosenSound);
    }

     bool _setActiveSound (String mySound) {
      if (chosenSound == mySound) {
        return true;
      } else {
        return false;
      }
    }


    @override
    void initState () {
      super.initState();
      assetAudioPlayer = AudioPlayer();
      listenToSensors();
      _loadSettings();
    }

  void playAlarmSound () async {
    if (!isPlaying && batteryStatusWork && mounted) {
      await assetAudioPlayer.play(AssetSource(chosenSound));
      setState(() {
        isPlaying = true;
      });
    }
  }

   @override
   void dispose () {
    accelerometerSubscription.cancel(); // Event listener'ı iptal et
    assetAudioPlayer.dispose();
    super.dispose();
   }

  void stopAlarmSound() {
    if (isPlaying && mounted) {
      assetAudioPlayer.stop();
      setState(() {
        isPlaying = false;
        listIsPlaying = false;
      });
    }
  }

  void playMySound (String myMusic, int index) async {
    if (listIsPlaying==false && !isPlaying) {
      await assetAudioPlayer.play(AssetSource(myMusic));
      setState(() {
        listPlayIndex = index;
        listIsPlaying = true;
      });
    }
  }


  void stopMyPlayMusic(int index) {
    if(listIsPlaying==true) {
      assetAudioPlayer.stop();
      setState(() {
        listPlayIndex = index;
        listIsPlaying = false;
        isPlaying= false;
      });
    }
  }


  void listenToSensors() {

    gyroscopeSubscription = gyroscopeEvents.listen((event) {
          print(event.x.abs());
          print(event.y.abs());
          print(event.z.abs());
      });
    accelerometerSubscription = userAccelerometerEvents.listen((event) {
      if (event.x.abs()> xValue || event.y.abs() > xValue || event.z.abs()> xValue) {
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
            return  MyHomePage(title: 'Secure Guard',);
          }));
        },),
        title: Text('Sound Settings'),

      ),
      body:  SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.alarm, color: Colors.orange),
                      Text("alarımı görmek için salla"),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: IconButton(
                      onPressed: () {stopAlarmSound();},
                      icon:  isPlaying ? const Icon(FontAwesomeIcons.stop) : const Icon(FontAwesomeIcons.play),
                    ),
                  ),
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: ListView.builder(
                  itemCount: playList.length,
                  itemBuilder: (context, index) {
                     Color leadIconColor = Colors.black54;
                     Icon trailIcon =  const Icon(FontAwesomeIcons.play);
                    if (index == listPlayIndex) {
                       leadIconColor = listIsPlaying ? Colors.green : Colors.black54;
                       trailIcon =  listIsPlaying ? const Icon(FontAwesomeIcons.stop) : const Icon(FontAwesomeIcons.play);
                    }
                    return ListTile(
                      leading:  Checkbox(
                        value: _setActiveSound(playList[index]),
                        tristate: true,
                        onChanged: (bool? newValue)  {
                            if (newValue != null) {
                              setState(() {
                                 chosenSound = playList[index];
                              });
                              _saveSettings();
                            }
                        },
                      ),
                      title: Icon(FontAwesomeIcons.music, color: leadIconColor),
                      subtitle: Text(playList[index]),
                      trailing: IconButton(
                        icon: trailIcon,
                        onPressed: () {
                          setState(() {
                            listPlayIndex = index;
                          });
                          if (listIsPlaying==false) {
                            playMySound(playList[index], index);
                          } else {
                            stopMyPlayMusic(index);
                          }
                      },
                      ),
                    );
                  },

                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}