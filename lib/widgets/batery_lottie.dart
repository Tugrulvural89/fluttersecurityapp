import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


//all lottie json file work dynamically under this widget
class LottieAnimations extends StatelessWidget {
  final String lottieFiles;
  const LottieAnimations({super.key, required this.lottieFiles});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height*0.10,
          child: Lottie.asset(lottieFiles),
        ),
      ),
    );
  }
}
