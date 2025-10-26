import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RepeatToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RepeatToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85, // make slightly smaller if needed
      child: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        inactiveTrackColor: const Color.fromARGB(55, 33, 149, 243),
        activeTrackColor: Colors.green, // track color when ON
        thumbColor: Colors.white, // fixed thumb color
      ),
    );
  }
}
