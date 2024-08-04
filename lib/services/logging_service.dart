import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  final List<Map<String, dynamic>> _logData = [];

  void logData(Map<String, dynamic> logEntry) {
    _logData.add(logEntry);
  }

  void clearLog() {
    _logData.clear();
  }

  Future<void> saveLog(String rideUUID, String? bike) async {
    for (var entry in _logData) {
      entry['uuid'] = rideUUID;
      entry['bike'] = bike ?? 'Brompton';
    }

    String jsonString = jsonEncode(_logData);
    await _writeJson(jsonString);
  }

  Future<File> _localFileIos() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory('${directory.path}/ride_logs');
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return File('${dir.path}/logdata_$timestamp.json');
  }

  Future<File> _localFileAndroid() async {
    Directory baseDir = Directory('/storage/emulated/0/Download');
    final dir = Directory('${baseDir.path}/ride_logs');
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return File('${dir.path}/logdata_$timestamp.json');
  }

  Future<void> _writeJson(String jsonString) async {
    final file = await (Platform.isIOS ? _localFileIos() : _localFileAndroid());
    await file.writeAsString(jsonString);
  }
}
