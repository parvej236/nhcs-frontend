# NUDHEB — Frontend Implementation Plan (Flutter Web)

> Your complete, detailed roadmap for building the entire frontend. Your friend handles the backend and provides APIs. This plan covers everything you need to build on the Flutter side.

---

# ⚡ Module 0: Base UI Design (UI-Only, No Backend)

> **Purpose**: Build ALL primary screens for every role with stunning, premium UI. No backend, no state management, no API calls. Only Flutter pages with dummy/hardcoded data, images, and full navigation between screens. Later modules will layer in state management, API integration, and real data.

## What Module 0 Delivers
- Complete navigable UI shell for all 3 roles (Patient, Doctor, Hospital Authority)
- Stunning, enterprise-grade UI matching Google/Stripe/Linear quality
- Healthcare-focused color system (Medical Blue, Teal, proper status colors)
- Shared widget library (cards, badges, buttons, stat widgets, timeline items)
- Hardcoded dummy data using project scenarios (Rahim, Dr. Ahmed, Dhaka Central Hospital)
- GoRouter navigation between all pages
- Desktop-first layout (responsive improvements come later)

## Module 0 Screens

### Shared / Auth (3 screens)
- **Role Selection Landing Page** — 4 ecosystem cards
- **Login Page** — role-aware login form
- **Registration Page** — multi-step identity verification

### Patient Ecosystem — 6 screens
- **Patient Dashboard** — 3-column layout: sidebar + main content (health card, AI summary, quick actions, prescriptions, appointments) + right panel (profile, vitals, calendar)
- **Health Timeline** — vertical chronological timeline with event nodes
- **Appointment Booking** — doctor search + slot selection + confirmation
- **My Appointments** — upcoming/past appointments list
- **Medical Vault** — tabbed view (prescriptions, lab reports, imaging)
- **Patient Profile** — health card, personal info, allergies, chronic diseases, medications

### Doctor Ecosystem — 5 screens
- **Doctor Dashboard** — stats bar, AI briefing, patient queue
- **Clinical Workspace** — split-screen (patient history left, treatment form right, AI assistant bottom)
- **Report Review** — pending reports with trend analysis
- **Schedule Management** — weekly calendar view
- **Doctor Profile** — professional card with credentials

### Hospital Authority Ecosystem — 6 screens
- **Command Center Dashboard** — real-time stats grid, alerts, department overview
- **Reception & Queue** — patient check-in, department queues
- **Staff Management** — staff directory, roster planner
- **Laboratory Dashboard** — kanban board for test tracking
- **Bed Management** — visual bed matrix with ward mapping
- **Pharmacy** — inventory table, low stock alerts

**Total: ~20 screens**

## Execution Order within Module 0
1. Core (theme, colors, typography, shared widgets)
2. Auth screens (role selection, login, register)
3. Patient ecosystem screens
4. Doctor ecosystem screens
5. Hospital authority screens

---

## Your Role & Assumptions

