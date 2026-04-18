import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/guest/guest_access_cubit.dart';

/// Icon map for different restricted sections
const Map<String, IconData> _sectionIcons = {
  'liked_songs': Icons.favorite,
  'your_mixes': Icons.shuffle,
  'recently_played': Icons.history,
  'your_library': Icons.library_music,
  'profile': Icons.person,
};

/// Modal shown when guest tries to access restricted sections
class GuestRestrictedModal extends StatelessWidget {
  final String section;
  final String title;
  final String message;
  final VoidCallback onSignIn;
  final VoidCallback onCancel;

  const GuestRestrictedModal({
    Key? key,
    required this.section,
    required this.title,
    required this.message,
    required this.onSignIn,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = _sectionIcons[section] ?? Icons.lock;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x1F1F1F),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0x1DB954).withOpacity(0.2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0x1DB954),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x1DB954),
                  foregroundColor: const Color(0x191414),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onSignIn();
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel();
                },
                child: Text(
                  'Not Now',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the modal
  static Future<void> show(
    BuildContext context, {
    required String section,
    required String title,
    required String message,
    required VoidCallback onSignIn,
  }) {
    return showDialog(
      context: context,
      builder: (context) => GuestRestrictedModal(
        section: section,
        title: title,
        message: message,
        onSignIn: onSignIn,
        onCancel: () {
          context.read<GuestAccessCubit>().dismissModal();
        },
      ),
    );
  }
}
