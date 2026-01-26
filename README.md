# FitCoach+ starter repo

This archive contains a lightweight starter scaffold for FitCoach+:
- backend (Express-like stub with Agora token + recommendations endpoints)
- mobile (Flutter minimal app with screens)
- admin (Next.js starter)
- infra (docker-compose for local dev)
- CI workflow (GitHub Actions skeleton)

Replace placeholders in `.env` files and run the local instructions in `infra/docker-compose.dev.yml` and subfolders.

## Mobile notes

### Demo mode
- Demo flag is compile-time: `DEMO_MODE` (see `mobile/lib/core/config/demo_mode.dart`).
- Run demo build:
  - `flutter run --dart-define=DEMO_MODE=true`
- Run normal build:
  - `flutter run`
- Demo data is gated through `DemoConfig.isDemo` in providers/screens.

### Provider architecture
- `LanguageProvider`: localization + RTL direction (`mobile/lib/presentation/providers/language_provider.dart`)
- `ThemeProvider` / `AppColors`: shared styling (`mobile/lib/core/constants/colors.dart`)
- `DemoModeProvider`: demo state (`mobile/lib/presentation/providers/demo_mode_provider.dart`)

### Translation keys
- Add new UI strings in `mobile/lib/presentation/providers/language_provider.dart` under both `en` and `ar` maps.
- Keep keys consistent across screens and update any new keys used in widgets.
