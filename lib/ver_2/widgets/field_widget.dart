import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qlutter/ver_2/constants/app_constants.dart';
import 'package:qlutter/ver_2/game/field_engine.dart';
import 'package:qlutter/ver_2/models/animated_ball.dart';
import 'package:qlutter/ver_2/models/coordinates.dart';
import 'package:qlutter/ver_2/models/item.dart';
import 'package:qlutter/ver_2/models/level.dart';
import 'package:qlutter/ver_2/widgets/advanced_animated_ball_widget.dart';
// import 'package:qlutter/ver_2/widgets/animated_ball_widget.dart';
import 'package:qlutter/ver_2/widgets/level_stats_widget.dart';
import 'package:ui/ui.dart';

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
  Coordinates? _startDragCoords;
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
            // const SizedBox(height: AppConstants.smallPadding),

            // Управление историей (блокируем во время анимации)
            // HistoryControlWidget(
            //   canUndo: _engine.canUndo && !_isAnimating,
            //   canRedo: _engine.canRedo && !_isAnimating,
            //   canReset: _engine.canReset && !_isAnimating,
            //   historySize: _engine.historySize,
            //   onUndo: _isAnimating ? () {} : _undo,
            //   onRedo: _isAnimating ? () {} : _redo,
            //   onReset: _isAnimating ? () {} : _resetToBeginning,
            // ),
            // const SizedBox(height: AppConstants.smallPadding),

            // Игровое поле
            SizedBox(
              width: fieldWidth + _elementSize,
              height: fieldHeight + _elementSize,
              // decoration: BoxDecoration(
              //   color: AppConstants.backgroundColor,
              //   border: Border.all(color: Colors.grey.shade300, width: 2),
              //   borderRadius: BorderRadius.circular(12),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.1),
              //       blurRadius: 8,
              //       offset: const Offset(2, 2),
              //     ),
              //   ],
              // ),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(12),
              //   child:
              // ),
              child: PlayGround(
                elementSize: _elementSize,
                levelId: widget.levelNumber - 1,
                middle: Stack(
                  children: [
                    // Статичное игровое поле
                    // _buildPlayGround(),
                    _buildFieldGrid(),
                    // Анимированные шары поверх статичного поля
                    if (_engine.isAnimating && _engine.currentAnimatedBall != null) _buildAnimatedBall(_engine.currentAnimatedBall!),
                  ],
                ),
                h: _engine.level.height + 1,
                w: _engine.level.width + 1,
              ),
            ),
            const Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedBall(AnimatedBall animatedBall) => Positioned(
    left: animatedBall.currentPosition.x * _elementSize,
    top: animatedBall.currentPosition.y * _elementSize,
    child: AdvancedAnimatedBallWidget(animatedBall: animatedBall, elementSize: _elementSize, onAnimationComplete: _onAnimationComplete),
  );
  void _onAnimationComplete() {
    _engine.completeAnimation();
    setState(() {
      _isAnimating = false;
    });

    // Проверяем завершение уровня после анимации
    if (_engine.isLevelComplete) {
      widget.onLevelComplete?.call();
    }
  }

  void _makeMove(Coordinates coords, Direction direction) {
    if (_isAnimating) return;

    final result = _engine.makeTurn(coords, direction);

    if (result.moved) {
      // Запускаем анимацию
      if (_engine.isAnimating) {
        setState(() {
          _isAnimating = true;
        });
        _engine.prepareMoveAnimation();
      } else {
        setState(() {});

        if (result.levelComplete) {
          widget.onLevelComplete?.call();
        }
      }
    }
  }

  void _undo() {
    if (_isAnimating) return;

    if (_engine.undo()) {
      setState(() {});
    }
  }

  void _redo() {
    if (_isAnimating) return;

    if (_engine.redo()) {
      setState(() {});
    }
  }

  void _resetToBeginning() {
    if (_isAnimating) return;

    if (_engine.resetToBeginning()) {
      setState(() {});
    }
  }

  void _resetLevel() {
    if (_isAnimating) return;

    _engine.resetLevel(widget.level);
    setState(() {});
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

  // Widget _buildStatusBar() => Container(
  //   height: AppConstants.statusBarHeight,
  //   padding: const EdgeInsets.symmetric(
  //     horizontal: AppConstants.defaultPadding,
  //   ),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       // Простая кнопка сброса уровня
  //       IconButton(
  //         icon: const Icon(Icons.refresh, size: AppConstants.iconSize),
  //         onPressed: _resetLevel,
  //         tooltip: 'Быстрый сброс уровня',
  //       ),

  //       // Счетчик шаров
  //       Text(
  //         '${AppConstants.ballCountText}${_engine.ballsCount}',
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),

  //       // Индикатор истории
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //         decoration: BoxDecoration(
  //           color: AppConstants.primaryColor.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Text(
  //           'Ходы: ${_engine.historySize - 1}',
  //           style: const TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500,
  //             color: AppConstants.primaryColor,
  //           ),
  //         ),
  //       ),
  //     ],
  //   ),
  // );

  Widget _buildFieldGrid() => Column(
    children: [
      for (int y = 0; y < _engine.level.height; y++)
        SizedBox(
          height: _elementSize,
          child: Row(
            children: [for (int x = 0; x < _engine.level.width; x++) SizedBox(width: _elementSize, height: _elementSize, child: _buildFieldElement(x, y))],
          ),
        ),
    ],
  );

  // Widget _buildPlayGround() => PlayGround(elementSize: _elementSize);

  Widget _buildFieldElement(int x, int y) {
    final item = _engine.level.field[y][x];
    // final padding = EdgeInsets.all(
    //   _elementSize * AppConstants.elementPaddingRatio,
    // );

    // Не показываем статичный шар если он анимируется
    final isBallAnimating =
        _engine.isAnimating &&
        _engine.currentAnimatedBall != null &&
        _engine.currentAnimatedBall!.targetPosition != null &&
        _engine.currentAnimatedBall!.targetPosition!.x == x &&
        _engine.currentAnimatedBall!.targetPosition!.y == y;

    if (isBallAnimating && item is Ball) {
      return Container(
        // padding: padding,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(_elementSize * AppConstants.elementBorderRadius), color: Colors.transparent),
        ),
      );
    }
    if (item is Block) {
      return Container(
        // padding: padding,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(_elementSize * AppConstants.elementBorderRadius), color: Colors.transparent),
        ),
      );
    }

    return GestureDetector(
      onTap: () {}, // => _onElementTap(x, y),
      // onPanStart: _onDragStart,
      // onPanEnd: _onDragEnd,
      onPanUpdate: (details) => _onPanUpdate(details, x, y),
      child: Container(
        // padding: padding,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_elementSize * ((item is Ball) ? 0.5 : AppConstants.elementBorderRadius)),
            color: _getColorForItem(item),
            boxShadow: _getElementShadow(item),
          ),
          child: _buildItemSpecialContent(item),
        ),
      ),
    );
  }

  List<BoxShadow> _getElementShadow(Item? item) {
    if (item == null) return [];

    if (item is Block) {
      return [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 2, offset: const Offset(1, 1))];
    } else if (item is Ball) {
      return [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 3, offset: const Offset(2, 2))];
    }

    return [];
  }

  Widget _buildItemSpecialContent(Item? item) {
    if (item == null) return const SizedBox();

    if (item is Hole) {
      return Container(
        margin: EdgeInsets.all(_elementSize * 0.15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_elementSize * 0.25),
          border: Border.all(color: Colors.black.withOpacity(0.4), width: max(2, _elementSize * 0.08)),
        ),
      );
    }

    return const SizedBox();
  }

  Color _getColorForItem(Item? item) {
    if (item == null) return Colors.transparent;

    switch (item.color) {
      case ItemColor.green:
        return AppConstants.ballGreen;
      case ItemColor.red:
        return AppConstants.ballRed;
      case ItemColor.blue:
        return AppConstants.ballBlue;
      case ItemColor.yellow:
        return AppConstants.ballYellow;
      case ItemColor.purple:
        return AppConstants.ballPurple;
      case ItemColor.cyan:
        return AppConstants.ballCyan;
      case ItemColor.gray:
        return AppConstants.blockGray;
    }
  }

  // Обработчик тапа на элемент (для десктопной версии)
  void _onElementTap(int x, int y) {
    if (_isDesktopPlatform()) {
      final item = _engine.level.field[y][x];
      if (item is Ball) {
        _showDirectionMenu(x, y);
      }
    }
  }

  bool _isDesktopPlatform() => kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux;

  void _showDirectionMenu(int x, int y) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        title: const Text('Выберите направление'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDirectionButton('⬆️ Вверх', Direction.up, x, y),
            _buildDirectionButton('⬇️ Вниз', Direction.down, x, y),
            _buildDirectionButton('< Влево', Direction.left, x, y),
            _buildDirectionButton('> Вправо', Direction.right, x, y),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена'))],
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details, int x, int y) {
    // print('swipe $x $y ${details.delta.dx}');
    if (details.delta.dx > AppConstants.swipeSensitivity)
      _makeMove(Coordinates(x, y), Direction.right);
    // print('Dragging in +X direction ${details.delta.dx}');
    else if (details.delta.dx < -AppConstants.swipeSensitivity)
      _makeMove(Coordinates(x, y), Direction.left);
    // print('Dragging in -X direction ${details.delta.dx}');
    else if (details.delta.dy > AppConstants.swipeSensitivity)
      _makeMove(Coordinates(x, y), Direction.down);
    // print('Dragging in +Y direction ${details.delta.dy}');
    else if (details.delta.dy < -AppConstants.swipeSensitivity)
      _makeMove(Coordinates(x, y), Direction.up);
    // print('Dragging in -Y direction ${details.delta.dy}');
  }

  // void _onDragStart(DragStartDetails details) {
  //   final renderBox = context.findRenderObject() as RenderBox;
  //   final localPosition = renderBox.globalToLocal(details.globalPosition);

  //   final x = (localPosition.dx / _elementSize).floor();
  //   final y = (localPosition.dy / _elementSize).floor();

  //   if (x >= 0 &&
  //       x < _engine.level.width &&
  //       y >= 0 &&
  //       y < _engine.level.height) {
  //     _startDragCoords = Coordinates(x, y);
  //   }
  // }

  // // В методе _onDragEnd
  // void _onDragEnd(DragEndDetails details) {
  //   if (_startDragCoords == null) return;

  //   final velocity = details.velocity;
  //   final direction = _getSwipeDirection(velocity.pixelsPerSecond);

  //   if (direction != Direction.nowhere) {
  //     final result = _engine.makeTurn(_startDragCoords!, direction);

  //     if (result.moved) {
  //       setState(() {});

  //       // Проверяем победу только если уровень завершен
  //       if (result.levelComplete) {
  //         widget.onLevelComplete?.call();
  //       }
  //     }
  //   }

  //   _startDragCoords = null;
  // }

  // В методе _buildDirectionButton
  Widget _buildDirectionButton(String text, Direction direction, int x, int y) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
      onPressed: () {
        Navigator.of(context).pop();
        _makeMove(Coordinates(x, y), direction);
      },
      child: Text(text, style: const TextStyle(fontSize: 16)),
    ),
  );

  // Direction _getSwipeDirection(Offset velocity) {
  //   final dx = velocity.dx.abs();
  //   final dy = velocity.dy.abs();
  //   final swipeLength = sqrt(dx * dx + dy * dy);

  //   final sensitivity = _elementSize * AppConstants.swipeSensitivity;
  //   if (swipeLength < sensitivity) return Direction.nowhere;

  //   if (dx >= dy) {
  //     return velocity.dx > 0 ? Direction.right : Direction.left;
  //   } else {
  //     return velocity.dy > 0 ? Direction.down : Direction.up;
  //   }
  // }
}
