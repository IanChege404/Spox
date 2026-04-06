import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:spotify_clone/constants/constants.dart';

/// Parses a Spotify URI or URL and returns the Spotify track/album/playlist ID
/// Returns null if the input is not a recognized Spotify URI.
String? parseSpotifyUri(String raw) {
  // Handle spotify:track:ID, spotify:album:ID, spotify:playlist:ID
  if (raw.startsWith('spotify:')) {
    final parts = raw.split(':');
    if (parts.length == 3) return parts[2];
  }
  // Handle https://open.spotify.com/track/ID or similar
  final uri = Uri.tryParse(raw);
  if (uri != null &&
      (uri.host == 'open.spotify.com' || uri.host == 'spotify.com')) {
    final segments = uri.pathSegments;
    if (segments.length >= 2) return segments[1];
  }
  return null;
}

class ScanSpotifyCodeScreen extends StatefulWidget {
  const ScanSpotifyCodeScreen({super.key});

  @override
  State<ScanSpotifyCodeScreen> createState() => _ScanSpotifyCodeScreenState();
}

class _ScanSpotifyCodeScreenState extends State<ScanSpotifyCodeScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _torchEnabled = false;
  bool _hasScanned = false;
  String? _scannedId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final raw = barcode!.rawValue!;
    final spotifyId = parseSpotifyUri(raw);

    setState(() {
      _hasScanned = true;
      _scannedId = spotifyId ?? raw;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: MyColors.darGreyColor,
        content: Text(
          spotifyId != null
              ? 'Spotify ID: $spotifyId'
              : 'Scanned: $raw',
          style: const TextStyle(color: MyColors.whiteColor),
        ),
        action: SnackBarAction(
          label: 'Scan again',
          textColor: MyColors.greenColor,
          onPressed: () => setState(() {
            _hasScanned = false;
            _scannedId = null;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      "images/icon_back.png",
                      height: 15,
                      width: 15,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Scan Spotify Code',
                    style: TextStyle(
                      fontFamily: 'AB',
                      color: MyColors.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  // Torch toggle button
                  IconButton(
                    icon: Icon(
                      _torchEnabled ? Icons.flashlight_off : Icons.flashlight_on,
                      color: _torchEnabled
                          ? MyColors.greenColor
                          : MyColors.whiteColor,
                    ),
                    onPressed: () {
                      _controller.toggleTorch();
                      setState(() => _torchEnabled = !_torchEnabled);
                    },
                  ),
                ],
              ),
            ),
            // Scanner viewfinder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Instruction / result text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _scannedId != null
                    ? 'ID: $_scannedId'
                    : 'Point your camera at a Spotify code.',
                style: const TextStyle(
                  fontFamily: "AB",
                  color: MyColors.whiteColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            if (_hasScanned)
              TextButton(
                onPressed: () => setState(() {
                  _hasScanned = false;
                  _scannedId = null;
                }),
                child: const Text(
                  'Scan again',
                  style: TextStyle(color: MyColors.greenColor, fontFamily: 'AM'),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
