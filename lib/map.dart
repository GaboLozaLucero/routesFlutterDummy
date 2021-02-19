import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:routes/transitions.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Map extends StatefulWidget {
  Map({this.app});
  final FirebaseApp app;
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  String _mapStyle;
  Position currentPosition;
  var geoLocator = new Geolocator();
  GoogleMapController googleMapController;
  double zoom = 18.0;
  bool mapToggle = false;
  var locations = [];
  List<Marker> _originDestinationMarker = [];
  var currentLocation;
  double destinationLatitude = 0,
      destinationLongitude = 0,
      waypointLatitude = 0,
      waypointLongitude = 0;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyBc7XKNS0qVKzaHvFSXDalxKwzOZqn4S5Y";
  String pinName = '';
  BitmapDescriptor pinStore;
  BitmapDescriptor pinDestination;

  @override
  void initState() {
    mapToggle = true;
    super.initState();
    rootBundle
        .loadString('images/map_style.txt')
        .then((string) => _mapStyle = string);
    _setOriginDestinationIcons();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLng = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLng, zoom: zoom);
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _setOriginDestinationIcons() async {
    pinStore = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 0.5), 'images/store_marker.bmp');
    pinDestination = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 0.5),
        'images/destination_marker.bmp');
  }

  _showTap(LatLng tappedPoint, String pinName, BitmapDescriptor pinIcon) {
    setState(() {
      _originDestinationMarker.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          infoWindow: InfoWindow(title: pinName),
          icon: pinIcon));
    });
  }

  _handleTap(LatLng tappedPoint) {
    print('lati: ${tappedPoint.latitude}, longi: ${tappedPoint.longitude}');

    _displayDialogSave(context, tappedPoint);
  }

  _displayDialogSave(BuildContext context, LatLng tappedPoint) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Save marker?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Latitude: ${tappedPoint.latitude}'),
                Text('Longitude: ${tappedPoint.longitude}'),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    pinName = 'Destination';
                    if (destinationLatitude != 0 && destinationLongitude != 0) {
                      Navigator.of(context).pop();
                      _displayError(context, pinName);
                    } else {
                      destinationLatitude = tappedPoint.latitude;
                      destinationLongitude = tappedPoint.longitude;

                      _showTap(tappedPoint, pinName, pinDestination);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Destination')),
              FlatButton(
                  onPressed: () {
                    pinName = 'Store';
                    if (waypointLatitude != 0 && waypointLongitude != 0) {
                      Navigator.of(context).pop();
                      _displayError(context, pinName);
                    } else {
                      waypointLatitude = tappedPoint.latitude;
                      waypointLongitude = tappedPoint.longitude;
                      BitmapDescriptor.fromAssetImage(
                              ImageConfiguration(devicePixelRatio: 0.5),
                              'images/store_marker.bmp')
                          .then((value) => pinStore = value);
                      _showTap(tappedPoint, pinName, pinStore);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Store')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }

  _displayError(BuildContext context, String pinName) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Error saving coordinates',
            ),
            content: Text('$pinName already exists'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  setPolyline() async {
    PointLatLng origen =
        PointLatLng(currentPosition.latitude, currentPosition.longitude);
    PointLatLng destination =
        PointLatLng(destinationLatitude, destinationLongitude);
    List<PolylineWayPoint> wayPoint = [
      PolylineWayPoint(location: '$waypointLatitude, $waypointLongitude')
    ];
    PolylineResult result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey, origen, destination,
        travelMode: TravelMode.walking, wayPoints: wayPoint);
    result.points.forEach((element) {
      polylineCoordinates.add(LatLng(element.latitude, element.longitude));
    });
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("poly"),
        color: Colors.amber,
        points: polylineCoordinates,
        width: 5,
        endCap: Cap.roundCap,
        consumeTapEvents: true,
        startCap: Cap.roundCap,
      );
      _polylines.add(polyline);
    });
  }

  _displayErrorCoordinates(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Store and Destination must be selected'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    LatLng latLng = LatLng(0.0, 0.0);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: zoom);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Map'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add_road),
              onPressed: () {
                setState(() {
                  _originDestinationMarker.length = 0;
                  destinationLatitude = 0;
                  destinationLongitude = 0;
                  waypointLatitude = 0;
                  waypointLongitude = 0;
                  polylineCoordinates.clear();
                });
              }),
          IconButton(
              icon: Icon(Icons.linear_scale),
              onPressed: () async {
                if (destinationLatitude == 0 && destinationLongitude == 0 ||
                    waypointLatitude == 0 && waypointLongitude == 0) {
                  _displayErrorCoordinates(context);
                } else {
                  await setPolyline();
                }
                setState(() {});
              })
        ],
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              height: height - 80.0,
              width: double.infinity,
              child: mapToggle
                  ? GoogleMap(
                      compassEnabled: true,
                      initialCameraPosition: cameraPosition,
                      onMapCreated: (controller) {
                        setState(() {
                          googleMapController = controller;
                          locatePosition();
                          controller.setMapStyle(_mapStyle);
                        });
                      },
                      markers: Set.from(_originDestinationMarker),
                      onTap: _handleTap,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      polylines: _polylines,
                    )
                  : Center(
                      child: Text('Loading map...',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
