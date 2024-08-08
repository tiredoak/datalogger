import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';

class LoggingService {
  final List<Map<String, dynamic>> _logData = [];
  final Set<String> _uniqueStreets = {};

  void logData(Map<String, dynamic> logEntry) {
    _logData.add(logEntry);
  }

  void logStreetData(String street, String city) {
    _uniqueStreets.add(jsonEncode({'street': street, 'city': city}));
  }

  void clearLog() {
    _logData.clear();
    _uniqueStreets.clear();
  }

  Future<void> saveLog(String rideUUID, String? bike) async {
    for (var entry in _logData) {
      entry['uuid'] = rideUUID;
      entry['bike'] = bike ?? 'Brompton';
    }

    String jsonString = jsonEncode(_logData);
    String timestamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[-:.]'), '');
    await _writeJson(jsonString, 'rides/sensors_$timestamp.json');
  }

  Future<void> saveStreetData(String rideUUID) async {
    List<Map<String, dynamic>> streetData = _uniqueStreets.map((e) {
      var data = jsonDecode(e);
      return {'uuid': rideUUID, 'street': data['street'], 'city': data['city']};
    }).toList();
    String jsonString = jsonEncode(streetData);
    String timestamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[-:.]'), '');
    await _writeJson(jsonString, 'streets/streets_${rideUUID}_$timestamp.json');
  }

  Future<File> _localFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final subDir = filename.startsWith('rides/')
        ? 'rides'
        : filename.startsWith('streets/')
            ? 'streets'
            : '';
    final dir = Directory('${directory.path}/ride_logs/$subDir');
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/${filename.split('/').last}');
  }

  Future<void> _writeJson(String jsonString, String filename) async {
    final file = await _localFile(filename);
    await file.writeAsString(jsonString);
  }

  Future<List<List<LatLng>>> getAllRoutes() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory('${directory.path}/ride_logs/rides');
    List<List<LatLng>> routes = [];

    if (await dir.exists()) {
      final files = dir.listSync().where((item) => item.path.endsWith('.json'));
      for (var file in files) {
        String content = await File(file.path).readAsString();
        List<dynamic> jsonData = jsonDecode(content);
        List<LatLng> route = jsonData.map((entry) {
          return LatLng(entry['latitude'], entry['longitude']);
        }).toList();
        routes.add(route);
      }
    }
    return routes;
  }

  int get uniqueStreetsCount => _uniqueStreets.length;
}
