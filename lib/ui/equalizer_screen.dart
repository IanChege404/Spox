import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_event.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_state.dart';
import 'package:spotify_clone/constants/constants.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  static const List<String> _bandLabels = [
    '60Hz',
    '230Hz',
    '910Hz',
    '3.6kHz',
    '14kHz'
  ];

  @override
  void initState() {
    super.initState();
    context.read<EqualizerBloc>().add(const LoadEqualizerEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      appBar: AppBar(
        backgroundColor: MyColors.blackColor,
        elevation: 0,
        title: const Text(
          'Equalizer',
          style: TextStyle(color: MyColors.whiteColor, fontFamily: 'AM'),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<EqualizerBloc, EqualizerState>(
            builder: (context, state) {
              final enabled = state is EqualizerLoaded ? state.enabled : false;
              return Switch(
                value: enabled,
                activeThumbColor: MyColors.greenColor,
                onChanged: (_) => context
                    .read<EqualizerBloc>()
                    .add(const ToggleEqualizerEvent()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<EqualizerBloc, EqualizerState>(
        builder: (context, state) {
          if (state is EqualizerInitial) {
            return const Center(
              child: CircularProgressIndicator(color: MyColors.greenColor),
            );
          }
          if (state is EqualizerError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: MyColors.whiteColor)),
            );
          }
          if (state is EqualizerLoaded) {
            return RepaintBoundary(
              child: _EqualizerBody(state: state, bandLabels: _bandLabels),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EqualizerBody extends StatelessWidget {
  final EqualizerLoaded state;
  final List<String> bandLabels;

  const _EqualizerBody({required this.state, required this.bandLabels});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Presets
          const Text(
            'Presets',
            style: TextStyle(
              color: MyColors.whiteColor,
              fontFamily: 'AM',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kEqualizerPresets.keys.map((preset) {
              final isSelected = state.activePreset == preset;
              return GestureDetector(
                onTap: () =>
                    context.read<EqualizerBloc>().add(ApplyPresetEvent(preset)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColors.greenColor
                        : MyColors.darGreyColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    preset,
                    style: TextStyle(
                      color: isSelected
                          ? MyColors.blackColor
                          : MyColors.whiteColor,
                      fontFamily: 'AM',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Band sliders
          const Text(
            'Custom',
            style: TextStyle(
              color: MyColors.whiteColor,
              fontFamily: 'AM',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (i) {
            return _BandSlider(
              label: bandLabels[i],
              value: state.bands[i],
              enabled: state.enabled,
              onChanged: (v) => context
                  .read<EqualizerBloc>()
                  .add(UpdateBandEvent(bandIndex: i, value: v)),
            );
          }),
          const SizedBox(height: 24),
          // Reset button
          Center(
            child: TextButton(
              onPressed: () => context
                  .read<EqualizerBloc>()
                  .add(const ResetEqualizerEvent()),
              child: const Text(
                'Reset to Flat',
                style: TextStyle(
                  color: MyColors.greenColor,
                  fontFamily: 'AM',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BandSlider extends StatelessWidget {
  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _BandSlider({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
        value >= 0 ? '+${value.toStringAsFixed(1)}' : value.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                color: MyColors.lightGrey,
                fontFamily: 'AM',
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: MyColors.greenColor,
                inactiveTrackColor: MyColors.darGreyColor,
                thumbColor: enabled ? MyColors.greenColor : MyColors.lightGrey,
                overlayColor: MyColors.greenColor.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value,
                min: -12.0,
                max: 12.0,
                divisions: 48,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$displayValue dB',
              style: const TextStyle(
                color: MyColors.lightGrey,
                fontFamily: 'AM',
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
