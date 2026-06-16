# NUDHEB — Full Implementation Plan

> National Unified Digital Healthcare Ecosystem of Bangladesh

This plan covers the **entire platform** — Backend, Frontend, Database, Security, AI, and DevOps — organized as instructed: **Module → Phase → Step**. Every module includes its Goal, Scope, Architecture Decisions, Database Changes, API Changes, Frontend Changes, Security Considerations, and Implementation Steps.

---

## Technology Stack (Locked In)

| Layer | Technology |
|---|---|
| Frontend | Flutter Web (Material 3, Riverpod, GoRouter) |
| Backend | Spring Boot, Java 21+ |
| Database | PostgreSQL |
| Cache | Redis |
| File Storage | MinIO / S3 |
| Auth | JWT + Refresh Token |
| Search | Elasticsearch (when needed) |
| AI | LLM Integration, RAG Architecture |
| Deployment | Docker, Docker Compose |
| Monitoring | Prometheus, Grafana |
| API | REST + WebSocket |

---

## Architecture Decisions (Global)

| Decision | Choice | Rationale |
|---|---|---|
| Backend Architecture | Hexagonal (Ports & Adapters) | Cleanest separation; DB/external services are adapters, domain stays pure |
| Frontend Architecture | Feature-First + Clean Architecture | Each ecosystem is independent; scales to 50+ features |
| State Management | Riverpod | Compile-safe, testable, no context dependency |
| Routing | GoRouter | Deep linking, role-based guards, URL-based navigation |
| Database Strategy | Environment-variable driven | Local PostgreSQL → Cloud PostgreSQL with zero code change |
| File Storage | Metadata in DB, files in MinIO/S3 | Never store binary in PostgreSQL |
| API Style | REST (primary) + WebSocket (real-time queues, notifications) | REST for CRUD; WebSocket for live updates |

---

# Module 1: Core Platform Infrastructure

**Goal**: Build the foundational backend and frontend skeleton that every other module depends on.

**Scope**: Project scaffolding, database setup, authentication system, role-based access, base UI shell.

---

## Phase 1: Backend Skeleton

### Step 1: Spring Boot Project Setup
- Initialize Spring Boot project with Java 21
- Configure multi-module Gradle/Maven structure:
  - `domain` — entities, value objects, domain services
  - `application` — use cases, ports (interfaces)
  - `infrastructure` — adapters (DB, file storage, external APIs)
  - `presentation` — REST controllers, DTOs, WebSocket handlers
- Configure `application.yml` with environment variable placeholders for DB, Redis, MinIO

### Step 2: Database Connection
- Install PostgreSQL locally (port 5432)
- Configure Spring Data JPA + Hibernate
- Enable Flyway for database migrations
- Create initial migration: `V1__init_schema.sql`
- All connection strings via environment variables (`DB_URL`, `DB_USER`, `DB_PASS`)

### Step 3: Redis Setup
- Configure Spring Data Redis for session/cache
- Environment variable driven (`REDIS_HOST`, `REDIS_PORT`)
- Optional during early development

### Step 4: MinIO Setup
- Configure MinIO client for file uploads
- Create buckets: `medical-reports`, `profile-images`, `documents`
- Metadata (filename, type, size, owner, timestamp) stored in PostgreSQL
- Binary content stored in MinIO

---

## Phase 2: Authentication & Authorization System

### Step 1: Database Schema — Users & Roles

```
Table: users
- id (UUID, PK)
- health_id (VARCHAR, UNIQUE) — auto-generated NUDHEB ID
- national_id (VARCHAR, UNIQUE, NULLABLE)
- birth_certificate_no (VARCHAR, UNIQUE, NULLABLE)
- email (VARCHAR, UNIQUE, NULLABLE)
- phone (VARCHAR, UNIQUE)
- password_hash (VARCHAR)
- role (ENUM: PATIENT, DOCTOR, HOSPITAL_ADMIN, GOVT_ADMIN)
- status (ENUM: PENDING, ACTIVE, SUSPENDED, DEACTIVATED)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

Table: refresh_tokens
- id (UUID, PK)
- user_id (UUID, FK → users)
- token (VARCHAR)
- expires_at (TIMESTAMP)
- revoked (BOOLEAN)

Table: audit_logs
- id (UUID, PK)
- user_id (UUID, FK → users)
- action (VARCHAR) — e.g. LOGIN, VIEW_RECORD, CREATE_PRESCRIPTION
- target_entity (VARCHAR)
- target_id (UUID)
- ip_address (VARCHAR)
- timestamp (TIMESTAMP)
- details (JSONB)
```

### Step 2: JWT Authentication
- Implement `/api/auth/login` — returns access token (15 min) + refresh token (7 days)
- Implement `/api/auth/refresh` — rotates refresh token
- Implement `/api/auth/logout` — revokes refresh token
- Spring Security filter chain with JWT validation
- Role-based endpoint protection via `@PreAuthorize`

