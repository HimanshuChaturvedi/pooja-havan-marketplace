# 🚀 Bharat Pooja Setu — Technical Governance & Roadmap

> [!IMPORTANT]
> **Rules:**
> 1. Existing upgrade items must NEVER be deleted.
> 2. Items may only be reorganized, grouped, reprioritized, or marked complete with ~~strikeout~~.
> 3. Document must support AI-assisted development and remains human-readable.

---

## 🏛️ System Architecture

### 1. User Mobile App (Flutter)
- **Core**: Pooja Booking, Samagri Shop, Booking History.
- **State**: Riverpod (Providers) + AppSession.
- **Routing**: GoRouter (Context-based).

### 2. Backend — Supabase
- **Database**: PostgreSQL (Relational Data).
- **Auth**: Anonymous Sign-in (Phase 1) → Phone OTP (Future).
- **Security**: Row Level Security (RLS) on all tables.
- **Functions**: Edge Functions (Webhook handling, aggregations).

### 3. Pandit & Vendor Systems (Future)
- **Pandit App**: Onboarding, Dashboard, Booking Assignment.
- **Admin Panel**: Web dashboard for analytics, revenue, and management.

### 4. External Integrations
- **Payments**: Razorpay (UPI, Cards, Wallets).
- **Notifications**: Firebase Cloud Messaging (FCM).
- **Automation**: WhatsApp Business API (Confirmations & Coordination).

---

## 🗺️ Phase-Based Roadmap

### PHASE 1 — Stability (100% Complete)
*Goal: Ensure current production flows remain stable.*

- [x] ~~MyBookings amount accuracy (Fixed total_amount column)~~
- [x] ~~Booking creation reliability (Anonymous Auth integration)~~
- [x] ~~Address sync fix in Samagri session~~
- [x] ~~**UX Polish**: Professionalized LoginPage with edge-pinned navigation and clean UI.~~
- [x] ~~**Privacy Policy**: Deployed live at `himanshuchaturvedi.github.io`.~~
- [x] ~~**Database**: Standardized Supabase schema for consistent total_amount tracking.~~

### PHASE 2 — Booking System Improvements (100% Complete)
*Goal: Make the booking system production ready.*

- [x] ~~**Booking Reference IDs**: Unique codes (POJ-2026-0001, SAM-2026-0002) for WhatsApp/Support.~~
- [x] ~~**Auth Migration**: Transition from Anonymous UUID to Google OAuth & Email OTP (v6.1 - v6.6).~~
- [x] ~~**State Migration**: Moved sessions to Riverpod `StateNotifierProvider` to eliminate static bugs.~~
- [x] ~~**UI Polish**: Implemented Shimmer loading skeletons and refined states globally.~~

### PHASE 3 — Pandit System
*Goal: Marketplace foundation.*

- [ ] Booking Lifecycle States: Tracking status (CREATED → ASSIGNED → ON_WAY → COMPLETED).
- [x] ~~Pandit onboarding & profiles.~~
- [ ] Ritual specialization & Languages/Experience.
- [ ] Availability calendar & Service area mapping.

### PHASE 4 — City Based Pricing
*Goal: Implement location-based pricing.*

- [ ] Dynamic pricing engine (City + Ritual + Location Type).
- [ ] Multi-tier pricing (Ghaziabad vs Delhi vs Mumbai).

### PHASE 5 — Samagri Marketplace Expansion
- [x] ~~Vendor onboarding & Vendor Dashboard (Basic).~~
- [x] ~~Delivery radius validation (Nearest Vendor Matching).~~
- [ ] Vendor inventory management (Add/Remove items).

### PHASE 6 — Location Intelligence
- [ ] GPS detection integration.
- [ ] Google Maps / MapMyIndia address autocomplete.
- [ ] Service availability validation by geo-fence.

### PHASE 7 — Temple Booking
- [ ] Temple selection and ritual scheduling.
- [ ] View temple details and photo galleries.

### PHASE 8 — WhatsApp Automation (WABA)
- [ ] Automated booking confirmations for Customers (Requires adding 'Phone Number' field during checkout or login).
- [ ] Pandit coordination and delivery updates.
- [ ] Meta API templates integration (Currently partially implemented for Registration OTP).

