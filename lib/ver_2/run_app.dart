//import 'package:qlutter/fox_render_box/example_app_runner.dart';

import 'package:flutter/material.dart';
import 'package:qlutter/ver_2/app.dart';
import 'package:qlutter/ver_2/game/level_manager.dart';
import 'package:qlutter/ver_2/models/app_state.dart';
import 'package:qlutter/ver_2/services/storage_service.dart';

void runAppVer2() async {
  WidgetsFlutterBinding.ensureInitialized();

  final levelManager = LevelManager();
  await levelManager.initialize();

  // Загружаем начальное состояние
  final currentLevel = await StorageService.getCurrentLevel();
  final completedLevels = await StorageService.getCompletedLevels();

  final initialState = AppState(currentLevel: currentLevel, completedLevels: completedLevels, isLoading: false, levelManager: levelManager);

  runApp(QOOXApp(initialState: initialState));
}
