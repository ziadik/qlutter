import 'dart:async';

import 'package:platform_info/platform_info.dart';
// import 'package:qlutter/src/common/database/database.dart';
import 'package:qlutter/ver_3/common/model/app_metadata.dart';
import 'package:qlutter/ver_3/common/model/dependencies.dart';
// import 'package:qlutter/src/common/util/dio_proxy.dart';
// import 'package:qlutter/src/common/util/http_log_interceptor.dart';
// import 'package:qlutter/src/common/util/log_buffer.dart';
import 'package:qlutter/ver_3/common/util/screen_util.dart';
import 'package:qlutter/ver_3/constants/pubspec.yaml.g.dart';
import 'package:qlutter/ver_3/feature/initialization/data/platform/platform_initialization.dart';
// import 'package:qlutter/src/feature/initialization/data/app_migrator.dart';
// import 'package:qlutter/src/feature/initialization/data/platform/platform_initialization.dart';
// import 'package:qlutter/src/feature/qlutter/data/qlutters_local_data_provider.dart';
// import 'package:qlutter/src/feature/qlutter/data/qlutters_repository.dart';
// import 'package:qlutter/src/feature/organizations/data/organizations_data_provider.dart';
// import 'package:qlutter/src/feature/organizations/data/organizations_repository.dart';
// import 'package:l/l.dart';
// import 'package:platform_info/platform_info.dart';
// import 'package:rxdart/rxdart.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({void Function(int progress, String message)? onProgress}) async {
  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);

      await step.value(dependencies);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace('Initialization failed at step "${step.key}": $error', stackTrace);
    }
  }
  return dependencies;
}

typedef _InitializationStep = FutureOr<void> Function(Dependencies dependencies);
final Map<String, _InitializationStep> _initializationSteps = <String, _InitializationStep>{
  'Platform pre-initialization': (_) => $platformInitialization(),

  'Creating app metadata': (dependencies) => dependencies.metadata = AppMetadata(
    isWeb: platform.js,
    isRelease: platform.buildMode.release,
    appName: Pubspec.name,
    appVersion: Pubspec.version.representation,
    appVersionMajor: Pubspec.version.major,
    appVersionMinor: Pubspec.version.minor,
    appVersionPatch: Pubspec.version.patch,
    appBuildTimestamp: Pubspec.version.build.isNotEmpty ? (int.tryParse(Pubspec.version.build.firstOrNull ?? '-1') ?? -1) : -1,
    operatingSystem: platform.operatingSystem.name,
    processorsCount: platform.numberOfProcessors,
    appLaunchedTimestamp: DateTime.now(),
    locale: platform.locale,
    deviceVersion: platform.version,
    deviceScreenSize: ScreenUtil.screenSize().representation,
  ),
  'Initializing analytics': (_) {},
  'Log app open': (_) {},
  'Get remote config': (_) {},
  'Restore settings': (_) {},

  'Initialize localization': (_) {},

  'Log app initialized': (_) {},
};
