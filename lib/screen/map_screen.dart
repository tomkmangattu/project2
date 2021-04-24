import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:jinga/screen/dashboard_screen.dart';
import 'package:jinga/services/local_database.dart';
import 'package:jinga/utilities/constants.dart';
import 'package:flutter/services.dart' show rootBundle;

final Set<Marker> _markers = {};

class MapScreen extends StatefulWidget {
  final MapProcess process;
  // static String id = 'map page';
  MapScreen({@required this.process});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  //
  // Completer<GoogleMapController> _mapCompleter = Completer();
  GoogleMapController _mapController;
  BitmapDescriptor myLocationIcon;
  bool _proceed = true;
  //gps coordinates of kochi
  static const LatLng _initialMapPosition = const LatLng(9.9312, 76.2673);
  MapType _currentMapType = MapType.normal;
  LatLng _lastMapPosition = _initialMapPosition;
  String _mapStyle;
  //
  void _loadMapStyle() {
    //https://mapstyle.withgoogle.com/
    rootBundle.loadString('assets/map_styles/map_style.txt').then((value) {
      _mapStyle = value;
    });
  }

  //
  Future<geolocator.Position> _determineCurrentLocation() async {
    bool locationServiceEnabled;
    geolocator.LocationPermission permission;
    locationServiceEnabled =
        await geolocator.Geolocator.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      await geolocator.Geolocator.openLocationSettings();

      return await geolocator.Geolocator.getCurrentPosition();
    }
    permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.deniedForever) {
        setState(() {
          _proceed = false;
        });
      }
      if (permission == geolocator.LocationPermission.denied) {
        setState(() {
          _proceed = false;
        });
      }
    }
    _showInSnackBar();
    return await geolocator.Geolocator.getCurrentPosition();
  }

  //
  void _setlocationImage() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(6, 6)),
      //  ImageConfiguration(devicePixelRatio: 2.5),
      //'assets/images/locationpin.png',
      'assets/images/redlocation.png',
    ).then((value) {
      myLocationIcon = value;
    });
  }
  //

  Future<geolocator.Position> _getPositionFromGps() async {
    geolocator.Position currentPosition =
        await _determineCurrentLocation().onError((error, stackTrace) {
      setState(() {
        _proceed = false;
      });
      return Future.error('Unable to get data');
    });
    return currentPosition;
  }

  //
  Future<List<double>> _getPositionFromTb() async {
    List<Map<String, dynamic>> latData =
        await DatabaseHelper.instance.query(DatabaseHelper.dataTb, 'latitude');
    List<Map<String, dynamic>> longData =
        await DatabaseHelper.instance.query(DatabaseHelper.dataTb, 'longitude');
    debugPrint(latData.toString());
    double lat = double.parse('${latData[0][DatabaseHelper.colValue]}');
    double long = double.parse('${longData[0][DatabaseHelper.colValue]}');
    if (lat != null && long != null) {
      return [lat, long];
    } else {
      return Future.error('Error getting data from db');
    }
  }

  //
  void _getcurrentLocation() async {
    double lat, long;
    if (widget.process == MapProcess.login) {
      await _getPositionFromGps().then((geolocator.Position position) {
        lat = position.latitude;
        long = position.longitude;
      });
    } else {
      await _getPositionFromTb().then((List data) {
        lat = data[0];
        long = data[1];
      }).onError((error, stackTrace) async {
        await _getPositionFromGps().then((geolocator.Position position) {
          lat = position.latitude;
          long = position.longitude;
        });
      });
    }
    debugPrint('latitide $lat , longitude $long');
    if (lat != null && long != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, long),
            zoom: 16,
          ),
        ),
      );
      _addMarker(lat, long);
    }
  }

  //
  void _addMarker(double lat, double long) async {
    _markers.clear();
    // final myIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5),
    //     'assets/images/locationpin.png');
    _lastMapPosition = LatLng(lat, long);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('home location'),
          position: _lastMapPosition,
          draggable: true,
          onDragEnd: (value) {
            _lastMapPosition = value;
            debugPrint(_lastMapPosition.toString());
          },
          infoWindow: InfoWindow(
            title: 'default location press and drag to change ',
            // snippet: 'press and drag to change ',
          ),
          icon: myLocationIcon,
        ),
      );
    });
  }

  //
  void _onMapCreated(GoogleMapController controller) {
    // _mapCompleter.complete(controller);
    setState(() {
      _mapController = controller;
    });
    _mapController.setMapStyle(_mapStyle);
    _getcurrentLocation();
    _setlocationImage();
  }

  //
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }
  //

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  // void _addMarkers() {
  //   debugPrint('Add marker');
  //   setState(() {
  //     _markers.add(
  //       Marker(
  //         markerId: MarkerId(_lastMapPosition.toString()),
  //         position: _lastMapPosition,
  //         draggable: true,
  //         onDragEnd: (value) {
  //           _lastMapPosition = value;
  //           debugPrint(value.toString());
  //         },
  //         infoWindow: InfoWindow(
  //           title: 'Deault location',
  //           snippet: 'home location',
  //         ),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
  //       ),
  //     );
  //   });
  // }

  //
  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            mapType: _currentMapType,
            markers: _markers,
            onCameraMove: _onCameraMove,
            initialCameraPosition: CameraPosition(
              target: _initialMapPosition,
              zoom: 11.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 36, 16, 16),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  FloatingActionButton(
                    elevation: 12,
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: kmapButtonsColor,
                    child: const Icon(
                      Icons.map,
                      size: 36.0,
                      color: Colors.white60,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  FloatingActionButton(
                    elevation: 12,
                    onPressed: _getcurrentLocation,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: kmapButtonsColor,
                    child: const Icon(
                      Icons.my_location,
                      size: 36,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _proceed
              ? Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 40),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 12,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        // padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kmapButtonsColor,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: TextButton(
                          onPressed: _onSetPressed,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Set location',
                                  style: TextStyle(
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      fontFamily: 'Poppins'),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white60,
                                  size: 30.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      elevation: 12,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onPressed: () {
                        debugPrint('cancel button pressed');
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 32,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showInSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black45,
        elevation: 12,
        content: Text(
          'Choose your location by dragging marker',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
    );
  }

  void _onSetPressed() async {
    if (widget.process != MapProcess.booking) {
      await storeLocation(_lastMapPosition);
    }
    switch (widget.process) {
      case MapProcess.login:
        Navigator.pushReplacementNamed(context, DashboardScreen.id);
        break;
      case MapProcess.change:
        Navigator.pop(context);
        break;
      case MapProcess.booking:
        Navigator.pop(context);
        break;
      default:
        Navigator.pop(context);
    }
  }
}

Future<bool> storeLocation(LatLng position) async {
  List<Map<String, dynamic>> result =
      await DatabaseHelper.instance.query(DatabaseHelper.dataTb, 'latitude');
  Map<String, dynamic> row1 = {
    DatabaseHelper.colName: 'latitude',
    DatabaseHelper.colValue: position.latitude.toString(),
  };

  Map<String, dynamic> row2 = {
    DatabaseHelper.colName: 'longitude',
    DatabaseHelper.colValue: position.longitude.toString(),
  };
  debugPrint(position.toString());
  if (result.isEmpty) {
    try {
      await DatabaseHelper.instance.insert(DatabaseHelper.dataTb, row1);
      await DatabaseHelper.instance.insert(DatabaseHelper.dataTb, row2);
    } catch (e) {
      return Future.error('cannot add location to database');
    }
  } else {
    try {
      await DatabaseHelper.instance
          .update(DatabaseHelper.dataTb, row1, 'latitude');
      await DatabaseHelper.instance
          .update(DatabaseHelper.dataTb, row2, 'longitude');
    } catch (e) {
      return Future.error('cannot add location to database');
    }
  }

  var data = await DatabaseHelper.instance.queryAll(DatabaseHelper.dataTb);
  debugPrint(data.toString());
  return true;
}
