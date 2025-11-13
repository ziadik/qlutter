import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:qlutter/ver_3/common/widget/app.dart';
import 'package:qlutter/ver_3/common/widget/app_error.dart';
import 'package:qlutter/ver_3/common/widget/inherited_dependencies.dart';
import 'package:qlutter/ver_3/feature/initialization/data/initialization.dart';
import 'package:qlutter/ver_3/feature/settings/widget/settings_scope.dart';

void runAppVer3() => runZonedGuarded<void>(() {
  // Splash screen
  final initializationProgress = ValueNotifier<({int progress, String message})>((progress: 0, message: ''));
  /* runApp(SplashScreen(progress: initializationProgress)); */
  $initializeApp(
    onProgress: (progress, message) => initializationProgress.value = (progress: progress, message: message),
    onSuccess: (dependencies) => runApp(
      InheritedDependencies(
        dependencies: dependencies,
        child: const SettingsScope(child: App()),
      ),
    ),
    onError: (error, stackTrace) {
      runApp(AppError(error: error));
      // ErrorUtil.logError(error, stackTrace).ignore();
    },
  ).ignore();
}, (error, stack) {});
