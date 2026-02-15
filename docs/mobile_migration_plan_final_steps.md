### Phase 7: Home, Workouts, Nutrition, Coach, Store Modules
- Deliverables:
  - Implement Home dashboard, Workouts, Nutrition, Coach, and Store screens and flows.
  - Integrate with AppState and routing.
  - Ensure all modules support localization and RTL.
- Tests:
  - Widget and integration tests for each module.
  - Goldens for key screens (optional).
- DoD:
  - All modules functional and visually match design.

### Phase 8: Release Preparation
- Deliverables:
  - Configure flavors (dev, prod) in `mobile/android` and `mobile/ios`.
  - Add app icons and splash screens.
  - Document build and release instructions in `docs/RELEASE.md`.
- Tests:
  - Build and run checks for all flavors.
  - CI workflow passes for all branches.
- DoD:
  - Ready for app store submission.

### Phase 9: CI/CD & Store Submission
- Deliverables:
  - Finalize GitHub Actions workflow for build, test, and artifact upload.
  - Add deployment steps (optional: Firebase App Distribution, TestFlight, Play Console).
  - Prepare app store metadata and screenshots.
- Tests:
  - CI runs on every push/PR; all tests pass.
- DoD:
  - App submitted to stores or distributed to testers.

---

## Final Checklist
- [x] All screens and flows implemented
- [x] Localization and RTL verified
- [x] Widget/integration tests pass
- [x] CI workflow green
- [x] Flavors, icons, splash screens configured
- [x] Release instructions documented
- [x] App store submission prepared

---

For details on build/release, see `docs/RELEASE.md`.
