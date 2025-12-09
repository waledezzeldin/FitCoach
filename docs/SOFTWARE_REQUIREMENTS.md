# FitCoach+ – Full Requirements Specification (Post-Modification) v2.0
**Status:** Draft for review  
**Owner:** Product (Fouad)  
**Date:** October 15, 2025

---

## Table of Contents
0. [Change Log](#0-change-log)  
1. [Purpose & Scope](#1-purpose--scope)  
2. [Definitions & Abbreviations](#2-definitions--abbreviations)  
3. [Target Users & Roles](#3-target-users--roles)  
4. [Assumptions (Explicit)](#4-assumptions-explicit)  
5. [High-Level System Overview](#5-high-level-system-overview)  
6. [Subscription Tiers & Entitlements](#6-subscription-tiers--entitlements)  
7. [User Journeys (Primary)](#7-user-journeys-primary)  
8. [Functional Requirements](#8-functional-requirements)  
9. [Non-Functional Requirements](#9-non-functional-requirements)  
10. [Data Model (Logical)](#10-data-model-logical)  
11. [API Surface (Representative)](#11-api-surface-representative)  
12. [UX & UI (Key Screens)](#12-ux--ui-key-screens)  
13. [Telemetry (Event Map)](#13-telemetry-event-map)  
14. [Compliance & Legal](#14-compliance--legal)  
15. [SLA, SLOs & Error Budgets](#15-sla-slos--error-budgets)  
16. [Security Controls](#16-security-controls)  
17. [Rollout Plan](#17-rollout-plan)  
18. [Open Questions (for Stakeholder Sign-off)](#18-open-questions-for-stakeholder-sign-off)  
19. [Appendices](#19-appendices)

---

## 0. Change Log
| Version | Date | Summary |
|---------|------|---------|
| v2.0 | 2025-10-15 | Added phone-number login, two-stage intake, Freemium default quotas, gated chat attachments, nutrition windows for non-subscribers, and post-interaction ratings. |
| v1.x | Pre-2025 | Baseline SRS with workout templates (2–6 day splits), injury substitution table, demo mode, coach scheduling, store, admin dashboards. |

## 1. Purpose & Scope
FitCoach+ is a mobile fitness coaching experience that minimizes time-to-value via a lightweight First Intake, delivers a Starter Plan immediately, and progressively unlocks richer personalization—Second Intake, Customized Plans, enhanced communication, and persistent nutrition—once users upgrade tiers.

**In scope**
- Mobile apps (Flutter iOS/Android), Backend (Node.js), Admin console (Next.js).
- Phone OTP auth + optional email/OAuth linking.
- Onboarding (First Intake), Home, Workout engine, Nutrition, Coach messaging/video, Ratings.
- Subscription management (Freemium, Premium, Smart Premium) with server-enforced entitlements.
- Coach scheduling/approvals, injury-aware substitutions, store + orders MVP, admin configuration/analytics/demo mode.

**Out of scope for v2.0**
- Wearable integrations.
- Advanced periodization.
- Food barcode scanning.
- Multi-location inventory.

## 2. Definitions & Abbreviations
- **E.164:** International phone number format (e.g., +201234567890).
- **First Intake:** 3 required questions (Gender, Fitness Goal, Exercise Location) asked after first sign-in.
- **Second Intake:** Premium/Smart Premium questionnaire (Age, Weight, Height, Experience, Days/Week, Injuries).
- **Starter Plan / Generic Plan:** Workout plan derived only from First Intake.
- **Customized Plan:** Plan generated from Second Intake + injury rules.
- **Tier:** Subscription level (Freemium, Premium, Smart Premium) defining entitlements.
- **Message/Call Quota:** Monthly allowance per tier enforced server-side.
- **Nutrition Window:** Time-bound access period (days) for non-subscribers; configurable.
- **Demo Mode:** Safe sandbox with seeded data and no external side effects.

## 3. Target Users & Roles
- **End User (Member):** Completes intakes, consumes plans, chats/books with coaches, rates sessions, purchases store items.
- **Coach:** Manages availability, approves bookings, chats with assigned users, reviews ratings.
- **Admin:** Manages users/coaches, entitlements, content, orders; oversees analytics, ratings, configuration.

## 4. Assumptions (Explicit)
- Primary markets: KSA, Egypt, Turkey. English at v2.0 launch; Arabic/Turkish follow.
- Units: user-selectable metric/imperial (default metric for MENA).
- Time zone: per-device; bookings shown in user time zone.
- Quotas reset at 00:00 UTC on the first calendar day monthly unless Admin overrides.
- Freemium users: one active nutrition plan at a time; regenerating replaces the previous plan and restarts the window.
- Ratings: 1–5 stars + optional comments; anonymous to coach (aggregate only) but attributable for moderation.
- Payments: Stripe-like API (test/prod) with pluggable provider interface for local gateways.
- OTP: SMS provider primary; WhatsApp fallback for weak SMS regions.
- Privacy: GDPR principles; DPA on file; guardian consent required for under-18 if enabled per region.

## 5. High-Level System Overview
- **Mobile App (Flutter):** First Intake → Home → Starter Plan; upgrade → Second Intake → Customized Plan; includes Chat, Calls, Nutrition, Ratings, Store, Account.
- **Backend (Node.js + DB):** Auth, entitlements, plan engine, injury substitutions, messaging, booking, payments, nutrition, ratings, admin APIs, telemetry.
- **Admin Console (Next.js):** Manage quotas/windows, content, catalog, orders, coaches, users, ratings, analytics, feature flags.

## 6. Subscription Tiers & Entitlements
### 6.1 Tier Matrix (Admin-editable defaults)
| Capability | Freemium | Premium | Smart Premium |
|------------|----------|---------|---------------|
| First Intake (3 Qs) | ✔ | ✔ | ✔ |
| Starter Workout Plan | ✔ | ✖ (replaced by Customized) | ✖ (replaced by Customized) |
| Second Intake (Full) | ✖ | ✔ | ✔ |
| Customized Workout Plan | ✖ | ✔ | ✔ |
| Coach Messages / mo | 20 | 200 | Unlimited |
| Coach Video Calls / mo | 1 × 15 min | 2 × 25 min | 4 × 25 min |
| Chat Image Attachments | ✖ | ✔ | ✔ |
| Nutrition Generation | ✔ | ✔ | ✔ |
| Nutrition Access Window | 7 days | Persistent | Persistent |
| Store Access | ✔ | ✔ | ✔ |
| Ads / Upsell Banners | Light | None | None |

### 6.2 Entitlement Enforcement
- Server-side counters track usage; client displays remaining quota.
- Soft warning at 80% usage; hard block when exceeding quota.
- Upgrades effective immediately; downgrades scheduled for next renewal.

## 7. User Journeys (Primary)
1. **Rapid onboarding:** New user → First Intake → Home → Starter Plan ≤ 60 seconds.
2. **Upgrade flow:** Freemium → Upgrade CTA → Paywall → Subscribe → Second Intake → Customized Plan.
3. **Message quota:** Chat until quota reached; further attempts trigger upsell.
4. **Call booking:** Schedule within remaining quota → attend → immediate post-call rating.
5. **Nutrition window:** Freemium generates plan → view for 7 days → lock with upsell; Premium retains access.
6. **Re-intake:** After subscription, rerun workout/nutrition intake → regenerate plans.

## 8. Functional Requirements
### 8.1 Authentication & Account (A-xx)
- **A-01 Phone Login:** Sign-in/up via phone (E.164). OTPs single-use, expire ≤10 min, lockout after 5 failures/15 min. Phone numbers unique per user.
- **A-02 Linking:** Users may link/unlink email/OAuth to the same account; any linked method works afterward.
- **A-03 Session Mgmt:** Short-lived access tokens + refresh tokens, device list with revoke. 2FA optional future.
- **Acceptance:** Valid OTP authenticates; duplicate numbers blocked; rate limits show clear errors.

### 8.2 Onboarding & Home (UX-xx)
- **UX-01 First Intake:** Mandatory Gender, Goal, Location form; persist Intake v1.
- **UX-02 Direct to Home:** Post-submit, navigate to Home showing Starter Plan + Upgrade CTA.
- **UX-03 Default Tier:** First sign-in provisions Freemium entitlements.
- **UX-04 Empty States:** Missing data uses skeleton + retry, never dead ends.
- **Acceptance:** Flow ≤4 taps; Home p95 render ≤2s on 4G.

### 8.3 Subscriptions & Billing (SUB-xx)
- **SUB-01 Tiers & Quotas:** Define per-tier quotas and nutrition windows; enforce server-side.
- **SUB-02 Upgrade/Downgrade:** Upgrade immediate; downgrade scheduled; proration supported.
- **SUB-03 Paywall:** Gated actions on Freemium display localized tier/price comparison.
- **Acceptance:** Quota exceed blocks action with upsell; upgrade unlocks instantly without restart.

### 8.4 Workout Planning (WO-xx)
- **WO-01 Starter Plan:** Derived solely from Intake v1; labeled “Starter Plan.”
- **WO-02 Second Intake:** Premium+ multi-step capturing Age, Weight, Height, Experience, Days/Week, Injuries; persist Intake v2.
- **WO-03 Customized Plan:** Generated via Intake v2 + injury rules; supports 2–6 day splits and progression guidance.
- **WO-04 Logs:** Users log sets/reps/weight/time; offline auto-save with sync.
- **Acceptance:** Adjusting days/week or injuries alters plan; Starter Plan never prompts for v2 fields.

### 8.5 Injury Substitution (INJ-xx)
- **INJ-01 Rules Engine:** Maintain avoid/substitute lists per injury; customized plans swap conflicting exercises while preserving muscle/plane intent.
- **INJ-02 Safety Checks:** Weekly volume within ±15% of template for major muscle groups; flag for coach review when not possible.
- **Acceptance:** Knee injury removes squats/lunges yet retains quad stimulus.

### 8.6 Coach Communication (CHAT-xx / CALL-xx / RATE-xx)
- **CHAT-01 Quotas:** Enforce per-tier message quotas; UI shows remaining count.
- **CHAT-02 Threads:** Single thread per user↔coach; attachments/reactions as per tier.
- **CHAT-03 Attachments:** Premium/Smart Premium only; Freemium sees disabled button + tooltip.
- **CALL-01 Scheduling:** Users request video calls within quota against coach availability slots; coach approves/declines; push/email confirmation.
- **CALL-02 Conferencing:** WebRTC/Twilio-class provider with in-app join and timer.
- **RATE-01 Ratings:** After call or chat inactivity ≥30 min, prompt for 1–5 stars + comment. Ratings visible to Admin; aggregates visible to Coach.
- **Acceptance:** Exceeding quotas blocks actions; rating prompt fires reliably and persists data.

### 8.7 Nutrition (NUT-xx)
- **NUT-01 Generation:** All tiers can generate macros + meal ideas.
- **NUT-02 Access Window:** Freemium defaults to 7-day access (Admin-configurable). After expiry, plan locks but remains stored for future unlock.
- **NUT-03 Re-Intake:** Premium+ users can rerun intake and regenerate with persistent access (unless window configured).
- **Acceptance:** Freemium lock occurs exactly at expiry; upgrading unlocks immediately with history retained.

### 8.8 Store & Orders (SHOP-xx)
- **SHOP-01 Catalog:** Admin-managed products with images, stock, localized pricing.
- **SHOP-02 Checkout:** Payments via configured gateway; tax/VAT per region; order history accessible.
- **Acceptance:** Successful orders issue receipts; idempotency prevents duplicates.

### 8.9 Admin Console (ADM-xx)
- **ADM-01 Quotas & Windows:** Configure tier quotas/windows; changes apply to next attempted action.
- **ADM-02 Users & Coaches:** CRUD, role assignment, availability management, reassignment.
- **ADM-03 Ratings:** View aggregates, read comments, moderate with reason logging.
- **ADM-04 Feature Flags:** Toggle chat attachments, rating prompts, regions/languages.
- **ADM-05 Content:** Manage exercises, substitutions, templates, preview plans.
- **Acceptance:** Adjusting Freemium quota impacts next send; disabling attachments hides UI after restart or config refresh.

### 8.10 Demo Mode (DEMO-xx)
- **DEMO-01 Safe Sandbox:** Seeded data, offline media, fake payments; DEMO badge visible.
- **DEMO-02 Reset:** Admin can reset demo data; no external side effects.
- **Acceptance:** No outbound payment/RTC calls in Demo; reset restores baseline.

## 9. Non-Functional Requirements (NFR-xx)
- **NFR-01 Performance:** Home render ≤2s p95 on 4G; plan generation ≤5s p95 (async warm-up post-intake).
- **NFR-02 Availability:** 99.5% monthly uptime for core APIs (auth, plans, chat, bookings, payments).
- **NFR-03 Security:** TLS 1.2+, Argon2/Bcrypt passwords, JWT rotation, RBAC, audit logs, encrypted PII at rest, secret rotation policy.
- **NFR-04 Privacy:** GDPR data rights, health-data consent, guardian consent for minors, regional residency as needed.
- **NFR-05 Accessibility:** WCAG 2.1 AA, dynamic type, screen-reader labels, color contrast ≥4.5:1.
- **NFR-06 Observability:** Structured logs, traces, metrics, alerting on SLO breaches, admin audit events.
- **NFR-07 Offline:** Read-only cached workouts; logs queue offline with retry/backoff.
- **NFR-08 Localization:** Externalized strings; RTL support; number/date/unit internationalization.

## 10. Data Model (Logical)
```
User(id, phone_e164, email?, oauth_ids[], tier, locale, units, tz, created_at)
IntakeV1(user_id, gender, goal, location, ts)
IntakeV2(user_id, age, height_cm, weight_kg, experience, days_per_week, injuries[], ts)
Subscription(user_id, tier, status, start, renewal, entitlements_json)
WorkoutTemplate(id, days_per_week, split, level, goal, location, blocks[])
UserPlan(id, user_id, type:{starter|custom}, source_intake:{v1|v2}, weeks[], substitutions_json, created_at)
WorkoutLog(id, user_id, plan_id, exercise_id, sets[{reps, load, rir, duration_s}], ts)
InjuryRule(id, code, avoid_keywords[], substitutes[])
Message(id, thread_id, sender, type:text|image, bytes?, ts)
Thread(id, user_id, coach_id, last_ts, message_count_mo)
AvailabilitySlot(id, coach_id, start_ts, end_ts, capacity)
Booking(id, user_id, coach_id, slot_id, status, join_url, duration_min, ts)
Rating(id, user_id, coach_id, modality:chat|call, stars, comment?, ts)
NutritionPlan(id, user_id, macros_json, meals_json, generated_ts, expires_ts?)
Product(id, sku, name, price_map, stock, img_url)
Order(id, user_id, items[], total, status, ts)
AdminAction(id, admin_id, action, target, diff_json, ts)
```

## 11. API Surface (Representative)
- **Auth:** `POST /auth/phone/request_otp`, `POST /auth/phone/verify`, `POST /auth/link`
- **Intake:** `POST /intake/v1`, `GET /intake/v1`, `POST /intake/v2` (Premium+), `GET /intake/v2`
- **Plans:** `POST /plans/generate` (starter|custom), `GET /plans/current`, `POST /workouts/:id/log`
- **Subscriptions:** `GET /subs`, `POST /subs/upgrade`, `POST /subs/downgrade`
- **Chat:** `GET /threads`, `POST /threads/:id/messages`, `POST /threads/:id/attachments` (tier-gated)
- **Calls:** `GET /coaches/:id/slots`, `POST /bookings`, `PATCH /bookings/:id` (approve/decline)
- **Ratings:** `POST /ratings`, `GET /ratings/coach/:id` (coach/admin)
- **Nutrition:** `POST /nutrition/generate`, `GET /nutrition/current`, `POST /nutrition/regenerate`
- **Admin:** `POST /admin/tiers/config`, `POST /admin/flags`, `GET /admin/analytics`
- **Demo:** `POST /demo/activate`, `POST /demo/reset`

## 12. UX & UI (Key Screens)
- **Auth:** Phone number → OTP → optional email/OAuth linking.
- **First Intake:** 3 compact pickers, progress “1/1”, single submit.
- **Home:** Starter Plan card, Upgrade CTA, message/call counters.
- **Paywall:** Tier matrix, local currency pricing, benefit list, trust badges.
- **Second Intake:** Multi-step form with preview summary before plan generation.
- **Plan:** Weekly tabs, exercises, timers, logging controls, injury badges.
- **Chat:** Thread view, composer, attachment button (tier gated), quota chip.
- **Calls:** Slot picker, booking status, countdown, in-call timer, end → rating modal.
- **Nutrition:** Macro overview, meal cards, expiry banner countdown for Freemium.
- **Account:** Units, language, notifications, device sessions, re-intake triggers.
- **Admin:** Configurations, users/coaches, catalog, ratings, analytics panels.

## 13. Telemetry (Event Map)
`auth.phone.requested`, `auth.phone.verified`, `intake.v1.completed`, `home.first_seen`, `subscription.started`, `paywall.viewed`, `subscription.upgraded`, `intake.v2.completed`, `plan.generated` (starter|custom), `workout.logged`, `injury.substitution.applied`, `chat.sent`, `chat.blocked_quota`, `call.scheduled`, `call.completed`, `rating.submitted`, `nutrition.generated`, `nutrition.expired`, `nutrition.view_locked`, `order.placed`.

## 14. Compliance & Legal
- Health-data consent screens; Terms/Privacy updated for phone OTP + ratings.
- Parental consent flow toggle for under-18 users; content filtered accordingly.
- Data retention: messages 24 months, ratings 36 months, logs 36 months; deletions honored per DSR.

## 15. SLA, SLOs & Error Budgets
- **Auth & Home:** p95 ≤2s; availability ≥99.5%/month; error budget 21 min/month.
- **Plans:** p95 ≤5s; retries on transient failures; warm cache on intake submit.
- **Chat/Calls:** Message enqueue <300 ms; call setup <5 s.
- **Payments:** Idempotency key required; webhook retries with backoff up to 24h.

## 16. Security Controls
- OTP throttling and fraud heuristics; HMAC-signed upload URLs; AV scan on attachments; MIME/type + size caps (images ≤10 MB, jpg/png/webp).
- RBAC across User/Coach/Admin; audit log every admin change.
- PII encryption at rest; key rotation; secrets stored in KMS/Vault equivalents.

## 17. Rollout Plan
- **M0 (Demo-only):** Phone OTP sandbox, First Intake → Home → Starter Plan, fake chat/calls, nutrition stub, paywall.
- **M1 (Core):** Real auth, quotas, Starter Plan logging, ratings MVP.
- **M2 (Billing):** Real payments, upgrades, Admin quota/window controls.
- **M3 (Coaching):** Availability, bookings, real calls, tier-gated attachments.
- **M4 (Customization):** Second Intake + Customized Plans + injury rules.
- **M5 (Nutrition):** Full nutrition engine + Freemium expiry logic.

## 18. Open Questions (for Stakeholder Sign-off)
1. Confirm/adjust default quotas per tier (see §6.1).
2. Define nutrition algorithm + food DB source and regional cuisine sets.
3. Finalize cooldown policy after OTP lockout (e.g., 30 minutes) and appeal flow.
4. Decide rating visibility to coaches (aggregate only vs sample comments) and minimum N for display (suggest N ≥ 5).
5. Determine if downgrades instantly remove attachments or allow grace until period end (suggest grace).

## 19. Appendices
- **A:** Exercise taxonomy & tags (equipment, muscles, movement patterns).
- **B:** Injury codes & substitution matrices (knee, shoulder, lower back, elbow, wrist, ankle).
- **C:** Error message catalog (localized, user-facing).
- **D:** Push notification templates (booking, quota nearing, nutrition expiry, upgrade success).

