import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';



class BatteryLottie extends StatelessWidget {
  const BatteryLottie({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height*0.10,
          child: Lottie.asset('assets/animations/animation_lo7a6jsk.json'),
        ),
      ),
    );
  }
}