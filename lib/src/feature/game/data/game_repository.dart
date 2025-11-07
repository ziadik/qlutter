import 'package:qlutter/src/feature/game/model/level.dart';

abstract interface class IGameRepository {
  Future<List<Level>> getAllLevels();
  Future<Level> getLevel(int id);
}

class GameRepositoryImpl implements IGameRepository {
  @override
  Future<List<Level>> getAllLevels() {
    // TODO: implement getAllLevels
    throw UnimplementedError();
  }

  @override
  Future<Level> getLevel(int id) {
    // TODO: implement getLevel
    throw UnimplementedError();
  }
}
