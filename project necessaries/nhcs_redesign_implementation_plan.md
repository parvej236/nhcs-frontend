# NHCS Full‑Stack UI Redesign — Implementation Plan

**Product:** NHCS – National Healthcare System ("NHCS AI")
**Frontend:** Flutter (Dart) web — *staying in Flutter*
**Backend:** Spring Boot 3.2.3 + PostgreSQL + JWT (existing)
**Design source of truth:** `nhcs-backend/src/main/resources/static/prototype/` (React prototype — visual reference only, NOT the shipped code)
**Approach:** Vertical slices — every feature is delivered full‑stack (Flutter UI + Spring endpoint + DB) before moving to the next.

---

## 1. Goals

1. Rebrand the app from **blue / light‑only** to **red‑coral (`#ef4444`), dark‑first** with a real light/dark toggle.
2. Add a **public marketing site** (logged‑out) with self‑service tools.
3. Add the new features shown in the prototype (Blood Donation, public Vitals Analyzer, AI briefings, appointment approval, arrivals check‑in) — wired to the **real backend**.
4. **Remove** the Government portal and the trimmed Hospital/Doctor pages.
5. Ship incrementally, each slice fully working with zero runtime errors.

---

## 2. Locked Decisions

| Topic | Decision |
|---|---|
| Platform | Stay in Flutter; keep Spring Boot backend |
| Theme | Red/coral `#ef4444`, **dark‑first** + light mode toggle; keep Inter (body) + Outfit (headings) |
| Government portal | **Remove entirely** (role, routes, pages, providers, sidebar) |
| Branding | NHCS – National Healthcare System, red heart logo |
| Build style | Vertical slices, full‑stack per feature |
| Registration | **Patient self‑register only**; Doctor / Hospital / Admin are **seeded** (no public signup). Backend tightened to enforce. |
| First milestone | Public marketing site + working login/register |
| Device target | Desktop‑first web (responsive‑friendly); mobile polish deferred |

### Default assumptions (change if needed)
- Seed accounts: `patient/password123` (exists), plus new `doctor/password123`, `hospital/password123`, `admin/password123`. Quick‑login buttons use these.
- Public "Join Queue" / "Book" prompts login rather than acting anonymously.
- Blog + Emergency Blood + Live Donor render static prototype content with a "login to continue" CTA in Milestone 1.
- New public site fully replaces the current `landing_page.dart`.
- Footer uses the prototype's emergency numbers / affiliates text.

---

## 3. Scope Delta vs. Current App

### Added (new)
- Public site: Web Hero, Stat Row, **Vitals Risk Analyzer** (public AI), **Doctor Directory + Queue**, **Emergency Blood + Live Donor** hubs, **Health Blog Hub**, Our Solutions, Success Stories.
- Patient: **Blood Donation** (donor toggle, AI eligibility, accept/decline requests, donation history), **Healthcare AI** (embedded vitals analyzer).
- Doctor: **AI Medical History Briefing** generator in the clinical workspace.
- Hospital: **Appointment Requests** approval workflow, **Arrivals Check‑In → queue sync**, **Department Timings**, **Laboratory Hub** (result upload → dispatch to doctor).
- Auth: red dark‑first **Login/Register** portal.

### Removed
- **Government portal** — all 6 pages, `GovtShell`, `GovtSidebar`, `/government` route, `GOVT` role usage in the client, govt providers/models/datasources/repositories.
- **Hospital:** Staff Management, Bed Management, Pharmacy, full Reception Kanban queue.
- **Doctor:** "My Schedule" page.
- **Patient:** standalone "AI Assistant (Coming Soon)" tab (replaced by Healthcare AI).

### Kept & restyled
- Patient: Dashboard, Profile (+ update wizard), Appointments (+ AI booking), Health Timeline, Medical Vault.
- Doctor: Dashboard, Clinical Workspace, Report Review, Professional Profile.
- Hospital: Command Dashboard (simplified).
- Shared: `AiInsightPanel`, `NotificationDropdown` (restyled). `WorkspaceSwitcher` kept for multi‑role users but with GOVT removed.

---

## 4. Design System

### 4.1 Color tokens (rewrite `lib/core/theme/app_colors.dart`)

Introduce **two token sets** (dark + light) mirroring the prototype's `TD`/`TL`.

