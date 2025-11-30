# FitCoach — Software Requirements Specification (SRS)
**Version:** v1.2 — Updated with exercise swapping & first‑time exercise tutorial  
**Platforms:** Flutter (iOS/Android), Node.js API, Next.js Admin  
**Roles:** User, Coach, Admin • **Demo Mode** supported

---

## 0) Changelog
- **v1.2**
  - Added **Exercise Swap** requirement (same category replacement, logs preserved, revert).
  - Added **First‑time Exercise Tutorial** requirement (contextual walkthrough for logging).
  - Consolidated assumptions into a dedicated **Assumptions & Rationale** section.
- v1.1 (prior): Major UX rewrite: onboarding, RTL/i18n, intake → plan generation, freemium locks, quotas, bookings, store, admin benefits matrix, NFRs.

---

## 1) Product Overview & Goals
FitCoach helps users reach health goals through personalized workout & nutrition plans, plus coach guidance and a supplements store. The app offers a freemium tier with upsell to paid plans governed by entitlements (chat messages, video sessions, nutrition access).

**Primary KPIs:** plan adherence, session bookings, subscription conversion, order conversion.  
**Non‑Goals:** medical diagnosis or treatment.

---

## 2) User Experience Flow (Happy Paths)

1. **Onboarding (first run only)**
   - Purpose & value; summary of features; links to ToS/Privacy.
   - Persists `onboarding_seen=true`. A “View again” lives in **Account → Help**.

2. **Language Selection**
   - Prompt immediately after onboarding: **Arabic / English**.  
   - Changeable later via **Account → Language**; Arabic uses RTL layout & localized numerals.

3. **Splash**
   - Animated logo during warm‑up (theme, remote config, session).

4. **Authentication**
   - Sign In: Email/Password **or** Google/Apple/Facebook. Success → **Home**.
   - Sign Up → **Intake** (only for new users). OTP password reset available.

5. **Intake (multi‑screen)**
   - Age, weight, height, gender.
   - Workout days/week (2,3,4,5,6).
   - Workout location (home, gym).
   - Experience (beginner, intermediate, advanced).
   - Injuries (shoulder, knee, lower back, ankle, neck) multi‑select (+ notes).
   - **Generating Plan** screen with progress %.
   - Plan templates loaded from **assets/data**; KPIs (calories, protein, carbs, fats, muscle‑gain, fat‑loss) computed at runtime.

6. **Post‑Intake**
   - Lands on **Home**; user provisioned with **Freemium** subscription.

7. **Home (Bottom Nav)**
   - **Workouts** • **Coach** • **Nutrition** • **Store** • **Account**.
   - Stats: calories burned, calories consumed, plan adherence %, recent activity.

8. **Workouts**
   - **Two‑week plan** per intake & KPIs; refresh every 14 days.
   - Each exercise: video, cues, prescribed sets/reps/rest.
   - **Start workout** → session timer; user logs sets/reps/weights/durations.
   - **NEW: First‑time Exercise Tutorial**: on first open of Exercise Detail, show callouts explaining timer, add set, edit weight/reps, complete & save; includes “Don’t show again” and Help → “Show tutorial”.
   - **NEW: Exercise Swap**: user may replace an exercise with another from the **same category** (muscle group + modality/equipment). Swapped exercise inherits prescription (sets/reps/rest) unless the template for that category suggests different defaults. User can **Revert to original**. All logging & analytics behave identically.

9. **Nutrition**
   - Shows **daily targets** (calories/macros).  
   - Freemium: locked overlay + Upgrade CTA. Premium tiers: full plan/logging.

10. **Coach**
   - “Need help? Contact your coach” → **Chat** or **Video**.
   - **Video Booking**: pick slot in calendar; request → Pending; coach Approve/Reject; status visible (Pending/Approved/Rejected/Canceled). Quotas enforced.
   - Chat limited by plan quota (messages/month).

11. **Store & Orders**
   - Browse products, add to cart, checkout, order confirmation. **Account → Orders** for history & statuses.

