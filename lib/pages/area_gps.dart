import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';

class AreaGpsPage extends StatefulWidget {
  const AreaGpsPage({super.key});

  @override
  State<AreaGpsPage> createState() => _AreaGpsPageState();
}

class _AreaGpsPageState extends State<AreaGpsPage> {
  late GoogleMapController mapController;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color secondaryOrange = const Color(0xFFFF8E62);

  // --- KOORDINAT PERSIS SMKN 1 CIANJUR ---
  static const LatLng _smkn1Cianjur = LatLng(-6.8265, 107.1367);
  final double _radiusMeter = 60.0; // Sedikit diperlebar agar menjangkau area kelas

  String _statusMessage = "Mencari GPS...";
  bool _isWithinRadius = false;
  
  final Map<MarkerId, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Marker Sekolah SMKN 1 Cianjur
    _markers[const MarkerId("sekolah")] = Marker(
      markerId: const MarkerId("sekolah"),
      position: _smkn1Cianjur,
      infoWindow: const InfoWindow(title: "SMKN 1 Cianjur"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
    _initLocationFeature();
  }

  Future<void> _initLocationFeature() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _statusMessage = "GPS HP Belum Aktif");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _statusMessage = "Izin Lokasi Ditolak");
        return;
      }
    }
    _startRealTimeTracking();
  }

  void _startRealTimeTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, 
      ),
    ).listen((Position position) {
      LatLng userLoc = LatLng(position.latitude, position.longitude);

      double distanceInMeters = Geolocator.distanceBetween(
        userLoc.latitude, userLoc.longitude,
        _smkn1Cianjur.latitude, _smkn1Cianjur.longitude,
      );

      if (mounted) {
        setState(() {
          // Update Marker Posisi Siswa (Warna Azure/Biru)
          _markers[const MarkerId("user_pos")] = Marker(
            markerId: const MarkerId("user_pos"),
            position: userLoc,
            infoWindow: const InfoWindow(title: "Lokasi Saya"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          );

          if (distanceInMeters <= _radiusMeter) {
            _statusMessage = "Anda Berada di Area SMKN 1";
            _isWithinRadius = true;
          } else {
            _statusMessage = "Diluar Radius (${distanceInMeters.toInt()}m lagi)";
            _isWithinRadius = false;
          }
        });

        // Gerakkan kamera mengikuti user dengan zoom level yang nyaman
        mapController.animateCamera(CameraUpdate.newLatLngZoom(userLoc, 18.0));
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
  }

  void _setMapStyle() async {
    // Style peta bersih (Silver theme)
    String style = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
      {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
      {"featureType": "poi.park", "stylers": [{"color": "#e5e5e5"}]}
    ]
    ''';
    mapController.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("Absensi SMKN 1 Cianjur", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _smkn1Cianjur, 
              zoom: 17.0,
            ),
            myLocationEnabled: false, 
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            circles: {
              Circle(
                circleId: const CircleId("radius_smk"),
                center: _smkn1Cianjur,
                radius: _radiusMeter,
                fillColor: primaryOrange.withOpacity(0.15),
                strokeColor: primaryOrange,
                strokeWidth: 2,
              ),
            },
            markers: Set<Marker>.of(_markers.values),
          ),

          // --- UI PANEL ---
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_isWithinRadius ? Colors.green : Colors.blue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _isWithinRadius ? Icons.verified_user_rounded : Icons.location_searching_rounded, 
                            color: _isWithinRadius ? Colors.green : Colors.blue
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("INFO RADIUS", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              Text(_statusMessage, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(thickness: 0.5)),
                    
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: _isWithinRadius 
                            ? [Colors.green.shade600, Colors.green.shade400] 
                            : [primaryOrange, secondaryOrange]
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isWithinRadius ? () {
                           // Logika ketika tombol absen diklik
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text("Berhasil! Mengirim data kehadiran..."))
                           );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          _isWithinRadius ? "KIRIM KEHADIRAN" : "ANDA DI LUAR AREA",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}