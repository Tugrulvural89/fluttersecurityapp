import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:security_app/screens/home_screen.dart';
import 'package:security_app/screens/set_password.dart';
import 'package:security_app/widgets/battery_widget.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:security_app/screens/guard_settings.dart';
import 'manager/sensor_manager.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        sliderTheme: const SliderThemeData(
          valueIndicatorColor: Colors.purple,
          valueIndicatorTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Secure Your Phone'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SensorManager sensorManager;
  int switchValue = 0;
  late bool? statusApp;
  int value = 0;
  // AccelerationEvent
   double xValue = 0.0;
  // AccelerationEvent True False

  // GyroscopeEvent
   double xValueG = 0.0;
  // GyroscopeEvent True False

  String chosenSound = 'audios/default_alarm.mp3';
  bool batteryStatusWork = false;
  bool isPlaying = false;

  bool isPasswordIncorrect = false;
  late AudioPlayer assetAudioPlayer;
  late StreamSubscription<UserAccelerometerEvent> accelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> gyroscopeSubscription;
 double _volumeListenerValue = 1;

  late String secValue;
  bool secValueUpdate = false;

  void _redirectFunc () {
    if (!isPlaying && switchValue != 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
        return const HomeScreen();
      }));
    }
  }


  @override
  void initState() {
    super.initState();
    assetAudioPlayer = AudioPlayer();
    listenToSensors();
    _loadSwitchValue();
    checkPass();
  }



  // V
  void playAlarmSound () async {
    if (batteryStatusWork) {
      if (!isPlaying && switchValue == 1) {
        setState(() {
          isPlaying = true;
        });
        await assetAudioPlayer.play(AssetSource(chosenSound));
        assetAudioPlayer.setReleaseMode(ReleaseMode.loop);
      }
    }
    if (!batteryStatusWork) {
      if (!isPlaying && switchValue == 1 ) {
        setState(() {
          isPlaying = true;
        });
        await assetAudioPlayer.play(AssetSource(chosenSound));
        assetAudioPlayer.setReleaseMode(ReleaseMode.loop);
      }
    }
  }
  void stopAlarmSound() {
    if (isPlaying) {
      assetAudioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    }
  }


  Future<String?> checkPass() async {
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final FlutterSecureStorage secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    String? storedPassword = await secureStorage.read(key: 'user_password');

      if (storedPassword != null) {
        setState(() {
          secValueUpdate = true;
          secValue = storedPassword;
          });
      }

    return storedPassword;
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

      if (event.x.abs()> 2 || event.y.abs() > 2) {
        if(!isPlaying && switchValue == 1  && secValueUpdate) {
          playAlarmSound();

        }
      }
    });
    accelerometerSubscription = userAccelerometerEvents.listen((event) {
      if (event.x.abs()> xValue || event.y.abs() > xValue) {
        if(!isPlaying && switchValue == 1  && secValueUpdate) {
          //playAlarmSound();
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
  @override
  void dispose() {
    accelerometerSubscription.cancel(); // Event listener'ı iptal et
    assetAudioPlayer.dispose();
    VolumeController().removeListener();
    super.dispose();
  }


  myTest (index) {
    setState(() {
      statusApp =  index == 1 ? true : false;
    });
  }

  _loadSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchValue = value;
      statusApp = false;
      value = prefs.getInt('switch_value') ?? 0;
      chosenSound = prefs.getString('chosenSound') ?? 'audios/default_alarm.mp3';
      xValue = prefs.getDouble('xValue') ?? 0.0;
      xValueG = prefs.getDouble('xValueG') ?? 0.0;
      batteryStatusWork =  prefs.getBool('batteryStatusWork') ?? false;
    });
  }

  _saveSwitchValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('switch_value', value);
  }



  Future<void> showPasswordPopup(BuildContext context) async {
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final FlutterSecureStorage secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    String? storedPassword = await secureStorage.read(key: 'user_password');

    final TextEditingController passwordController = TextEditingController();

    if (!mounted) return;
    bool isPasswordIncorrect = false; // Flag to track incorrect password attempts
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // To make the dialog compact
                children: [
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter 4-digit password',
                      errorText: isPasswordIncorrect ? 'Incorrect password' : 'Right',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    if (passwordController.text == storedPassword) {
                      // Password is correct
                      stopAlarmSound();
                      Navigator.of(context).pop();
                    } else {
                      // Password is incorrect, show error
                      setState(() {
                        isPasswordIncorrect = true;
                      });

                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.deepPurple,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title,style: const TextStyle(color: Colors.white),),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Text(
                'Guard Status', style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 20,
              ),
              ToggleSwitch(
                minWidth: 90.0,
                minHeight: 70.0,
                initialLabelIndex: switchValue,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.deepPurpleAccent,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                icons: const [
                  FontAwesomeIcons.lightbulb,
                  FontAwesomeIcons.solidLightbulb,
                ],
                iconSize: 30.0,
                activeBgColors: const [[Colors.black, Colors.black26],
                  [Colors.yellow, Colors.orange]],
                animate: true, // with just animate set to true, default curve = Curves.easeIn
                curve: Curves.bounceInOut, // animate must be set to true when using custom curve
                onToggle: (index) {
                  setState(() {
                    switchValue = index ?? 0;
                  });
                    _saveSwitchValue(index ?? 0);

                    if (switchValue==1) {
                        if (!secValueUpdate){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
                            return const SetPasswordView();
                          }));
                        } else {
                          screenLock(
                            context: context,
                            correctString: secValue,
                            canCancel: false,
                          );
                        }
                    }
                    if (switchValue == 0 && isPlaying) {
                      showPasswordPopup(context);
                    }
                },
              ),
              const SizedBox(
                height: 5,
              ),
               Text((switchValue == 0) ? 'Not Working' :'Working'),
              const SizedBox(
                height: 50,
              ),
              TextButton(onPressed: () {
                if (switchValue!=1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GuardSettings(),));
                }

              }, child: Text("Guard Settings", style: TextStyle(
                  color:  (switchValue == 0) ?
                      Colors.deepPurpleAccent :
                          Colors.blueGrey),),),
              const SizedBox(
                height: 10,
              ),
              TextButton(onPressed: (){}, child:  Text("Location Settings", style: TextStyle(
                  color:  (switchValue == 0) ?
                  Colors.deepPurpleAccent :
                  Colors.blueGrey),)),
              const SizedBox(height:5),
              TextButton(onPressed: _redirectFunc, child:  Text("Sound Settings" , style: TextStyle(
                  color:  (switchValue == 0) ?
                  Colors.deepPurpleAccent :
                  Colors.blueGrey),),),
              Center(
                  child: SizedBox(height: MediaQuery.of(context).size.height* 0.15,
                      child: const BatteryPage())),
              const SizedBox(height: 5,),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * 0.75 ,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_outlined, color: Colors.orange,),
                    Expanded(
                      child: Text("You can secure your phone unwanted movement!",
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ) ,
              )
            ],
          ),
        ),
      ),
    );
  }
}

