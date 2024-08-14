import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record_data/services/logging_service.dart';
import 'package:record_data/services/permission_service.dart';
import 'package:record_data/services/sensor_service.dart';
import 'package:record_data/services/timer_service.dart';
import 'package:record_data/services/location_service.dart';
import 'package:record_data/widgets/rating_dialog.dart';
import 'package:record_data/widgets/map_screen.dart';
import 'package:record_data/widgets/profile_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _logService = LoggingService();
  final _permissionService = PermissionService();
  final _locationService = LocationService();
  late SensorService _sensorService;
  final TimerService _timerService = TimerService();

  bool _isRecording = false;
  bool _isLoading = true;
  int _countdown = 0;
  String _rideUUID = const Uuid().v4();
  String? _street = 'Unknown';
  String? _city = 'Unknown';
  final List<LatLng> _path = [];
  LatLng? _currentPosition;

  String? _bike = 'Brompton';
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkPermissions();
    await _getCurrentLocation();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkPermissions() async {
    await _permissionService.checkPermissions();
    setState(() {
      _sensorService = SensorService(_permissionService.getDeviceInfo());
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _startCountdown() {
    setState(() {
      _countdown = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_countdown == 0) {
          timer.cancel();
          _startRecording();
        } else {
          _countdown--;
        }
      });
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _logService.clearLog();
      _rideUUID = const Uuid().v4();
      _path.clear();
    });

    _timerService.startTimer((elapsedSeconds) {
      setState(() {});
    });

    _sensorService.startListening((logEntry) {
      setState(() {
        _logService.logData(logEntry);
      });
    });

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationTimer =
        Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      Position position = await Geolocator.getCurrentPosition();
      try {
        final locationData = await _locationService.getStreetAndCity(
            position.latitude, position.longitude);
        setState(() {
          _street = locationData['street'];
          _city = locationData['city'];
          _path.add(LatLng(position.latitude, position.longitude));
        });
        _logService.logStreetData(_street!, _city!);
      } catch (e) {
        // Handle any errors
      }
    });
  }

  void _stopRecording() async {
    _sensorService.stopListening();
    _timerService.stopTimer();
    _locationTimer?.cancel();

    setState(() {
      _isRecording = false;
    });

    await _logService.saveLog(_rideUUID, _bike);
    await _logService.saveStreetData(_rideUUID);

    final result = await showRatingDialog(context);
    if (result != null) {
      setState(() {
        _bike = result['bike'];
      });
      await _logService.saveLog(_rideUUID, _bike);
      _showSnackbar(_logService.uniqueStreetsCount);
    }
  }

  void _showSnackbar(int uniqueStreets) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You collected $uniqueStreets streets'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : MapScreen(
                  path: _path,
                  initialPosition: _currentPosition, // Pass the current position
                ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startCountdown,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 24),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isRecording ? 'Stop Recording' : 'Record'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sensorService.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }
}
