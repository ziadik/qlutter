import 'package:flutter/material.dart';
import 'package:qlutter/ver_3/common/router/home_guard.dart';
import 'package:qlutter/ver_3/common/router/routes.dart';

class MyRouter {
  final List<Routes> routes;
  final Routes defaultRoute;
  final List<HomeGuard> guards;
  final Function(Object error, StackTrace stackTrace)? onError;
  final List<NavigatorObserver> observers;

  RouterConfig<Object>? config;

  MyRouter({required this.routes, required this.defaultRoute, required this.guards, this.onError, this.observers = const []}) {
    _initializeRouterConfig();
  }

  // Initialize router config
  void _initializeRouterConfig() {
    final routeInformationParser = _MyRouteInformationParser();
    final routerDelegate = MyRouterDelegate(this);

    config = RouterConfig(
      routeInformationProvider: PlatformRouteInformationProvider(initialRouteInformation: RouteInformation(location: defaultRoute.name)),
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
    );
  }

  // Method to generate routes
  Route<dynamic>? generateRoute(RouteSettings settings) {
    try {
      // Apply guards
      for (final guard in guards) {
        final route = _getRouteFromName(settings.name);
        if (route != null && !guard.canActivate(route)) {
          return _buildRoute(defaultRoute, settings);
        }
      }

      // Find the matching route
      final route = _getRouteFromName(settings.name);
      if (route != null && routes.contains(route)) {
        return _buildRoute(route, settings);
      }

      // Fallback to default route
      return _buildRoute(defaultRoute, settings);
    } catch (error, stackTrace) {
      // Handle errors
      onError?.call(error, stackTrace);
      return _buildRoute(defaultRoute, settings);
    }
  }

  // Helper method to convert route name to Routes enum
  Routes? _getRouteFromName(String? name) {
    if (name == null) return null;

    try {
      return Routes.values.firstWhere((route) => route.name == name);
    } catch (e) {
      return null;
    }
  }

  // Build actual route
  MaterialPageRoute _buildRoute(Routes route, RouteSettings settings) {
    WidgetBuilder builder;

    builder = (context) => route.builder(context); // Replace with your actual widget

    return MaterialPageRoute(builder: builder, settings: settings);
  }

  void resetRouterConfig() {
    config = null;
    _initializeRouterConfig();
  }
}

// Custom Route Information Parser
class _MyRouteInformationParser extends RouteInformationParser<Routes> {
  @override
  Future<Routes> parseRouteInformation(RouteInformation routeInformation) async {
    final routeName = routeInformation.location;
    if (routeName == null) return Routes.levels;

    try {
      return Routes.values.firstWhere((route) => route.name == routeName);
    } catch (e) {
      return Routes.levels;
    }
  }

  @override
  RouteInformation restoreRouteInformation(Routes configuration) {
    return RouteInformation(location: configuration.name);
  }
}

// Custom Router Delegate
class MyRouterDelegate extends RouterDelegate<Routes> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Routes> {
  final MyRouter router;

  MyRouterDelegate(this.router);

  Routes _currentRoute = Routes.levels;
  List<Routes> _routeStack = [Routes.levels];

  Routes currentRoute() => _currentRoute;

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Routes get currentConfiguration => _currentRoute;

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    observers: router.observers,
    pages: _routeStack.map((route) => MaterialPage(child: _buildPageForRoute(context, route), key: ValueKey(route.name), name: route.name)).toList(),
    onPopPage: (route, result) {
      if (!route.didPop(result)) return false;

      if (_routeStack.length > 1) {
        _routeStack.removeLast();
        _currentRoute = _routeStack.last;
        notifyListeners();
      }

      return true;
    },
  );

  Widget _buildPageForRoute(BuildContext context, Routes route) {
    Widget? r = route.builder(context);
    return r ?? Placeholder();
  }

  @override
  Future<void> setNewRoutePath(Routes configuration) async {
    // Apply guards
    for (final guard in router.guards) {
      if (!guard.canActivate(configuration)) {
        _currentRoute = router.defaultRoute;
        _routeStack = [router.defaultRoute];
        notifyListeners();
        return;
      }
    }

    _currentRoute = configuration;
    _routeStack = [configuration];
    notifyListeners();
  }

  // Method to navigate to a new route
  void navigateTo(Routes route) {
    // Apply guards
    for (final guard in router.guards) {
      if (!guard.canActivate(route)) {
        return;
      }
    }

    _routeStack.add(route);
    _currentRoute = route;
    notifyListeners();
  }

  // Method to replace current route
  void replaceWith(Routes route) {
    // Apply guards
    for (final guard in router.guards) {
      if (!guard.canActivate(route)) {
        return;
      }
    }

    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }
    _routeStack.add(route);
    _currentRoute = route;
    notifyListeners();
  }

  // Method to clear stack and go to route
  void pushAndRemoveUntil(Routes route) {
    // Apply guards
    for (final guard in router.guards) {
      if (!guard.canActivate(route)) {
        return;
      }
    }

    _routeStack = [route];
    _currentRoute = route;
    notifyListeners();
  }
}
