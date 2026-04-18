# Contributing to Spox

Thank you for your interest in contributing to Spox! This document outlines the process for contributing to this Flutter Spotify clone project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors. Please be constructive in feedback, welcoming to newcomers, and considerate of differing viewpoints.

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/Spox.git
   cd Spox
   ```
3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/IanChege404/Spox.git
   ```
4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

1. Ensure you have **Flutter 3.x** (stable channel) installed.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Copy `.env.example` to `.env` and fill in your Spotify API credentials (see `SPOTIFY_SETUP.md`).
4. Run the app:
   ```bash
   flutter run
   ```

## Building

### Development Build (Debug APK)

For local testing on an emulator or connected device:

```bash
flutter build apk --debug
```

### Release Build (Production APK)

For production releases:

```bash
flutter build apk --release
```

### App Bundle (for Google Play)

For Play Store submission:

```bash
# Standard build (recommended for most systems)
flutter build appbundle --release

# With size analysis (requires ≥16GB free RAM, run separately if memory-constrained)
flutter build appbundle --target-platform android-arm64 --analyze-size
```

**Note**: If you encounter `Gradle task bundleRelease failed with exit code 143`, this indicates memory exhaustion. See [Troubleshooting](#troubleshooting) below.

## Testing

Before submitting a pull request, ensure all checks pass locally.

### Format code

```bash
dart format .
```

### Analyze code

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

All three commands must exit with no errors or warnings before opening a PR.

## Pull Request Process

1. Ensure your branch is up to date with `upstream/main`:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. Run the full test suite (format, analyze, test) as described above.
3. Open a pull request against the `main` branch with a clear title and description of your changes.
4. Reference any related issues in the PR description (e.g., `Closes #42`).
5. A maintainer will review your PR. Address any requested changes promptly.
6. Once approved, your PR will be merged — thank you!

## Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Use `dart format .` to auto-format all Dart files before committing.
- Organize imports: Dart SDK → Flutter → third-party packages → project imports.
- Use the **BLoC pattern** for all state management; do not add business logic directly to widgets.
- Keep widgets small and composable; extract reusable widgets into `lib/widgets/`.
- Add doc comments (`///`) to public classes and methods.
- Avoid `print()` in production code; use structured logging via the app's logger utility.

## Troubleshooting

### `Gradle task bundleRelease failed with exit code 143`

Exit code 143 (SIGTERM) indicates the Gradle process was terminated due to memory exhaustion. This is very common on systems with <16GB RAM. The project has been configured with emergency low-memory settings in `android/gradle.properties`.

**Troubleshooting steps (in order):**

1. **Kill Gradle daemon & clean build cache**:
   ```bash
   ./gradlew --stop
   rm -rf build/
   flutter pub get
   flutter build appbundle --release
   ```

2. **Close unnecessary applications** to free up system RAM:
   ```bash
   # Monitor available memory during build
   watch -n 1 free -h
   ```
   Target: At least **2-3GB free RAM** before starting the build.

3. **Build APK instead of App Bundle** (APK requires less memory):
   ```bash
   flutter build apk --release
   ```

4. **Use debug build for testing** (much faster and lighter):
   ```bash
   flutter build apk --debug
   ```

5. **Reduce system load** - Stop heavy services/applications:
   ```bash
   # Check what's using memory
   ps aux --sort=-%mem | head -n 10
   ```

6. **Check for swap thrashing** (indicator of severe memory pressure):
   ```bash
   # If vm.swappiness > 60, system is swapping heavily (bad for build performance)
   cat /proc/sys/vm/swappiness
   ```

7. **Split into smaller builds** on low-memory VMs:
   ```bash
   # Build without analysis (saves ~500MB)
   flutter build appbundle --release
   
   # Then separately run size analysis if needed
   flutter build appbundle --target-platform android-arm64 --analyze-size 2>&1 | tee build_size.log
   ```

8. **As last resort - submit via CI/CD** instead of local build:
   - Push to a feature branch
   - Let GitHub Actions (or your CI system) build the release
   - CI environments typically have more RAM available

**If issue persists:**
- Your system may have insufficient resources for Flutter/Android builds
- Consider: 
  - Adding more RAM to your build machine
  - Using a cloud build service (GitHub Actions, Firebase App Distribution, etc.)
  - Building on a different machine with more resources
