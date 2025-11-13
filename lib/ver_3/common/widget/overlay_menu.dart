import 'package:flutter/material.dart';
import 'package:qlutter/ver_3/common/router/my_router.dart';
import 'package:qlutter/ver_3/common/router/routes.dart';

/// {@template overlay_menu}
/// OverlayMenu widget.
/// {@endtemplate}
class OverlayMenu extends StatefulWidget {
  /// {@macro overlay_menu}
  const OverlayMenu({required this.child, required this.router, this.navigator = true, super.key});

  /// Add additional navigator (for modal dialogs) to the widget tree.
  final bool navigator;

  /// The router instance for navigation
  final MyRouter router;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<OverlayMenu> createState() => _OverlayMenuState();
}

/// State for widget OverlayMenu.
class _OverlayMenuState extends State<OverlayMenu> with SingleTickerProviderStateMixin, _PanelController {
  late final FlowDelegate _overlayDelegate;

  @override
  void initState() {
    super.initState();
    _overlayDelegate = _OverlayMenuFlowDelegate(animation: _panelAnimationController);
  }

  Widget addNavigator(Widget child) => widget.navigator
      ? Navigator(
          reportsRouteUpdateToEngine: false,
          pages: <Page<Object?>>[MaterialPage<void>(child: child)],
          onPopPage: (route, result) => route.didPop(result),
        )
      : child;

  @override
  Widget build(BuildContext context) => _InheritedOverlayMenu(
    scope: this,
    child: addNavigator(
      Flow(
        delegate: _overlayDelegate,
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          _MenuRail(router: widget.router),
          widget.child,
        ],
      ),
    ),
  );
}

mixin _PanelController on State<OverlayMenu>, SingleTickerProviderStateMixin<OverlayMenu> {
  late final AnimationController _panelAnimationController;
  final ValueNotifier<Widget?> _panelNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _panelAnimationController = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
  }

  @override
  void dispose() {
    _panelAnimationController.dispose();
    _panelNotifier.dispose();
    super.dispose();
  }

  Future<void> showPanel(Widget panel) async {
    await hidePanel();
    _panelNotifier.value = panel;
    await _panelAnimationController.forward().catchError((_, __) {});
  }

  Future<void> hidePanel() async {
    if (_panelAnimationController.isDismissed && _panelNotifier.value == null) return;
    await _panelAnimationController.reverse().catchError((_, __) {});
    _panelNotifier.value = null;
  }
}

class _InheritedOverlayMenu extends InheritedWidget {
  const _InheritedOverlayMenu({required this.scope, required super.child});

  final _OverlayMenuState scope;

  @override
  bool updateShouldNotify(covariant _InheritedOverlayMenu oldWidget) => false;
}

class _OverlayMenuFlowDelegate extends FlowDelegate {
  _OverlayMenuFlowDelegate({this.animation}) : super(repaint: animation);

  static const double railWidth = 72;

  final Animation<double>? animation;

  @override
  void paintChildren(FlowPaintingContext context) {
    context
      ..paintChild(0, transform: Matrix4.translationValues(0, 0, 0))
      ..paintChild(1, transform: Matrix4.translationValues(railWidth, 0, 0));
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) => switch (i) {
    0 => BoxConstraints.tightFor(width: railWidth, height: constraints.maxHeight),
    1 => BoxConstraints.tightFor(width: constraints.maxWidth - railWidth, height: constraints.maxHeight),
    _ => throw Exception('Invalid index: $i'),
  };

  @override
  bool shouldRepaint(covariant _OverlayMenuFlowDelegate oldDelegate) => !identical(oldDelegate.animation, animation);
}

class _MenuRail extends StatefulWidget {
  final MyRouter router;

  const _MenuRail({required this.router});

  @override
  State<_MenuRail> createState() => _MenuRailState();
}

class _MenuRailState extends State<_MenuRail> {
  final List<({String name, NavigationRailDestination destination, Routes route})> _destinations = [
    (name: Routes.levels.name, route: Routes.levels, destination: NavigationRailDestination(icon: Icon(Icons.gamepad), label: Text('Levels'))),
    (name: Routes.settings.name, route: Routes.settings, destination: NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings'))),
  ];

  Routes _getCurrentRoute() {
    final delegate = widget.router.config?.routerDelegate;
    if (delegate is MyRouterDelegate) {
      return delegate.currentRoute();
    }
    return widget.router.defaultRoute;
  }

  void _navigateTo(Routes route) {
    final delegate = widget.router.config?.routerDelegate;
    if (delegate is MyRouterDelegate) {
      delegate.navigateTo(route);
    } else {
      // Fallback для традиционной навигации
      Navigator.of(context).pushNamed(route.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _getCurrentRoute();
    final currentIndex = _destinations.indexWhere((element) => element.route == currentRoute);

    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: _OverlayMenuFlowDelegate.railWidth,
        child: NavigationRail(
          selectedIndex: currentIndex >= 0 ? currentIndex : null,
          destinations: _destinations.map((e) => e.destination).toList(),
          onDestinationSelected: (index) {
            if (index == currentIndex) return;
            final destination = _destinations[index];
            _navigateTo(destination.route);
          },
          extended: false,
          minWidth: _OverlayMenuFlowDelegate.railWidth,
          minExtendedWidth: _OverlayMenuFlowDelegate.railWidth,
          elevation: 4,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
