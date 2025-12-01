# FitCoach Mobile

Flutter client for the FitCoach platform. It delivers multilingual onboarding,
demo-aware dashboards, and an intake workflow that persists across sessions.

## Prerequisites

- Flutter 3.24+ with the stable channel
- Android/iOS tooling as required by your platform

## Running the App

```sh
flutter run
```

Use `--dart-define=DEMO=true` to pre-load demo data locally.

## Testing

- Unit/Widget tests

	```sh
	flutter test
	```

- Integration tests (Phase 1 + Phase 2 flows)

	```sh
	flutter test test/integration
	```

	These suites validate localization + intro + auth progression as well as the
	two-stage intake resume/completion path, using the shared secure-storage
	mock under `test/support/mock_secure_storage.dart`.
