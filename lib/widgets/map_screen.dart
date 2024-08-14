import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final List<LatLng> path;
  final LatLng? initialPosition;

  const MapScreen({super.key, required this.path, this.initialPosition});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPosition != null) {
        _mapController.move(widget.initialPosition!, 16.0);
      }
    });
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path.isNotEmpty) {
      _mapController.move(widget.path.last, 16.0);
    } else if (widget.initialPosition != null) {
      _mapController.move(widget.initialPosition!, 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: widget.initialPosition ??
            LatLng(38.71667,
                -9.13333), // Default to Lisbon if no position provided
        zoom: 16.0, // Initial zoom level set to 16
        interactiveFlags: InteractiveFlag.all,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: widget.path,
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            if (widget.initialPosition != null)
              Marker(
                point: widget.initialPosition!,
                builder: (ctx) => Container(
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
            if (widget.path.isNotEmpty)
              Marker(
                point: widget.path.last,
                builder: (ctx) => Container(
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
