import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_event.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_state.dart';
import 'package:spotify_clone/services/hive_service.dart';

class EqualizerBloc extends Bloc<EqualizerEvent, EqualizerState> {
  final HiveService _hiveService;

  static const String _enabledKey = 'eq_enabled';
  static const String _presetKey = 'eq_preset';
  static const String _bandsKey = 'eq_bands';

  EqualizerBloc({required HiveService hiveService})
      : _hiveService = hiveService,
        super(const EqualizerInitial()) {
    on<LoadEqualizerEvent>(_onLoad);
    on<ApplyPresetEvent>(_onApplyPreset);
    on<UpdateBandEvent>(_onUpdateBand);
    on<ToggleEqualizerEvent>(_onToggle);
    on<ResetEqualizerEvent>(_onReset);
  }

  Future<void> _onLoad(
      LoadEqualizerEvent event, Emitter<EqualizerState> emit) async {
    try {
      final enabled = _hiveService.getSetting(_enabledKey, true);
      final preset = _hiveService.getSetting(_presetKey, 'Flat');
      final storedBands = _hiveService.getSetting(_bandsKey);
      final bands = storedBands is List
          ? List<double>.from(storedBands.map((e) => (e as num).toDouble()))
          : List<double>.from(kEqualizerPresets['Flat']!);

      emit(EqualizerLoaded(
        enabled: enabled as bool,
        activePreset: preset as String,
        bands: bands,
      ));
    } catch (_) {
      emit(EqualizerLoaded(
        enabled: true,
        activePreset: 'Flat',
        bands: List<double>.from(kEqualizerPresets['Flat']!),
      ));
    }
  }

  Future<void> _onApplyPreset(
      ApplyPresetEvent event, Emitter<EqualizerState> emit) async {
    final current = state is EqualizerLoaded
        ? state as EqualizerLoaded
        : EqualizerLoaded(
            enabled: true,
            activePreset: 'Flat',
            bands: List<double>.from(kEqualizerPresets['Flat']!),
          );

    final presetBands =
        kEqualizerPresets[event.presetName] ?? kEqualizerPresets['Flat']!;
    final newState = current.copyWith(
      activePreset: event.presetName,
      bands: List<double>.from(presetBands),
    );
    emit(newState);
    await _persist(newState);
  }

  Future<void> _onUpdateBand(
      UpdateBandEvent event, Emitter<EqualizerState> emit) async {
    if (state is! EqualizerLoaded) return;
    final current = state as EqualizerLoaded;
    final newBands = List<double>.from(current.bands);
    newBands[event.bandIndex] = event.value.clamp(-12.0, 12.0);
    final newState =
        current.copyWith(activePreset: 'Custom', bands: newBands);
    emit(newState);
    await _persist(newState);
  }

  Future<void> _onToggle(
      ToggleEqualizerEvent event, Emitter<EqualizerState> emit) async {
    if (state is! EqualizerLoaded) return;
    final current = state as EqualizerLoaded;
    final newState = current.copyWith(enabled: !current.enabled);
    emit(newState);
    await _persist(newState);
  }

  Future<void> _onReset(
      ResetEqualizerEvent event, Emitter<EqualizerState> emit) async {
    final newState = EqualizerLoaded(
      enabled: state is EqualizerLoaded
          ? (state as EqualizerLoaded).enabled
          : true,
      activePreset: 'Flat',
      bands: List<double>.from(kEqualizerPresets['Flat']!),
    );
    emit(newState);
    await _persist(newState);
  }

  Future<void> _persist(EqualizerLoaded state) async {
    await _hiveService.saveSetting(_enabledKey, state.enabled);
    await _hiveService.saveSetting(_presetKey, state.activePreset);
    await _hiveService.saveSetting(_bandsKey, state.bands);
  }
}
