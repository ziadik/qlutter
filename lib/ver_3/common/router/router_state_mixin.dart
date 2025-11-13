import 'package:flutter/widgets.dart' show State, StatefulWidget, ValueNotifier;
import 'package:qlutter/ver_3/common/router/home_guard.dart';
import 'package:qlutter/ver_3/common/router/my_router.dart';
import 'package:qlutter/ver_3/common/router/routes.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  late final MyRouter router;
  late final ValueNotifier<List<({Object error, StackTrace stackTrace})>> errorsObserver;

  @override
  void initState() {
    //final dependencies = Dependencies.of(context);
    // Observe all errors.
    errorsObserver = ValueNotifier<List<({Object error, StackTrace stackTrace})>>(<({Object error, StackTrace stackTrace})>[]);

    // Create router.
    router = MyRouter(
      routes: Routes.values,
      defaultRoute: Routes.levels,
      guards: [
        // Home route should be always on top.
        HomeGuard(),
      ],
      onError: (error, stackTrace) => errorsObserver.value = <({Object error, StackTrace stackTrace})>[(error: error, stackTrace: stackTrace), ...errorsObserver.value],
      /* observers: <NavigatorObserver>[
        HeroController(),
      ], */
    );
    super.initState();
  }
}
