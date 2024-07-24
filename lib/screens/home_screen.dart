import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record_data/services/logging_service.dart';
import 'package:record_data/services/permission_service.dart';
import 'package:record_data/services/sensor_service.dart';
import 'package:uuid/uuid.dart';
import 'package:record_data/widgets/rating_dialog.dart';
import 'package:record_data/services/timer_service.dart'; // Import the new timer service

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _logService = LoggingService();
  final _permissionService = PermissionService();
  late SensorService _sensorService;
  final TimerService _timerService =
      TimerService(); // Initialize the timer service

  bool _isRecording = false;
  bool _isLoading = true;
  int _countdown = 0;
  String _rideUUID = const Uuid().v4();

  int? _roadQuality;
  String? _roadType;
  String? _bike = 'Brompton';
  String? _mount = 'good';
  String? _mountPosition = 'vertical';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await _permissionService.checkPermissions();
    setState(() {
      _sensorService = SensorService(_permissionService.getDeviceInfo());
      _isLoading = false;
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
    });

    _timerService.startTimer((elapsedSeconds) {
      setState(() {});
    });

    _sensorService.startListening((logEntry) {
      setState(() {
        _logService.logData(logEntry);
      });
    });
  }

  void _stopRecording() async {
    _sensorService.stopListening();
    _timerService.stopTimer();

    setState(() {
      _isRecording = false;
    });

    final result = await showRatingDialog(context, _roadQuality, _roadType);
    if (result != null) {
      setState(() {
        _roadQuality = result['roadQuality'];
        _roadType = result['roadType'];
        _bike = result['bike'];
        _mount = result['mount'];
        _mountPosition = result['mountPosition'];
      });
      await _logService.saveLog(
          _rideUUID, _roadQuality, _roadType, _bike, _mount, _mountPosition);
      _showSnackbar();
    }
  }

  void _showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log data saved to file'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accelerometer Logger'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_countdown > 0)
                    Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_isRecording)
                    Text(
                      'Elapsed time: ${_timerService.elapsedSeconds} s',
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isRecording ? _stopRecording : _startCountdown,
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 48),
                      padding: const EdgeInsets.symmetric(
                          vertical: 60, horizontal: 100),
                    ),
                    child: Text(_isRecording ? 'Stop Recording' : 'Record'),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _sensorService.dispose();
    super.dispose();
  }
}
