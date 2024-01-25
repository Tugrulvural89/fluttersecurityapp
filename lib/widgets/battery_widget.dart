import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import 'batery_lottie.dart';

// check device in battery or not
// we will use this option on settings and condition alarm state
class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  final Battery _battery= Battery();

  late BatteryState? _batteryState;

  @override
  void initState() {
    super.initState();
    _getBatteryStatus();
    _batteryState = null;
    _checkListBattery();
  }

  void _getBatteryStatus () async {
    final batteryState =  await _battery.batteryState;
    setState(() {
      _batteryState = batteryState;
    });
  }

  void _checkListBattery () async {
    _battery.onBatteryStateChanged.listen((event) {
        _batteryState = event;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
        _batteryState == BatteryState.charging ?
              const LottieAnimations(
                lottieFiles: 'assets/animations/animation_lo7a6jsk.json',)
        // if you want to change non battery status animation add LottieAnimations
                          : const Text('No charging now'),
        // if you want to print out battery status true false
        // Center(
        //   child: Text(
        //     _batteryState == BatteryState.charging ? 'True' : 'False'
        //   ),
        // ),
    );
  }

}
