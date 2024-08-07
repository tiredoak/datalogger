// lib/widgets/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:record_data/services/logging_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoutesMapScreen()),
            );
          },
          child: const Text('See My Map'),
        ),
      ),
    );
  }
}

class RoutesMapScreen extends StatelessWidget {
  const RoutesMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routes'),
      ),
      body: FutureBuilder<List<List<LatLng>>>(
        future: LoggingService().getAllRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes found.'));
          } else {
            return FlutterMap(
              options: MapOptions(
                center: snapshot.data!.isNotEmpty
                    ? snapshot.data!.first.first
                    : LatLng(38.71667, -9.13333), // Default to Lisbon
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: snapshot.data!
                      .map((route) => Polyline(
                            points: route,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ))
                      .toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
