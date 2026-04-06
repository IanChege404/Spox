import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_event.dart';
import 'package:spotify_clone/bloc/queue/queue_state.dart';
import 'package:spotify_clone/data/model/album_track.dart';

void main() {
  group('QueueBloc', () {
    late QueueBloc queueBloc;

    final mockTrack1 = AlbumTrack('Song 1', 'Artist 1');
    final mockTrack2 = AlbumTrack('Song 2', 'Artist 2');
    final mockTrack3 = AlbumTrack('Song 3', 'Artist 1');

    setUp(() {
      queueBloc = QueueBloc();
    });

    tearDown(() {
      queueBloc.close();
    });

    test('initial state is QueueInitial', () {
      expect(queueBloc.state, isA<QueueInitial>());
    });

    // Initialize queue with songs
    blocTest<QueueBloc, QueueState>(
      'emits QueueLoaded when InitializeQueueEvent is added with songs',
      build: () => queueBloc,
      act: (bloc) {
        bloc.add(InitializeQueueEvent(
          songs: [mockTrack1, mockTrack2, mockTrack3],
          currentIndex: 0,
        ));
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.queue.length, 'queue length', 3)
            .having((state) => state.currentIndex, 'current index', 0),
      ],
    );

    // Initialize queue with empty list
    blocTest<QueueBloc, QueueState>(
      'emits QueueEmpty when InitializeQueueEvent is added with empty list',
      build: () => queueBloc,
      act: (bloc) {
        bloc.add(const InitializeQueueEvent(songs: [], currentIndex: 0));
      },
      expect: () => [
        isA<QueueEmpty>(),
      ],
    );

    // Add song to end of queue
    blocTest<QueueBloc, QueueState>(
      'emits QueueLoaded with updated queue when AddToQueueEvent is added to end',
      build: () => queueBloc,
      seed: () => QueueLoaded(queue: [mockTrack1], currentIndex: 0),
      act: (bloc) {
        bloc.add(AddToQueueEvent(song: mockTrack2, position: -1));
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.queue.length, 'queue length', 2)
            .having((state) => state.queue.last.trackName, 'last song name',
                'Song 2'),
      ],
    );

    // Add song to specific position
    blocTest<QueueBloc, QueueState>(
      'emits QueueLoaded with song at specific position when AddToQueueEvent is added',
      build: () => queueBloc,
      seed: () => QueueLoaded(queue: [mockTrack1, mockTrack3], currentIndex: 0),
      act: (bloc) {
        bloc.add(AddToQueueEvent(song: mockTrack2, position: 1));
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.queue.length, 'queue length', 3)
            .having((state) => state.queue[1].trackName, 'song at index 1',
                'Song 2'),
      ],
    );

    // Remove song from queue
    blocTest<QueueBloc, QueueState>(
      'emits QueueLoaded with updated queue when RemoveFromQueueEvent is added',
      build: () => queueBloc,
      seed: () => QueueLoaded(
          queue: [mockTrack1, mockTrack2, mockTrack3], currentIndex: 0),
      act: (bloc) {
        bloc.add(const RemoveFromQueueEvent(1));
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.queue.length, 'queue length', 2)
            .having((state) => state.queue[1].trackName, 'remaining songs',
                'Song 3'),
      ],
    );

    // Remove last song (queue becomes empty)
    blocTest<QueueBloc, QueueState>(
      'emits QueueEmpty when removing the last song from queue',
      build: () => queueBloc,
      seed: () => QueueLoaded(queue: [mockTrack1], currentIndex: 0),
      act: (bloc) {
        bloc.add(const RemoveFromQueueEvent(0));
      },
      expect: () => [
        isA<QueueEmpty>(),
      ],
    );

    // Reorder queue
    blocTest<QueueBloc, QueueState>(
      'emits QueueLoaded with reordered queue when ReorderQueueEvent is added',
      build: () => queueBloc,
      seed: () => QueueLoaded(
          queue: [mockTrack1, mockTrack2, mockTrack3], currentIndex: 0),
      act: (bloc) {
        bloc.add(const ReorderQueueEvent(oldIndex: 0, newIndex: 2));
      },
      expect: () => [
        isA<QueueLoaded>()
            .having(
                (state) => state.queue.first.trackName, 'first song', 'Song 2')
            .having(
                (state) => state.queue.last.trackName, 'last song', 'Song 1'),
      ],
    );

    // Toggle shuffle mode OFF
    blocTest<QueueBloc, QueueState>(
      'emits QueueLoaded with shuffle mode OFF when ToggleShuffleEvent is added',
      build: () => queueBloc,
      seed: () => QueueLoaded(
        queue: [mockTrack1, mockTrack2],
        currentIndex: 0,
        isShuffle: true,
      ),
      act: (bloc) {
        bloc.add(const ToggleShuffleEvent());
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.isShuffle, 'shuffle mode', false),
      ],
    );

    // Toggle shuffle mode ON
    blocTest<QueueBloc, QueueState>(
      'emits QueueLoaded with shuffle mode ON when ToggleShuffleEvent is added',
      build: () => queueBloc,
      seed: () => QueueLoaded(
        queue: [mockTrack1, mockTrack2],
        currentIndex: 0,
        isShuffle: false,
      ),
      act: (bloc) {
        bloc.add(const ToggleShuffleEvent());
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.isShuffle, 'shuffle mode', true),
      ],
    );

    // Cycle repeat mode: OFF -> ALL -> ONE -> OFF
    blocTest<QueueBloc, QueueState>(
      'cycles repeat mode from RepeatMode.off to RepeatMode.all',
      build: () => queueBloc,
      seed: () => QueueLoaded(
        queue: [mockTrack1],
        currentIndex: 0,
        repeatMode: RepeatMode.off,
      ),
      act: (bloc) {
        bloc.add(const CycleRepeatModeEvent());
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.repeatMode, 'repeat mode', RepeatMode.all),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'cycles repeat mode from RepeatMode.all to RepeatMode.one',
      build: () => queueBloc,
      seed: () => QueueLoaded(
        queue: [mockTrack1],
        currentIndex: 0,
        repeatMode: RepeatMode.all,
      ),
      act: (bloc) {
        bloc.add(const CycleRepeatModeEvent());
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.repeatMode, 'repeat mode', RepeatMode.one),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'cycles repeat mode from RepeatMode.one back to RepeatMode.off',
      build: () => queueBloc,
      seed: () => QueueLoaded(
        queue: [mockTrack1],
        currentIndex: 0,
        repeatMode: RepeatMode.one,
      ),
      act: (bloc) {
        bloc.add(const CycleRepeatModeEvent());
      },
      expect: () => [
        isA<QueueLoaded>()
            .having((state) => state.repeatMode, 'repeat mode', RepeatMode.off),
      ],
    );

    // Clear queue
    blocTest<QueueBloc, QueueState>(
      'emits QueueEmpty when ClearQueueEvent is added',
      build: () => queueBloc,
      seed: () => QueueLoaded(
          queue: [mockTrack1, mockTrack2, mockTrack3], currentIndex: 0),
      act: (bloc) {
        bloc.add(const ClearQueueEvent());
      },
      expect: () => [
        isA<QueueEmpty>(),
      ],
    );

    // Edge case: Try to remove invalid index
    blocTest<QueueBloc, QueueState>(
      'ignores RemoveFromQueueEvent with invalid index',
      build: () => queueBloc,
      seed: () => QueueLoaded(queue: [mockTrack1, mockTrack2], currentIndex: 0),
      act: (bloc) {
        bloc.add(const RemoveFromQueueEvent(999));
      },
      expect: () => [],
    );
  });
}
