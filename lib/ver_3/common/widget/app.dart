import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qlutter/ver_3/common/constant/config.dart';
import 'package:qlutter/ver_3/common/localization/localization.dart';
import 'package:qlutter/ver_3/common/router/router_state_mixin.dart';
import 'package:qlutter/ver_3/common/widget/overlay_menu.dart';
import 'package:qlutter/ver_3/common/widget/window_scope.dart';
import 'package:qlutter/ver_3/feature/game/widget/game_scope.dart';
import 'package:qlutter/ver_3/feature/settings/widget/settings_scope.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with RouterStateMixin {
  final Key builderKey = GlobalKey(); // Disable recreate widget tree

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'qlutter generator',
    debugShowCheckedModeBanner: !Config.environment.isProduction,

    // Router
    routerConfig: router.config,

    // Localizations
    localizationsDelegates: const <LocalizationsDelegate<Object?>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      Localization.delegate,
    ],
    supportedLocales: Localization.supportedLocales,
    /* locale: SettingsScope.localeOf(context), */

    // Theme
    theme: SettingsScope.themeOf(context),

    // Scopes
    builder: (context, child) => WindowScope(
      key: builderKey,
      title: Localization.of(context).title,

      child: OverlayMenu(
        router: router,
        child: GameScope(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );
}
