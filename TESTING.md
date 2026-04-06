# Testing Guide

This document explains how tests are organized and maintained in the Spotify Clone project.

## Phase 5: Code Quality Summary

### Current Status ✅
- **Overall Coverage**: 22.80% (917/4022 lines) - Baseline achieved ✅
- **BLoC Layer**: 67.5% (critical business logic) - Target 70% 🎯
- **Services**: 21.2% - Target 35% 📈
- **Repositories**: 29.9% - Target 40% 📈
- **Total Tests**: 179 passing ✅
- **CI/CD Pipeline**: Automated testing, coverage reporting ✅
- **GitHub Actions**: Per-layer thresholds (65% BLoCs, 20% services, 25% repositories)

### Completed Work
- ✅ Enhanced GitHub Actions workflow with coverage verification
- ✅ Expanded AudioPlayerBloc tests (14+ new cases)
- ✅ Expanded SearchBloc tests (8+ new cases)
- ✅ Created SpotifyAuthService comprehensive tests (29 cases, 100% coverage)
- ✅ Added coverage badges to README
- ✅ Configured per-layer coverage thresholds

## Test Coverage Goals

- **BLoCs (Business Logic):** ≥70% (critical application logic)
- **Services & Repositories:** ≥35-40% (data access & API integration)
- **Overall Coverage:** ≥15% (sanity baseline)
- **UI & Widgets:** Widget tests via `test/widget_test.dart` (integration-style testing)

**Rationale:** Unit tests focus on testable business logic (BLoCs, services). UI is integration-tested via widget tests. Datasources are tested indirectly through repository tests. The codebase has 1431 untested UI lines which require widget/integration testing, not unit tests.

## Test Structure

```
test/
├── bloc/                         # BLoC unit tests (179 tests)
│   ├── audio_player_bloc_test.dart     (23 tests, 72.4%)
│   ├── search_bloc_test.dart           (14 tests, 73.5%)
│   ├── home_bloc_test.dart             (7 tests, 90.9%)
│   ├── liked_songs_bloc_test.dart      (8 tests, 71.1%)
│   ├── queue_bloc_test.dart            (12 tests, 76.8%)
│   ├── lyrics_bloc_test.dart           (7 tests, 70.5%)
│   ├── stats_bloc_test.dart            (7 tests, 68.6%)
│   ├── theme_bloc_test.dart            (7 tests, 71.4%)
│   └── auth_bloc_test.dart             (10 tests, 75.9%)
├── services/                     # Service unit tests
│   ├── spotify_auth_service_test.dart  (29 tests, 100%)
│   ├── audio_player_service_test.dart  (18 tests)
│   └── hive_service_test.dart          (32 tests)
├── data/
│   └── repositories/
│       └── spotify_repository_test.dart (24 tests)
└── widget_test.dart              # Widget/integration tests (1 test)
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run With Coverage
```bash
flutter test --coverage
```


### Generate Coverage Report
```bash
lcov --list coverage/lcov.info
```

### Run Specific Test File
```bash
flutter test test/bloc/audio_player_bloc_test.dart
```

### Run Tests Matching Pattern
```bash
flutter test --name "SearchBloc"
```

## Testing Patterns

### 1. BLoC Testing (using `bloc_test`)

All BLoC tests follow this pattern:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDependency extends Mock implements ActualDependency {}

void main() {
  group('MyBloc', () {
    late MockDependency mockDependency;
    late MyBloc myBloc;

    setUp(() {
      mockDependency = MockDependency();
      when(() => mockDependency.method()).thenAnswer((_) async => value);
      myBloc = MyBloc(mockDependency);
    });

    tearDown(() => myBloc.close());

    test('initial state is MyInitial', () {
      expect(myBloc.state, equals(MyInitial()));
    });

    blocTest<MyBloc, MyState>(
      'emits [Loading, Success] when MyEvent succeeds',
      build: () => myBloc,
      act: (bloc) => bloc.add(MyEvent()),
      expect: () => [
        isA<MyLoading>(),
        isA<MySuccess>(),
      ],
    );

    blocTest<MyBloc, MyState>(
      'emits [Loading, Error] when MyEvent fails',
      build: () => myBloc,
      act: (bloc) {
        when(() => mockDependency.method())
            .thenThrow(Exception('Error'));
        bloc.add(MyEvent());
      },
      expect: () => [
        isA<MyLoading>(),
        isA<MyError>(),
      ],
    );
  });
}
```

