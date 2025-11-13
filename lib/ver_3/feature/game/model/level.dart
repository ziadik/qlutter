import 'package:qlutter/ver_3/feature/game/model/item.dart';

class Level {
  Level(this.field) : ballsCount = _countBalls(field);
  final List<List<Item?>> field;
  final int ballsCount;

  static int _countBalls(List<List<Item?>> field) {
    var count = 0;
    for (final row in field) {
      for (final item in row) {
        if (item is Ball) count++;
      }
    }
    return count;
  }

  int get width => field.isNotEmpty ? field[0].length : 0;
  int get height => field.length;

  Level copyWith({List<List<Item?>>? field}) => Level(field ?? this.field);
}