12. **Account**
   - Edit profile (including weight/height/gender), change password (old/new/confirm), **Forgot password via OTP**, language, view subscription & orders, show onboarding again.

13. **Subscriptions**
   - **My Subscription** & **Compare Plans**. Benefits & quotas driven by **Benefits Matrix** configured in Admin. Admin can override per user.

---

## 3) Functional Requirements (“Shall” Statements)

### A. Onboarding, Language, Splash
1. App **shall** display onboarding on first run and store completion per account.
2. App **shall** support **Arabic and English** with runtime switching and RTL for Arabic.
3. App **shall** show an animated splash while preloading core resources.

### B. Authentication
1. App **shall** support Email/Password and OAuth (Google/Apple/Facebook).
2. App **shall** provide OTP‑based password reset.
3. After successful sign‑in, app **shall** route to **Home**; after sign‑up, to **Intake**.

### C. Intake & Plan Generation
1. App **shall** present intake as **multiple screens** covering: age, weight, height, gender, workout days/week, location, experience, injuries (+ notes).
2. App **shall** display a **Generating Plan** view with progress %.
3. Plan generator **shall** use templates from **assets/data** and compute KPIs at runtime (calories, protein, carbs, fats, muscle‑gain, fat‑loss).

### D. Workouts & Logging
1. App **shall** provide a rolling **two‑week workout plan** that refreshes every 14 days.
2. App **shall** let users **start** a workout, run a **session timer**, and **log** sets/reps/weights/durations per exercise.
3. Exercise detail **shall** show an instructional video and textual cues.
4. **NEW — First‑time Exercise Tutorial**
   - On first open of any Exercise Detail, the app **shall** show a contextual tutorial overlay explaining the logging UI (timer, add set, edit values, finish).  
   - The app **shall** persist a per‑feature/tutorial “seen” flag and provide a way to re‑open via Help.
5. **NEW — Exercise Swap (same category)**
   - The user **shall** be able to **swap** an exercise with another from the **same category** (muscle group + modality/equipment).
   - The swap flow **shall** filter the catalog to valid replacements and preview the target exercise (video/cues).
   - Upon swap, the replacement **shall** inherit sets/reps/rest from the original **unless** the category template specifies alternative defaults; users may edit prescriptions before saving.
   - The system **shall** persist swaps per user/day and **shall** support **reverting** to the original exercise.
   - Logging, timers, analytics, and plan adherence **shall** work identically for swapped exercises.
   - Coaches **shall** be able to mark specific exercises as **locked** to prevent swapping for programming reasons (e.g., assessment days).

### E. Nutrition
1. App **shall** show daily nutrition targets (calories/macros) derived from KPIs.
2. Freemium users **shall** see Nutrition as locked with an Upgrade CTA; paid tiers receive access to daily plans and logging.

### F. Subscriptions, Entitlements, Quotas
1. New users **shall** be assigned **Freemium** and may upgrade/downgrade plans.
2. Server **shall** enforce entitlements: **sessions/month**, **chat messages/month**, **nutrition access**.
3. Admin **shall** configure plans, prices, and quotas in a **Benefits Matrix**, and **may override per user** (e.g., grant extra sessions).
4. Quota windows **shall** reset monthly based on user time zone (see Assumptions §11).

### G. Coach Interaction
1. Users **shall** chat with their assigned coach and **book** video sessions in a calendar.
2. Coaches **shall** approve/reject bookings; users **shall** see status updates.
3. All chat & sessions **shall** decrement the user’s monthly quotas.

### H. Store & Orders
1. App **shall** allow browsing products, cart management, checkout, and viewing order history.
2. Admin **shall** manage products (CRUD, inventory) and orders (view/edit/cancel).

### I. Account & Settings
1. Users **shall** edit profile (gender, weight, height), change password, request OTP reset.
2. Users **shall** change app language and re‑open onboarding/tutorials.
3. Users **shall** view current subscription, compare plans, and see order history.

