import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MappaPage extends StatefulWidget {
  const MappaPage({super.key});

  @override
  State<MappaPage> createState() => _MappaPageState();
}

class _MappaPageState extends State<MappaPage> {
  final LatLng napoliLatLng = LatLng(40.8522, 14.2681);

  late final MapController _mapController;
  double _currentZoom = 13.0; // Zoom iniziale

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _zoomIn() {
    setState(() {
      if (_currentZoom < 18) _currentZoom++;
      _mapController.move(napoliLatLng, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      if (_currentZoom > 5) _currentZoom--;
      _mapController.move(napoliLatLng, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoadGuardian'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: napoliLatLng,
              zoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.roadguardian_client',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,  // Aumentato da 20 a 40
                    height: 40, // Aumentato da 20 a 40
                    point: napoliLatLng,
                    builder: (ctx) => Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MappaPage(),
  ));
}