### Step 3: Registration Endpoints
- `POST /api/auth/register/patient` — NID/Birth Cert verification (mock initially)
- `POST /api/auth/register/doctor` — requires BMDC number, goes to PENDING status
- `POST /api/auth/register/hospital` — requires govt license, goes to PENDING status
- Approval workflow for doctors and hospitals (approved by authority/govt admins)

### Step 4: Audit Logging
- AOP-based audit interceptor on all sensitive operations
- Every login, record access, prescription creation, report upload is logged
- Stored in `audit_logs` table with user, action, target, timestamp, IP

---

## Phase 3: Frontend Core Shell

### Step 1: Project Structure
```
lib/
├── core/
│   ├── theme/           — AppTheme, colors, typography
│   ├── routing/         — GoRouter config, route guards
│   ├── network/         — Dio client, interceptors, token refresh
│   ├── utils/           — constants, helpers, validators
│   └── widgets/         — shared reusable widgets
├── features/
│   ├── auth/            — login, registration, role selection
│   ├── patient/         — patient ecosystem
│   ├── doctor/          — doctor ecosystem
│   ├── hospital/        — hospital authority ecosystem
│   └── government/      — government authority ecosystem
└── main.dart
```

Each feature follows:
```
feature/
├── data/
│   ├── datasources/     — API calls
│   ├── models/          — JSON serializable models
│   └── repositories/    — repository implementations
├── domain/
│   ├── entities/        — pure domain objects
│   ├── repositories/    — abstract repository interfaces
│   └── usecases/        — business logic
└── presentation/
    ├── pages/           — full screens
    ├── widgets/         — feature-specific widgets
    └── providers/       — Riverpod providers
```

### Step 2: Design System
- **Colors**: Medical Blue (`#0F6292`) primary, Professional Teal secondary, Gray scale neutrals
- **Typography**: Google Fonts — Inter for body, Outfit for headings
- **Components Library**: Buttons, Cards, Input fields, Stat widgets, Timeline items, Status badges, Loading/Error/Empty states
- **Every screen must support**: Loading, Empty, Error, Success states

### Step 3: Network Layer
- Dio HTTP client with base URL configuration
- JWT token interceptor (auto-attach access token to headers)
- 401 interceptor (auto-refresh token, retry request)
- Error handling middleware (parse API errors into user-friendly messages)

### Step 4: Routing & Guards
- GoRouter with role-based redirect guards
- Unauthenticated → `/login`
- Patient → `/user/*`
- Doctor → `/doctor/*`
- Hospital Admin → `/authority/*`
- Govt Admin → `/government/*`
- Unauthorized role access → redirect to appropriate dashboard

---

# Module 2: Citizen / Patient Ecosystem

**Goal**: Enable citizens to register, view their health profile, book appointments, access medical records, and receive AI health summaries.

**Scope**: Registration, profile management, dashboard, health timeline, appointment booking, medical vault, prescriptions, notifications.

---

## Phase 1: Patient Profile System

### Step 1: Database Schema

```
Table: patient_profiles
- id (UUID, PK)
- user_id (UUID, FK → users, UNIQUE)
- full_name (VARCHAR)
- date_of_birth (DATE)
- gender (ENUM: MALE, FEMALE, OTHER)
- blood_group (VARCHAR)
- marital_status (VARCHAR)
- occupation (VARCHAR)
- present_address (JSONB)
- permanent_address (JSONB)
- religion (VARCHAR, NULLABLE)
- organ_donor_status (BOOLEAN)
- profile_photo_url (VARCHAR, NULLABLE)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

Table: patient_emergency_contacts
- id (UUID, PK)
- patient_id (UUID, FK → patient_profiles)
- name (VARCHAR)
- relationship (VARCHAR)
- phone (VARCHAR)

Table: patient_allergies
- id (UUID, PK)
- patient_id (UUID, FK → patient_profiles)
- allergen (VARCHAR)
- severity (ENUM: MILD, MODERATE, SEVERE)
- noted_date (DATE)

Table: patient_chronic_diseases
- id (UUID, PK)
- patient_id (UUID, FK → patient_profiles)
- disease_name (VARCHAR)
- diagnosed_date (DATE)
- status (ENUM: ACTIVE, MANAGED, RESOLVED)
- notes (TEXT)

Table: patient_medications (current)
- id (UUID, PK)
- patient_id (UUID, FK → patient_profiles)
- medication_name (VARCHAR)
- dosage (VARCHAR)
- frequency (VARCHAR)
- prescribed_by (UUID, FK → doctor_profiles, NULLABLE)
- start_date (DATE)
- end_date (DATE, NULLABLE)
- active (BOOLEAN)

Table: patient_vaccinations
- id (UUID, PK)
- patient_id (UUID, FK → patient_profiles)
- vaccine_name (VARCHAR)
- date_administered (DATE)
- administered_by (VARCHAR)
- dose_number (INTEGER)
- batch_number (VARCHAR, NULLABLE)
```

