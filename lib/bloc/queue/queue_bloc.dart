import 'package:bloc/bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_event.dart';
import 'package:spotify_clone/bloc/queue/queue_state.dart';
import 'package:spotify_clone/data/model/album_track.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  QueueBloc() : super(const QueueInitial()) {
    on<InitializeQueueEvent>(_onInitializeQueue);
    on<AddToQueueEvent>(_onAddToQueue);
    on<RemoveFromQueueEvent>(_onRemoveFromQueue);
    on<ReorderQueueEvent>(_onReorderQueue);
    on<ToggleShuffleEvent>(_onToggleShuffle);
    on<CycleRepeatModeEvent>(_onCycleRepeatMode);
    on<ClearQueueEvent>(_onClearQueue);
  }

  Future<void> _onInitializeQueue(
    InitializeQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (event.songs.isEmpty) {
      emit(const QueueEmpty());
    } else {
      emit(QueueLoaded(
        queue: event.songs,
        currentIndex: event.currentIndex,
      ));
    }
  }

  Future<void> _onAddToQueue(
    AddToQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    final currentState = state;
    if (currentState is QueueLoaded) {
      final updatedQueue = List<AlbumTrack>.from(currentState.queue);
      if (event.position == -1 || event.position >= updatedQueue.length) {
        updatedQueue.add(event.song);
      } else {
        updatedQueue.insert(event.position, event.song);
      }

      emit(currentState.copyWith(queue: updatedQueue));
    }
  }

  Future<void> _onRemoveFromQueue(
    RemoveFromQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    final currentState = state;
    if (currentState is QueueLoaded) {
      if (event.index >= 0 && event.index < currentState.queue.length) {
        final updatedQueue = List<AlbumTrack>.from(currentState.queue);
        updatedQueue.removeAt(event.index);

        if (updatedQueue.isEmpty) {
          emit(const QueueEmpty());
        } else {
          emit(currentState.copyWith(queue: updatedQueue));
        }
      }
    }
  }

  Future<void> _onReorderQueue(
    ReorderQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    final currentState = state;
    if (currentState is QueueLoaded) {
      final updatedQueue = List<AlbumTrack>.from(currentState.queue);
      final item = updatedQueue.removeAt(event.oldIndex);
      updatedQueue.insert(event.newIndex, item);

      emit(currentState.copyWith(queue: updatedQueue));
    }
  }

  Future<void> _onToggleShuffle(
    ToggleShuffleEvent event,
    Emitter<QueueState> emit,
  ) async {
    final currentState = state;
    if (currentState is QueueLoaded) {
      emit(currentState.copyWith(isShuffle: !currentState.isShuffle));
    }
  }

  Future<void> _onCycleRepeatMode(
    CycleRepeatModeEvent event,
    Emitter<QueueState> emit,
  ) async {
    final currentState = state;
    if (currentState is QueueLoaded) {
      final nextMode = _getNextRepeatMode(currentState.repeatMode);
      emit(currentState.copyWith(repeatMode: nextMode));
    }
  }

  Future<void> _onClearQueue(
    ClearQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueEmpty());
  }

  /// Cycle through repeat modes: off -> all -> one -> off
  RepeatMode _getNextRepeatMode(RepeatMode current) {
    switch (current) {
      case RepeatMode.off:
        return RepeatMode.all;
      case RepeatMode.all:
        return RepeatMode.one;
      case RepeatMode.one:
        return RepeatMode.off;
    }
  }
}
