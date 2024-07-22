import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showRatingDialog(BuildContext context, int? roadQuality, String? roadType) {
  int? tempRoadQuality = roadQuality;
  String? tempRoadType = roadType;

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
                  items: List.generate(10, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    );
                  }),
                  onChanged: (int? newValue) {
                    setState(() {
                      tempRoadQuality = newValue;
                    });
                  },
                  hint: const Text('Select road quality (1-10)'),
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
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop({
                    'roadQuality': tempRoadQuality,
                    'roadType': tempRoadType,
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