### Step 2: API Endpoints
- `GET /api/patient/profile` — get current patient profile
- `PUT /api/patient/profile` — update profile
- `GET /api/patient/allergies` — list allergies
- `POST /api/patient/allergies` — add allergy
- `GET /api/patient/chronic-diseases` — list chronic conditions
- `GET /api/patient/medications` — list active medications
- `GET /api/patient/emergency-contacts` — list emergency contacts
- `POST /api/patient/emergency-contacts` — add emergency contact

### Step 3: Frontend — Profile Screens
- **Profile View Page**: Displays health card with QR code, personal info, allergies, chronic diseases
- **Profile Edit Page**: Multi-step form with validation for all personal/health fields
- **Emergency Info Card**: Quickly accessible card showing blood group, allergies, emergency contacts

---

## Phase 2: Patient Dashboard

### Step 1: API Endpoints
- `GET /api/patient/dashboard/summary` — returns health stats (total visits, active treatments, upcoming appointments, pending reports, active medications count)
- `GET /api/patient/dashboard/ai-summary` — returns AI-generated health summary text

### Step 2: Frontend — Dashboard Page
- **Health Card Widget**: Gradient card showing name, Health ID with QR, blood group, age, allergies
- **AI Summary Banner**: Highlighted panel with AI-generated insight (e.g., "1 pending follow-up recommended")
- **Quick Actions Grid**: Book Appointment, Health Timeline, Medical Vault, AI Assistant
- **Active Prescriptions List**: Cards showing current medications with dosage instructions
- **Upcoming Appointments**: Next scheduled visits with doctor name, time, hospital

---

## Phase 3: Health Timeline

### Step 1: Database Schema

```
Table: health_events
- id (UUID, PK)
- patient_id (UUID, FK → patient_profiles)
- event_type (ENUM: CONSULTATION, LAB_TEST, IMAGING, SURGERY, ADMISSION, DISCHARGE, VACCINATION, PRESCRIPTION, FOLLOW_UP, EMERGENCY)
- title (VARCHAR)
- description (TEXT)
- event_date (TIMESTAMP)
- doctor_id (UUID, FK → doctor_profiles, NULLABLE)
- hospital_id (UUID, FK → hospitals, NULLABLE)
- reference_id (UUID, NULLABLE) — links to specific record (prescription, lab report, etc.)
- reference_type (VARCHAR, NULLABLE) — e.g., "prescription", "lab_report"
- metadata (JSONB, NULLABLE) — flexible additional data
- created_at (TIMESTAMP)
```

### Step 2: API Endpoints
- `GET /api/patient/timeline?page=0&size=20&year=2026` — paginated timeline events
- `GET /api/patient/timeline/filters` — available years/event types for filtering

### Step 3: Frontend — Timeline Page
- Vertical chronological timeline grouped by year
- Each event node shows: icon (by type), title, date, doctor, hospital
- Click expands to show full details or navigates to the linked record
- Filter by year, event type
- Infinite scroll pagination

---

## Phase 4: Appointment Booking System

### Step 1: Database Schema

```
Table: appointments
- id (UUID, PK)
- patient_id (UUID, FK → patient_profiles)
- doctor_id (UUID, FK → doctor_profiles)
- hospital_id (UUID, FK → hospitals)
- appointment_date (DATE)
- time_slot (TIME)
- queue_number (INTEGER)
- status (ENUM: SCHEDULED, ARRIVED, WAITING, IN_CONSULTATION, COMPLETED, MISSED, CANCELLED)
- visit_type (ENUM: NEW, FOLLOW_UP, EMERGENCY, REFERRAL)
- reason (TEXT, NULLABLE)
- consultation_fee (DECIMAL)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

Table: doctor_schedules
- id (UUID, PK)
- doctor_id (UUID, FK → doctor_profiles)
- hospital_id (UUID, FK → hospitals)
- day_of_week (INTEGER) — 0=Sunday, 6=Saturday
- start_time (TIME)
- end_time (TIME)
- slot_duration_minutes (INTEGER) — default 15
- max_patients (INTEGER)
- is_active (BOOLEAN)
```

### Step 2: API Endpoints
- `GET /api/doctors/search?specialization=cardiology&hospital=...&page=0` — search doctors
- `GET /api/doctors/{id}/available-slots?date=2026-06-20` — available time slots
- `POST /api/appointments` — book appointment
- `GET /api/patient/appointments?status=SCHEDULED` — list patient's appointments
- `PATCH /api/appointments/{id}/cancel` — cancel appointment

### Step 3: Frontend — Appointment Flow
- **Doctor Search**: Filters by specialization, hospital, date; shows doctor cards with fees, experience
- **Slot Selection**: Calendar date picker + available time slots grid
- **Booking Confirmation**: Summary card with appointment ID, queue number, date, time
- **My Appointments**: List of upcoming/past appointments with status badges

---

## Phase 5: Medical Record Vault

### Step 1: Database Schema

