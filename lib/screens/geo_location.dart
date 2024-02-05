import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/batery_lottie.dart';
import '../widgets/google_maps.dart';

class GeoLocation extends StatefulWidget {
  const GeoLocation({super.key});
  @override
   createState() => GeoLocationState();
}

class GeoLocationState extends State<GeoLocation>{

  late StreamSubscription<Position> serviceStatusStream;

  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState () {
    super.initState();
    _determinePosition();
  }


  @override
  void dispose() {
    serviceStatusStream.cancel();
    super.dispose();
  }
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
   _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();

    bool serviceEnabled;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        if (Platform.isAndroid) {
          await Geolocator.openAppSettings();
        } else if (Platform.isIOS) {
          await Geolocator.openLocationSettings();
        } else {

        }
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    late LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          )
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        pauseLocationUpdatesAutomatically: true,
        timeLimit: const Duration(seconds: 5),
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: true,

      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    serviceStatusStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
              print(latitude);
              print(longitude);
              setState(() {
                if (position != null) {
                  latitude = position.latitude;
                  longitude = position.longitude;
                }
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        children: [
          Expanded(
              flex:1, child: latitude != 0.0 ?
                  GoogleMapsWidget(initialLocation:
                  LatLng(latitude, longitude))
                        : const SizedBox(
                                  child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: LottieAnimations(
                                          lottieFiles:
                                          'assets/animations/1705759952887.json'
                                          ,)
                                        ,)
                                    ,)
            ,)
          ),
        ],
      )
    );
  }
}
