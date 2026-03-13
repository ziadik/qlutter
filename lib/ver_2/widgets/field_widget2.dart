import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qlutter/map_editor/playground_ui.dart';
import 'package:qlutter/ver_2/constants/app_constants.dart';
import 'package:qlutter/ver_2/game/field_engine.dart';
import 'package:qlutter/ver_2/models/animated_ball.dart';
import 'package:qlutter/ver_2/models/coordinates.dart';
import 'package:qlutter/ver_2/models/item.dart';
import 'package:qlutter/ver_2/models/level.dart';
import 'package:qlutter/ver_2/widgets/level_stats_widget.dart';

class FieldWidget extends StatefulWidget {
  const FieldWidget({required this.level, required this.levelNumber, required this.wrap_level_navigation, super.key, this.onLevelComplete});

  final Level level;
  final int levelNumber;
  final VoidCallback? onLevelComplete;
  final Widget Function(Widget child) wrap_level_navigation;

  @override
  State<FieldWidget> createState() => _FieldWidgetState();
}

class _FieldWidgetState extends State<FieldWidget> {
  late FieldEngine _engine;
  double _elementSize = AppConstants.elementMinSizeDesktop;
  Timer? _timer;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _engine = FieldEngine(widget.level);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isAnimating) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(FieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _timer?.cancel();
      _engine.resetLevel(widget.level);
      _startTimer();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        _elementSize = _calculateOptimalElementSize(constraints, isLandscape, mediaQuery);

        final fieldWidth = (_elementSize * (_engine.level.width + 1)) + 4;
        final fieldHeight = (_elementSize * (_engine.level.height + 1)) + 4;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Статистика уровня
            widget.wrap_level_navigation(
              SizedBox(
                width: fieldWidth - ((isLandscape ? 1 : 3) * _elementSize),
                child: LevelStatsWidget(stats: _engine.stats, initialBallsCount: _engine.initialBallsCount, currentBallsCount: _engine.ballsCount),
              ),
            ),
            const Spacer(),

            // Игровое поле с PlayGround
            SizedBox(
              width: fieldWidth + _elementSize,
              height: fieldHeight + _elementSize,
              child: PlayGround(
                elementSize: _elementSize,
                levelId: widget.levelNumber - 1,
                h: _engine.level.height + 1,
                w: _engine.level.width + 1,
                fieldEngine: _engine,
                onBallMoved: _makeMove,
                isEditorMode: false,
              ),
            ),
            const Spacer(),
          ],
        );
      },
    );
  }

  void _makeMove(Coordinates coords, Direction direction) {
    if (_isAnimating) return;

    final result = _engine.makeTurn(coords, direction);

    if (result.moved) {
      if (_engine.isAnimating) {
        setState(() {
          _isAnimating = true;
        });
      } else {
        setState(() {});
      }
    }
  }

  void _onAnimationComplete() {
    _engine.completeAnimation();
    setState(() {
      _isAnimating = false;
    });

    if (_engine.isLevelComplete) {
      widget.onLevelComplete?.call();
    }
  }

  double _calculateOptimalElementSize(BoxConstraints constraints, bool isLandscape, MediaQueryData mediaQuery) {
    final availableWidth = constraints.maxWidth - AppConstants.defaultPadding * 2;
    final availableHeight = constraints.maxHeight * (isLandscape ? 0.85 : 0.95) - AppConstants.statusBarHeight;

    final widthBasedSize = availableWidth / (_engine.level.width + 1);
    final heightBasedSize = availableHeight / (_engine.level.height + 1);

    double elementSize = min(widthBasedSize, heightBasedSize);

    final minSize = mediaQuery.size.shortestSide < 600
        ? AppConstants.elementMinSizeMobile
        : mediaQuery.size.shortestSide < 900
        ? AppConstants.elementMinSizeTablet
        : AppConstants.elementMinSizeDesktop;

    final maxSize = mediaQuery.size.shortestSide < 600
        ? AppConstants.elementMaxSizeMobile
        : mediaQuery.size.shortestSide < 900
        ? AppConstants.elementMaxSizeTablet
        : AppConstants.elementMaxSizeDesktop;

    return elementSize.clamp(minSize, maxSize);
  }
}
