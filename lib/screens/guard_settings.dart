import 'dart:async';
import 'package:flutter/material.dart';
import 'package:security_app/screens/set_password.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

class GuardSettings extends StatefulWidget {
  const GuardSettings({super.key});
  @override
  createState()=> _GuardSettingsWidgetState();
}

class _GuardSettingsWidgetState extends State<GuardSettings> {
  // AccelerationEvent
  double xValue = 0.0;
  // GyroscopeEvent
  double xValueG = 0.0;
  bool batteryStatusWork = false;
  // loading lottie animation check
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = false;
      xValue = prefs.getDouble('xValue') ?? 0.0;
      xValueG = prefs.getDouble('xValueG') ?? 0.0;
      batteryStatusWork =  prefs.getBool('batteryStatusWork') ?? false;
    });
  }

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('xValue', xValue);
    await prefs.setDouble('xValueG', xValueG);
    await prefs.setBool('batteryStatusWork', batteryStatusWork );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
              return const MyHomePage(title: 'Secure Guards',);
            }));
          }, icon: Icon(Icons.arrow_back)
          ,)
        ,title: const Text('Settings'),),
      body: isLoading ? _buildLoading() : _baseScreen(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.10,
          child: Lottie.asset('assets/animations/animation_loader_settings.json'),
        ),
      ),
    );
  }
  Widget _baseScreen() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          const Text("low value more sensitive. close zero."),
          const Text("Sarjdayken çalışsın"),
          Checkbox(
              value: batteryStatusWork,
              onChanged: (newBool) {
                setState(() {
                  batteryStatusWork = newBool ?? false;
                });
                _saveSettings();
              }),
          const Text("x yatay eksende hızlanma"),
          Slider(
              value: xValue,
              min: 0.0,
              max: 1.0,
              divisions: 8,
              label: "X Value: ${xValue.toStringAsFixed(2)}",
              onChanged: (newValue){
                setState(() {
                  xValue = newValue;
                });
                _saveSettings();
              }
          ),
          const Text("x ekseninde masa üstünde dönme "),
          Slider(
              value: xValueG,
              min: 0.0,
              max: 1.0,
              divisions: 8,
              label: "X Value: ${xValueG.toStringAsFixed(2)}",
              onChanged: (newValue){
                setState(() {
                  xValueG = newValue;
                });
                _saveSettings();
              }
          ),
          TextButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SetPasswordView()));
          }, child: const Text("Password Settings")),
          const SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }


}