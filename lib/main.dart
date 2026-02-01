import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';

// Constants
const String mapStyleUrl =
    "https://tile.openstreetmap.jp/styles/maptiler-basic-ja/style.json";
const double initialLat = 35.681236; // 東京駅
const double initialLon = 139.767125;
const double initialZoom = 5;
const double maxZoom = 14;
const int coordDecimalPlaces = 3;
const double circleRadius = 40.0;
const String circleColor = '#FF0000';
const double circleBlur = 0.5;
const double circleOpacity = 0.5;
const int attributionMargin = 16;

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
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
  }

  Future<Position> _getLocation() async {
    await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }

  Future<LatLng> _getRoundedLocation(Position pos) async {
    final roundedLat = double.parse(
      pos.latitude.toStringAsFixed(coordDecimalPlaces),
    );
    final roundedLon = double.parse(
      pos.longitude.toStringAsFixed(coordDecimalPlaces),
    );
    return LatLng(roundedLat, roundedLon);
  }

  Future<void> _addCurrentLocationMarker(LatLng location) async {
    await controller!.addCircle(
      CircleOptions(
        geometry: location,
        circleRadius: circleRadius,
        circleColor: circleColor,
        circleBlur: circleBlur,
        circleOpacity: circleOpacity,
      ),
    );
  }

  void _onMapCreated(MapLibreMapController ctrl) async {
    controller = ctrl;

    final pos = await _getLocation();
    final location = await _getRoundedLocation(pos);

    setState(() {
      currentLocation = location;
    });

    controller!.animateCamera(CameraUpdate.newLatLngZoom(location, 14));

    await _addCurrentLocationMarker(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Viewer'),
        elevation: 0,
        toolbarHeight: 40,
      ),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: mapStyleUrl,
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(initialLat, initialLon),
              zoom: initialZoom,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(1, maxZoom),
            attributionButtonMargins: Point(
              attributionMargin.toDouble(),
              attributionMargin.toDouble(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Text(
            currentLocation != null
                ? 'Current Location: ${currentLocation!.latitude.toStringAsFixed(coordDecimalPlaces)}, ${currentLocation!.longitude.toStringAsFixed(coordDecimalPlaces)}'
                : 'Getting location...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
