import 'package:flutter/widgets.dart';

/// {@template game_scope}
/// GameScope widget.
/// {@endtemplate}
class GameScope extends StatefulWidget {
  /// {@macro game_scope}
  const GameScope({
    required this.child,
    super.key, // ignore: unused_element
  });

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<GameScope> createState() => _GameScopeState();
}

/// State for widget GameScope.
class _GameScopeState extends State<GameScope> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(covariant GameScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }

  /* #endregion */

  @override
  Widget build(BuildContext context) =>
      _InheritedGameScope(state: this, child: widget.child);
}

/// Inherited widget for quick access in the element tree.
class _InheritedGameScope extends InheritedWidget {
  const _InheritedGameScope({required this.state, required super.child});

  final _GameScopeState state;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `GameScope.maybeOf(context)`.
  static _InheritedGameScope? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) => listen
      ? context.dependOnInheritedWidgetOfExactType<_InheritedGameScope>()
      : context.getInheritedWidgetOfExactType<_InheritedGameScope>();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedGameScope of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `GameScope.of(context)`.
  static _InheritedGameScope of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedGameScope oldWidget) => false;
}
