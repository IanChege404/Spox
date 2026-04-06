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
