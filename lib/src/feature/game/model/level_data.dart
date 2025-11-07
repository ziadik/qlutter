class LevelData {
  LevelData({
    required this.id,
    required this.rows,
    required this.cols,
    required this.grid,
  });

  final int id;
  final int rows;
  final int cols;
  final List<List<int>> grid;
}
