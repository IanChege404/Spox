import 'package:flutter/material.dart';
import 'package:spotify_clone/constants/constants.dart';

/// Reusable empty state widget for screens with no data
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.favorite,
///   title: 'No Liked Songs',
///   subtitle: 'Start liking songs to build your collection',
///   ctaLabel: 'Explore',
///   onCtaPressed: () => Navigator.pushNamed(context, '/search'),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final Color iconColor;
  final double iconSize;

  const EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaPressed,
    this.iconColor = MyColors.lightGrey,
    this.iconSize = 80,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'AB',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: MyColors.whiteColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'AM',
                  fontSize: 14,
                  color: MyColors.lightGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // CTA Button (if provided)
              if (ctaLabel != null && onCtaPressed != null)
                ElevatedButton(
                  onPressed: onCtaPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    ctaLabel!,
                    style: const TextStyle(
                      fontFamily: 'AB',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MyColors.blackColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable error state widget for failed data loading
///
/// Usage:
/// ```dart
/// ErrorStateWidget(
///   message: 'Failed to load playlists',
///   onRetry: () => context.read<HomeBloc>().add(LoadHomeDataEvent()),
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const ErrorStateWidget({
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),

            // Error Message
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'AB',
                fontSize: 16,
                color: MyColors.whiteColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Retry Button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
