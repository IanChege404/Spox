import 'package:equatable/equatable.dart';

abstract class EqualizerEvent extends Equatable {
  const EqualizerEvent();

  @override
  List<Object?> get props => [];
}

/// Load equalizer state from Hive
class LoadEqualizerEvent extends EqualizerEvent {
  const LoadEqualizerEvent();
}

/// Apply a named preset
class ApplyPresetEvent extends EqualizerEvent {
  final String presetName;
  const ApplyPresetEvent(this.presetName);

  @override
  List<Object?> get props => [presetName];
}

/// Update a single band level (band index 0-4, value -12.0 to +12.0 dB)
class UpdateBandEvent extends EqualizerEvent {
  final int bandIndex;
  final double value;
  const UpdateBandEvent({required this.bandIndex, required this.value});

  @override
  List<Object?> get props => [bandIndex, value];
}

/// Toggle equalizer on/off
class ToggleEqualizerEvent extends EqualizerEvent {
  const ToggleEqualizerEvent();
}

/// Reset equalizer to flat
class ResetEqualizerEvent extends EqualizerEvent {
  const ResetEqualizerEvent();
}