### J. Coach App
1. Coaches **shall** log in with admin‑created credentials and be required to set a new password at first login.
2. Coaches **shall** manage availability (single and recurring slots) and booking approvals.
3. Coaches **shall** view/edit assigned users’ workout & nutrition plans.
4. Coaches **shall** message users; entitlements limit user’s message quota.
5. Coach profile **shall** store photo, experience, and certificate uploads.

### K. Admin Web
1. Admins **shall** manage users & coaches (CRUD) and assign coaches to users.
2. Admins **shall** configure plans & **Benefits Matrix** (quotas/prices/benefits).
3. Admins **shall** manage store (products, inventory) and orders.
4. Admins **shall** view analytics (MAU, adherence, bookings, subscription & store revenue).
5. Admins **shall** view **Audit Log** for sensitive actions (who/what/when).

---

## 4) Data Model (essentials)
- **User**: profile, language_preference, onboarding_seen, subscription_id, usage_counters{chat,sessions}, metrics.
- **CoachProfile**: photo_url, experience_years, certificates[].
- **PlanTemplate** (assets/data) → **UserPlan** (instantiated from template).
- **ExerciseCategory**: {id, muscle_group, modality/equipment}. (For swap filtering)
- **UserPlanDayExercise**: {exercise_id, category_id, prescription, is_swapped, swapped_from_exercise_id, coach_locked}.
- **WorkoutLog**: {exercise_id, sets[], weight, reps, duration, calories_estimate, started_at, finished_at}.
- **NutritionLog**: {date, calories, protein, carbs, fats}.
- **SubscriptionPlan**, **BenefitsMatrix**, **Subscription**, **UsageCounter**.
- **AvailabilitySlot**, **Booking**(status).
- **Product**, **Inventory**, **Order**, **OrderItem**, **Payment/Refund**.
- **AuditEvent**.

---

## 5) Non‑Functional Requirements (NFRs)
- **Performance**: Home < 2s avg; plan generation < 5s; list/detail p95 < 1.2s; booking actions < 800ms server RTT.
- **Uptime**: 99.5% monthly; error budget policy.
- **Security & Privacy**: TLS; at‑rest encryption; RBAC; audit logs; PII minimization; GDPR data export/delete; “informational only” medical disclaimer.
- **Accessibility**: Screen reader labels, dynamic type, color‑contrast AA, touch targets ≥ 44px.
- **Theming**: Centralized theme & component library.
- **i18n/L10n**: Full RTL for Arabic; localized numerals/dates/units.
- **Observability**: Tracing, metrics with p95/p99, structured logs.
- **Offline**: Queue workout logs; retry on reconnect (idempotent).

---

## 6) Notifications
- Push/email events: booking requested/approved/rejected, coach message, order status, subscription changes, password reset.
- Users control notification preferences in **Account → Notifications**.

---

## 7) Demo Mode (no external side effects)
- Seeded personas (e.g., Mina H., Coach Sara), local videos, store items, fake payments.  
- API gateway enforces `DEMO_MODE` to **block** real email/push/payment.  
- Persistent **DEMO** badge; inactivity auto‑reset.

---

## 8) Acceptance Tests (selected)
1. **First‑time Exercise Tutorial**: On first open of Exercise Detail, tutorial appears; dismissing marks as seen; Help re‑opens tutorial.
2. **Exercise Swap**: From Exercise Detail, Swap → catalog filtered to same category; selecting replacement updates prescription and saves; Revert restores original; logs behave unchanged.
3. **Freemium Locks**: Nutrition shows locked overlay; upgrade → unlocks without restart.
4. **Quota Enforcement**: Chat/session inputs disabled at limit; server returns over‑quota error; admin override applies immediately.
5. **Booking Flow**: User requests slot → Pending; coach Approves → status=Approved; both notified; slot becomes unavailable.
6. **RTL**: Switching to Arabic mirrors layout; numerals/dates localized.

---