```
Table: prescriptions
- id (UUID, PK)
- patient_id (UUID, FK)
- doctor_id (UUID, FK)
- hospital_id (UUID, FK)
- appointment_id (UUID, FK → appointments, NULLABLE)
- diagnosis (JSONB) — array of diagnosis entries
- medicines (JSONB) — array of {name, dosage, frequency, duration, instructions}
- clinical_notes (TEXT)
- symptoms (TEXT)
- follow_up_date (DATE, NULLABLE)
- created_at (TIMESTAMP)

Table: lab_reports
- id (UUID, PK)
- patient_id (UUID, FK)
- doctor_id (UUID, FK, NULLABLE) — ordering doctor
- hospital_id (UUID, FK)
- test_name (VARCHAR)
- test_category (VARCHAR) — e.g., Blood, Pathology, Urine
- status (ENUM: ORDERED, SAMPLE_COLLECTED, PROCESSING, VERIFIED, PUBLISHED)
- results (JSONB) — structured results
- file_url (VARCHAR, NULLABLE) — link to PDF/image in MinIO
- ordered_at (TIMESTAMP)
- completed_at (TIMESTAMP, NULLABLE)
- verified_by (UUID, FK → users, NULLABLE)

Table: imaging_reports
- id (UUID, PK)
- patient_id (UUID, FK)
- doctor_id (UUID, FK, NULLABLE)
- hospital_id (UUID, FK)
- imaging_type (ENUM: XRAY, CT_SCAN, MRI, ULTRASOUND, ECG)
- status (ENUM: REQUESTED, SCHEDULED, COMPLETED, REPORTED)
- findings (TEXT, NULLABLE)
- file_urls (JSONB) — array of MinIO links
- requested_at (TIMESTAMP)
- completed_at (TIMESTAMP, NULLABLE)
- reported_by (UUID, FK → users, NULLABLE)
```

### Step 2: API Endpoints
- `GET /api/patient/prescriptions?page=0&size=10` — paginated prescriptions
- `GET /api/patient/prescriptions/{id}` — single prescription detail
- `GET /api/patient/lab-reports` — lab reports
- `GET /api/patient/imaging-reports` — imaging reports
- `GET /api/patient/prescriptions/{id}/pdf` — generate/download PDF

### Step 3: Frontend — Vault Pages
- **Prescriptions Tab**: List with doctor name, diagnosis summary, date; click for full detail with PDF download
- **Lab Reports Tab**: List with status badges (Ordered → Published); click for results view
- **Imaging Reports Tab**: Gallery/list view of imaging with type icons; click for image viewer
- **Download/Share**: PDF generation and secure sharing links

---

# Module 3: Doctor Ecosystem

**Goal**: Enable verified doctors to manage their clinical workspace, patient queues, create treatments, review reports, and receive AI-assisted clinical support.

**Scope**: Doctor registration/verification, dashboard, daily queue, clinical workspace, treatment creation, report review, follow-up management.

---

## Phase 1: Doctor Profile & Verification

### Step 1: Database Schema

```
Table: doctor_profiles
- id (UUID, PK)
- user_id (UUID, FK → users, UNIQUE)
- full_name (VARCHAR)
- bmdc_registration_no (VARCHAR, UNIQUE)
- specializations (JSONB) — array of specializations
- degrees (JSONB) — array of {degree, institution, year}
- certifications (JSONB)
- experience_years (INTEGER)
- languages (JSONB)
- bio (TEXT)
- profile_photo_url (VARCHAR, NULLABLE)
- digital_signature_url (VARCHAR, NULLABLE)
- verification_status (ENUM: PENDING, VERIFIED, REJECTED)
- verified_by (UUID, FK → users, NULLABLE)
- verified_at (TIMESTAMP, NULLABLE)

Table: doctor_hospital_affiliations
- id (UUID, PK)
- doctor_id (UUID, FK → doctor_profiles)
- hospital_id (UUID, FK → hospitals)
- department (VARCHAR)
- designation (VARCHAR)
- join_date (DATE)
- leave_date (DATE, NULLABLE)
- is_active (BOOLEAN)
```

### Step 2: API Endpoints
- `POST /api/doctor/register` — submit profile for verification
- `GET /api/doctor/profile` — get own profile
- `PUT /api/doctor/profile` — update profile
- `GET /api/doctor/{id}/public` — public doctor profile (for patients searching)

### Step 3: Frontend — Doctor Profile
- **Registration Form**: Multi-step form (personal info → BMDC credentials → specialization → hospital affiliation)
- **Profile Page**: Professional card with degrees, specializations, hospital, verification badge
- **Pending Verification Screen**: Status tracker for doctors awaiting approval

---

## Phase 2: Doctor Dashboard & Daily Queue

### Step 1: API Endpoints
- `GET /api/doctor/dashboard/summary` — today's stats (appointments, follow-ups, emergency cases, pending reports)
- `GET /api/doctor/dashboard/ai-briefing` — AI daily briefing text
- `GET /api/doctor/queue?date=today` — today's patient queue with summary cards
- `PATCH /api/appointments/{id}/status` — update appointment status (ARRIVED, IN_CONSULTATION, COMPLETED)