**Key Points:**
- Use `blocTest<Bloc, State>()` helper for event→state verification
- Mock external dependencies with `mocktail`
- Test both success and error paths
- Use `seed()` to test from non-initial states
- Use `wait()` for debounce/async operations

### 2. Service Testing

Services are tested by mocking their dependencies:

```dart
test('service method returns expected value', () async {
  final result = await service.doSomething();
  expect(result, equals(expectedValue));
});
```

For Hive (local persistence):
```dart
test('saves data to Hive', () async {
  await hiveService.saveLikedSong(song);
  final retrieved = hiveService.getLikedSongs();
  expect(retrieved, contains(song));
});
```

### 3. Repository Testing

Repositories test the layer between datasources and BLoCs:

```dart
test('repository delegates to datasource', () async {
  when(() => mockDatasource.fetchData())
      .thenAnswer((_) async => apiResponse);
  
  final result = await repository.getData();
  
  expect(result, equals(expectedModel));
  verify(() => mockDatasource.fetchData()).called(1);
});
```

### 4. Stream Testing

For services that return streams:

```dart
test('returns position stream', () {
  final stream = audioPlayerService.positionStream;
  expect(stream, emits(isA<Duration>()));
});
```

Mock streams in setUp:
```dart
when(() => mockService.positionStream)
    .thenAnswer((_) => Stream<Duration>.value(Duration.zero));
```

## Coverage Enforcement

### CI/CD Pipeline

Every push triggers:
1. `flutter analyze` — Lint checks
2. `dart format --set-exit-if-changed` — Format validation
3. `flutter test --coverage` — All tests + coverage collection
4. Coverage threshold check (≥40%)
5. Codecov upload for PR comments

**Failing Conditions:**
- Test failures block merge
- Lint errors block merge
- Format errors block merge
- Coverage < 40% blocks merge (can be overridden with `[skip-coverage]` in commit message)

### Coverage Badge

Coverage badge in README is automatically updated by Codecov on each push.

## Adding New Tests

### 1. Create Test File
```bash
# For a new BLoC
touch test/bloc/my_bloc_test.dart

# For a new service
touch test/services/my_service_test.dart
```

### 2. Write Test

Use the patterns above as templates. Key checklist:
- ✅ Mock all external dependencies
- ✅ Test success path
- ✅ Test error path
- ✅ Test edge cases (empty data, null values, invalid inputs)
- ✅ Use descriptive test names
- ✅ Clean up resources in tearDown

### 3. Run Test
```bash
flutter test test/bloc/my_bloc_test.dart
```

### 4. Check Coverage
```bash
flutter test --coverage
python3 << 'EOF'
import re
with open('coverage/lcov.info', 'r') as f:
    content = f.read()
    lh = sum(int(m) for m in re.findall(r'LH:(\d+)', content))
    lf = sum(int(m) for m in re.findall(r'LF:(\d+)', content))
    print(f"Coverage: {lh / lf * 100:.2f}%")
EOF
```

## Common Testing Scenarios

### Testing Event Sequence
```dart
blocTest<MyBloc, MyState>(
  'handles multiple events correctly',
  build: () => myBloc,
  act: (bloc) {
    bloc.add(EventA());
    bloc.add(EventB());
    bloc.add(EventC());
  },
  expect: () => [
    isA<StateA>(),
    isA<StateB>(),
    isA<StateC>(),
  ],
);
```

### Testing With Initial State
```dart
blocTest<MyBloc, MyState>(
  'transitions from initial state',
  build: () => myBloc,
  seed: () => MyInitial(),
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [isA<MySuccess>()],
);
```

### Testing State Updates
```dart
blocTest<MyBloc, MyState>(
  'updates state data correctly',
  build: () => myBloc,
  seed: () => MyLoaded(data: oldData),
  act: (bloc) => bloc.add(UpdateEvent(newData: newData)),
  verify: (bloc) {
    expect((bloc.state as MyLoaded).data, equals(newData));
  },
);
```

