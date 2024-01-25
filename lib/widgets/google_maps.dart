import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsWidget extends StatefulWidget {
  final LatLng initialLocation;
  const GoogleMapsWidget({super.key,
     required this.initialLocation});

  @override
  State<GoogleMapsWidget> createState() => GoogleMapsWidgetState();
}

class GoogleMapsWidgetState extends State<GoogleMapsWidget> {

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();


  @override
  Widget build(BuildContext context) {
      CameraPosition kGooglePlex = CameraPosition(
      target: widget.initialLocation,
      zoom: 12,
    );

    return GoogleMap(
          initialCameraPosition:kGooglePlex,
          onMapCreated:  (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: {
             Marker(
              markerId: MarkerId('Your Phone'),
              position: widget.initialLocation,
            )
          },
        );
  }
}
