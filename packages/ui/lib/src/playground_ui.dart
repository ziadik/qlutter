import 'package:flutter/material.dart';
import 'package:ui/src/level_maps.dart';
import 'package:ui/src/wall_painter.dart';

const double sizeWall = 100;

class PlayGround extends StatelessWidget {
  const PlayGround({
    super.key,
    this.elementSize = sizeWall,
    this.middle,
    required this.h,
    required this.w,
    required this.levelId,
    this.customLevel, // Новый параметр для кастомного уровня
  });

  final double elementSize;
  final Widget? middle;
  final int h;
  final int w;
  final int levelId;
  final List<String>? customLevel; // Кастомный уровень из редактора

  @override
  Widget build(BuildContext context) {
    // Используем кастомный уровень, если он предоставлен, иначе загружаем из LevelMaps
    final List<String> levelData;

    if (customLevel != null) {
      levelData = customLevel!;
    } else if (levelId >= 0 && levelId < LevelMaps.totalLevels) {
      levelData = LevelMaps.levels[levelId];
    } else {
      // Пустой уровень по умолчанию
      levelData = List.generate(h, (_) => List.filled(w, 'N').join(' '));
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: (elementSize / 2), top: (elementSize / 1.5)),
          child: Container(height: ((h - 1) * elementSize), width: ((w - 1) * elementSize), color: const Color(0xFF50427D)),
        ),
        _buildGridLines(elementSize, w - 1, h - 1),
        DynamicWallWidget(board: GameBoard(levelData), elementSize: elementSize, middle: middle),
      ],
    );
  }

  Widget _buildGridLines(double cellSize, int w, int h) {
    return Padding(
      padding: EdgeInsets.only(left: (elementSize / 2), top: (elementSize / 1.5)),
      child: SizedBox(
        height: cellSize * h,
        width: cellSize * w,
        child: CustomPaint(
          painter: GridPainter(gridWidth: w, gridHeight: h, cellSize: cellSize),
        ),
      ),
    );
  }
}

class GameBoard {
  final List<List<WallType>> grid;
  final int width;
  final int height;

  GameBoard(List<String> textLayout) : grid = _parseTextLayout(textLayout), width = textLayout.isNotEmpty ? textLayout[0].split(' ').length : 0, height = textLayout.length;

  static List<List<WallType>> _parseTextLayout(List<String> textLayout) {
    return textLayout.map((row) {
      // Разделяем строку по пробелам и преобразуем в WallType
      return row.split(' ').map((symbol) {
        switch (symbol) {
          case 'L':
            return WallType.L;
          case 'R':
            return WallType.R;
          case 'T':
            return WallType.T;
          case 'D':
            return WallType.D;
          case 'LIT':
            return WallType.LIT;
          case 'RIT':
            return WallType.RIT;
          case 'LID':
            return WallType.LID;
          case 'RID':
            return WallType.RID;
          case 'LOT':
            return WallType.LOT;
          case 'ROT':
            return WallType.ROT;
          case 'LOD':
            return WallType.LOD;
          case 'ROD':
            return WallType.ROD;
          case 'B':
            return WallType.B;
          case 'LB':
            return WallType.LB;
          case 'RB':
            return WallType.RB;
          case 'N':
          default:
            return WallType.N;
        }
      }).toList();
    }).toList();
  }

  WallType getWallType(int column, int row) {
    if (row < 0 || row >= height || column < 0 || column >= width) {
      return WallType.N;
    }
    return grid[row][column];
  }
}

enum WallType {
  L, // LeftWallCP
  R, // LeftWallCP + Flip
  T, // TopWallCP
  LIT, // TopLeftInAngleCP
  RIT, // TopLeftInAngleCP + Flip
  LOT, // TopLeftOutAngleCP
  ROT, // TopLeftOutAngleCP + Flip
  D, // DownWallCP
  N, // None
  LID, // DownLeftInAngleCP
  RID, // DownLeftInAngleCP + Flip
  LOD, // DownRightOutAngleCP + Flip
  ROD, // DownRightOutAngleCP
  B, // BlockCP
  LB, // Left Bridge
  RB, // Right Bridge
}

class DynamicWallWidget extends StatelessWidget {
  final GameBoard board;
  final double elementSize;
  final Widget? middle;

