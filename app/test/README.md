# 🧪 Bharat Pooja Setu — Testing Governance & Regression Suite

This document defines the testing architecture, flow, and reporting for the Bharat Pooja Setu project.

## 🏛️ Testing Framework
We use a **lightweight, native Flutter testing stack**:
1.  **Integration Test**: Flutter's official end-to-end framework. Runs on real devices/emulators.
2.  **Mocktail**: For simple, type-safe dependency mocking.
3.  **Custom HTML Reporter**: A lightweight script to generate colorful, chart-based visual reports.

---

## 🚦 Core Regression Flows
These flows are tested automatically before every release.

### 1. Functional Testing
We verify the **behavior** of the app.
- **Scenario**: Selecting a ritual, filling an address, and confirming.
- **Goal**: Ensure the UI transitions correctly and business logic (like fee calculation) is accurate.

### 2. Database (E2E) Verification
Since our integration tests run against the **real Supabase backend**, we can verify DB state directly.
- **Verification**: After a booking is confirmed in the UI, the test can use `supabase.from('bookings').select()` to verify the row actually exists with the correct `total_amount` and `user_id`.
- **RLS Testing**: Verifies that the Anonymous Auth correctly restricts data access.

---

## 📊 How to Run & View Reports

### 1. Run All Tests
Navigate to the `app` directory and run:
```powershell
# Run the regression suite
flutter test integration_test/app_test.dart
```

### 2. Generate Colorful Report
After running the tests, run the reporter script:
```powershell
# Generate visual report with charts
python scripts/generate_report.py
```
This will create `reports/index.html` which you can open in any browser.

---

## 🛠️ Infrastructure Overview

```
app/
├── integration_test/
│   ├── app_test.dart         # Main entry point for suite
│   └── flows/                # Individual test scenarios
├── test/
│   └── unit/                 # Unit and Repository tests
└── scripts/
    └── generate_report.py    # Custom colorful HTML reporter
```

---

## 🤖 Autonomous Debug Mode
If a test fails, the AI Agent will:
1.  Read the test logs from `reports/logs.txt`.
2.  Take a screenshot/recording (if available).
3.  Analyze the failing step in the code.
4.  Propose and apply a fix automatically.
