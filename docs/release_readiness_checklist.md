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
- [ ] Repository contract tests for critical FE adapters pass
- [ ] Webhook signature verification tests pass

## Configuration
- [ ] Environment variables documented
- [ ] Secrets stored securely (CI/CD + production)
- [ ] API base URLs verified (dev/staging/prod)
- [ ] Webhook endpoints configured (payments)
- [ ] Demo mode flags verified off in production build
- [ ] Simulated backend feature flags verified off in production (`ENABLE_SIMULATED_AI_EXTRACTION`)

## Integration Closure Gates
- [ ] API contract doc updated for final FE/BE endpoints and wrappers
- [ ] Frontend integration guide updated (repository/provider map)
- [ ] Backend integration guide updated (route ownership + auth policy)
- [ ] Profile photo flow contract validated end-to-end
- [ ] Messaging contract wrappers/socket payloads validated
- [ ] Payments lifecycle and webhook behavior validated

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
- [x] 2026-02-12: Added FE/BE integration closure gates and production flag checks.