**Dark (default)**
| Token | Hex |
|---|---|
| bgMain | `#0B0F19` |
| bgCard | `#131C2E` |
| bgInput | `#1B2640` |
| border | `#2A3A5A` |
| textPrimary | `#F8FAFC` |
| textSecondary | `#94A3B8` |
| brandPrimary | `#EF4444` |
| brandSecondary | `#F87171` |
| success | `#10B981` / warning `#F59E0B` / danger `#EF4444` |
| radius | 16 / innerRadius 12 |

**Light**
| Token | Hex |
|---|---|
| bgMain | `#F8FAFC` |
| bgCard | `#FFFFFF` |
| bgInput | `#F1F5F9` |
| border | `#E2E8F0` |
| textPrimary | `#0F172A` |
| textSecondary | `#64748B` |
| brandPrimary | `#DE3B3B` |

### 4.2 Theming implementation
- Add `AppTheme.darkTheme` alongside `lightTheme` (Material 3, `ColorScheme.fromSeed(seedColor: brandPrimary, brightness: …)`).
- Add a `themeModeProvider` (Riverpod `StateProvider<ThemeMode>` or `StateNotifier`) persisted via `shared_preferences`; default `ThemeMode.dark`.
- Wire `MaterialApp.router` with `theme`, `darkTheme`, `themeMode`.
- Typography: `google_fonts` — Inter body, Outfit display (already in use).

### 4.3 Restyled primitives (`lib/core/widgets/`)
`AppCard`, `AppButton` (primary/secondary/outline/danger), `AppInput`, `AppSelect`, `AppChip` (normal/warning/danger/success), `AppProgress` — token‑driven so they respond to theme mode. Mirror the prototype's `system.jsx` primitives.

---

## 5. Architecture

### 5.1 Flutter
- Keep feature‑first structure under `lib/features/*`, core under `lib/core/*`.
- Keep **go_router** + **Riverpod**. Update routes: remove `/government`; add public site as `/` and `/login` (tabbed sign‑in/register).
- Keep the Dio API stack (`api_client.dart`, interceptors, `api_endpoints.dart`); extend endpoints per slice.
- New shared area: `lib/features/public/` for the marketing site (hero, analyzer, doctor directory, blood/blog sections, footer).

### 5.2 Backend
- Add a **public** controller group (`/api/v1/public/**`) with `permitAll` in `SecurityConfig`.
- Add domain entities + repositories per slice (see §7).
- Add proper `@Service` classes (move logic out of `PatientController`).
- Extend `DataInitializer` to seed login users for doctor/hospital/admin and demo domain data.
- Lock down inconsistent `@PreAuthorize` (DoctorController, applications approve/reject/pending).

---

## 6. Milestone / Slice Plan

> Each slice lists **Frontend**, **Backend**, and **Done‑when** (acceptance). Slices are ordered; earlier slices unblock later ones.

### Slice 0 — Foundation (theme + Government removal)
**Frontend**
- Rewrite `app_colors.dart` (dark+light token sets), add `AppTheme.darkTheme`, `themeModeProvider` (persisted), wire into `MaterialApp`.
- Build restyled primitives (`AppCard/Button/Input/Select/Chip/Progress`).
- **Remove Government:** delete `lib/features/government/`, `GovtShell`, `GovtSidebar`, `/government` route + guard mapping, `govt_providers`, remove GOVT from client role routing/workspace switcher. Remove role‑application *approval UI* (approvals were a govt page); backend applications endpoints stay dormant since Doctor/Hospital are seeded.
**Backend**
- No new endpoints. Confirm build still green after client changes.
**Done‑when:** App boots in dark red theme, toggling to light works and persists, no references to Government remain, no route/role errors.

### Slice 1 — Public marketing site (static shell) + theme toggle
**Frontend** (`lib/features/public/`)
- `PublicShell` with sticky `NavigationHeader` (Home, Risk Analyzer, Specialists & Queue, Emergency Blood, Health Blog) + theme toggle + **Login Portal** button.
- Sections: `WebHero`, `StatRow`, `VitalsChecker`, `DoctorQueueTracker`, `EmergencyBloodRequest`, `LiveDonorAvailability`, `OurSolutions`, `SuccessStories`, `HealthBlogHub`, `Footer`.
- In this slice, all data is static placeholders; anchor‑scroll nav works.
**Backend**: none.
**Done‑when:** `/` renders the full new marketing page, desktop layout matches prototype, theme toggle works throughout.

