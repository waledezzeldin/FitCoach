# Feature Flag and Incomplete UI Policy

Last updated: 2026-02-12

## Goal
Ensure incomplete/demo/simulated functionality is never exposed in production behavior unless an explicit build/runtime flag enables it.

## Mandatory Rules
1. Demo-only frontend behavior must be guarded by demo flag checks.
   - Primary gates:
     - `DemoConfig.isDemo`
     - `DemoModeConfig.isDemo`
   - Any placeholder data, mock saves, or "coming soon" interactions must be hidden when demo mode is off.
2. Simulated backend behavior must be explicitly feature-flagged.
   - Example:
     - InBody simulated AI extraction is controlled by `ENABLE_SIMULATED_AI_EXTRACTION=true`.
     - Default behavior (flag absent/false): service disabled with `503`.
3. Webhook and payment-critical paths must fail closed.
   - Signature validation failures must reject requests.
4. New placeholder UI/actions are not allowed without one of:
   - Full backend integration.
   - Explicitly gated demo/experimental mode with documented flag.

## Current Flagged Behaviors
- Frontend demo mode:
  - Demo IDs, mock datasets, and non-production paths.
  - Account/payment mock actions hidden in non-demo.
- Backend simulated AI extraction:
  - Env flag: `ENABLE_SIMULATED_AI_EXTRACTION`
  - Optional test/perf flag: `AI_EXTRACTION_DELAY_MS`

## Implementation Checklist for New Features
- Add flag definition and default (`off` unless approved).
- Add tests for both enabled and disabled behavior.
- Document behavior and expected API status codes.
- Update `docs/integration_gap_progress_tracker.md` item status.
