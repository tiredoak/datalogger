import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/reverse';

  Future<Map<String, String>> getStreetAndCity(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?format=geocodejson&lat=$lat&lon=$lon&zoom=18&addressdetails=1'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final properties = data['features'][0]['properties']['geocoding'];
      final street = properties['street'] ?? 'Unknown';
      final city = properties['city'] ?? 'Unknown';
      return {'street': street, 'city': city};
    } else {
      throw Exception('Failed to load location data');
    }
  }
}