### Testing Debounce
```dart
blocTest<SearchBloc, SearchState>(
  'debounces search queries',
  build: () => searchBloc,
  act: (bloc) {
    bloc.add(const SearchQueryEvent('a'));
    bloc.add(const SearchQueryEvent('ab'));
    bloc.add(const SearchQueryEvent('abc'));
  },
  wait: const Duration(milliseconds: 400),
  expect: () => [
    isA<SearchLoading>(),
    isA<SearchLoaded>(),
  ],
  verify: (bloc) {
    // Verify API was called only once (for final query)
    verify(() => mockApi.search('abc')).called(1);
  },
);
```

## Debugging Failed Tests

### Print Debug Info
```dart
blocTest<MyBloc, MyState>(
  'test name',
  build: () => myBloc,
  act: (bloc) {
    print('Before: ${bloc.state}');
    bloc.add(MyEvent());
  },
  expect: () => [
    isA<MySuccess>(),
  ],
);
```

### Run With Verbose Output
```bash
flutter test --verbose test/bloc/my_bloc_test.dart
```

### Use skip() to Isolate Tests
```dart
blocTest<MyBloc, MyState>(
  'only run this test',
  build: () => myBloc,
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [isA<MySuccess>()],
  skip: false, // Set to true to skip others
);
```

## Mocking Strategies

### Mock External Services
```dart
class MockSpotifyApi extends Mock implements SpotifyApiService {}
```

### Mock Streams
```dart
when(() => mockService.eventStream)
    .thenAnswer((_) => Stream.value(event));
```

### Mock Async Operations
```dart
when(() => mockService.fetchData())
    .thenAnswer((_) async => Future.value(data));
```

### Track Mock Calls
```dart
verify(() => mockService.method()).called(1);
verifyNever(() => mockService.method());
verifyInOrder([
  () => mockService.methodA(),
  () => mockService.methodB(),
]);
```

## Performance

### Test Execution Time
- Individual test file: <1 second
- Full suite: ~20 seconds
- With coverage: ~25 seconds

To speed up tests:
1. Avoid real networking (always mock)
2. Use `setUpAll()` for expensive setup
3. Avoid file I/O in tests

## CI/CD Integration

### GitHub Actions Workflow

Tests run automatically on:
- Push to `main` or `develop` branch
- Pull requests to `main` or `develop`

**Artifacts:**
- Coverage report uploaded to Codecov
- APK/iOS builds triggered on main push

### Local Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
echo "Running tests..."
flutter test || exit 1
flutter analyze || exit 1
```

## Best Practices

1. **Test Behavior, Not Implementation**
   - ✅ Test that BLoC emits correct states
   - ❌ Don't test internal timer logic

2. **Test Public APIs Only**
   - ✅ Test public methods
   - ❌ Don't access private fields

3. **One Assert Per Test (Usually)**
   - ✅ `expect(bloc.state, isA<Success>())`
   - ❌ Multiple unrelated assertions

4. **Clear Test Names**
   - ✅ `'emits [Loading, Loaded] when FetchEvent succeeds'`
   - ❌ `'test1'`

5. **Isolate Tests**
   - Each test should be independent
   - No shared state between tests
   - Always tearDown in tearDown()

6. **Test Edge Cases**
   - Empty lists
   - Null values
   - Network errors
   - Timeouts

## Contributing

When adding new features:
1. Write passing tests first (TDD optional but recommended)
2. Ensure new code maintains >70% coverage for affected layer
3. Run full test suite: `flutter test --coverage`
4. Submit PR with passing CI/CD checks

## Troubleshooting

### Tests Hang
- Ensure all mocked streams have `thenAnswer()`
- Check for missing `close()` in tearDown

### Unexpected State
- Print actual state: `print('Actual: ${bloc.state}')`
- Check mock return values match expectations

### Import Errors
- Ensure test imports match file location
- Check `pubspec.yaml` for test dependencies

## Further Reading

- [bloc_test Documentation](https://pub.dev/packages/bloc_test)
- [mocktail Documentation](https://pub.dev/packages/mocktail)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