## 9) Risks & Mitigations
- **Program Integrity with Swaps**: Excessive swapping may break balance. → Enforce category equivalence; allow coach‑locked exercises; warn if equipment/location conflicts.
- **Double‑Booking**: Race conditions on approvals. → DB unique constraints + transactional updates.
- **Quota Timezones**: Confusion over reset timing. → Show “Resets on {local date}” and store reset anchor.
- **Vendor Lock‑in**: Chat/video/payments/push vary. → Provider interface with adapters; feature flags; stubs for Demo.
- **Tutorial Fatigue**: Overlays annoy seasoned users. → One‑time per feature with easy re‑open via Help.
- **Privacy/Liability**: Health data sensitivity. → Strict access control, retention windows, disclaimers.

---

## 10) Open Decisions
- Choose providers: (e.g., Stripe for payments; Agora/Twilio for RTC; FCM/APNs for push).  
- Decide if nutrition logging is calorie‑only or full meal logging (MVP assumes targets + optional logging).  
- Shipping/tax rules for store (regions, VAT, returns).

---

## 11) Assumptions & Rationale
These assumptions guided the requirements and can be revisited during tech design:
1. **Provider Abstraction**: Payments, chat/video, and push are integrated via a provider interface to allow vendor changes without app rewrites.
2. **Quota Reset Anchor**: Monthly quotas reset at local midnight on the **user’s** time‑zone anchor date; counters computed server‑side to avoid client drift.
3. **KPI Computation**: KPIs use standard BMR/TDEE formulas and macronutrient splits suitable for general fitness; coaches can override by editing plans.
4. **Template‑Driven Plans**: Workout plans derive from versioned templates in `assets/data`, then materialize into a user‑specific plan that may be safely edited/swapped without corrupting the source template.
5. **Media Delivery**: Production exercise videos are on a CDN with offline fallback thumbnails; Demo uses local assets.
6. **Security Posture**: All admin actions write **AuditEvent** records; sensitive PII is minimized; export/delete endpoints exist for GDPR.
7. **Arabic Localization**: Full RTL and fonts are available; content fits within typical mobile viewports (no truncation).
8. **Store Scope (MVP)**: Supplements only; no complex shipping logic initially; order editing limited to cancel/refund by admins.
9. **Coach Locking**: Coaches may lock certain programmed exercises to maintain progression; users can still view rationale.
10. **Exercise Category Taxonomy**: Categories are well‑defined (muscle group + equipment/modality) to make swap filtering precise.
11. **Tutorial Storage**: “Seen” flags are stored per account (cloud) with a local cache so reinstalls don’t re‑trigger tutorials unnecessarily.

---

## 12) Admin Configuration (“Benefits Matrix”)
- Plans (Freemium, Premium, Smart Premium…): monthly price, chat messages/month, coach sessions/month, nutrition access (yes/no), other benefits.  
- Per‑user overrides: additional messages/sessions, temporary unlocks, expiry date.  
- Live propagation: changes apply on next token refresh or pull‑to‑refresh.

---

## 13) API Surface (outline)
- **Auth**: sign‑in/up, OAuth, OTP reset.
- **Intake/Plan**: submit intake, generate plan (async job), fetch KPIs & plan.
- **Workouts**: get plan; exercise detail; **swap exercise**; start/stop session; log sets.
- **Nutrition**: get daily targets; (optional) log intake.
- **Coach**: availability CRUD; bookings approve/reject; chat; RTC token.
- **Subscriptions**: plans list/compare; checkout; entitlements; usage counters.
- **Store**: products, cart, checkout, orders.
- **Admin**: users/coaches CRUD; benefits matrix; products/inventory; orders; analytics; audit log; settings.

---

## 14) Definition of Done (per feature)
- Unit & widget tests incl. **RTL/i18n**.
- Analytics events tracked (screen views, swap_confirmed, tutorial_completed).
- Accessibility check (labels, focus order, contrast).
- Error states and empty states handled.
- Observability: logs/traces/metrics added.
- Documentation: user help & admin runbooks updated.

