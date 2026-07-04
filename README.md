# NHCS Frontend — National Health Commission System Client Portal

A beautiful, high-fidelity Flutter client application for the **National Health Commission System (NHCS)** of Bangladesh. This application serves as a unified digital portal for Patients, Doctors, and Hospitals, integrating real-time smart symptom checkups, queues, blood donations, and AI diagnostics.

---

## 🗺️ How the System Serves Citizens (End-to-End Process Flow)

The frontend coordinates multiple distinct clinical portals to provide a unified experience:

### 1. Vitals Checkup & Smart Doctor Suggestions
* **AI Vitals Panel:** Citizens check their risk status by keying in symptoms in Bangla. 
* **Specialist Recommendations:** The AI detects medical risks and filters the database. It ranks and shows the top 1 or 2 best-matching doctors in the catalog.
* **Specialist Catalog:** Displays horizontal scrolling previews of 10 system doctors, falling back to database fetches when queries or AI suggestions are triggered.

### 2. Connected Appointment Booking & Medical Vault
* **Log-in:** Evaluations are pre-filled with connected credentials (`patient_judge` for Laila Khan).
* **Clinical Vault:** Patients view past completed appointments, dynamic clinical prescriptions, lab results showing critical biomarkers, and cardiac scan findings.

### 3. Public Emergency Blood Requests
* **Immediate Booking:** Public dashboard lets users submit a blood request to any system hospital (Dhaka Medical College, Chittagong General, etc.).
* **Command Center:** The request is sent to the target hospital's queue dashboard.

### 4. Hospital Blood CommandCenter & Donor Matching
* **Pending Queue:** Hospitals view all pending requests.
* **AI Matcher:** Clicking **Run AI Matcher** queries active local O+ donors in the system, calculates compatibility scores and geographic distances, and lists the best matches.
* **Fulfillment:** Hospitals can notify donors, fetch phone numbers, and finalize donations.

---

## 🛠️ Technology Stack

* **Client Engine:** Flutter (Web & Mobile targets)
* **State Management:** Riverpod 2.x
* **Fonts & Typography:** Outfit & Inter (Google Fonts)
* **Design System:** Custom token-driven theme system mirroring prototype aesthetics (Light & Dark modes)

---

## 🔮 Future Enhancements

* **📈 Patient Health Charts:** Implement interactive line graphs showing blood glucose and blood pressure changes over time.
* **💬 Real-time Doctor Chat:** Integrate WebSockets for direct messaging between patients and doctor profiles during queue wait times.
* **🔔 Push Notifications:** Incorporate Firebase Cloud Messaging (FCM) to trigger background alarms when blood requests match a registered donor profile.