### Step 2: Frontend — Dashboard & Queue
- **Dashboard**: Stats bar (total patients today, follow-ups, emergencies, pending reports)
- **AI Daily Briefing Banner**: "32 patients, 7 diabetes cases, 2 high-risk cardiac patients"
- **Patient Queue List**: Cards showing name, age, gender, existing diseases, risk level, visit type
- **Status Controls**: Buttons to advance appointment status (Call Patient → Start Consultation → Complete)

---

## Phase 3: Clinical Workspace (Treatment Creation)

### Step 1: API Endpoints
- `GET /api/doctor/patient/{healthId}/summary` — clinical summary (conditions, meds, allergies, recent visits)
- `GET /api/doctor/patient/{healthId}/timeline` — patient health timeline
- `GET /api/doctor/patient/{healthId}/reports` — patient's lab/imaging reports
- `POST /api/doctor/treatments` — submit treatment (diagnosis, prescription, tests, follow-up, referral)
- `GET /api/doctor/patient/{healthId}/ai-clinical-summary` — AI-generated clinical summary

### Step 2: Frontend — Clinical Workspace
- **Split-Screen Layout** (tablet/desktop):
  - **Left Panel**: Patient summary (conditions, allergies, current meds, risk level), health timeline, previous prescriptions, lab reports
  - **Right Panel**: Active treatment form
- **Treatment Form Sections**:
  - Symptoms input
  - Clinical notes
  - Diagnosis selector (search/autocomplete for ICD codes)
  - Prescription builder (medicine name, dosage, frequency, duration, instructions)
  - Investigation orders (select lab tests / imaging)
  - Follow-up date picker
  - Referral section (select specialist + include relevant records)
- **AI Clinical Assistant Side-Panel**:
  - Drug interaction alerts
  - Allergy warnings
  - Missing information alerts
  - Relevant guideline suggestions
- **Submit Treatment**: Creates prescription record, test orders, follow-up event, notifies patient and hospital

---

## Phase 4: Report Review & Follow-Up

### Step 1: API Endpoints
- `GET /api/doctor/pending-reports` — lab/imaging reports awaiting doctor review
- `GET /api/doctor/follow-ups` — upcoming follow-up patients
- `GET /api/doctor/patient/{healthId}/report-trends` — AI report comparison data

### Step 2: Frontend — Report Review
- **Pending Reports Dashboard**: List of new reports with patient name and test type
- **Report Detail View**: Results with AI trend comparison (current vs previous, percentage change, trend indicator)
- **Follow-Up List**: Upcoming follow-ups with previous treatment context

---

# Module 4: Hospital Authority Ecosystem

**Goal**: Enable hospital administrators to manage the entire hospital operations — staff, appointments, labs, pharmacy, beds, and emergency — through a unified command center.

**Scope**: Hospital registration, dashboard, doctor management, appointment/queue management, laboratory operations, imaging, pharmacy, bed management, emergency, financial operations.

---

## Phase 1: Hospital Registration & Setup

### Step 1: Database Schema

```
Table: hospitals
- id (UUID, PK)
- user_id (UUID, FK → users)
- name (VARCHAR)
- hospital_type (ENUM: PUBLIC, PRIVATE, CLINIC, DIAGNOSTIC_CENTER, MEDICAL_COLLEGE)
- license_number (VARCHAR, UNIQUE)
- address (JSONB)
- contact_info (JSONB) — phone, email, website
- departments (JSONB) — array of department names
- total_beds (INTEGER)
- icu_beds (INTEGER)
- emergency_available (BOOLEAN)
- ambulance_count (INTEGER)
- verification_status (ENUM: PENDING, APPROVED, SUSPENDED)
- approved_by (UUID, FK → users, NULLABLE)
- created_at (TIMESTAMP)

Table: hospital_departments
- id (UUID, PK)
- hospital_id (UUID, FK → hospitals)
- name (VARCHAR)
- head_doctor_id (UUID, FK → doctor_profiles, NULLABLE)
- floor (VARCHAR, NULLABLE)
- is_active (BOOLEAN)
```

### Step 2: API Endpoints
- `POST /api/hospital/register` — submit hospital for govt approval
- `GET /api/hospital/profile` — hospital profile
- `PUT /api/hospital/profile` — update hospital info
- `GET /api/hospital/departments` — list departments

### Step 3: Frontend — Hospital Setup
- **Registration Form**: Multi-step (legal info → capacity → departments → services)
- **Hospital Profile Page**: Overview card with departments, capacity, license info

---

## Phase 2: Hospital Command Center Dashboard

### Step 1: API Endpoints
- `GET /api/hospital/dashboard/overview` — real-time stats (patients today, active appointments, emergency cases, available beds, occupied beds, lab workload, doctor availability)
- `GET /api/hospital/dashboard/alerts` — operational alerts (ICU >90%, medicine shortage, equipment maintenance due)
- `WebSocket /ws/hospital/live-stats` — real-time updates

