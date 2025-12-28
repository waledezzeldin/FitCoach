# Release Readiness Checklist

## Builds
- [ ] Flutter APK build (release)
- [ ] Flutter iOS build (release)
- [ ] Backend production build/package

## Tests
- [ ] Flutter `flutter test` passes
- [ ] Backend `npm test` passes
- [ ] Golden tests approved (light/dark/RTL)
- [ ] Integration tests (Flutter + backend) pass

## Configuration
- [ ] Environment variables documented
- [ ] Secrets stored securely (CI/CD + production)
- [ ] API base URLs verified (dev/staging/prod)
- [ ] Webhook endpoints configured (payments)

## Monitoring & Observability
- [ ] Logging configured
- [ ] Error tracking enabled
- [ ] Health checks exposed

## App Store Prep
- [ ] App icons and splash screens finalized
- [ ] Store metadata (screenshots, copy)
- [ ] Versioning and changelog

## Progress Log
- [ ] 2025-__-__: Checklist created.
