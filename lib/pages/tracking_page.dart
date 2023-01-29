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
  StreamController<String> streamController = StreamController<String>();

  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(36.51144636892763, 127.83505205195452),
    zoom: 7,
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      streamController.add(await turnedGPS());
    });
    streamController.stream.listen((event) {
      getGPS();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == 'gps') {
            print('GPS ON/OFF 확인');
          } else if (snapshot.data == 'permission') {
            print('위치 권한 확인');
          } else {
            print(snapshot.data);
          }
        }

        return Scaffold(
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
            },
          ),
        );
      },
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }

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

    return 'normal';
  }

  getGPS() async {
    Location location = Location();
    return await location.getLocation();
  }
}
