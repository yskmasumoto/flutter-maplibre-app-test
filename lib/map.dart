import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MapScreen());
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? controller;

  Future<Position> _getLocation() async {
    await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(MapLibreMapController ctrl) async {
    controller = ctrl;

    final pos = await _getLocation();

    controller!.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14),
    );

    controller!.addSymbol(
      SymbolOptions(
        geometry: LatLng(pos.latitude, pos.longitude),
        iconImage: "marker-15",
        iconSize: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        styleString: "https://demotiles.maplibre.org/style.json",
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(35.681236, 139.767125), // 初期値: 東京駅
          zoom: 5,
        ),
      ),
    );
  }
}