### Step 2: Frontend — Command Center
- **Overview Stats Grid**: Large stat cards (Active Patients, Available Beds, Doctors on Duty, Emergency Cases, Lab Workload)
- **Alerts Banner**: Color-coded operational alerts
- **Department Status**: Quick overview of each department's current load
- **Real-time Updates**: WebSocket-powered live stat refresh

---

## Phase 3: Doctor & Staff Management

### Step 1: Database Schema

```
Table: hospital_staff
- id (UUID, PK)
- hospital_id (UUID, FK → hospitals)
- user_id (UUID, FK → users, NULLABLE)
- full_name (VARCHAR)
- role (ENUM: DOCTOR, NURSE, TECHNICIAN, RECEPTIONIST, PHARMACIST, ADMIN)
- department_id (UUID, FK → hospital_departments, NULLABLE)
- shift (VARCHAR)
- status (ENUM: ACTIVE, ON_LEAVE, INACTIVE)
- joined_at (DATE)

Table: duty_rosters
- id (UUID, PK)
- hospital_id (UUID, FK → hospitals)
- staff_id (UUID, FK → hospital_staff)
- date (DATE)
- shift_start (TIME)
- shift_end (TIME)
- duty_type (ENUM: OPD, EMERGENCY, ICU, WARD)
```

### Step 2: API Endpoints
- `GET /api/hospital/staff?role=DOCTOR&page=0` — list staff
- `POST /api/hospital/staff` — add staff
- `GET /api/hospital/roster?week=2026-W25` — weekly roster
- `POST /api/hospital/roster` — create/update roster entry
- `PATCH /api/hospital/doctors/{id}/verify` — verify a doctor's credentials

### Step 3: Frontend — Staff Management
- **Staff Directory**: Filterable list by role, department, status
- **Roster Planner**: Calendar view for duty scheduling
- **Doctor Verification Queue**: Pending doctor applications with approve/reject actions

---

## Phase 4: Queue & Appointment Operations

### Step 1: API Endpoints
- `GET /api/hospital/appointments?date=today&department=cardiology` — today's appointments by department
- `GET /api/hospital/queue/live` — live queue status
- `PATCH /api/hospital/appointments/{id}/check-in` — mark patient arrived
- `WebSocket /ws/hospital/queue` — real-time queue updates

### Step 2: Frontend — Operations
- **Reception Desk UI**: Search by Health ID / NID / Appointment ID → check-in patient
- **Department Queues**: Live view per department showing waiting/in-consultation/completed
- **Queue Monitor Dashboard**: Wait time estimates, consultation progress

---

## Phase 5: Laboratory Operations

### Step 1: API Endpoints
- `GET /api/hospital/lab/orders?status=ORDERED` — pending lab orders
- `PATCH /api/hospital/lab/orders/{id}/status` — update status (SAMPLE_COLLECTED → PROCESSING → VERIFIED → PUBLISHED)
- `POST /api/hospital/lab/orders/{id}/results` — upload results (structured data + file)
- `GET /api/hospital/lab/workload` — lab workload stats

### Step 2: Frontend — Lab Dashboard
- **Kanban Board**: Columns for each status (Ordered → Sample Collected → Processing → Verified → Published)
- **Result Entry Form**: Structured numerical fields + file upload to MinIO
- **Verification Workflow**: Senior technician reviews before publishing

---

## Phase 6: Bed & Admission Management

### Step 1: Database Schema

```
Table: beds
- id (UUID, PK)
- hospital_id (UUID, FK → hospitals)
- ward (VARCHAR)
- bed_number (VARCHAR)
- bed_type (ENUM: GENERAL, ICU, CCU, NICU, PRIVATE)
- status (ENUM: AVAILABLE, OCCUPIED, MAINTENANCE)
- current_patient_id (UUID, FK → patient_profiles, NULLABLE)

Table: admissions
- id (UUID, PK)
- patient_id (UUID, FK)
- hospital_id (UUID, FK)
- doctor_id (UUID, FK)
- bed_id (UUID, FK → beds)
- admission_date (TIMESTAMP)
- discharge_date (TIMESTAMP, NULLABLE)
- reason (TEXT)
- status (ENUM: ADMITTED, DISCHARGED, TRANSFERRED)
- discharge_summary (TEXT, NULLABLE)
- final_diagnosis (TEXT, NULLABLE)
```

### Step 2: API Endpoints
- `GET /api/hospital/beds?status=AVAILABLE&type=ICU` — bed availability
- `POST /api/hospital/admissions` — admit patient
- `POST /api/hospital/admissions/{id}/discharge` — discharge with summary
- `GET /api/hospital/admissions/active` — currently admitted patients

### Step 3: Frontend — Bed Management
- **Bed Matrix**: Visual grid showing wards × beds, color-coded by status
- **Admission Form**: Select patient, bed, assign doctor
- **Discharge Form**: Final diagnosis, discharge summary, medication plan, follow-up

---

## Phase 7: Pharmacy Operations

### Step 1: Database Schema

