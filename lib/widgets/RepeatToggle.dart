import 'package:flutter/material.dart';

class RepeatToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RepeatToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeThumbColor: Colors.green,
      value: value,
      splashRadius: 0,
      onChanged: onChanged,
      inactiveThumbColor: Colors.grey,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
