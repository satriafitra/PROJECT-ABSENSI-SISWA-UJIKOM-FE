import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animate_do/animate_do.dart';

class AreaGpsPage extends StatefulWidget {
  const AreaGpsPage({super.key});

  @override
  State<AreaGpsPage> createState() => _AreaGpsPageState();
}

class _AreaGpsPageState extends State<AreaGpsPage> {
  late GoogleMapController mapController;

  // Warna Utama
  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color secondaryOrange = const Color(0xFFFF8E62);

  // Koordinat Sekolah (Contoh: Monas Jakarta, ganti dengan koordinat sekolahmu)
  static const LatLng _sekolahLocation = LatLng(-6.175392, 106.827153);
  
  // Radius dalam meter
  final double _radiusMeter = 50.0;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
  }

  void _setMapStyle() async {
    String style = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#e9e9e9"}]},
      {"featureType": "poi", "stylers": [{"visibility": "off"}]}
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: const Text(
          "Area Absensi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // --- GOOGLE MAPS ---
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _sekolahLocation,
              zoom: 18.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            circles: {
              Circle(
                circleId: const CircleId("area_sekolah"),
                center: _sekolahLocation,
                radius: _radiusMeter,
                fillColor: primaryOrange.withOpacity(0.2),
                strokeColor: primaryOrange,
                strokeWidth: 2,
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId("sekolah"),
                position: _sekolahLocation,
                infoWindow: const InfoWindow(title: "Area Sekolah"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              ),
            },
          ),

          // --- OVERLAY GRADIENT ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // --- BOTTOM INFO CARD ---
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
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
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
                            color: primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Icons.my_location_rounded, color: primaryOrange),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Status Lokasi",
                                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Mengecek Kehadiran...",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(thickness: 0.5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusIcon(Icons.gps_fixed_rounded, "GPS Aktif"),
                        _buildStatusIcon(Icons.verified_user_outlined, "Radius ${_radiusMeter.toInt()}m"),
                        _buildStatusIcon(Icons.security_rounded, "Terproteksi"),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // Button Verifikasi
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [primaryOrange, secondaryOrange]),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Logika Verifikasi
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "VERIFIKASI LOKASI",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  Widget _buildStatusIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: primaryOrange.withOpacity(0.6)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }
}