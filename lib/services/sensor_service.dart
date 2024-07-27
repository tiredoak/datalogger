import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<Position>? _locationSubscription;
  Position? _currentPosition;

  AccelerometerEvent? _accelerometerEvent;
  UserAccelerometerEvent? _userAccelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;

  final Map<String, dynamic> _deviceInfo;

  SensorService(this._deviceInfo);

  void startListening(Function(Map<String, dynamic>) onData) {
    _locationSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      _currentPosition = position;
      _logSensorData(onData);
    });

    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      _accelerometerEvent = event;
      _logSensorData(onData);
    });

    _userAccelerometerSubscription =
        userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      _userAccelerometerEvent = event;
      _logSensorData(onData);
    });

    _gyroscopeSubscription =
        gyroscopeEventStream().listen((GyroscopeEvent event) {
      _gyroscopeEvent = event;
      _logSensorData(onData);
    });

    _magnetometerSubscription =
        magnetometerEventStream().listen((MagnetometerEvent event) {
      _magnetometerEvent = event;
      _logSensorData(onData);
    });
  }

  void _logSensorData(Function(Map<String, dynamic>) onData) {
    final timestamp = DateTime.now().toIso8601String();
    final latitude = _currentPosition?.latitude ?? 0.0;
    final longitude = _currentPosition?.longitude ?? 0.0;

    Map<String, dynamic> logEntry = {
      "Timestamp": timestamp,
      "Latitude": latitude,
      "Longitude": longitude,
      "DeviceInfo": _deviceInfo,
      "AccelerometerEvent": _accelerometerEvent == null
          ? {}
          : {
              "X": _accelerometerEvent!.x,
              "Y": _accelerometerEvent!.y,
              "Z": _accelerometerEvent!.z,
            },
      "UserAccelerometerEvent": _userAccelerometerEvent == null
          ? {}
          : {
              "X": _userAccelerometerEvent!.x,
              "Y": _userAccelerometerEvent!.y,
              "Z": _userAccelerometerEvent!.z,
            },
      "GyroscopeEvent": _gyroscopeEvent == null
          ? {}
          : {
              "X": _gyroscopeEvent!.x,
              "Y": _gyroscopeEvent!.y,
              "Z": _gyroscopeEvent!.z,
            },
      "MagnetometerEvent": _magnetometerEvent == null
          ? {}
          : {
              "X": _magnetometerEvent!.x,
              "Y": _magnetometerEvent!.y,
              "Z": _magnetometerEvent!.z,
            },
    };

    onData(logEntry);
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _locationSubscription?.cancel();
  }

  void dispose() {
    stopListening();
  }
}
