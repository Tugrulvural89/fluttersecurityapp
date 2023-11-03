import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:security_app/screens/home_screen.dart';
import 'package:security_app/widgets/battery_widget.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


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
  late bool? statusApp;

  void _redirectFunc () {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreen(),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _loadSwitchValue();
  }


  myTest (index) {
    setState(() {
      statusApp =  index == 1 ? true : false;
    });
  }

  _loadSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('switch_value') ?? 0;
    setState(() {
      switchValue = value;
      statusApp = false;
    });
  }

  _saveSwitchValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('switch_value', value);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
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
              },
            ),
            const SizedBox(
              height: 5,
            ),
             Text("${(switchValue == 0) ? 'Not Working' :'Working'}"),
            const SizedBox(
              height: 50,
            ),
            Text('Guard Settings', style: Theme.of(context).textTheme.titleMedium,),
            const SizedBox(
              height: 10,
            ),
            TextButton(onPressed: (){}, child: const Text("Location Settings")),
            const SizedBox(height:5),
            TextButton(onPressed: _redirectFunc, child: const Text("Sound Settings"),),
            Center(child: SizedBox(height: MediaQuery.of(context).size.height*0.20,child: const BatteryPage())),
            const SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }
}

