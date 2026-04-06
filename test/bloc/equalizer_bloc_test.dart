import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_event.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_state.dart';
import 'package:spotify_clone/services/hive_service.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  group('EqualizerBloc', () {
    late MockHiveService mockHiveService;
    late EqualizerBloc equalizerBloc;

    setUp(() {
      mockHiveService = MockHiveService();

      // Default mock responses
      when(() => mockHiveService.getSetting('eq_enabled', true))
          .thenReturn(true);
      when(() => mockHiveService.getSetting('eq_preset', 'Flat'))
          .thenReturn('Flat');
      when(() => mockHiveService.getSetting('eq_bands')).thenReturn(null);
      when(() => mockHiveService.saveSetting(any(), any()))
          .thenAnswer((_) async {});

      equalizerBloc = EqualizerBloc(hiveService: mockHiveService);
    });

    tearDown(() {
      equalizerBloc.close();
    });

    test('initial state is EqualizerInitial', () {
      expect(equalizerBloc.state, isA<EqualizerInitial>());
    });

    blocTest<EqualizerBloc, EqualizerState>(
      'emits EqualizerLoaded with Flat preset on LoadEqualizerEvent',
      build: () => equalizerBloc,
      act: (bloc) => bloc.add(const LoadEqualizerEvent()),
      expect: () => [
        isA<EqualizerLoaded>()
            .having((s) => s.enabled, 'enabled', true)
            .having((s) => s.activePreset, 'preset', 'Flat')
            .having((s) => s.bands.length, 'bands count', 5),
      ],
    );

    blocTest<EqualizerBloc, EqualizerState>(
      'emits EqualizerLoaded with saved preset on load',
      build: () {
        when(() => mockHiveService.getSetting('eq_preset', 'Flat'))
            .thenReturn('Bass Boost');
        when(() => mockHiveService.getSetting('eq_enabled', true))
            .thenReturn(true);
        when(() => mockHiveService.getSetting('eq_bands'))
            .thenReturn([6.0, 4.0, 0.0, 0.0, 0.0]);
        return EqualizerBloc(hiveService: mockHiveService);
      },
      act: (bloc) => bloc.add(const LoadEqualizerEvent()),
      expect: () => [
        isA<EqualizerLoaded>()
            .having((s) => s.activePreset, 'preset', 'Bass Boost')
            .having((s) => s.bands[0], 'bass band', 6.0),
      ],
    );

    blocTest<EqualizerBloc, EqualizerState>(
      'ApplyPresetEvent changes preset and updates bands',
      build: () => equalizerBloc,
      seed: () => EqualizerLoaded(
        enabled: true,
        activePreset: 'Flat',
        bands: List<double>.from(kEqualizerPresets['Flat']!),
      ),
      act: (bloc) => bloc.add(const ApplyPresetEvent('Bass Boost')),
      expect: () => [
        isA<EqualizerLoaded>()
            .having((s) => s.activePreset, 'preset', 'Bass Boost')
            .having((s) => s.bands[0], 'bass band', 6.0),
      ],
      verify: (_) {
        verify(() => mockHiveService.saveSetting(any(), any())).called(
          greaterThan(0),
        );
      },
    );

    blocTest<EqualizerBloc, EqualizerState>(
      'UpdateBandEvent updates a specific band and sets preset to Custom',
      build: () => equalizerBloc,
      seed: () => EqualizerLoaded(
        enabled: true,
        activePreset: 'Flat',
        bands: [0.0, 0.0, 0.0, 0.0, 0.0],
      ),
      act: (bloc) =>
          bloc.add(const UpdateBandEvent(bandIndex: 2, value: 5.0)),
      expect: () => [
        isA<EqualizerLoaded>()
            .having((s) => s.activePreset, 'preset', 'Custom')
            .having((s) => s.bands[2], 'mid band', 5.0),
      ],
    );

    blocTest<EqualizerBloc, EqualizerState>(
      'UpdateBandEvent clamps value to -12.0..+12.0',
      build: () => equalizerBloc,
      seed: () => EqualizerLoaded(
        enabled: true,
        activePreset: 'Flat',
        bands: [0.0, 0.0, 0.0, 0.0, 0.0],
      ),
      act: (bloc) =>
          bloc.add(const UpdateBandEvent(bandIndex: 0, value: 50.0)),
      expect: () => [
        isA<EqualizerLoaded>().having((s) => s.bands[0], 'clamped', 12.0),
      ],
    );

    blocTest<EqualizerBloc, EqualizerState>(
      'ToggleEqualizerEvent flips the enabled state',
      build: () => equalizerBloc,
      seed: () => EqualizerLoaded(
        enabled: true,
        activePreset: 'Flat',
        bands: [0.0, 0.0, 0.0, 0.0, 0.0],
      ),
      act: (bloc) => bloc.add(const ToggleEqualizerEvent()),
      expect: () => [
        isA<EqualizerLoaded>().having((s) => s.enabled, 'enabled', false),
      ],
    );

    blocTest<EqualizerBloc, EqualizerState>(
      'ResetEqualizerEvent resets to Flat preset',
      build: () => equalizerBloc,
      seed: () => EqualizerLoaded(
        enabled: true,
        activePreset: 'Bass Boost',
        bands: [6.0, 4.0, 0.0, 0.0, 0.0],
      ),
      act: (bloc) => bloc.add(const ResetEqualizerEvent()),
      expect: () => [
        isA<EqualizerLoaded>()
            .having((s) => s.activePreset, 'preset', 'Flat')
            .having((s) => s.bands, 'flat bands', [0.0, 0.0, 0.0, 0.0, 0.0]),
      ],
    );

    test('kEqualizerPresets contains all expected presets', () {
      expect(kEqualizerPresets.keys,
          containsAll(['Flat', 'Bass Boost', 'Treble Boost', 'Vocal', 'Electronic']));
      for (final bands in kEqualizerPresets.values) {
        expect(bands.length, 5);
      }
    });
  });
}
