import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class TrackingPage extends StatefulWidget {
  final String selectedCourse;
  const TrackingPage(this.selectedCourse, {Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();
  LocationData? currentLocation;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: turnedGPS(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == 'gps') {
            // TODO: GPS ON/OFF
          } else if (snapshot.data == 'permission') {
            // TODO: Permission
          } else if (snapshot.data == 'normal') {
            return googleMap();
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Future<String> turnedGPS() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return 'gps';
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return 'permission';
      }
    }

    currentLocation = await location.getLocation();
    return 'normal';
  }

  Widget googleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        zoom: 13.5,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("currentLocation"),
          position:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        ),
      },
      onMapCreated: (mapController) {
        _googleMapController.complete(mapController);
      },
    );
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    GoogleMapController googleMapController = await _googleMapController.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }
}
