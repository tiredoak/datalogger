import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showRatingDialog(
    BuildContext context, int? roadQuality, String? roadType) {
  int? tempRoadQuality = roadQuality;
  String? tempRoadType = roadType;
  String? tempBike = 'Brompton';
  String? tempMount = 'good';
  String? tempMountPosition = 'vertical';

  return showDialog<Map<String, dynamic>?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('How good was the road?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: tempRoadQuality,
                  items: const [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('1 - Bad'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('2 - Average'),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text('3 - Good'),
                    ),
                  ],
                  onChanged: (int? newValue) {
                    setState(() {
                      tempRoadQuality = newValue;
                    });
                  },
                  hint: const Text('Select road quality (1-3)'),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: tempRoadType,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'cobblestone',
                      child: Text('Cobblestone'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'asphalt',
                      child: Text('Asphalt'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      tempRoadType = newValue;
                    });
                  },
                  hint: const Text('Select road type'),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: tempBike,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Gira',
                      child: Text('Gira'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Brompton',
                      child: Text('Brompton'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      tempBike = newValue;
                    });
                  },
                  hint: const Text('Select bike (Gira or Brompton)'),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: tempMount,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'bad',
                      child: Text('Bad mount'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'good',
                      child: Text('Good mount'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      tempMount = newValue;
                    });
                  },
                  hint: const Text('Select mount (bad or good)'),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: tempMountPosition,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'horizontal',
                      child: Text('Horizontal'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'vertical',
                      child: Text('Vertical'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      tempMountPosition = newValue;
                    });
                  },
                  hint: const Text(
                      'Select mount position (horizontal or vertical)'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop({
                    'roadQuality': tempRoadQuality,
                    'roadType': tempRoadType,
                    'bike': tempBike,
                    'mount': tempMount,
                    'mountPosition': tempMountPosition,
                  });
                },
              ),
            ],
          );
        },
      );
    },
  );
}