  const DynamicWallWidget({required this.board, required this.elementSize, super.key, this.middle});

  @override
  Widget build(BuildContext context) {
    final firstLayer = <Widget>[]; // Первый слой
    final secondLayer = <Widget>[]; // Второй слой

    for (int row = 0; row < board.grid.length; row++) {
      for (int column = 0; column < board.grid[row].length; column++) {
        final wallType = board.getWallType(column, row);

        if (wallType != WallType.N) {
          final wallPainter = _getWallPainter(wallType);

          if (wallPainter != null) {
            final wallWidget = DrawWallWidget(wall: wallPainter, column: column, row: row, elementSize: elementSize, flipX: _needsFlipX(wallType));

            // Распределяем по слоям
            if (_isFirstLayer(wallType)) {
              firstLayer.add(wallWidget);
            } else {
              secondLayer.add(wallWidget);
            }

            // Разделить на слои Первый и Второй
            if (wallType == WallType.RB || wallType == WallType.LB) {
              secondLayer.add(wallWidget);
              final wallShadowWidget = DrawWallWidget(wall: LeftBridgesShadow(), column: column, row: row, elementSize: elementSize, flipX: _needsFlipX(wallType));
              firstLayer.add(wallShadowWidget);
            }
          }
        }
      }
    }

    return Stack(
      children: [
        IgnorePointer(child: Stack(children: firstLayer)),
        // Первый слой
        if (middle != null) Positioned(left: elementSize + elementSize * -0.49, top: elementSize * 0.65, child: middle!),
        IgnorePointer(child: Stack(children: secondLayer)), // Второй слой
      ],
    );
  }

  // Проверяем принадлежность к первому слою Будет сзади
  bool _isFirstLayer(WallType type) {
    return type == WallType.T || type == WallType.LIT || type == WallType.RIT || type == WallType.LOT || type == WallType.B || type == WallType.ROT;
  }

  // Проверяем принадлежность ко второму слою Будет впереди
  bool _isSecondLayer(WallType type) {
    return type == WallType.L || type == WallType.R || type == WallType.D || type == WallType.LID || type == WallType.RID || type == WallType.LOD || type == WallType.ROD;
  }

  CustomPainter? _getWallPainter(WallType type) {
    switch (type) {
      case WallType.L:
        return LeftWallCP();
      case WallType.R:
        return LeftWallCP(); // + Flip
      case WallType.T:
        return TopWallCP();
      case WallType.D:
        return DownWallCP();
      case WallType.LIT:
        return TopLeftInAngleCP();
      case WallType.RIT:
        return TopLeftInAngleCP(); // + Flip
      case WallType.LID:
        return DownLeftInAngleCP();
      case WallType.RID:
        return DownLeftInAngleCP(); // + Flip
      case WallType.LOT:
        return TopLeftOutAngleCP();
      case WallType.ROT:
        return TopLeftOutAngleCP(); // + Flip
      case WallType.LOD:
        return DownRightOutAngleCP(); // + Flip
      case WallType.ROD:
        return DownRightOutAngleCP();
      case WallType.B:
        return BlockCP();
      case WallType.LB:
        return LeftBridgeWOTShadowCP();
      case WallType.RB:
        return LeftBridgeWOTShadowCP();
      case WallType.N:
      default:
        return null;
    }
  }

  bool _needsFlipX(WallType type) {
    return type == WallType.R || type == WallType.RIT || type == WallType.RID || type == WallType.ROT || type == WallType.RB || type == WallType.LOD;
  }
}

class DrawWallWidget extends StatelessWidget {
  const DrawWallWidget({required this.wall, required this.column, required this.row, super.key, this.flipX = false, this.rotate = 0, required this.elementSize});

  final CustomPainter wall;
  final int column;
  final int row;
  final bool flipX;
  final int rotate;
  final double elementSize;

  @override
  Widget build(BuildContext context) => Positioned(
    top: row * elementSize,
    left: column * elementSize,
    child: Transform.flip(
      flipX: flipX,
      child: SizedBox(
        height: elementSize + 1, // Небольшой overlap
        width: elementSize + 1,
        child: CustomPaint(size: Size(elementSize, elementSize), painter: wall),
      ),
    ),
  );
}
