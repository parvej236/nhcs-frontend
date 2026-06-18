# DATABASE & DEVELOPMENT ENVIRONMENT INSTRUCTION PROMPT

## CONTEXT

You are building a full-stack healthcare platform using:

* Flutter Web (Frontend)
* Spring Boot (Backend)
* PostgreSQL (Primary Database)
* Redis (Cache)
* MinIO/S3 (File Storage)

The system must support both local development and future production deployment.

---

## CORE REQUIREMENT

The system must be designed in a way that:

* Works fully on local machine during development
* Can be easily moved to cloud in production without rewriting architecture
* Keeps database independent from backend runtime environment

---

## DATABASE RULE

You must NOT assume database is embedded or automatically hosted.

Database is a separate service and must be explicitly configured.

---

## DEVELOPMENT ENVIRONMENT (LOCAL)

During development:

* Flutter Web runs on localhost
* Spring Boot runs on localhost (e.g., port 8080)
* PostgreSQL runs locally on machine (port 5432)
* Redis runs locally (optional during early stage)
* MinIO runs locally (for file storage)

All services communicate through localhost networking.

---

## PRODUCTION ENVIRONMENT (CLOUD)

During production:

* Flutter Web is deployed (Vercel / Firebase / Hosting)
* Spring Boot is deployed (VPS / AWS / Render / Kubernetes)
* PostgreSQL is hosted on cloud provider (Neon / AWS RDS / Supabase / Railway)
* Redis is hosted as managed service
* MinIO or S3 is used for file storage

Only configuration changes, not architecture changes.

---

## IMPORTANT DESIGN RULE

You must design the system so that:

* Switching from local DB → cloud DB requires only configuration update
* No code rewrite should be required for deployment transition
* Database connection must always use environment variables

Example:

* DB URL
* DB username
* DB password

---

## ARCHITECTURE PRINCIPLE

Follow clean separation:

Frontend → API Layer → Backend Service → Database

Never tightly couple frontend or backend to a specific database provider.

---

## DATABASE CHOICE

Primary database must be:

* PostgreSQL

Reason:

* Supports relational medical data
* Handles complex relationships
* ACID compliance is required for healthcare systems
* Scalable for large national datasets

---

## DATA STORAGE RULE

* All structured medical data → PostgreSQL
* All files (reports, images, scans) → MinIO/S3
* Cache/session/temporary data → Redis

Never store large binary files inside PostgreSQL.

---

## ENVIRONMENT CONFIGURATION RULE

All sensitive configuration must be stored in environment variables:

* DB connection string
* API keys
* Cloud credentials

Never hardcode values.

---

## DEPLOYMENT READINESS RULE

Even in development phase:

* System must be designed with production deployment in mind
* No architecture should break during migration to cloud

---

## FINAL GOAL

Build a scalable healthcare system where:

* Local development is simple and fast
* Cloud deployment is seamless
* Database is replaceable without breaking backend logic
* System is production-grade from day one
