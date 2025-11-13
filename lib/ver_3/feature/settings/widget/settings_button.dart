import 'package:flutter/material.dart';
import 'package:qlutter/ver_3/feature/settings/widget/settings_screen.dart';

class SettingsIconButton extends StatelessWidget {
  /// {@macro profile_icon_button}
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.person),
    tooltip: 'Settings',
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
    },
  );
}
