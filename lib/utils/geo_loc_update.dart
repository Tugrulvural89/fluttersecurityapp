import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? positionStreamSubscription;

  Dio dio = Dio();
  String apiUrl = "https://yourapi.com/location"; // POST isteğinizi göndereceğiniz URL

  Future<StreamSubscription<Position>?> startListeningPosition(LocationPermission permission) async {
      bool serviceEnabled;
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }


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
          // Only set to true if our app will be started up in the background.
          showBackgroundLocationIndicator: true,
          allowBackgroundLocationUpdates: true,

        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
        );
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        positionStreamSubscription = Geolocator.getPositionStream(locationSettings:  locationSettings)
            .listen((Position? position) {
          if (position != null) _postLocationData(position.latitude, position.longitude);
          print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        }
            );


      } else {
        positionStreamSubscription = null;
      }
      return positionStreamSubscription;
  }

  void _postLocationData(double? lang, double? lat) async {
    try {
      print(lang.toString());
      print(lat.toString());
      // var response = await dio.post(apiUrl, data: {
      //   'latitude': position.latitude,
      //   'longitude': position.longitude,
      // });

    } catch (e) {
      print("Konum gönderme hatası: $e");
    }
  }
}