### PHASE 9 — Ratings & Reviews
- [ ] Pandit ratings and service reviews.
- [ ] User feedback and NPS collection.

### PHASE 10 — Multi-City Expansion
- [ ] Regional scaling: Bangalore, Mumbai, Varanasi.

### PHASE 11 — Pandit Earnings System
- [ ] Pandit wallet and earnings dashboard.
- [ ] Payout tracking and tax management.

### PHASE 12 — Admin Dashboard
- [ ] Centralized booking and revenue analytics.
- [ ] Pandit & Vendor management console.

### PHASE 13 — Custom Node.js Backend API Layer
*Goal: Move from Supabase (ready-made) to a custom Node.js backend for full control and scalability.*
- [ ] Build Express.js/Fastify REST API server as middle layer between app and database.
- [ ] Move Razorpay keys, WhatsApp tokens, Maps API keys to server-side (currently in Flutter = risky).
- [ ] Move sensitive business logic (pricing engine, fraud detection, payment webhooks) to backend.
- [ ] Support multiple data sources (DB + ML models + third-party APIs) from one place.
- [ ] Deploy on Railway.app or Render.com (free tier available).
- [ ] Update Flutter app to call Node.js APIs instead of Supabase directly.
- **Why Node.js over Supabase:** Full custom control, secrets completely server-side, complex logic support.
- **Trigger**: When daily active users cross 10,000+ or business logic becomes too complex for Edge Functions.

---

## Restore Pandit Details Experience

> [!NOTE]
> **Future Enhancement Only:** Do NOT modify the current active booking flow.

- **Current State**:
  - `PanditDetailsPage` still exists in the codebase.
  - It is currently not reachable from the active customer booking flow.
  - The current `PanditSelectionPage` immediately selects the Pandit and proceeds to the next booking step.
  - The old `PanditListPage` is no longer part of the active application flow.
  - The `/pandit-details` route still exists but is effectively orphaned.

- **Recommended Future Implementation**:
  - Preserve the current one-tap Pandit selection flow.
  - Do NOT open `PanditDetailsPage` when the customer taps the Pandit card.
  - Add a separate "View Profile" button/icon on each Pandit card.
  - Tapping the card should continue selecting the Pandit immediately.
  - Tapping "View Profile" should open `PanditDetailsPage`.
  - Returning from `PanditDetailsPage` should return the customer to the same Pandit selection screen without losing booking progress.

- **Future Profile Enhancements**:
  - About Pandit
  - Experience
  - Languages
  - Areas of Expertise
  - Verification Badge
  - Customer Ratings & Reviews
  - Total Poojas Performed
  - Availability
  - Profile Gallery (optional)

---

## ⚖️ Testing Governance

### Regression Suite Definition
*These flows must never break.*

1. **Book a Pooja Flow**: Ritual → Bandit → Date/Time → Summary → Confirm → Success → MyBookings.
2. **Buy a Samagri Flow**: Shop → Cart → Summary → Confirm → Success → MyBookings.

### Autonomous Debug Model
If a regression test fails:
1. AI inspects failing test artifacts.
2. AI identifies root cause and proposes fix.
3. AI reruns suite until green.
4. Phase continues only after total regression pass.

### Feature Flag System (Safety)
Deploy new features behind flags for Closed Testing:
- `enable_pandit_system`
- `enable_city_pricing`
- `enable_online_payments`

## 💸 Strategic Note on Payments

**Current Pilot Model**: Direct payment to Pandit (Cash/UPI) after ritual completion.

**Razorpay Integration Strategy**:
- Razorpay should **NOT** be implemented immediately.
- **Trigger**: Transition to Phase 5 or 6, once order volume is stable and vendor/pandit trust is established.
- **Why?**: Pilot testing ensures the operations (booking/delivery) work first without the complexity of refunds and payment failures.

---

## 🧪 Documentation Mapping
- `book_pooja_flow_test.dart`: Verifies pooja journey and history visibility.
- `samagri_order_flow_test.dart`: Verifies shop items addition and checkout.
