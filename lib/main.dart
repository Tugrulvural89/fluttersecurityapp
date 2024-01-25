import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:security_app/screens/geo_location.dart';
import 'package:security_app/screens/home_screen.dart';
import 'package:security_app/screens/set_password.dart';
import 'package:security_app/services/locations.dart';
import 'package:security_app/utils/icon_copy_text.dart';
import 'package:security_app/widgets/battery_widget.dart';
import 'package:security_app/widgets/google_maps.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:security_app/screens/guard_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'manager/sensor_manager.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:dio/dio.dart';

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
  int switchValue = 0;
  int value = 0;
  // AccelerationEvent
   double xValue = 1.0;
  // AccelerationEvent True False
  // GyroscopeEvent
   double xValueG = 3.0;
  // GyroscopeEvent True False
  String chosenSound = 'audios/default_alarm.mp3';
  bool batteryStatusWork = true;
  bool isPlaying = false;
  bool isPasswordIncorrect = false;
  double _volumeListenerValue = 1;
  // this is location post and get api header auth values
  String userId = '';
  String userPass = '';
  ApiService apiService = ApiService();
  late String secValue;
  bool secValueUpdate = false;
  late Tuple2 idAndPass;
  late bool userStatus;
  late bool userCreated;
  late SensorManager sensorManager;

  @override
  void initState() {
    super.initState();
    sensorWork();
    checkPass();
    userCheck();
  }

  void userCheck() async {
    idAndPass = await apiService.generateLocationPassword();
    setState(() {
       userId = idAndPass.item1;
       userPass = idAndPass.item2;
     });
    userCreated = await apiService.checkAndCreate();
  }

  void sensorWork() async {
    await _loadSwitchValue();
    sensorManager = SensorManager(
        assetAudioPlayer: AudioPlayer(),
        xValue: xValue,
        batteryStatusWork: batteryStatusWork,
        switchValue: value,
        secValueUpdate: secValueUpdate,
        isPlaying: isPlaying,
        chosenSound: chosenSound);
     sensorManager.listenToSensors();
  }

  void stopSound() {
    sensorManager.stopAlarmSound();
  }



  // check user settings instaces. if user delete cache or
  // temp data this settings need set default value
  _loadSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchValue = value;
      value = prefs.getInt('switch_value') ?? 0;
      chosenSound = prefs.getString('chosenSound') ?? 'audios/default_alarm.mp3';
      xValue = prefs.getDouble('xValue') ?? 1.0;
      xValueG = prefs.getDouble('xValueG') ?? 3.0;
      batteryStatusWork =  prefs.getBool('batteryStatusWork') ?? true;
    });
  }

  // secure function on / off settings to save on temp
  _saveSwitchValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('switch_value', value);
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

  @override
  void dispose() {
    sensorManager.dispose();
    super.dispose();
  }


  // last step quit alarm if user not save any pass before it shouldn't work
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
                    // stop alarm add here
                      stopSound();
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
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const GeoLocation()));
              }, child:  Text("Location", style: TextStyle(
                  color:  (switchValue == 0) ?
                  Colors.deepPurpleAccent :
                  Colors.blueGrey),)),
              const SizedBox(height:5),
              TextButton(onPressed: () {
                if (!isPlaying && switchValue != 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
                    return const HomeScreen();
                  }));
                }
              }, child:  Text("Sound Settings" , style: TextStyle(
                  color:  (switchValue == 0) ?
                  Colors.deepPurpleAccent :
                  Colors.blueGrey),),),
              Center(
                  child: SizedBox(height: MediaQuery.of(context).size.height* 0.09,
                      child: const BatteryPage())),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CopyableText(text: userId),
                  Text('User ID : $userId',
                    softWrap: true,
                    textAlign: TextAlign.center,)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CopyableText(text: userPass),
                  Text('User Pass : $userPass',
                    softWrap: true,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
              TextButton(child: Text(
                'Check online Location from ${apiService.baseUrl}',
                softWrap: true,
                textAlign: TextAlign.center,
              ),
                  onPressed: () async =>_launchUrl(apiService.baseUrl)),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl(baseUrl) async {
  if (!await launchUrl(Uri.parse(baseUrl))) {
    throw Exception('Could not launch');
  }
}


