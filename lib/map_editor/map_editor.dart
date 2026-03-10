import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlutter/map_editor/playground_ui.dart';
import 'package:ui/src/level_maps.dart';
import 'package:qlutter/ver_2/game/field_engine.dart';
import 'package:qlutter/ver_2/models/level.dart';
import 'package:qlutter/ver_2/models/item.dart';
import 'package:qlutter/ver_2/widgets/field_widget2.dart';
import 'package:qlutter/ver_2/game/level_manager.dart';
import 'package:ui/src/wall_painter.dart';

// Константы для цветов
class GameColors {
  static const Color ballGreen = Color(0xFF4CAF50);
  static const Color ballRed = Color(0xFFF44336);
  static const Color ballBlue = Color(0xFF2196F3);
  static const Color ballYellow = Color(0xFFFFEB3B);
  static const Color ballPurple = Color(0xFF9C27B0);
  static const Color ballCyan = Color(0xFF00BCD4);

  static const Color holeGreen = Color(0xFF2E7D32);
  static const Color holeRed = Color(0xFFC62828);
  static const Color holeBlue = Color(0xFF1565C0);
  static const Color holeYellow = Color(0xFFF9A825);
  static const Color holePurple = Color(0xFF6A1B9A);
  static const Color holeCyan = Color(0xFF00838F);

  static const Color blockGray = Color(0xFF9E9E9E);
}

class MapEditor extends StatefulWidget {
  const MapEditor({super.key});

  @override
  State<MapEditor> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  int gridWidth = 13;
  int gridHeight = 13;
  List<List<WallType>> grid = [];
  WallType selectedTool = WallType.L;
  bool isErasing = false;

  // Разделитель экрана (0.6 = 60% редактор, 40% превью)
  double editorSplitRatio = 0.6;

  // Режим просмотра: 'editor' - только редактор, 'play' - только игра, 'split' - разделенный
  String viewMode = 'split';

  // Текущий загруженный уровень для превью
  Level? _previewLevel;
  int _currentLevelNumber = 1;
  bool _isLoading = false;

  // Текущий индекс готового уровня из LevelMaps
  int _currentPresetLevelIndex = 0;

  // Флаг для отображения стен поверх игрового поля
  bool _showWallsOverlay = false;

