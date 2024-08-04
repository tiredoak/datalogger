import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showRatingDialog(BuildContext context) {
  String? tempBike = 'Brompton';

  return showDialog<Map<String, dynamic>?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Which bike did you use?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop({
                    'bike': tempBike,
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
