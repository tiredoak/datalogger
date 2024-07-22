import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerEvent;
  StreamSubscription<GyroscopeEvent>? _gyroscopeEvent;
  StreamSubscription<MagnetometerEvent>? _magnetometerEvent;
  StreamSubscription<Position>? _location;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Map<String, dynamic> deviceInfoData = {};
  Position? _currentPosition;
  bool _isRecording = false;
  final List<Map<String, dynamic>> _logData = [];
  bool isLoading = true;
  String _rideUUID = const Uuid().v4(); // UUID for the entire ride
  int _countdown = 0; // Countdown variable

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isIOS) {
      IosDeviceInfo into = await deviceInfo.iosInfo;
      setState(() {
        deviceInfoData = into.data;
      });
    } else {
      AndroidDeviceInfo into = await deviceInfo.androidInfo;
      setState(() {
        deviceInfoData = into.data;
      });
    }
    PermissionStatus permissionStatusLocation =
        await Permission.location.request();
    PermissionStatus mission = await Permission.storage.request();
    print(mission.name);
    PermissionStatus permissionStatusStoarge =
        await Permission.manageExternalStorage.request();

    if (permissionStatusLocation.isPermanentlyDenied) {
      openAppSettings();
    } else if (Platform.isAndroid &&
        permissionStatusStoarge.isPermanentlyDenied) {
      openAppSettings();
    }

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  AccelerometerEvent? accelerometerEvent;
  UserAccelerometerEvent? userAcceelerometerEvent;
  GyroscopeEvent? gyroscopeEvent;
  MagnetometerEvent? magnetometerEvet;
  Timer? timer;

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

  void _startRecording() async {
    setState(() {
      _isRecording = true;
      _logData.clear();
      _rideUUID = const Uuid().v4(); // Generate a new UUID for each ride
    });

    _location = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
    });
    _accelerometerSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        accelerometerEvent = event;
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
    _userAccelerometerEvent = userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        userAcceelerometerEvent = event;
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );

    _gyroscopeEvent = gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        gyroscopeEvent = event;
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );

    _magnetometerEvent = magnetometerEvents.listen(
      (MagnetometerEvent event) {
        print("Jelllo");
        magnetometerEvet = event;
        _logAccelerometerData(deviceInfoData, accelerometerEvent,
            userAcceelerometerEvent, gyroscopeEvent, magnetometerEvet);
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
  }

  void _logAccelerometerData(
      Map<String, dynamic> map,
      AccelerometerEvent? event,
      UserAccelerometerEvent? userEvent,
      GyroscopeEvent? gyroEvent,
      MagnetometerEvent? magnetometerEvent) {
    final timestamp = DateTime.now().toIso8601String();

    final latitude = _currentPosition?.latitude ?? 0.0;
    final longitude = _currentPosition?.longitude ?? 0.0;

    Map<String, dynamic> logEntryData = {
      "Timestamp": timestamp,
      "uuid": _rideUUID, // Use the UUID for the entire ride
      "Device Info": map,
      "Latitude": latitude,
      "Longitude": longitude,
      "AccelerometerEvent": event == null
          ? {}
          : {
              "X": event.x,
              "Y": event.y,
              "Z": event.z,
            },
      "UserAccelerometerEvent": userEvent == null
          ? {}
          : {
              "X": userEvent.x,
              "Y": userEvent.y,
              "Z": userEvent.z,
            },
      "GyroscopeEvent": gyroEvent == null
          ? {}
          : {
              "X": gyroEvent.x,
              "Y": gyroEvent.y,
              "Z": gyroEvent.z,
            },
      "MagnetometerEvent": magnetometerEvent == null
          ? {}
          : {
              "X": magnetometerEvent.x,
              "Y": magnetometerEvent.y,
              "Z": magnetometerEvent.z,
            },
    };
    setState(() {
      _logData.add(logEntryData);
    });
  }

  void _stopRecording() {
    _accelerometerSubscription?.cancel();
    _userAccelerometerEvent?.cancel();
    _gyroscopeEvent?.cancel();
    _magnetometerEvent?.cancel();
    _location?.cancel();

    _saveLogData();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _saveLogData() async {
    String jsonString = jsonEncode(_logData);

    await writeJson(jsonString);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Log data saved to download '),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accelerometer Logger'),
      ),
      body: Center(
        child: isLoading
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isRecording ? _stopRecording : _startCountdown,
                    child: Text(_isRecording ? 'Stop Recording' : 'Record'),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 48),
                      padding: const EdgeInsets.symmetric(
                          vertical: 60, horizontal: 100),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeEvent?.cancel();
    _magnetometerEvent?.cancel();
    _userAccelerometerEvent?.cancel();
    _location?.cancel();
    super.dispose();
  }

  Future<File> get _localFileIos async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory('${directory.path}/ride_logs');
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    return File('${dir.path}/logdata_$timestamp.json');
  }

  Future<File> get _localFileAndroid async {
    Directory baseDir = Directory('/storage/emulated/0/Download');
    final dir = Directory('${baseDir.path}/ride_logs');
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    return File('${dir.path}/logdata_$timestamp.json');
  }

  Future<File> writeJson(String jsonString) async {
    final file = await (Platform.isIOS ? _localFileIos : _localFileAndroid);
    return file.writeAsString(jsonString);
  }
}
