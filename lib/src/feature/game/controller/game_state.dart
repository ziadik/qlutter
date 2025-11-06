import 'package:meta/meta.dart';

/// {@template game_state_placeholder}
/// Entity placeholder for GameState
/// {@endtemplate}
typedef GameEntity = Object;

/// {@template game_state}
/// GameState.
/// {@endtemplate}
sealed class GameState extends _$GameStateBase {
  /// {@macro game_state}
  const GameState({required super.data, required super.message});

  /// Idling state
  /// {@macro game_state}
  const factory GameState.idle({required GameEntity? data, String message}) =
      GameState$Idle;

  /// Processing
  /// {@macro game_state}
  const factory GameState.processing({
    required GameEntity? data,
    String message,
  }) = GameState$Processing;

  /// Successful
  /// {@macro game_state}
  const factory GameState.successful({
    required GameEntity? data,
    String message,
  }) = GameState$Successful;

  /// An error has occurred
  /// {@macro game_state}
  const factory GameState.error({required GameEntity? data, String message}) =
      GameState$Error;
}

/// Idling state
final class GameState$Idle extends GameState {
  const GameState$Idle({required super.data, super.message = 'Idling'});
}

/// Processing
final class GameState$Processing extends GameState {
  const GameState$Processing({
    required super.data,
    super.message = 'Processing',
  });
}

/// Successful
final class GameState$Successful extends GameState {
  const GameState$Successful({
    required super.data,
    super.message = 'Successful',
  });
}

/// Error
final class GameState$Error extends GameState {
  const GameState$Error({
    required super.data,
    super.message = 'An error has occurred.',
  });
}

/// Pattern matching for [GameState].
typedef GameStateMatch<R, S extends GameState> = R Function(S state);

@immutable
abstract base class _$GameStateBase {
  const _$GameStateBase({required this.data, required this.message});

  /// Data entity payload.
  @nonVirtual
  final GameEntity? data;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// Has data?
  bool get hasData => data != null;

  /// If an error has occurred?
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Is in progress state?
  bool get isProcessing =>
      maybeMap<bool>(orElse: () => false, processing: (_) => true);

  /// Is in idle state?
  bool get isIdling => !isProcessing;

  /// Pattern matching for [GameState].
  R map<R>({
    required GameStateMatch<R, GameState$Idle> idle,
    required GameStateMatch<R, GameState$Processing> processing,
    required GameStateMatch<R, GameState$Successful> successful,
    required GameStateMatch<R, GameState$Error> error,
  }) => switch (this) {
    GameState$Idle s => idle(s),
    GameState$Processing s => processing(s),
    GameState$Successful s => successful(s),
    GameState$Error s => error(s),
    _ => throw AssertionError(),
  };

  /// Pattern matching for [GameState].
  R maybeMap<R>({
    required R Function() orElse,
    GameStateMatch<R, GameState$Idle>? idle,
    GameStateMatch<R, GameState$Processing>? processing,
    GameStateMatch<R, GameState$Successful>? successful,
    GameStateMatch<R, GameState$Error>? error,
  }) => map<R>(
    idle: idle ?? (_) => orElse(),
    processing: processing ?? (_) => orElse(),
    successful: successful ?? (_) => orElse(),
    error: error ?? (_) => orElse(),
  );

  /// Pattern matching for [GameState].
  R? mapOrNull<R>({
    GameStateMatch<R, GameState$Idle>? idle,
    GameStateMatch<R, GameState$Processing>? processing,
    GameStateMatch<R, GameState$Successful>? successful,
    GameStateMatch<R, GameState$Error>? error,
  }) => map<R?>(
    idle: idle ?? (_) => null,
    processing: processing ?? (_) => null,
    successful: successful ?? (_) => null,
    error: error ?? (_) => null,
  );

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  String toString() => 'GameState{message: $message}';
}
