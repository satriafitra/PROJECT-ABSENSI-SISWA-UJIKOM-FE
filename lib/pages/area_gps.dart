import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/theme_provider.dart';

class AreaGpsPage extends StatefulWidget {
  const AreaGpsPage({super.key});

  @override
  State<AreaGpsPage> createState() => _AreaGpsPageState();
}

class _AreaGpsPageState extends State<AreaGpsPage> {
  GoogleMapController? mapController;
  bool _isMapControllerInitialized = false;

  // Palette Warna Utama
  final Color primaryOrange = const Color(0xFFFF6B35);

  static const LatLng _smkn1Cianjur = LatLng(-6.8265, 107.1367);
  final double _radiusMeter = 120.0;

  String _statusMessage = "Menghitung...";
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

  // Monitor perubahan tema saat halaman aktif
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isMapControllerInitialized && mapController != null) {
      final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
      _updateMapStyle(isDark);
    }
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
      if (!mounted) return;
      
      LatLng userLoc = LatLng(position.latitude, position.longitude);
      double distance = Geolocator.distanceBetween(
        userLoc.latitude, userLoc.longitude,
        _smkn1Cianjur.latitude, _smkn1Cianjur.longitude,
      );

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
        );

        if (distance <= _radiusMeter) {
          _statusMessage = "Area Terverifikasi";
          _isWithinRadius = true;
        } else {
          _statusMessage = "Di Luar Jangkauan";
          _isWithinRadius = false;
        }
      });

      mapController?.animateCamera(CameraUpdate.newLatLng(userLoc));
    });
  }

  void _updateMapStyle(bool isDarkMode) async {
    String style = isDarkMode ? _darkMapStyle : _lightMapStyle;
    await mapController?.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.bgWhite,
      body: Stack(
        children: [
          // MAPS
          GoogleMap(
            onMapCreated: (c) {
              mapController = c;
              _isMapControllerInitialized = true;
              _updateMapStyle(themeProvider.isDarkMode);
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
                fillColor: primaryOrange.withOpacity(themeProvider.isDarkMode ? 0.15 : 0.08),
                strokeColor: primaryOrange.withOpacity(0.4),
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
                  _buildCircleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context), themeProvider),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.4 : 0.05), 
                            blurRadius: 10, 
                            offset: const Offset(0, 5)
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.school_rounded, color: primaryOrange, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "SMKN 1 CIANJUR", 
                            style: TextStyle(
                              color: themeProvider.textColor, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 13, 
                              letterSpacing: 0.5
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM INFO PANEL
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
                      color: themeProvider.isDarkMode 
                          ? const Color(0xFF1E1E1E).withOpacity(0.85) 
                          : themeProvider.cardColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: themeProvider.isDarkMode ? Colors.white10 : Colors.white, 
                        width: 2
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), 
                          blurRadius: 20, 
                          offset: const Offset(0, 10)
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("JARAK", _distanceLabel, Icons.straighten_rounded, themeProvider),
                            Container(width: 1, height: 30, color: themeProvider.isDarkMode ? Colors.white10 : Colors.grey.shade300),
                            _buildStatItem("STATUS", _statusMessage, _isWithinRadius ? Icons.verified_rounded : Icons.location_off_rounded, themeProvider),
                          ],
                        ),
                        const SizedBox(height: 25),
                        
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
                                  : [
                                      themeProvider.isDarkMode ? Colors.white12 : Colors.grey.shade300, 
                                      themeProvider.isDarkMode ? Colors.white12 : Colors.grey.shade400
                                    ]
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: _isWithinRadius ? [
                                BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
                              ] : [],
                            ),
                            child: Center(
                              child: Text(
                                _isWithinRadius ? "ABSEN SEKARANG" : "MASUK AREA SEKOLAH",
                                style: TextStyle(
                                  color: _isWithinRadius ? Colors.white : (themeProvider.isDarkMode ? Colors.white38 : Colors.grey),
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

  Widget _buildStatItem(String label, String value, IconData icon, ThemeProvider theme) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: primaryOrange),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: theme.subTextColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: theme.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap, ThemeProvider theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(theme.isDarkMode ? 0.3 : 0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Icon(icon, color: theme.textColor, size: 18),
      ),
    );
  }

  final String _lightMapStyle = '''[
    {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]}
  ]''';

  final String _darkMapStyle = '''[
    { "elementType": "geometry", "stylers": [ { "color": "#242f3e" } ] },
    { "elementType": "labels.text.fill", "stylers": [ { "color": "#746855" } ] },
    { "elementType": "labels.text.stroke", "stylers": [ { "color": "#242f3e" } ] },
    { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#d59563" } ] },
    { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#d59563" } ] },
    { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#263c3f" } ] },
    { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#6b9a76" } ] },
    { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#38414e" } ] },
    { "featureType": "road", "elementType": "geometry.stroke", "stylers": [ { "color": "#212a37" } ] },
    { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#9ca5b3" } ] },
    { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#746855" } ] },
    { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#1f2835" } ] },
    { "featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [ { "color": "#f3d19c" } ] },
    { "featureType": "transit", "elementType": "geometry", "stylers": [ { "color": "#2f3948" } ] },
    { "featureType": "transit.station", "elementType": "labels.text.fill", "stylers": [ { "color": "#d59563" } ] },
    { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#17263c" } ] },
    { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#515c6d" } ] },
    { "featureType": "water", "elementType": "labels.text.stroke", "stylers": [ { "color": "#17263c" } ] }
  ]''';
}