import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import 'batery_lottie.dart';


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
    return Column(
      children: [
        _batteryState == BatteryState.charging ? const BatteryLottie() : const SizedBox(height: 5),
        Center(
          child: Text(
            _batteryState == BatteryState.charging ? 'True' : 'False'
          ),
        ),
      ],
    );
  }

}