```
Table: pharmacy_inventory
- id (UUID, PK)
- hospital_id (UUID, FK)
- medicine_name (VARCHAR)
- generic_name (VARCHAR)
- category (VARCHAR)
- stock_quantity (INTEGER)
- minimum_threshold (INTEGER)
- unit_price (DECIMAL)
- expiry_date (DATE)
- last_restocked (TIMESTAMP)

Table: medicine_dispensing
- id (UUID, PK)
- prescription_id (UUID, FK → prescriptions)
- patient_id (UUID, FK)
- hospital_id (UUID, FK)
- dispensed_medicines (JSONB)
- dispensed_by (UUID, FK → users)
- dispensed_at (TIMESTAMP)
```

### Step 2: API Endpoints
- `GET /api/hospital/pharmacy/inventory?search=...&belowThreshold=true` — search inventory
- `POST /api/hospital/pharmacy/dispense` — dispense medicine against prescription
- `GET /api/hospital/pharmacy/alerts` — low stock alerts

### Step 3: Frontend — Pharmacy Dashboard
- **Inventory Table**: Searchable, sortable list with stock levels and expiry
- **Low Stock Alerts**: Red badges on items below threshold
- **Dispense Flow**: Scan/search prescription → verify → dispense → update inventory

---

# Module 5: National Health Authority (Government) Ecosystem

**Goal**: Provide government officials with nationwide healthcare intelligence — disease surveillance, resource monitoring, workforce analytics, compliance management, and AI-powered predictions.

**Scope**: National dashboard, disease intelligence, outbreak detection, resource planning, compliance monitoring, vaccination programs.

---

## Phase 1: National Healthcare Dashboard

### Step 1: API Endpoints
- `GET /api/govt/dashboard/national-overview` — total citizens, doctors, hospitals, daily consultations, admissions, emergency cases
- `GET /api/govt/dashboard/disease-stats` — active disease case counts
- `GET /api/govt/dashboard/hospital-utilization` — bed occupancy rates nationwide
- `GET /api/govt/registries/citizens?page=0` — citizen registry with search
- `GET /api/govt/registries/doctors?page=0` — doctor registry
- `GET /api/govt/registries/hospitals?page=0` — hospital registry

### Step 2: Frontend — National Dashboard
- **National Stats Bar**: Total citizens, doctors, hospitals, daily consultations
- **Disease Monitoring Panel**: Top diseases with case counts, trend arrows
- **Hospital Utilization Map**: (future) geographic heatmap
- **Registry Views**: Searchable tables for citizens, doctors, hospitals

---

## Phase 2: Disease Intelligence Center

### Step 1: Database Schema

```
Table: disease_statistics (aggregated daily)
- id (UUID, PK)
- disease_name (VARCHAR)
- date (DATE)
- region (VARCHAR)
- new_cases (INTEGER)
- total_active (INTEGER)
- recoveries (INTEGER)
- deaths (INTEGER)
- hospitalized (INTEGER)

Table: outbreak_alerts
- id (UUID, PK)
- disease_name (VARCHAR)
- region (VARCHAR)
- severity (ENUM: LOW, MODERATE, HIGH, CRITICAL)
- detected_at (TIMESTAMP)
- status (ENUM: ACTIVE, MONITORING, RESOLVED)
- description (TEXT)
- ai_recommendation (TEXT, NULLABLE)
```

### Step 2: API Endpoints
- `GET /api/govt/diseases/{name}/stats?from=...&to=...&region=...` — disease-specific analytics
- `GET /api/govt/diseases/{name}/trends` — historical trend data for charting
- `GET /api/govt/outbreaks/active` — active outbreak alerts
- `GET /api/govt/diseases/heatmap?disease=dengue` — geographic distribution data

### Step 3: Frontend — Disease Intelligence
- **Disease Detail Page**: Overview, total cases, recovery rate, mortality rate, regional distribution table
- **Trend Charts**: Line/bar charts showing disease progression over time
- **Outbreak Alerts Panel**: Color-coded alerts with severity and AI recommendations

---

## Phase 3: Resource Planning & Workforce Intelligence

### Step 1: API Endpoints
- `GET /api/govt/resources/beds?region=...` — bed capacity by region
- `GET /api/govt/resources/equipment?type=ventilator` — equipment availability
- `GET /api/govt/workforce/summary` — national workforce stats by specialty and region
- `GET /api/govt/workforce/gaps` — identified shortages (e.g., Northern Region needs 67 more cardiologists)

### Step 2: Frontend — Resource Center
- **Capacity Dashboard**: Regional tables showing beds, ICU, ambulances
- **Workforce Gap Analysis**: Visual cards showing required vs available by region and specialty
- **Resource Shortage Alerts**: Highlighted regions needing attention

---

## Phase 4: Compliance & Audit

### Step 1: API Endpoints
- `GET /api/govt/compliance/hospitals` — compliance status of all hospitals
- `GET /api/govt/compliance/doctors` — license validity tracking
- `GET /api/govt/audit/logs?action=...&from=...&to=...` — searchable audit trail
- `PATCH /api/govt/hospitals/{id}/status` — approve/suspend hospital
- `PATCH /api/govt/doctors/{id}/status` — approve/suspend doctor

