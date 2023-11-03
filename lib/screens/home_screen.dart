import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  final assetAudioPlayer = AudioPlayer();
   bool isPlaying = false;
   bool listIsPlaying = false;
   int listPlayIndex = 100;


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



  @override
  void initState () {
    super.initState();
    listenToSensors();
  }

  void playAlarmSound () async {
    if (isPlaying==false) {
      await assetAudioPlayer.play(AssetSource('audios/default_alarm.mp3'));
      setState(() {
        isPlaying = true;
      });
    }
  }


   @override
   void dispose () {
      assetAudioPlayer.dispose();
     super.dispose();
   }

  void stopAlarmSound() {
      assetAudioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
  }

  void playMySound (String myMusic, int index) async {
    if (listIsPlaying==false) {
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
      });
    }
  }


  void listenToSensors() {
    userAccelerometerEvents.listen((event) {
      if (event.x.abs()>0.5 || event.y.abs()>0.5 || event.z.abs()>0.5) {
        playAlarmSound();
      }
    });
    assetAudioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      print(event);
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
      appBar: AppBar(),
      body:  SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 50,
                child: IconButton(
                    onPressed: () {stopAlarmSound();},
                    icon:  isPlaying ? Icon(FontAwesomeIcons.stop) :Icon(FontAwesomeIcons.play),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: ListView.builder(
                  itemCount: playList.length,
                  itemBuilder: (context, index) {
                     Color leadIconColor = Colors.black54;
                     Icon trailIcon =  Icon(FontAwesomeIcons.play);
                    if (index == listPlayIndex) {
                       leadIconColor = listIsPlaying ? Colors.green : Colors.black54;
                       trailIcon =  listIsPlaying ? Icon(FontAwesomeIcons.stop) :Icon(FontAwesomeIcons.play);
                    }
                    return ListTile(
                      leading:  Icon(FontAwesomeIcons.music, color: leadIconColor),
                      title: Text(playList[index]),
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