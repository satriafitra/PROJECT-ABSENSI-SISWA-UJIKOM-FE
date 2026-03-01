import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';

class AreaGpsPage extends StatefulWidget {
  const AreaGpsPage({super.key});

  @override
  State<AreaGpsPage> createState() => _AreaGpsPageState();
}

class _AreaGpsPageState extends State<AreaGpsPage> {
  late GoogleMapController mapController;

  // Palette Warna Terang & Mewah
  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color bgLight = const Color(0xFFF8F9FA);
  final Color surfaceWhite = Colors.white;

  static const LatLng _smkn1Cianjur = LatLng(-6.8265, 107.1367);
  final double _radiusMeter = 60.0;

  String _statusMessage = "Menghitung Jarak...";
  String _distanceLabel = "0m";
  bool _isWithinRadius = false;
  
  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initMarkers();
    _initLocationFeature();
  }

  void _initMarkers() {
    _markers[const MarkerId("sekolah")] = Marker(
      markerId: const MarkerId("sekolah"),
      position: _smkn1Cianjur,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(title: "SMKN 1 Cianjur"),
    );
  }

  Future<void> _initLocationFeature() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    _startRealTimeTracking();
  }

  void _startRealTimeTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, 
      ),
    ).listen((Position position) {
      LatLng userLoc = LatLng(position.latitude, position.longitude);

      double distance = Geolocator.distanceBetween(
        userLoc.latitude, userLoc.longitude,
        _smkn1Cianjur.latitude, _smkn1Cianjur.longitude,
      );

      if (mounted) {
        setState(() {
          _distanceLabel = "${distance.toInt()}m";
          
          _markers[const MarkerId("user_pos")] = Marker(
            markerId: const MarkerId("user_pos"),
            position: userLoc,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          );

          _polylines[const PolylineId("path")] = Polyline(
            polylineId: const PolylineId("path"),
            points: [userLoc, _smkn1Cianjur],
            color: primaryOrange.withOpacity(0.5),
            width: 4,
            patterns: [PatternItem.dash(15), PatternItem.gap(10)],
            jointType: JointType.round,
          );

          if (distance <= _radiusMeter) {
            _statusMessage = "Area Terverifikasi";
            _isWithinRadius = true;
          } else {
            _statusMessage = "Di Luar Jangkauan";
            _isWithinRadius = false;
          }
        });

        mapController.animateCamera(CameraUpdate.newLatLng(userLoc));
      }
    });
  }

  void _setMapStyle() async {
    // Style Silver/White Premium
    String style = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
      {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#e9e9e9"}]}
    ]
    ''';
    mapController.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          // MAPS (Background)
          GoogleMap(
            onMapCreated: (c) {
              mapController = c;
              _setMapStyle();
            },
            initialCameraPosition: const CameraPosition(target: _smkn1Cianjur, zoom: 17),
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            markers: Set<Marker>.of(_markers.values),
            polylines: Set<Polyline>.of(_polylines.values),
            circles: {
              Circle(
                circleId: const CircleId("rad"),
                center: _smkn1Cianjur,
                radius: _radiusMeter,
                fillColor: primaryOrange.withOpacity(0.08),
                strokeColor: primaryOrange.withOpacity(0.3),
                strokeWidth: 2,
              ),
            },
          ),

          // TOP NAVIGATION
          Positioned(
            top: 50, left: 20, right: 20,
            child: FadeInDown(
              child: Row(
                children: [
                  _buildCircleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.school_rounded, color: primaryOrange, size: 20),
                          const SizedBox(width: 10),
                          const Text("SMKN 1 CIANJUR", 
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM INFO PANEL (Light Glassmorphism)
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: surfaceWhite.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("JARAK", _distanceLabel, Icons.straighten_rounded),
                            Container(width: 1, height: 30, color: Colors.grey.shade300),
                            _buildStatItem("STATUS", _statusMessage, _isWithinRadius ? Icons.verified_rounded : Icons.location_off_rounded),
                          ],
                        ),
                        const SizedBox(height: 25),
                        
                        // Main Action Button
                        InkWell(
                          onTap: _isWithinRadius ? () {} : null,
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isWithinRadius 
                                  ? [primaryOrange, const Color(0xFFFF8E62)]
                                  : [Colors.grey.shade300, Colors.grey.shade400]
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: _isWithinRadius ? [
                                BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
                              ] : [],
                            ),
                            child: Center(
                              child: Text(
                                _isWithinRadius ? "ABSEN SEKARANG" : "MASUK AREA SEKOLAH",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  fontSize: 14
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: primaryOrange),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceWhite,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Icon(icon, color: Colors.black87, size: 18),
      ),
    );
  }
}