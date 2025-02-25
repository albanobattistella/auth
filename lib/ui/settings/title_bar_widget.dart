import 'package:flutter/material.dart';

class SettingsTitleBarWidget extends StatelessWidget {
  const SettingsTitleBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.keyboard_double_arrow_left_outlined),
            ),
            const Text("Settings"),
          ],
        ),
      ),
    );
  }
}