### Slice 2 — Auth (login / register) wired to real backend
**Frontend**
- New `LoginPortalPage` (tabbed Sign In / Register), patient‑only register, quick demo‑login buttons.
- On login: store JWT, route by role (PATIENT→`/user`, DOCTOR→`/doctor`, HOSPITAL→`/authority`); handle multi‑role via WorkspaceSwitcher.
**Backend**
- Restrict `AuthService.register` to **PATIENT only** (ignore elevated role requests; create Patient profile).
- Seed `doctor/hospital/admin` **User** accounts in `DataInitializer`, linking the seeded doctors to users.
- Remove the `nehal` auto‑approve backdoor (or gate behind a dev flag).
**Done‑when:** Register creates a patient and logs in; seeded doctor/hospital/admin can log in and land on their portal; JWT persists across reload.

### Slice 3 — Public real data (stats + doctor directory + vitals AI)
**Backend** (new `PublicController`, all `permitAll`)
- `GET /api/v1/public/stats` → `{patients, doctors, hospitals}` real counts.
- `GET /api/v1/public/doctors` → list `{id,name,specialization,hospital,fee,experience,rating,queueCount}` (queueCount = today's `Upcoming` appointments for that doctor).
- `POST /api/v1/public/vitals-analyze` → body `{symptomsText, bpSystolic?, bpDiastolic?, glucose?}`; calls Gemini (reuse the existing Gemini integration) → `{category, severity(success|warning|danger), bpVal, glucoseVal, summary, recommendations[]}`; keyword fallback when no API key.
- Add `/api/v1/public/**` to `SecurityConfig` permitAll.
**Frontend**
- Wire `StatRow`/hero numbers to `/public/stats`.
- Wire `DoctorQueueTracker` to `/public/doctors`; "Join Queue"/"Book" → redirect to login.
- Wire `VitalsChecker` to `/public/vitals-analyze` (keep the 3 "simulate" presets as example inputs).
**Done‑when:** Public page shows real counts, real doctors with live queue numbers, and real AI risk output; blood/blog remain static with login CTA.

### Slice 4 — Patient portal redesign (read paths)
Restyle Dashboard, Profile (+wizard), Timeline, Vault, Appointments to the new theme against **existing** patient APIs (`/patients/me`, dashboard, timeline, prescriptions, lab/imaging, appointments). Embed Healthcare AI (vitals analyzer) tab.
**Done‑when:** Patient portal fully themed and functional on current endpoints.

### Slice 5 — Appointments approval + arrivals check‑in (Hospital ↔ Patient ↔ Doctor)
**Backend**
- Extend `Appointment` with `approvalStatus` (`PENDING/APPROVED/REJECTED`) and `arrivalStatus` (`AWAITING/CHECKED_IN/COMPLETED`).
- Endpoints: `GET /hospital/appointments/pending`, `PUT /hospital/appointments/{id}/approve|reject`, `PUT /hospital/appointments/{id}/check-in`; patient booking sets `PENDING`.
**Frontend**
- Hospital: Appointment Requests page (approve), Arrivals Check‑In page (mark present → queue).
- Patient: booking reflects approval state; Doctor queue reflects checked‑in patients.
**Done‑when:** A patient booking flows Pending→Approved→Checked‑in→Doctor queue, end‑to‑end on real data.

### Slice 6 — Doctor clinical workspace writes + Laboratory Hub
**Backend**
- Doctor write endpoints: create Prescription, create/append LabReport order, submit diagnosis/treatment plan for a patient (mutates patient records).
- Hospital Lab Hub: `GET /hospital/lab-orders`, `POST /hospital/lab-orders/{id}/results` → publishes `LabReport` + dispatches to ordering doctor.
- Lock down DoctorController with `@PreAuthorize`.
**Frontend**
- Doctor Clinical Workspace: patient card+vitals, **AI Medical History Briefing** (reuse Gemini), treatment/prescription form submit.
- Doctor Report Review: pending/reviewed tabs, mark reviewed.
- Hospital Laboratory Hub: upload results → dispatch.
**Done‑when:** Doctor can open a queued patient, generate an AI briefing, submit a treatment plan/prescription; lab results uploaded by hospital appear in the doctor's review and the patient's vault.

### Slice 7 — Blood Donation (Patient) + Emergency Blood (public real)
**Backend** — new domain:
- `BloodDonor` (userId, bloodGroup, isActive, lastDonationDate, eligibility fields).
- `BloodRequest` (hospital, patient, group, urgency, neededBy, status).
- `DonationRecord` (donorId, recipient, group, date, units, status).
- Endpoints: register/toggle donor, list matching requests, accept/decline, donation history; AI eligibility check (chronic/recency rules + Gemini narrative).
- Public: `POST /public/blood-request` (emergency request), `GET /public/donor-availability` (hub stats).
**Frontend**
- Patient Blood Donation screen (donor toggle, AI eligibility analyzer, requests accept/decline, history).
- Public Emergency Blood + Live Donor wired to real endpoints.
**Done‑when:** Donor lifecycle and emergency request flow work on real data with AI eligibility.

### Slice 8 — Health Blog + Notifications (real)
**Backend**: `BlogPost` entity + `GET /public/blog`, `GET /public/blog/{id}`; `Notification` entity + per‑user notification endpoints.
**Frontend**: Health Blog Hub wired to real posts; `NotificationDropdown` wired to real notifications.
**Done‑when:** Blog lists real posts; notifications reflect real events (e.g., appointment approved, report published).

### Slice 9 — Polish & responsive pass
Mobile/tablet breakpoints for public site + portals, empty/error/loading states, accessibility, snackbar/error consistency, remove dead code, final QA.

---

## 7. Backend Work Summary (by need)

### Already exists (reuse)
- Auth (JWT login/register), Patient profile/dashboard/timeline/appointments/prescriptions/lab/imaging, Gemini `ai-suggest`, Applications flow, Doctors list, Hospitals list.

### New endpoints to build (grouped)
- **Public:** `/public/stats`, `/public/doctors`, `/public/vitals-analyze`, `/public/blood-request`, `/public/donor-availability`, `/public/blog`.
- **Hospital:** appointment approval + arrivals, lab‑order results dispatch, hospital dashboard metrics.
- **Doctor:** create prescription / treatment plan / diagnosis, report review write, own queue.
- **Blood domain:** donor register/toggle, requests match/accept/decline, donation history, AI eligibility.
- **Notifications & Blog:** CRUD/read endpoints.

### New / extended entities
`Appointment` (+approvalStatus, +arrivalStatus), `BloodDonor`, `BloodRequest`, `DonationRecord`, `BlogPost`, `Notification`, (optional) `VitalsHistory` time‑series for real vitals trends.

### Security / hardening
- `permitAll` for `/api/v1/public/**`; everything else authenticated.
- Add `@PreAuthorize` to DoctorController and applications approve/reject/pending.
- Registration = PATIENT only. Remove/guard the `nehal` backdoor.
- Keep CORS dev‑open; tighten before production.

### Seeding (`DataInitializer`)
- Add User accounts: `doctor`, `hospital`, `admin` (+ link doctors to users so they can log in).
- Seed demo blood requests, blog posts, and a few appointments in each approval/arrival state for demoable flows.

---

## 8. Government Removal Checklist
- [ ] Delete `lib/features/government/` (pages, data, providers, models, datasources, repositories).
- [ ] Remove `GovtShell`, `GovtSidebar`, `WorkspaceSwitcher` GOVT entry.
- [ ] Remove `/government` route + guard role→route mapping for GOVT.
- [ ] Remove GOVT from client role handling / default‑role selection.
- [ ] Remove the govt role‑application *approval* UI (approvals were a govt page). Backend applications endpoints remain but are dormant (Doctor/Hospital are seeded).
- [ ] Grep for `GOVT`, `govt`, `government`, `account_balance`, `MoHFW` and clean references.
- [ ] Confirm `flutter analyze` is clean and app boots.

---

## 9. Risks & Notes
- **Backend gap is large** — most new features have no endpoints today; vertical slices keep each shippable.
- **IDs are mixed** (Long vs `PR-`/`LR-`/`APP-` strings) — keep DTOs explicit on the client.
- **List endpoints serialize full JPA entities** — prefer adding lean DTOs for new endpoints (as PatientController already does).
- **Vitals are single String values** — a real analyzer/trend needs a `VitalsHistory` table (Slice 6+).
- **Gemini** is a raw HTTP call gated on `GEMINI_API_KEY`; always provide a deterministic fallback so public tools never hard‑fail.
- **Demo credentials** are for development only; do not ship weak seeded passwords to production.

---

## 10. Suggested Delivery Order (recap)
`Slice 0 → 1 → 2 → 3` = **Milestone 1 (public site + auth, with real public data).**
`Slice 4` = patient portal restyle.
`Slice 5 → 6` = the appointment/clinical/lab full loop.
`Slice 7 → 8` = blood donation + blog/notifications.
`Slice 9` = responsive & polish.

*Document generated as the agreed plan of record. Update as slices complete.*
