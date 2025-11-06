import 'package:flutter/widgets.dart' show State, StatefulWidget, ValueNotifier;
import 'package:qlutter/src/common/router/home_guard.dart';
import 'package:qlutter/src/common/router/routes.dart';
import 'package:octopus/octopus.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  late final Octopus router;
  late final ValueNotifier<List<({Object error, StackTrace stackTrace})>>
  errorsObserver;

  @override
  void initState() {
    //final dependencies = Dependencies.of(context);
    // Observe all errors.
    errorsObserver =
        ValueNotifier<List<({Object error, StackTrace stackTrace})>>(
          <({Object error, StackTrace stackTrace})>[],
        );

    // Create router.
    router = Octopus(
      routes: Routes.values,
      defaultRoute: Routes.levels,
      guards: <IOctopusGuard>[
        // Home route should be always on top.
        HomeGuard(),
      ],
      onError: (error, stackTrace) =>
          errorsObserver.value = <({Object error, StackTrace stackTrace})>[
            (error: error, stackTrace: stackTrace),
            ...errorsObserver.value,
          ],
      /* observers: <NavigatorObserver>[
        HeroController(),
      ], */
    );
    super.initState();
  }
}
