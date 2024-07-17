// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
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
  Position? _currentPosition;
  bool _isRecording = false;
  final List<String> _logData = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    PermissionStatus statusLocation = await Permission.location.request();
    //  PermissionStatus statusSensor= await Permission.sensors.request();
    print(statusLocation.name);
    //  print(statusSensor.name);
  }

  Timer? timer;
  void _startRecording() async {
    setState(() {
      _isRecording = true;
      _logData.clear();
    });

    // _accelerometerSubscription = accelerometerEventStream().listen(
    //   (AccelerometerEvent event) {
    //     print(event);
    //   },
    //   onError: (error) {
    //     print(error);
    //     // Logic to handle error
    //     // Needed for Android in case sensor is not available
    //   },
    //   cancelOnError: true,
    // );
    Geolocator.getPositionStream().listen((Position position) {
      _currentPosition = position;
    });
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _logAccelerometerData(iosInfo.data);
    });
  }

  void _logAccelerometerData(Map<String, dynamic> map) {
    final timestamp = DateTime.now().toIso8601String();

    final latitude = _currentPosition?.latitude ?? 0.0;
    final longitude = _currentPosition?.longitude ?? 0.0;

    final logEntry =
        'Timestamp: $timestamp, Device Info: $map, Latitude: $latitude,Longiture: $longitude';
    setState(() {
      _logData.add(logEntry);
    });
  }

  void _stopRecording() {
    _accelerometerSubscription?.cancel();
    timer!.cancel();
    _saveLogData();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _saveLogData() async {
    print("Hello");
    for (var element in _logData) {
      print(element);
    }
    // final directory = await getApplicationDocumentsDirectory();
    // final filePath = '${directory.path}/accelerometer_log.csv';
    // final file = File(filePath);

    // final logFileData = 'Timestamp,Device Info,X,Y,Z,Latitude,Longitude\n${_logData.join('\n')}';
    // await file.writeAsString(logFileData);

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('Log data saved to $filePath'),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accelerometer Logger'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          child: Text(_isRecording ? 'Stop Recording' : 'Record'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
}