### Step 2: Frontend — Compliance Center
- **Hospital Compliance Table**: Status badges (compliant, warning, non-compliant)
- **Doctor License Monitor**: Expiring licenses, pending verifications
- **Audit Log Viewer**: Searchable, filterable table of all system actions

---

# Module 6: AI Integration Layer

**Goal**: Provide intelligent, non-autonomous assistance across all ecosystems.

**Scope**: Patient health summaries, doctor clinical summaries, hospital resource predictions, government disease forecasting.

---

## Phase 1: AI Service Architecture

### Step 1: Backend Design
- Dedicated `AiService` in the application layer
- Interfaces defined as ports; LLM provider is an adapter (swappable)
- RAG architecture for medical knowledge retrieval where appropriate
- All AI outputs clearly labeled as "AI-Generated Recommendation" — not medical advice

### Step 2: AI Endpoints
- `GET /api/ai/patient/health-summary?patientId=...` — patient-facing health summary
- `GET /api/ai/doctor/clinical-summary?patientId=...` — doctor-facing clinical summary
- `GET /api/ai/doctor/drug-interactions?medicines=[...]` — drug interaction check
- `GET /api/ai/hospital/resource-forecast?hospitalId=...` — resource demand prediction
- `GET /api/ai/govt/outbreak-risk?region=...&disease=...` — outbreak risk assessment

### Step 3: Frontend Integration
- AI outputs rendered in dedicated panels/banners with clear "AI-Generated" labels
- Never presented as medical facts — always as recommendations

---

# Module 7: Notification System

**Goal**: Real-time notifications across all ecosystems.

---

## Phase 1: Implementation

### Step 1: Database Schema

```
Table: notifications
- id (UUID, PK)
- user_id (UUID, FK → users)
- type (ENUM: APPOINTMENT, PRESCRIPTION, REPORT, FOLLOW_UP, ALERT, SYSTEM)
- title (VARCHAR)
- message (TEXT)
- is_read (BOOLEAN, DEFAULT FALSE)
- reference_id (UUID, NULLABLE)
- reference_type (VARCHAR, NULLABLE)
- created_at (TIMESTAMP)
```

### Step 2: API + WebSocket
- `GET /api/notifications?page=0` — paginated notifications
- `PATCH /api/notifications/{id}/read` — mark as read
- `WebSocket /ws/notifications` — real-time push

### Step 3: Frontend
- Notification bell icon in app bar with unread count badge
- Notification dropdown/page listing all notifications
- Click navigates to the referenced entity (appointment, prescription, report)

---

# Module 8: DevOps & Deployment

**Goal**: Containerized, production-ready deployment.

---

## Phase 1: Docker Setup

### Step 1: Dockerfiles
- `Dockerfile.backend` — multi-stage build for Spring Boot JAR
- `Dockerfile.frontend` — build Flutter Web, serve with Nginx

### Step 2: Docker Compose
- `docker-compose.yml` with services:
  - `backend` (Spring Boot)
  - `db` (PostgreSQL)
  - `redis` (Redis)
  - `minio` (MinIO)
  - `frontend` (Flutter Web via Nginx)
- Environment variables for all configuration
- Volume mounts for data persistence

### Step 3: Monitoring
- Prometheus scraping Spring Boot Actuator metrics
- Grafana dashboards for API response times, error rates, DB query performance

---

# Execution Order

> [!IMPORTANT]
> We will execute these modules **in order**, completing each phase before moving to the next. After each major module, the corresponding `[module_name]_guide.md` documentation will be generated.

| Priority | Module | Depends On |
|---|---|---|
| 1 | Module 1: Core Infrastructure | — |
| 2 | Module 2: Patient Ecosystem | Module 1 |
| 3 | Module 3: Doctor Ecosystem | Module 1, Module 2 |
| 4 | Module 4: Hospital Authority | Module 1, Module 2, Module 3 |
| 5 | Module 5: Government Authority | Module 1–4 |
| 6 | Module 6: AI Integration | Module 1–5 |
| 7 | Module 7: Notifications | Module 1 |
| 8 | Module 8: DevOps | All |

---

## Open Questions

> [!IMPORTANT]
> 1. **Backend Repository**: Should I create the Spring Boot backend project inside this same repo (e.g., `d:\flutter projects\uhcs\backend\`), or will you have a separate repository for it?
> 2. **AI Provider**: For the AI layer, do you have a preferred LLM provider (OpenAI, Gemini, local model), or should I design it provider-agnostic from the start?
> 3. **Government Map Visualization**: For disease heatmaps and geographic views, do you have a preferred mapping library or should I use a standard solution like Mapbox/Leaflet?
> 4. **Execution Start**: Should I begin with **Module 1: Core Infrastructure** (backend skeleton + auth + frontend shell), or do you want to start with frontend-only first?
