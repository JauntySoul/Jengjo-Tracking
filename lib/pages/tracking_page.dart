import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
  LatLng? currentLocation;
  LatLng currentCameraTarget =
      const LatLng(36.51144636892763, 127.83505205195452);
  double currentCameraZoom = 17;
  bool whetherCameraIsFixed = true;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
            return mapScreen();
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

    LocationData currentLocationData = await location.getLocation();
    currentLocation =
        LatLng(currentLocationData.latitude!, currentLocationData.longitude!);
    return 'normal';
  }

  Widget mapScreen() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentCameraTarget,
            zoom: currentCameraZoom,
          ),
          onMapCreated: (mapController) {
            _googleMapController.complete(mapController);
          },
          gestureRecognizers: {
            Factory<DragGestureRecognizer>(() => MyDragGestureRecognizer(() {
                  if (whetherCameraIsFixed) {
                    setState(() {
                      whetherCameraIsFixed = false;
                    });
                  }
                }))
          },
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          tiltGesturesEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          // TODO: 마커 폴리곤 폴리라인 서클
          onCameraMove: (position) {
            currentCameraTarget = position.target;
          },
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: () {
                      whetherCameraIsFixed = !whetherCameraIsFixed;
                      currentCameraZoom = 17;
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          whetherCameraIsFixed ? Colors.blue : Colors.grey,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      alignment: Alignment.center,
                    ),
                    child: const Icon(Icons.gps_fixed),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: () {
                      cameraZoom('plus');
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          topRight: Radius.circular(5.0),
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: () {
                      cameraZoom('minus');
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5.0),
                          bottomRight: Radius.circular(5.0),
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                    child: const Icon(Icons.remove),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = LatLng(location.latitude!, location.longitude!);
      },
    );
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = LatLng(newLoc.latitude!, newLoc.longitude!);
        if (whetherCameraIsFixed) {
          cameraFixed();
        }
      },
    );
  }

  void cameraFixed() async {
    GoogleMapController googleMapController = await _googleMapController.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLocation!,
          zoom: currentCameraZoom,
        ),
      ),
    );
  }

  void cameraZoom(String operator) async {
    GoogleMapController googleMapController = await _googleMapController.future;
    double realCameraZoom = await googleMapController.getZoomLevel();

    if (operator == 'plus') {
      currentCameraZoom = realCameraZoom + (0.5 - (realCameraZoom % 0.5));
    } else if (operator == 'minus') {
      if (realCameraZoom % 0.5 == 0) {
        currentCameraZoom = realCameraZoom - 0.5;
      } else {
        currentCameraZoom = realCameraZoom - (realCameraZoom % 0.5);
      }
    }

    googleMapController.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentCameraTarget, zoom: currentCameraZoom)));
  }
}

class MyDragGestureRecognizer extends DragGestureRecognizer {
  Function myDragGestureRecognizer;

  MyDragGestureRecognizer(this.myDragGestureRecognizer);

  @override
  void resolve(GestureDisposition disposition) {
    super.resolve(disposition);
    myDragGestureRecognizer();
  }

  @override
  String get debugDescription => throw UnimplementedError();

  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    throw UnimplementedError();
  }
}