- **You build**: All Flutter Web UI, state management, API integration, routing, theming, and UX
- **Your friend builds**: Spring Boot backend, PostgreSQL database, REST APIs, WebSocket endpoints, JWT auth
- **Contract**: You will consume APIs as documented in the [full_stack_implementation_plan.md](file:///d:/flutter%20projects/uhcs/project%20necessaries/full_stack_implementation_plan.md). Share that file with your friend so they build the exact endpoints you need.
- **Until APIs are ready**: You will use mock data / fake repositories so you can develop the UI independently

---

## Technology Stack (Frontend Only)

| Concern | Technology | Version |
|---|---|---|
| Framework | Flutter Web | Latest Stable |
| UI System | Material 3 | Built-in |
| State Management | Riverpod | `flutter_riverpod` |
| Routing | GoRouter | `go_router` |
| HTTP Client | Dio | `dio` |
| WebSocket | `web_socket_channel` | For real-time features |
| Fonts | Google Fonts | `google_fonts` (Inter, Outfit) |
| Charts | fl_chart | For dashboards and analytics |
| PDF | `printing` + `pdf` | Prescription PDF generation |
| JSON Serialization | `json_serializable` + `freezed` | Type-safe API models |
| Code Generation | `build_runner` | For freezed/json_serializable |
| Local Storage | `shared_preferences` or `hive` | Token persistence |
| Image/File Picker | `file_picker` | Report/document uploads |

---

## Architecture Decision: Feature-First Clean Architecture

```
lib/
├── core/                          ← Shared across ALL features
│   ├── theme/
│   │   ├── app_theme.dart         ← ThemeData, light/dark mode
│   │   ├── app_colors.dart        ← Color constants (Medical Blue, Teal, etc.)
│   │   ├── app_typography.dart    ← Text styles (Inter body, Outfit headings)
│   │   └── app_spacing.dart       ← Spacing tokens (4, 8, 12, 16, 24, 32, 48)
│   ├── routing/
│   │   ├── app_router.dart        ← GoRouter configuration
│   │   └── route_guards.dart      ← Auth guard, role guard
│   ├── network/
│   │   ├── api_client.dart        ← Dio singleton with base URL
│   │   ├── auth_interceptor.dart  ← Auto-attach JWT, auto-refresh on 401
│   │   ├── error_interceptor.dart ← Parse API errors → AppException
│   │   └── api_endpoints.dart     ← All endpoint URL constants
│   ├── models/
│   │   ├── api_response.dart      ← Generic wrapper {data, message, status}
│   │   ├── paginated_response.dart← {content, page, totalPages, totalElements}
│   │   └── app_exception.dart     ← Typed exceptions (NetworkException, AuthException, etc.)
│   ├── providers/
│   │   ├── auth_provider.dart     ← Global auth state (current user, token, role)
│   │   └── dio_provider.dart      ← Dio instance provider
│   ├── utils/
│   │   ├── constants.dart         ← App name, version, asset paths
│   │   ├── validators.dart        ← Form validators (email, phone, NID, etc.)
│   │   ├── date_formatter.dart    ← Date/time formatting helpers
│   │   └── extensions.dart        ← Dart extension methods
│   └── widgets/                   ← SHARED reusable components
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_text_field.dart
│       ├── stat_card.dart
│       ├── status_badge.dart
│       ├── timeline_item.dart
│       ├── loading_widget.dart
│       ├── empty_state_widget.dart
│       ├── error_state_widget.dart
│       ├── responsive_layout.dart ← Desktop / Tablet / Mobile breakpoints
│       └── app_sidebar.dart       ← Shared sidebar navigation shell
│
├── features/
│   ├── auth/                      ← Module 1
│   ├── patient/                   ← Module 2
│   ├── doctor/                    ← Module 3
│   ├── hospital/                  ← Module 4
│   └── government/               ← Module 5
│
└── main.dart
```

Each feature module follows this internal structure:
```
features/patient/
├── data/
│   ├── datasources/
│   │   ├── patient_remote_datasource.dart    ← Dio API calls
│   │   └── patient_mock_datasource.dart      ← Mock/fake data for dev
│   ├── models/
│   │   ├── patient_profile_model.dart        ← JSON serializable (freezed)
│   │   ├── appointment_model.dart
│   │   ├── prescription_model.dart
│   │   └── ...
│   └── repositories/
│       └── patient_repository_impl.dart      ← Implements domain interface
├── domain/
│   ├── entities/
│   │   ├── patient_profile.dart              ← Pure domain object
│   │   ├── appointment.dart
│   │   └── ...
│   ├── repositories/
│   │   └── patient_repository.dart           ← Abstract interface
│   └── usecases/
│       ├── get_patient_profile.dart
│       ├── book_appointment.dart
│       └── ...
└── presentation/
    ├── providers/
    │   ├── patient_dashboard_provider.dart    ← Riverpod providers
    │   ├── appointment_provider.dart
    │   └── ...
    ├── pages/
    │   ├── patient_dashboard_page.dart
    │   ├── health_timeline_page.dart
    │   ├── appointment_booking_page.dart
    │   ├── medical_vault_page.dart
    │   └── ...
    └── widgets/
        ├── health_card_widget.dart
        ├── ai_summary_banner.dart
        ├── prescription_card.dart
        └── ...
```

---

## Design System Specification

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| `primaryColor` | `#0F6292` | Medical Blue — headers, primary buttons, active states |
| `primaryDark` | `#0A4B75` | Gradient endpoints, selected states |
| `secondaryColor` | `#0D9488` | Professional Teal — secondary actions, accents |
| `surfaceColor` | `#FFFFFF` | Cards, panels, modals |
| `backgroundColor` | `#F8FAFB` | Page backgrounds |
| `sidebarColor` | `#0C2444` | Dark sidebar/navigation |
| `successColor` | `#22C55E` | Success states, positive trends |
| `warningColor` | `#F59E0B` | Warnings, pending states |
| `dangerColor` | `#EF4444` | Errors, critical alerts, negative trends |
| `textPrimary` | `#1A1A2E` | Primary text |
| `textSecondary` | `#64748B` | Secondary text, labels |
| `textMuted` | `#94A3B8` | Muted text, placeholders |
| `divider` | `#E2E8F0` | Dividers, borders |

### Typography Scale

| Style | Font | Weight | Size | Usage |
|---|---|---|---|---|
| Display | Outfit | Bold (700) | 32px | Page titles |
| Heading 1 | Outfit | SemiBold (600) | 24px | Section headers |
| Heading 2 | Outfit | SemiBold (600) | 20px | Card titles |
| Heading 3 | Inter | SemiBold (600) | 16px | Subsection headers |
| Body Large | Inter | Regular (400) | 16px | Primary body text |
| Body | Inter | Regular (400) | 14px | Default body text |
| Body Small | Inter | Regular (400) | 12px | Captions, labels |
| Button | Inter | SemiBold (600) | 14px | Button text |
| Overline | Inter | Medium (500) | 11px | Category labels |

### Spacing Tokens
- `xs`: 4px
- `sm`: 8px
- `md`: 12px
- `base`: 16px
- `lg`: 24px
- `xl`: 32px
- `xxl`: 48px

### Border Radius
- `sm`: 8px — small chips, badges
- `md`: 12px — input fields, small cards
- `lg`: 16px — cards, panels
- `xl`: 20px — large cards, health card
- `full`: 999px — circular avatars, pills

### Elevation / Shadows
- `subtle`: `BoxShadow(color: black.withOpacity(0.03), blurRadius: 8, offset: Offset(0, 2))`
- `card`: `BoxShadow(color: black.withOpacity(0.05), blurRadius: 12, offset: Offset(0, 4))`
- `elevated`: `BoxShadow(color: primary.withOpacity(0.15), blurRadius: 20, offset: Offset(0, 8))`

### Screen State Rules (MANDATORY for every page)
Every page/widget that loads data MUST implement all four states:
1. **Loading**: Skeleton shimmer or centered spinner
2. **Empty**: Illustration + message + optional action button
3. **Error**: Error illustration + message + "Retry" button
4. **Success**: The actual content

### Responsive Breakpoints
| Breakpoint | Width | Layout |
|---|---|---|
| Desktop | ≥1200px | Sidebar + Content + Right Panel (3-column) |
| Laptop | ≥900px | Sidebar + Content (2-column) |
| Tablet | ≥600px | Collapsible sidebar + Content |
| Mobile | <600px | Bottom nav + Content (single column) |

---

# Module 1: Core Foundation

**Goal**: Set up project structure, design system, network layer, auth flow, and routing.

---

## Phase 1: Design System & Shared Components

### Step 1: Create Theme Files
- `app_colors.dart` — All color constants from the palette above
- `app_typography.dart` — All text styles with Google Fonts
- `app_spacing.dart` — Spacing and radius tokens
- `app_theme.dart` — Combines everything into `ThemeData` for Material 3

### Step 2: Create Shared Widget Library
Build every reusable widget ONCE, use everywhere:

| Widget | Description | Props |
|---|---|---|
| `AppButton` | Primary, secondary, outlined, danger, disabled variants | `label`, `onPressed`, `variant`, `isLoading`, `icon` |
| `AppTextField` | Text input with label, hint, error, prefix/suffix icons | `label`, `controller`, `validator`, `obscure`, `prefixIcon` |
| `AppCard` | Consistent card with optional header, footer | `child`, `padding`, `onTap`, `elevation` |
| `StatCard` | Dashboard stat card with value, label, trend, icon | `title`, `value`, `icon`, `color`, `trend` |
| `StatusBadge` | Colored badge for statuses (Active, Pending, etc.) | `label`, `status` |
| `TimelineItem` | Single event node in a vertical timeline | `title`, `date`, `icon`, `type`, `isLast` |
| `LoadingWidget` | Skeleton shimmer or spinner | `type` (shimmer, spinner) |
| `EmptyStateWidget` | Empty illustration + message | `message`, `actionLabel`, `onAction` |
| `ErrorStateWidget` | Error illustration + retry | `message`, `onRetry` |
| `ResponsiveLayout` | Adapts layout to breakpoint | `desktop`, `tablet`, `mobile` |
| `AppSidebar` | Navigation sidebar with role-based menu items | `currentRoute`, `role`, `onNavigate` |
| `AppSearchBar` | Search input with debounce | `onSearch`, `hint` |
| `PatientSummaryCard` | Compact patient info card (used in queue, search results) | `name`, `age`, `gender`, `conditions`, `riskLevel` |

### Step 3: Create Responsive Layout Shell
- `AppScaffold` widget wrapping every page — handles sidebar, app bar, and responsive behavior
- Desktop: persistent sidebar on left
- Tablet: collapsible drawer sidebar
- Mobile: bottom navigation bar

---

## Phase 2: Network Layer

### Step 1: Dio Client Setup
- `ApiClient` class — singleton Dio instance
- Base URL configurable via environment (`const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api')`)
- Request/response logging in debug mode

### Step 2: Auth Interceptor
- Reads JWT access token from secure storage
- Attaches `Authorization: Bearer <token>` to every request
- On 401 response: calls `/api/auth/refresh` with refresh token, retries original request
- On refresh failure: clears tokens, redirects to `/login`

### Step 3: Error Interceptor
- Catches `DioException` and maps to `AppException` subtypes:
  - `NetworkException` — no internet
  - `ServerException` — 5xx
  - `AuthException` — 401/403
  - `ValidationException` — 400 with field errors
  - `NotFoundException` — 404
- Every provider/repository catches these and exposes them as `AsyncValue.error`

### Step 4: Mock Data Layer
- For every remote datasource, create a matching mock datasource
- Mock datasources return realistic fake data (use the scenario data from the project docs — Rahim, Dr. Ahmed, Dhaka Central Hospital)
- Toggle between real/mock via a Riverpod provider flag: `isMockMode`
- This lets you develop all UI before backend APIs exist

---

## Phase 3: Authentication Flow

### Step 1: Auth State Management
- `AuthNotifier` (Riverpod `AsyncNotifier`) holds:
  - `currentUser` — logged in user info (id, healthId, name, role)
  - `accessToken` / `refreshToken`
  - `isAuthenticated` flag
- Persists tokens in `shared_preferences` or `flutter_secure_storage`
- On app start: checks for saved token → validates → auto-login or redirect to login

### Step 2: Auth Screens

#### Role Selection Page (`/`)
- Full-screen premium landing page
- 4 large cards: Citizen, Doctor, Hospital Authority, Government Authority
- Each card has icon, title, brief description
- Tapping navigates to `/login?role=patient`

#### Login Page (`/login`)
- Title changes based on role query param
- Fields: User ID / Email, Password
- "Sign In" button → calls `POST /api/auth/login`
- Link to Register page
- Loading state on button during API call
- Error state for wrong credentials

#### Registration Page (`/register`)
- **Patient**: NID/Birth Certificate number, phone, date of birth → verify → create profile
- **Doctor**: NID, BMDC number, specialization → submit for review (goes to Pending)
- **Hospital**: License number, hospital name, contact → submit for review
- Multi-step form with progress indicator

### Step 3: Route Guards
- `GoRouter.redirect` checks:
  1. If not authenticated → redirect to `/`
  2. If authenticated but wrong role for route → redirect to correct dashboard
  3. If authenticated and correct role → allow

### Step 4: API Contracts (Auth)
APIs you'll call (share with your backend friend):

| Method | Endpoint | Request Body | Response |
|---|---|---|---|
| POST | `/api/auth/login` | `{identifier, password}` | `{accessToken, refreshToken, user: {id, healthId, name, role}}` |
| POST | `/api/auth/refresh` | `{refreshToken}` | `{accessToken, refreshToken}` |
| POST | `/api/auth/logout` | `{refreshToken}` | `{message}` |
| POST | `/api/auth/register/patient` | `{nationalId, phone, dateOfBirth, password}` | `{user, accessToken}` |
| POST | `/api/auth/register/doctor` | `{nationalId, bmdcNo, specialization, phone, password}` | `{message: "Pending verification"}` |

---

# Module 2: Patient Ecosystem (`/user/*`)

**Goal**: Build the complete patient portal — dashboard, profile, timeline, appointment booking, medical vault.

---

## Phase 1: Patient Dashboard (`/user/dashboard`)

### Step 1: Data Layer
- **Model**: `DashboardSummary` (freezed) — `{totalVisits, activetreatments, upcomingAppointments, pendingReports, activeMedications}`
- **Model**: `AiHealthSummary` (freezed) — `{summaryText, lastUpdated}`
- **Remote Datasource**: calls `GET /api/patient/dashboard/summary` and `GET /api/patient/dashboard/ai-summary`
- **Mock Datasource**: returns Rahim's mock data
- **Provider**: `dashboardSummaryProvider` — `AsyncNotifierProvider` that fetches on load

### Step 2: UI Composition
Layout (desktop 3-column):

```
┌──────────┬─────────────────────────────────┬──────────────┐
│          │                                 │              │
│ Sidebar  │  Main Content (scrollable)      │ Right Panel  │
│          │                                 │              │
│ - Home   │  ┌─────────────────────────┐    │ Profile Card │
│ - Timeline│  │  Digital Health Card     │    │ Vitals       │
│ - Appts  │  │  (gradient, QR, name,   │    │ Calendar     │
│ - Vault  │  │   blood group, age)     │    │ Next Appt    │
│ - AI     │  └─────────────────────────┘    │ Recent Tests │
│ - Settings│                                 │              │
│          │  ┌─────────────────────────┐    │              │
│          │  │  AI Health Summary      │    │              │
│          │  │  Banner (orange accent)  │    │              │
│          │  └─────────────────────────┘    │              │
│          │                                 │              │
│          │  ┌──────┐ ┌──────┐ ┌──────┐    │              │
│          │  │Book  │ │Time- │ │Med   │    │              │
│          │  │Appt  │ │line  │ │Vault │    │              │
│          │  └──────┘ └──────┘ └──────┘    │              │
│          │                                 │              │
│          │  Active Prescriptions List      │              │
│          │  Upcoming Appointments List     │              │
│          │                                 │              │
└──────────┴─────────────────────────────────┴──────────────┘
```

### Step 3: Widget Breakdown
- `HealthCardWidget` — gradient container, avatar, name, Health ID, QR icon, blood group, age, allergies
- `AiSummaryBanner` — accent-colored container, auto_awesome icon, summary text
- `QuickActionsGrid` — 2x2 or 3-col grid of action cards with icons
- `PrescriptionListItem` — medicine name, dosage, frequency, pill icon
- `AppointmentListItem` — doctor name, time, hospital, status badge

---

## Phase 2: Patient Profile (`/user/profile`)

### Step 1: Data Layer
- **Models** (freezed): `PatientProfile`, `EmergencyContact`, `Allergy`, `ChronicDisease`, `Medication`, `Vaccination`
- **Providers**: `patientProfileProvider`, `allergiesProvider`, `medicationsProvider`

### Step 2: UI — Profile View
- Digital Health Card (reusable from dashboard)
- Personal Information section — name, DOB, gender, blood group, NID, marital status, occupation
- Address section — present and permanent
- Emergency Contacts list — name, relationship, phone
- Medical tab bar:
  - **Allergies Tab**: list with severity badges (Mild=green, Moderate=amber, Severe=red)
  - **Chronic Diseases Tab**: list with status badges (Active, Managed, Resolved)
  - **Current Medications Tab**: list with dosage and prescribing doctor
  - **Vaccination History Tab**: list with vaccine name, date, dose number

### Step 3: UI — Profile Edit
- Multi-step form wizard:
  - Step 1: Personal Info (name, DOB, gender, blood group, occupation, marital status)
  - Step 2: Address (present, permanent with "same as present" toggle)
  - Step 3: Emergency Contacts (add/remove dynamically)
  - Step 4: Health Info (allergies, chronic diseases, current medications)
- Each step validates before allowing next
- Final review page before submission

---

## Phase 3: Health Timeline (`/user/timeline`)

### Step 1: Data Layer
- **Model**: `HealthEvent` — `{id, eventType, title, description, eventDate, doctorName, hospitalName, referenceId, referenceType}`
- **Enum**: `HealthEventType` — CONSULTATION, LAB_TEST, IMAGING, SURGERY, ADMISSION, DISCHARGE, VACCINATION, PRESCRIPTION, FOLLOW_UP, EMERGENCY
- **Provider**: `timelineProvider` — paginated, filterable

### Step 2: UI
- **Filter Bar**: Year dropdown + Event type chips (all, consultations, lab tests, etc.)
- **Vertical Timeline**: 
  - Left: year markers
  - Center: dotted line with event nodes
  - Each node: icon (color-coded by type), title, date, doctor, hospital
  - Click to expand details or navigate to the full record
- **Infinite scroll**: load more as user scrolls down
- **Empty state**: "No health events yet. Book your first appointment to start your timeline."

---

## Phase 4: Appointment Booking (`/user/appointments`)

### Step 1: Data Layer
- **Models**: `Doctor` (search result), `DoctorSchedule`, `TimeSlot`, `Appointment`
- **Providers**: `doctorSearchProvider`, `availableSlotsProvider`, `appointmentsProvider`

### Step 2: UI — Booking Flow (Multi-step)

#### Step 1: Search & Select Doctor
- Search bar + filters (specialization dropdown, hospital dropdown)
- Results as cards: doctor photo, name, specialization, hospital, experience, fee, rating
- Select a doctor → navigate to slot selection

#### Step 2: Select Date & Time
- Calendar date picker (horizontal scrollable week strip or full calendar)
- Available time slots as a grid of tappable chips (e.g., 9:00 AM, 9:15 AM, 9:30 AM)
- Unavailable slots grayed out
- Selected slot highlighted in primary color

#### Step 3: Confirm Booking
- Summary card: doctor name, specialization, hospital, date, time, fee
- "Confirm Booking" button
- Success dialog with: Appointment ID, Queue Number, date, time
- Option to add to calendar

### Step 3: UI — My Appointments (`/user/appointments/list`)
- Tab bar: Upcoming | Past | Cancelled
- Each card: doctor name, hospital, date, time, status badge
- Upcoming cards have "Cancel" action
- Past cards have "View Prescription" action

---

## Phase 5: Medical Vault (`/user/vault`)

### Step 1: Data Layer
- **Models**: `Prescription`, `LabReport`, `ImagingReport`
- **Providers**: `prescriptionsProvider`, `labReportsProvider`, `imagingReportsProvider`

### Step 2: UI — Vault with Tabs

#### Prescriptions Tab
- List of prescription cards: date, doctor name, diagnosis summary, hospital
- Click → **Prescription Detail Page**:
  - Doctor info header
  - Diagnosis section
  - Medicines table (name, dosage, frequency, duration, instructions)
  - Clinical notes
  - Follow-up date
  - "Download PDF" button

#### Lab Reports Tab
- List with: test name, category, date, status badge (Ordered → Published)
- Click → **Report Detail Page**:
  - Test results (structured key-value pairs)
  - AI interpretation banner ("Your blood glucose is higher than recommended range")
  - Trend chart (if previous results exist)
  - Download attached file

#### Imaging Tab
- Gallery/list view with: imaging type icon, date, status
- Click → image viewer (zoom, pan for X-rays, MRI, etc.)
- Findings text below image

---

# Module 3: Doctor Ecosystem (`/doctor/*`)

**Goal**: Build the doctor's clinical workspace for patient management, treatment creation, and report review.

---

## Phase 1: Doctor Dashboard (`/doctor/dashboard`)

### Step 1: Data Layer
- **Models**: `DoctorDashboardSummary`, `AiBriefing`, `QueuePatient`
- **Providers**: `doctorDashboardProvider`, `patientQueueProvider`

### Step 2: UI Layout (Desktop)
```
┌──────────┬──────────────────────────────────────────────┐
│          │                                              │
│ Sidebar  │  Stats Bar                                   │
│          │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐│
│ - Dash   │  │Today:32│ │Follow:7│ │Emerg:2 │ │Reports ││
│ - Queue  │  └────────┘ └────────┘ └────────┘ └────────┘│
│ - Patients│                                             │
│ - Reports │  AI Daily Briefing Banner                   │
│ - Schedule│                                             │
│ - Profile │  Patient Queue List                         │
│          │  ┌─────────────────────────────────────────┐ │
│          │  │ 08:00 │ Rahim │ 45M │ Diabetes, HTN │→ │ │
│          │  │ 08:15 │ Karim │ 38M │ Asthma        │→ │ │
│          │  │ 08:30 │ Hasan │ 52M │ Cardiac       │→ │ │
│          │  └─────────────────────────────────────────┘ │
│          │                                              │
└──────────┴──────────────────────────────────────────────┘
```

### Step 3: Widget Breakdown
- `DoctorStatCard` — uses shared `StatCard`
- `AiBriefingBanner` — "32 patients, 7 diabetes cases, 2 high-risk cardiac patients"
- `PatientQueueCard` — name, age, gender, conditions, risk badge, visit type, action button ("Start Consultation")
- Queue card action: navigates to Clinical Workspace for that patient

---

## Phase 2: Clinical Workspace (`/doctor/workspace/:healthId`)

> This is the **most complex and most critical screen** in the entire application.

### Step 1: Data Layer
- **Models**: `PatientClinicalSummary`, `PatientTimelineEvent`, `TreatmentForm`, `DrugInteractionAlert`
- **Providers**: `patientSummaryProvider(healthId)`, `patientReportsProvider(healthId)`, `treatmentFormProvider`

### Step 2: UI — Split Screen Layout (Desktop)

```
┌──────────────────────────────┬───────────────────────────────┐
│  PATIENT HISTORY (scrollable)│  TREATMENT FORM (scrollable)  │
│                              │                               │
│  ┌─ Patient Summary ───────┐│  ┌─ Symptoms ───────────────┐ │
│  │ Rahim, 45M, O+          ││  │ [Text area]               │ │
│  │ Conditions: Diabetes,HTN ││  └─────────────────────────┘ │
│  │ Allergies: Penicillin    ││                               │
│  │ Meds: Metformin, Amlo   ││  ┌─ Clinical Notes ─────────┐ │
│  │ Risk: Moderate           ││  │ [Text area]               │ │
│  └──────────────────────────┘│  └─────────────────────────┘ │
│                              │                               │
│  ┌─ AI Clinical Summary ───┐│  ┌─ Diagnosis ──────────────┐ │
│  │ Blood glucose increased  ││  │ [Search/autocomplete]     │ │
│  │ 12% over last 3 visits.  ││  │ + Add diagnosis           │ │
│  │ Compliance inconsistent.  ││  └─────────────────────────┘ │
│  └──────────────────────────┘│                               │
│                              │  ┌─ Prescription ───────────┐ │
│  ┌─ Health Timeline ───────┐│  │ Medicine: [__________]    │ │
│  │ 2026: Current visit      ││  │ Dosage:   [__________]    │ │
│  │ 2025: Medication adjust  ││  │ Frequency:[__________]    │ │
│  │ 2024: Eye examination    ││  │ Duration: [__________]    │ │
│  └──────────────────────────┘│  │ Instructions: [________]  │ │
│                              │  │ + Add another medicine     │ │
│  ┌─ Previous Prescriptions ┐│  └─────────────────────────┘ │
│  │ [Expandable list]        ││                               │
│  └──────────────────────────┘│  ┌─ Investigations ─────────┐ │
│                              │  │ [x] Blood Glucose         │ │
│  ┌─ Lab Reports ───────────┐│  │ [ ] ECG                   │ │
│  │ [Expandable list]        ││  │ [ ] X-Ray                 │ │
│  └──────────────────────────┘│  │ + Add custom test          │ │
│                              │  └─────────────────────────┘ │
│                              │                               │
│                              │  ┌─ Follow-up ──────────────┐ │
│                              │  │ Date: [Date Picker]       │ │
│                              │  └─────────────────────────┘ │
│                              │                               │
│                              │  ┌─ Referral (optional) ────┐ │
│                              │  │ Specialist: [Dropdown]    │ │
│                              │  └─────────────────────────┘ │
│                              │                               │
│                              │      [ Submit Treatment ]     │
│                              │                               │
└──────────────────────────────┴───────────────────────────────┘

┌─ AI ASSISTANT (Collapsible Bottom/Right Panel) ─────────────┐
│ ⚠️ Drug Interaction: Medicine A conflicts with Metformin     │
│ ⚠️ Allergy Alert: Contains Penicillin derivative             │
│ ℹ️ Consider ordering ECG — not available in recent records   │
└─────────────────────────────────────────────────────────────┘
```

### Step 3: Treatment Submission Flow
1. Doctor fills all sections
2. AI assistant runs real-time checks (drug interactions, allergies) as fields change
3. Doctor clicks "Submit Treatment"
4. Confirmation dialog shows summary
5. On confirm: `POST /api/doctor/treatments`
6. Success → creates prescription, test orders, follow-up event
7. Patient and hospital are notified (backend handles)

---

## Phase 3: Report Review (`/doctor/reports`)

### Step 1: UI
- **Pending Reports List**: Filter by patient, test type
- **Report Detail**: Results table + AI trend comparison panel (current vs previous with % change)
- **Follow-Up Queue**: `/doctor/follow-ups` — patients due for follow-up with previous context

---

# Module 4: Hospital Authority Ecosystem (`/authority/*`)

**Goal**: Build the hospital command center for operational management.

---

## Phase 1: Hospital Dashboard (`/authority/dashboard`)
- **Real-time Stats Grid**: Active Patients, Available Beds, Doctors on Duty, Emergency Cases, Lab Workload
- **Operational Alerts Banner**: "ICU >90%", "Medicine X shortage", "Equipment Y maintenance due"
- **Department Overview**: Quick status per department
- **WebSocket**: Live refresh via `/ws/hospital/live-stats`

## Phase 2: Reception & Queue Management (`/authority/reception`)
- **Check-in UI**: Search by Health ID / NID / Appointment ID → patient card → mark as arrived
- **Department Queues**: Tab per department showing live queue (Waiting → In Consultation → Completed)
- **Queue Monitor**: Wait time estimates, consultation durations

## Phase 3: Doctor & Staff Management (`/authority/staff`)
- **Staff Directory**: Table with filters (role, department, status), search
- **Add Staff Form**: Name, role, department, shift
- **Roster Planner**: Calendar grid view — drag and assign shifts
- **Doctor Verification**: Pending applications list with documents → approve/reject

## Phase 4: Laboratory Dashboard (`/authority/lab`)
- **Kanban Board**: Drag cards across columns (Ordered → Sample Collected → Processing → Verified → Published)
- **Result Entry Form**: Structured fields for numerical results + file upload
- **Workload Stats**: Tests per technician, pending counts

## Phase 5: Bed & Admission Management (`/authority/beds`)
- **Bed Matrix**: Visual grid — rows=wards, columns=bed numbers, color=status (green=available, red=occupied, gray=maintenance)
- **Click to Admit**: Tap available bed → admission form (select patient, doctor)
- **Active Admissions**: List of currently admitted patients with days admitted, doctor, ward

## Phase 6: Pharmacy (`/authority/pharmacy`)
- **Inventory Table**: Searchable, sortable by stock level / expiry
- **Low Stock Panel**: Items below threshold in red
- **Dispense Flow**: Enter prescription ID → verify → dispense → auto-update stock

---

# Module 5: Government Ecosystem (`/government/*`)

**Goal**: Build national-level healthcare intelligence dashboards.

---

## Phase 1: National Dashboard (`/government/dashboard`)
- **National Stats**: Total citizens, doctors, hospitals registered
- **Daily Activity**: Today's consultations, admissions, discharges, emergencies
- **Disease Overview**: Top 10 active diseases with case counts and trend arrows (↑ increasing / ↓ decreasing)

## Phase 2: Registries (`/government/registries`)
- **Citizen Registry**: Paginated searchable table (name, Health ID, NID, blood group, status)
- **Doctor Registry**: Paginated searchable table (name, BMDC, specialization, hospital, verification status)
- **Hospital Registry**: Paginated searchable table (name, type, license, beds, status, compliance)

## Phase 3: Disease Intelligence (`/government/diseases`)
- **Disease List Page**: Cards per disease (Diabetes, Dengue, etc.) with key stats
- **Disease Detail Page**: Line charts (cases over time), regional distribution table, recovery/mortality rates
- **Outbreak Alerts**: Active alerts with severity, region, AI recommendation

## Phase 4: Resource & Workforce (`/government/resources`)
- **Bed Capacity by Region**: Table/chart showing total vs occupied beds per region
- **Workforce Gaps**: Cards showing "Northern Region: 67 cardiologists shortage"
- **Equipment Dashboard**: Ventilators, CT scanners etc. by region

## Phase 5: Compliance Center (`/government/compliance`)
- **Hospital Compliance**: Status badges (Compliant, Warning, Non-Compliant), action buttons
- **Doctor License Monitor**: Approaching expiry, already expired, pending verification
- **Audit Log Viewer**: Searchable, filterable table of all system-wide actions

---

# Module 6: Cross-Cutting Features

## Notification System (All Roles)
- Bell icon in app bar with unread count badge
- Dropdown panel with notification list
- Click → navigate to referenced entity
- Provider: `notificationsProvider` — polls or WebSocket-driven

## AI Integration (All Roles)
- All AI outputs use a consistent `AiInsightPanel` widget with "AI-Generated" label
- Patient: health summary, report explanations
- Doctor: clinical summary, drug interactions, allergy alerts
- Hospital: resource forecasting
- Government: outbreak predictions

---

# Execution Order

| Priority | What to Build | Estimated Screens |
|---|---|---|
| **1** | Core (Theme, Widgets, Network, Auth) | 3 screens (role select, login, register) |
| **2** | Patient Dashboard + Profile | 4 screens |
| **3** | Patient Timeline + Appointments | 4 screens |
| **4** | Patient Medical Vault | 3 screens |
| **5** | Doctor Dashboard + Queue | 2 screens |
| **6** | Doctor Clinical Workspace | 1 complex screen |
| **7** | Doctor Reports + Follow-ups | 2 screens |
| **8** | Hospital Command Center | 2 screens |
| **9** | Hospital Staff + Queue Mgmt | 3 screens |
| **10** | Hospital Lab + Beds + Pharmacy | 3 screens |
| **11** | Government Dashboard + Registries | 4 screens |
| **12** | Government Disease Intel + Compliance | 4 screens |
| **13** | Notifications (all roles) | 1 shared component |
| **Total** | | **~36 screens** |

> [!TIP]
> Start with mock datasources. Once your friend's APIs are ready, you simply swap `MockDatasource` → `RemoteDatasource` in the repository implementation. Zero UI changes needed.

---

## What to Share with Your Backend Friend

Share the [full_stack_implementation_plan.md](file:///d:/flutter%20projects/uhcs/project%20necessaries/full_stack_implementation_plan.md) file. It contains:
- Every database table schema they need to create
- Every API endpoint you will call (method, path, request body, response)
- The authentication flow contract (JWT + refresh tokens)
- WebSocket endpoints for real-time features

This ensures you both build against the same contract and everything connects seamlessly.
