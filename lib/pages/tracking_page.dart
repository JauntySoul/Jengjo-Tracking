import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:jeongjo_tracking/main.dart';

class TrackingPage extends StatefulWidget {
  final String selectedCourse;
  const TrackingPage(this.selectedCourse, {Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();
  Location location = Location();
  late StreamSubscription<LocationData> locationChangeListener;
  LatLng currentLocation = const LatLng(36.511446, 127.835052);
  LatLng currentCameraTarget = const LatLng(36.511446, 127.835052);
  double currentCameraZoom = 17;
  bool whetherCameraIsFixed = true;
  Set<Marker> markers = {};

  @override
  void initState() {
    initLocationChangeListener();
    locationChangeListener.resume();
    initMarker();
    super.initState();
  }

  @override
  void dispose() {
    locationChangeListener.cancel();
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
          markers: markers,
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

  Future<String> turnedGPS() async {
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

  void initLocationChangeListener() async {
    locationChangeListener = location.onLocationChanged.listen(
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
    googleMapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLocation,
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

  void initMarker() async {
    List courseList = jsonDecode(
        await rootBundle.loadString('assets/json/courseList.json'))['list'];
    List spotList = [];

    for (var element in courseList) {
      spotList.add(jsonDecode(
          await rootBundle.loadString('assets/json/$element.json'))['spot']);
    }

    for (var i in spotList) {
      for (var j in i) {
        markers.add(Marker(
          markerId: MarkerId(j['name']),
          position: LatLng(j['lat'], j['lng']),
          onTap: () {
            markerDialog(j);
          },
          consumeTapEvents: true,
        ));
      }
    }
  }

  void markerDialog(element) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color buttonColor = stampStatusGlobal['${element['name']}'] == 'false'
            ? Colors.blue
            : Colors.red;
        String buttonText = stampStatusGlobal['${element['name']}'] == 'false'
            ? 'doStamp'.tr()
            : 'alreadyStamp'.tr();
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Center(child: Text(element['name'].toString().tr())),
            content: SizedBox(
              width: 300,
              height: 500,
              child: Text(element['explain'].toString().tr()),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (stampStatusGlobal['${element['name']}'] ==
                            'false') {
                          stampStatusGlobal['${element['name']}'] = 'true';
                          await storage.write(
                              key: element['name'], value: 'true');
                          setState(() {
                            buttonColor = Colors.red;
                            buttonText = 'alreadyStamp'.tr();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                      ),
                      child: Text(buttonText),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('dialogClose'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
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
