import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
    await _writeJson(jsonString);
  }

  Future<void> saveStreetData(String rideUUID) async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    List<Map<String, dynamic>> streetData = _uniqueStreets.map((e) {
      var data = jsonDecode(e);
      return {'uuid': rideUUID, 'street': data['street'], 'city': data['city']};
    }).toList();
    String jsonString = jsonEncode(streetData);
    await _writeStreetJson(jsonString, timestamp);
  }

  Future<File> _localFileIos(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory('${directory.path}/ride_logs');
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$filename');
  }

  Future<File> _localFileAndroid(String filename) async {
    Directory baseDir = Directory('/storage/emulated/0/Download');
    final dir = Directory('${baseDir.path}/ride_logs');
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$filename');
  }

  Future<void> _writeJson(String jsonString) async {
    final file = await (Platform.isIOS
        ? _localFileIos('logdata.json')
        : _localFileAndroid('logdata.json'));
    await file.writeAsString(jsonString);
  }

  Future<void> _writeStreetJson(String jsonString, String timestamp) async {
    final file = await (Platform.isIOS
        ? _localFileIos('streetdata_$timestamp.json')
        : _localFileAndroid('streetdata_$timestamp.json'));
    await file.writeAsString(jsonString);
  }

  int get uniqueStreetsCount => _uniqueStreets.length;
}
