import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/src/level_maps.dart';
import 'playground_ui.dart';
import 'wall_painter.dart';

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

  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _widthController.text = gridWidth.toString();
    _heightController.text = gridHeight.toString();
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
        title: const Text('Редактор карт с превью', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF50427D),
        actions: [
          IconButton(icon: const Icon(Icons.collections), onPressed: _loadPresetMap, tooltip: 'Готовые карты', color: Colors.white70),
          IconButton(icon: const Icon(Icons.aspect_ratio), onPressed: _changeGridSize, tooltip: 'Размер карты', color: Colors.white70),
          IconButton(icon: const Icon(Icons.upload), onPressed: _importMap, tooltip: 'Импорт', color: Colors.white70),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportMap, tooltip: 'Экспорт', color: Colors.white70),
          IconButton(icon: const Icon(Icons.cleaning_services), onPressed: _clearGrid, tooltip: 'Очистить', color: Colors.white70),
        ],
      ),
      body: Column(
        children: [
          // Панель инструментов
          _buildToolbar(),

          // Переключатель режима
          _buildModeSwitch(),

          // Разделенный экран: редактор и превью
          Expanded(
            child: Row(
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

                // Правая часть - превью PlayGround
                Expanded(
                  flex: (100 - editorSplitRatio * 100).toInt(),
                  child: Container(
                    color: Colors.grey[900],
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Превью уровня',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: PlayGround(
                              h: gridHeight,
                              w: gridWidth,
                              levelId: -1, // Используем кастомный уровень
                              customLevel: _gridToLevelMap(),
                              elementSize: 40, // Меньший размер для превью
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Загружена карта: $levelIndex ($levelWidth×$levelHeight)')));
    } catch (e) {
      _showError('Ошибка при загрузке уровня: $e');
    }
  }
}
