import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:qlutter/src/feature/game/widget/game_screen.dart';
import 'package:qlutter/src/feature/settings/widget/settings_screen.dart';

enum Routes with OctopusRoute {
  levels('levels', title: 'Levels'),
  level('level', title: 'Level'),
  settings('settings', title: 'Settings');
  // about('about', title: 'About'),
  // developer('developer', title: 'Developer');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) =>
      switch (this) {
        Routes.levels => const GameScreen(),
        Routes.level => const GameScreen(),

        Routes.settings => const SettingsScreen(),
        // Routes.about => const AboutScreen(),
        // Routes.developer => const DeveloperScreen(),
      };
}