  // Данные стен для оверлея (могут быть больше на +1)
  List<String>? _wallsOverlayData;

  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _widthController.text = gridWidth.toString();
    _heightController.text = gridHeight.toString();
    _loadPreviewLevel();
  }

  Future<void> _loadPreviewLevel() async {
    setState(() => _isLoading = true);
    try {
      await LevelManager().initialize();
      final level = await LevelManager().loadLevel(1);
      setState(() {
        _previewLevel = level;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading preview level: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _initializeGrid() {
    grid = List.generate(gridHeight, (_) => List.filled(gridWidth, WallType.N));
  }

  // Панель инструментов
  final List<MapEntry<String, WallType>> tools = [
    const MapEntry('L', WallType.L),
    const MapEntry('R', WallType.R),
    const MapEntry('T', WallType.T),
    const MapEntry('D', WallType.D),
    const MapEntry('LIT', WallType.LIT),
    const MapEntry('RIT', WallType.RIT),
    const MapEntry('LID', WallType.LID),
    const MapEntry('RID', WallType.RID),
    const MapEntry('LOT', WallType.LOT),
    const MapEntry('ROT', WallType.ROT),
    const MapEntry('LOD', WallType.LOD),
    const MapEntry('ROD', WallType.ROD),
    const MapEntry('RB', WallType.RB),
    const MapEntry('LB', WallType.LB),
    const MapEntry('B', WallType.B),
    const MapEntry('N', WallType.N),
  ];

  void _onCellTapped(int row, int column) {
    setState(() {
      if (isErasing) {
        grid[row][column] = WallType.N;
      } else {
        grid[row][column] = selectedTool;
      }
    });
  }

  void _onCellDragged(int row, int column) {
    _onCellTapped(row, column);
  }

  void _clearGrid() {
    setState(() {
      _initializeGrid();
    });
  }

  String _wallTypeToSymbol(WallType type) {
    switch (type) {
      case WallType.L:
        return 'L';
      case WallType.R:
        return 'R';
      case WallType.T:
        return 'T';
      case WallType.D:
        return 'D';
      case WallType.LIT:
        return 'LIT';
      case WallType.RIT:
        return 'RIT';
      case WallType.LID:
        return 'LID';
      case WallType.RID:
        return 'RID';
      case WallType.LOT:
        return 'LOT';
      case WallType.ROT:
        return 'ROT';
      case WallType.LOD:
        return 'LOD';
      case WallType.ROD:
        return 'ROD';
      case WallType.B:
        return 'B';
      case WallType.N:
        return 'N';
      case WallType.LB:
        return 'LB';
      case WallType.RB:
        return 'RB';
    }
  }

  // Преобразование текущей сетки в формат для PlayGround
  List<String> _gridToLevelMap() {
    return grid.map((row) {
      return row.map(_wallTypeToSymbol).join(' ');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор карт с превью уровней', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF50427D),
        actions: [
          // Кнопка выбора уровня для превью
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white70),
            onPressed: _showLevelSelector,
            tooltip: 'Выбрать уровень для превью',
          ),

          // Переключатель режима просмотра
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers, color: Colors.white70),
            tooltip: 'Режим просмотра',
            onSelected: (value) {
              setState(() {
                viewMode = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'split',
                child: Row(children: [Icon(Icons.splitscreen), SizedBox(width: 8), Text('Разделенный')]),
              ),
              const PopupMenuItem(
                value: 'editor',
                child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Только редактор')]),
              ),
              const PopupMenuItem(
                value: 'play',
                child: Row(children: [Icon(Icons.play_arrow), SizedBox(width: 8), Text('Только превью')]),
              ),
            ],
          ),

          IconButton(icon: const Icon(Icons.collections), onPressed: _loadPresetMap, tooltip: 'Готовые карты', color: Colors.white70),
          IconButton(icon: const Icon(Icons.aspect_ratio), onPressed: _changeGridSize, tooltip: 'Размер карты', color: Colors.white70),
          IconButton(icon: const Icon(Icons.upload), onPressed: _importMap, tooltip: 'Импорт', color: Colors.white70),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportMap, tooltip: 'Экспорт', color: Colors.white70),
          IconButton(icon: const Icon(Icons.cleaning_services), onPressed: _clearGrid, tooltip: 'Очистить', color: Colors.white70),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Панель инструментов
                if (viewMode != 'play') _buildToolbar(),

                // Переключатель режима
                if (viewMode != 'play') _buildModeSwitch(),

                // Основная область
                Expanded(child: _buildMainContent()),
              ],
            ),
    );
  }

  Widget _buildMainContent() {
    switch (viewMode) {
      case 'editor':
        return _buildEditorOnly();
      case 'play':
        return _buildPreviewOnly();
      case 'split':
      default:
        return _buildSplitView();
    }
  }

  Widget _buildEditorOnly() {
    return Container(
      color: const Color(0xFF50427D),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(scrollDirection: Axis.vertical, child: _buildEditorGrid()),
        ),
      ),
    );
  }

  Widget _buildPreviewOnly() {
    return Container(
      color: Colors.grey[900],
      child: Center(child: _buildLevelPreview()),
    );
  }

  Widget _buildSplitView() {
    return Row(
      children: [
        // Левая часть - редактор
        Expanded(
          flex: (editorSplitRatio * 100).toInt(),
          child: Container(
            color: const Color(0xFF50427D),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(scrollDirection: Axis.vertical, child: _buildEditorGrid()),
              ),
            ),
          ),
        ),

        // Вертикальный разделитель
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              editorSplitRatio += details.delta.dx / context.size!.width;
              editorSplitRatio = editorSplitRatio.clamp(0.3, 0.8);
            });
          },
          child: Container(
            width: 8,
            color: Colors.grey[300],
            child: const VerticalDivider(thickness: 1, width: 1, color: Colors.grey),
          ),
        ),

        // Правая часть - превью уровня из LevelManager
        Expanded(
          flex: (100 - editorSplitRatio * 100).toInt(),
          child: Container(
            color: Colors.grey[900],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Превью уровня',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      if (_previewLevel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                          child: Text('Уровень $_currentLevelNumber', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),

                      // Кнопка для наложения стен
                      if (_previewLevel != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            icon: Icon(_showWallsOverlay ? Icons.layers : Icons.layers_outlined, color: _showWallsOverlay ? Colors.green : Colors.white70),
                            onPressed: _toggleWallsOverlay,
                            tooltip: _showWallsOverlay ? 'Скрыть стены' : 'Показать стены поверх',
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: Center(child: _buildLevelPreview())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleWallsOverlay() {
    setState(() {
      if (!_showWallsOverlay) {
        // При включении оверлея, берем текущие стены из редактора
        _wallsOverlayData = _gridToLevelMap();
      }
      _showWallsOverlay = !_showWallsOverlay;
    });
  }

  Widget _buildLevelPreview() {
    if (_previewLevel == null) {
      return const Center(
        child: Text('Загрузите уровень для превью', style: TextStyle(color: Colors.white)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 550,
          height: 550,
          color: const Color(0xFF50427D),
          child: Stack(
            children: [
              // Игровое поле с элементами
              _buildLevelGrid(_previewLevel!),

              // Оверлей со стенами (если включен)
              if (_showWallsOverlay && _wallsOverlayData != null) _buildWallsOverlay(_wallsOverlayData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWallsOverlay(List<String> wallsData) {
    const double cellSize = 35;

    // Размеры оверлея (могут быть больше на 1)
    final int overlayHeight = wallsData.length;
    final int overlayWidth = wallsData.isNotEmpty ? wallsData[0].split(' ').length : 0;

    // Размеры игрового поля
    final int gameHeight = _previewLevel?.height ?? 0;
    final int gameWidth = _previewLevel?.width ?? 0;

    // Рассчитываем смещение, если оверлей больше игрового поля
    // В PlayGround поле всегда +1 по размеру, поэтому смещаем на 1 ячейку
    final double offsetX = (overlayWidth > gameWidth) ? 0 : 0;
    final double offsetY = (overlayHeight > gameHeight) ? 0 : 0;

    return IgnorePointer(
      child: Center(
        child: Transform.translate(
          offset: Offset(offsetX / 2, offsetY / 2),
          child: SizedBox(
            width: overlayWidth * cellSize,
            height: overlayHeight * cellSize,
            child: Stack(
              children: [
                for (int y = 0; y < overlayHeight; y++)
                  for (int x = 0; x < overlayWidth; x++)
                    // Проверяем, попадает ли ячейка оверлея в область игрового поля
                    if (x < gameWidth && y < gameHeight)
                      Positioned(left: x * cellSize, top: y * cellSize, child: _buildWallOverlayCell(wallsData[y].split(' ')[x], cellSize))
                    else
                      // Для дополнительных ячеек (крайних) рисуем с уменьшенной прозрачностью
                      Positioned(left: x * cellSize, top: y * cellSize, child: _buildWallOverlayCell(wallsData[y].split(' ')[x], cellSize, isExtraCell: true)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWallOverlayCell(String wallSymbol, double size, {bool isExtraCell = false}) {
    final WallType type = _symbolToWallType(wallSymbol);

    if (type == WallType.N) return const SizedBox();

    final painter = _getPainterForType(type);
    final needsFlip = _needsFlipX(type);

    if (painter == null) return const SizedBox();

    return Opacity(
      opacity: isExtraCell ? 0.3 : 0.7, // Крайние ячейки более прозрачные
      child: Transform.flip(
        flipX: needsFlip,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: painter, size: Size(size, size)),
        ),
      ),
    );
  }

  Widget _buildLevelGrid(Level level) {
    const double cellSize = 35;

    return Center(
      child: SizedBox(
        width: level.width * cellSize,
        height: level.height * cellSize,
        child: Stack(
          children: [
            // Сетка
            CustomPaint(
              painter: GridPainter(gridWidth: level.width, gridHeight: level.height, cellSize: cellSize),
            ),

            // Элементы уровня
            for (int y = 0; y < level.height; y++)
              for (int x = 0; x < level.width; x++) Positioned(left: x * cellSize, top: y * cellSize, child: _buildLevelItem(level.field[y][x], cellSize)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelItem(Item? item, double size) {
    if (item == null) return const SizedBox();

    if (item is Block) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        child: Container(
          decoration: BoxDecoration(
            color: GameColors.blockGray,
            borderRadius: BorderRadius.circular(size * 0.15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: size * 0.1, offset: Offset(size * 0.05, size * 0.05))],
          ),
        ),
      );
    }

    if (item is Ball) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getBallColor(item.color),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: size * 0.1, offset: Offset(size * 0.05, size * 0.05))],
            gradient: RadialGradient(center: Alignment(-0.3, -0.3), radius: 0.8, colors: [_getBallColor(item.color).withOpacity(0.9), _getBallColor(item.color).withOpacity(0.7)]),
          ),
        ),
      );
    }

    if (item is Hole) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.15),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: _getHoleColor(item.color).withOpacity(0.2),
            border: Border.all(color: _getHoleColor(item.color), width: size * 0.08),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: size * 0.05, offset: Offset.zero)],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Color _getBallColor(ItemColor color) {
    switch (color) {
      case ItemColor.green:
        return GameColors.ballGreen;
      case ItemColor.red:
        return GameColors.ballRed;
      case ItemColor.blue:
        return GameColors.ballBlue;
      case ItemColor.yellow:
        return GameColors.ballYellow;
      case ItemColor.purple:
        return GameColors.ballPurple;
      case ItemColor.cyan:
        return GameColors.ballCyan;
      case ItemColor.gray:
        return GameColors.blockGray;
    }
  }

  Color _getHoleColor(ItemColor color) {
    switch (color) {
      case ItemColor.green:
        return GameColors.holeGreen;
      case ItemColor.red:
        return GameColors.holeRed;
      case ItemColor.blue:
        return GameColors.holeBlue;
      case ItemColor.yellow:
        return GameColors.holeYellow;
      case ItemColor.purple:
        return GameColors.holePurple;
      case ItemColor.cyan:
        return GameColors.holeCyan;
      case ItemColor.gray:
        return GameColors.blockGray;
    }
  }

  Future<void> _showLevelSelector() async {
    final totalLevels = LevelManager().totalLevels;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите уровень для превью'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: totalLevels,
            itemBuilder: (context, index) {
              final levelNumber = index + 1;
              return ListTile(
                leading: CircleAvatar(child: Text('$levelNumber')),
                title: Text('Уровень $levelNumber'),
                subtitle: Text('Нажмите для просмотра'),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  try {
                    final level = await LevelManager().loadLevel(levelNumber);
                    setState(() {
                      _previewLevel = level;
                      _currentLevelNumber = levelNumber;
                      _isLoading = false;
                      // Сбрасываем оверлей при загрузке нового уровня
                      _showWallsOverlay = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Уровень $levelNumber загружен для превью')));
                  } catch (e) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e'), backgroundColor: Colors.red));
                  }
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена'))],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 80,
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          final isSelected = selectedTool == tool.value && !isErasing;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTool = tool.value;
                isErasing = false;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToolPreview(tool.value),
                  Text(tool.key, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolPreview(WallType type) {
    final painter = _getPainterForType(type);
    final needsFlip = _needsFlipX(type);
    if (painter == null) return const Icon(Icons.clear, size: 20);

    return SizedBox(
      width: 30,
      height: 30,
      child: Transform.flip(
        flipX: needsFlip,
        child: CustomPaint(painter: painter),
      ),
    );
  }

  CustomPainter? _getPainterForType(WallType type) {
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

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Ластик'),
              const SizedBox(width: 16),
              Switch(
                value: !isErasing,
                onChanged: (value) {
                  setState(() {
                    isErasing = !value;
                  });
                },
              ),
              const Text('Режим рисования'),
            ],
          ),
          Text('Размер: $gridWidth×$gridHeight', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEditorGrid() {
    const cellSize = 40.0;

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 2)),
      child: SizedBox(
        width: gridWidth * cellSize,
        height: gridHeight * cellSize,
        child: Listener(
          onPointerDown: (event) {
            _handlePointerEvent(event, cellSize);
          },
          onPointerMove: (event) {
            _handlePointerEvent(event, cellSize);
          },
          child: Stack(
            children: [
              // Сетка
              _buildGridLines(cellSize),

              // Элементы стен
              for (int row = 0; row < gridHeight; row++)
                for (int column = 0; column < gridWidth; column++) _buildGridCell(row, column, cellSize),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePointerEvent(PointerEvent event, double cellSize) {
    final column = (event.localPosition.dx / cellSize).floor();
    final row = (event.localPosition.dy / cellSize).floor();

    if (row >= 0 && row < gridHeight && column >= 0 && column < gridWidth) {
      setState(() {
        if (isErasing) {
          grid[row][column] = WallType.N;
        } else {
          grid[row][column] = selectedTool;
        }

        // Если оверлей включен, обновляем его при изменении сетки
        if (_showWallsOverlay) {
          _wallsOverlayData = _gridToLevelMap();
        }
      });
    }
  }

  Widget _buildGridLines(double cellSize) {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(gridWidth: gridWidth, gridHeight: gridHeight, cellSize: cellSize),
      ),
    );
  }

  Widget _buildGridCell(int row, int column, double cellSize) {
    final wallType = grid[row][column];
    final painter = _getPainterForType(wallType);
    final needsFlip = _needsFlipX(wallType);

    return Positioned(
      left: column * cellSize,
      top: row * cellSize,
      child: GestureDetector(
        onTap: () => _onCellTapped(row, column),
        onPanUpdate: (details) {
          final localPosition = details.localPosition;
          final cellRow = (localPosition.dy / cellSize).floor();
          final cellColumn = (localPosition.dx / cellSize).floor();

          if (cellRow >= 0 && cellRow < gridHeight && cellColumn >= 0 && cellColumn < gridWidth) {
            _onCellDragged(cellRow, cellColumn);
          }
        },
        child: SizedBox(
          width: cellSize,
          height: cellSize,
          child: painter != null
              ? Transform.flip(
                  flipX: needsFlip,
                  child: CustomPaint(painter: painter),
                )
              : null,
        ),
      ),
    );
  }

  void _importMap() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Импорт карты'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Вставьте код карты:'),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: textController,
                  maxLines: 10,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Вставьте сюда код из экспорта..."),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              _parseImportedMap(textController.text);
              Navigator.pop(context);
            },
            child: const Text('Импорт'),
          ),
        ],
      ),
    );
  }

  void _parseImportedMap(String importedText) {
    try {
      // Очищаем текст от лишних символов
      final cleanedText = importedText.replaceAll('[', '').replaceAll(']', '').replaceAll("'", '').trim();

      // Разбиваем на строки
      final lines = cleanedText.split('\n').where((line) => line.trim().isNotEmpty).toList();

      final importedHeight = lines.length;
      if (importedHeight < 5 || importedHeight > 20) {
        _showError('Неверный размер карты: $importedHeight. Допустимо от 5 до 20.');
        return;
      }
      // Определяем ширину по первой строке
      final firstLineSymbols = lines[0].trim().split(' ').where((symbol) => symbol.isNotEmpty).toList();
      final importedWidth = firstLineSymbols.length;
      if (importedWidth < 5 || importedWidth > 20) {
        _showError('Неверная ширина карты: $importedWidth. Допустимо от 5 до 20.');
        return;
      }

      final newGrid = <List<WallType>>[];

      for (final line in lines) {
        final trimmedLine = line.trim();
        // Убираем запятые в конце строк
        final cleanLine = trimmedLine.endsWith(',') ? trimmedLine.substring(0, trimmedLine.length - 1) : trimmedLine;

        final symbols = cleanLine.split(' ').where((symbol) => symbol.isNotEmpty).toList();

        if (symbols.length != importedWidth) {
          _showError('Неверное количество элементов в строке: ${symbols.length}. Ожидается $importedWidth.');
          return;
        }

        final row = symbols.map(_symbolToWallType).toList();
        newGrid.add(row);
      }

      setState(() {
        gridWidth = importedWidth;
        gridHeight = importedHeight;
        grid = newGrid;
        _widthController.text = importedWidth.toString();
        _heightController.text = importedHeight.toString();

        // Обновляем оверлей если он включен
        if (_showWallsOverlay) {
          _wallsOverlayData = _gridToLevelMap();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Карта $importedWidth×$importedHeight успешно импортирована!')));
    } catch (e) {
      _showError('Ошибка при импорте: $e');
    }
  }

  void _exportMap() {
    final buffer = StringBuffer();
    buffer.writeln('[');

    for (int row = 0; row < gridHeight; row++) {
      final rowSymbols = grid[row].map(_wallTypeToSymbol).toList();
      final rowString = "\"${rowSymbols.join(' ')}\"";

      if (row < gridHeight - 1) {
        buffer.writeln('  $rowString,');
      } else {
        buffer.writeln('  $rowString');
      }
    }

    buffer.write(']');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Экспорт карты $gridWidth×$gridHeight'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Размер: $gridWidth×$gridHeight'),
              const SizedBox(height: 8),
              SelectableText(buffer.toString(), style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: buffer.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано в буфер обмена!')));
                    },
                    tooltip: 'Копировать',
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  WallType _symbolToWallType(String symbol) {
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
        return WallType.N;
      default:
        return WallType.N;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _changeGridSize() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Размер карты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите размер карты (5-20):'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ширина', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Высота', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSizeButton('13×13', 13, 13),
                  _buildSizeButton('8×12', 8, 12),
                  _buildSizeButton('12×8', 12, 8),
                  _buildSizeButton('10×15', 10, 15),
                  _buildSizeButton('5×7', 5, 7),
                  _buildSizeButton('20×20', 20, 20),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              final newWidth = int.tryParse(_widthController.text);
              final newHeight = int.tryParse(_heightController.text);

              if (newWidth != null && newHeight != null && newWidth >= 5 && newWidth <= 20 && newHeight >= 5 && newHeight <= 20) {
                _resizeGrid(newWidth, newHeight);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Размеры должны быть от 5 до 20'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton(String label, int width, int height) {
    return ElevatedButton(
      onPressed: () {
        _widthController.text = width.toString();
        _heightController.text = height.toString();
      },
      child: Text(label),
    );
  }

  void _resizeGrid(int newWidth, int newHeight) {
    setState(() {
      final oldGrid = grid;
      gridWidth = newWidth;
      gridHeight = newHeight;

      // Создаем новую сетку
      final newGrid = List.generate(newHeight, (row) {
        if (row < oldGrid.length) {
          // Копируем существующие строки
          return List.generate(newWidth, (col) {
            if (col < oldGrid[row].length) {
              return oldGrid[row][col]; // Сохраняем существующие данные
            } else {
              return WallType.N; // Заполняем новые клетки пустотами
            }
          });
        } else {
          // Создаем новые строки
          return List.filled(newWidth, WallType.N);
        }
      });

      grid = newGrid;

      // Обновляем оверлей если он включен
      if (_showWallsOverlay) {
        _wallsOverlayData = _gridToLevelMap();
      }
    });
  }

  void _loadPresetMap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Загрузить готовую карту'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Выберите готовую карту:'),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: LevelMaps.totalLevels,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Text('${index + 1}'),
                        title: Text(LevelMaps.getLevelName(index)),
                        subtitle: Text('${LevelMaps.levels[index].length}×${LevelMaps.levels[index].length}'),
                        onTap: () {
                          _loadLevel(index);
                          // Также загружаем соответствующий уровень из LevelManager для превью
                          _loadCorrespondingPreviewLevel(index + 1);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена'))],
      ),
    );
  }

  Future<void> _loadCorrespondingPreviewLevel(int levelNumber) async {
    setState(() => _isLoading = true);
    try {
      final level = await LevelManager().loadLevel(levelNumber);
      setState(() {
        _previewLevel = level;
        _currentLevelNumber = levelNumber;
        _isLoading = false;
        // Сбрасываем оверлей при загрузке нового уровня
        _showWallsOverlay = false;
      });
    } catch (e) {
      print('Error loading corresponding preview level: $e');
      setState(() => _isLoading = false);
    }
  }

  void _loadLevel(int levelIndex) {
    try {
      if (levelIndex < 0 || levelIndex >= LevelMaps.totalLevels) {
        _showError('Неверный индекс уровня: $levelIndex');
        return;
      }

      final levelData = LevelMaps.levels[levelIndex];
      final levelHeight = LevelMaps.height(levelIndex);
      final levelWidth = LevelMaps.width(levelIndex);

      final newGrid = <List<WallType>>[];

      for (final line in levelData) {
        final symbols = line.split(' ').where((symbol) => symbol.isNotEmpty).toList();
        final row = symbols.map(_symbolToWallType).toList();
        newGrid.add(row);
      }

      setState(() {
        gridWidth = levelWidth;
        gridHeight = levelHeight;
        grid = newGrid;
        _widthController.text = levelWidth.toString();
        _heightController.text = levelHeight.toString();
        _currentPresetLevelIndex = levelIndex;

        // Обновляем оверлей если он включен
        if (_showWallsOverlay) {
          _wallsOverlayData = _gridToLevelMap();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Загружена карта: ${levelIndex + 1} (${LevelMaps.getLevelName(levelIndex)})')));
    } catch (e) {
      _showError('Ошибка при загрузке уровня: $e');
    }
  }
}
