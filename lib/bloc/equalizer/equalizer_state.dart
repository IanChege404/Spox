import 'package:equatable/equatable.dart';

/// Named equalizer presets with 5-band levels (dB: bass, low-mid, mid, high-mid, treble)
const Map<String, List<double>> kEqualizerPresets = {
  'Flat':        [0.0,  0.0,  0.0,  0.0,  0.0],
  'Bass Boost':  [6.0,  4.0,  0.0,  0.0,  0.0],
  'Treble Boost':[0.0,  0.0,  0.0,  4.0,  6.0],
  'Vocal':       [-2.0, 2.0,  4.0,  3.0,  1.0],
  'Electronic':  [4.0,  2.0, -2.0,  2.0,  4.0],
};

abstract class EqualizerState extends Equatable {
  const EqualizerState();

  @override
  List<Object?> get props => [];
}

class EqualizerInitial extends EqualizerState {
  const EqualizerInitial();
}

class EqualizerLoaded extends EqualizerState {
  final bool enabled;
  final String activePreset;
  /// 5 band levels in dB ranging from -12.0 to +12.0
  final List<double> bands;

  const EqualizerLoaded({
    required this.enabled,
    required this.activePreset,
    required this.bands,
  });

  EqualizerLoaded copyWith({
    bool? enabled,
    String? activePreset,
    List<double>? bands,
  }) {
    return EqualizerLoaded(
      enabled: enabled ?? this.enabled,
      activePreset: activePreset ?? this.activePreset,
      bands: bands ?? this.bands,
    );
  }

  @override
  List<Object?> get props => [enabled, activePreset, bands];
}

class EqualizerError extends EqualizerState {
  final String message;
  const EqualizerError(this.message);

  @override
  List<Object?> get props => [message];
}
