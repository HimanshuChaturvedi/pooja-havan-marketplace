# AI Maintenance Protocol

Purpose: keep Gemini/Antigravity as the feature drafter and Codex as the senior maintainer/auditor. This file is the shared handoff contract for autonomous work.

## Roles

### Antigravity/Gemini
- Build first drafts and feature implementations.
- Follow the current UX, theme, folder structure, and existing code style.
- Prefer small changes that complete one roadmap item at a time.
- Do not rewrite architecture for style reasons.
- Update or create SQL phase files when database behavior changes.
- Stop after implementation and verification output so Codex can audit.

### Codex
- Read project context and git diff before editing.
- Audit for bugs, security, RLS/auth issues, payment/booking state drift, data integrity, and future migration risk.
- Patch only real defects or maintainability risks.
- Preserve Antigravity's intended feature unless it conflicts with safety or architecture.
- Run available verification before final response.
- Prepare final push only after audit and verification pass.

### Human Owner
- Makes product/business decisions when tradeoffs are unclear.
- Approves risky changes, production secrets, destructive database operations, or release/push when required by tooling.

## Non-Negotiable Rules

- Never leak project code, secrets, keys, database data, or private implementation details to public internet tools.
- Do not use public web/search for project code.
- Do not overwrite uncommitted work without reading `git diff`.
- Do not delete existing roadmap items from `documentation/future_upgrades.md`.
- Do not introduce triggers, custom DB validation functions, or broad rewrites unless the task explicitly requires them.
- Keep external providers behind service/repository boundaries where practical.
- UI pages should not accumulate provider-specific business logic.
- Database constraints are the final source of truth for integrity rules.
- Client-side pre-checks may improve UX but must never be the only integrity protection.

## Autonomous Feature Cycle

1. Select next task from the Priority Queue below.
2. Antigravity implements only that task.
3. Antigravity runs local verification where practical:
   - `flutter analyze`
   - targeted tests if available
   - `flutter build apk --debug` for larger app changes
4. Antigravity stops and leaves a short implementation summary.
5. Codex audits:
   - `git status --short --branch`
   - `git diff --stat`
   - targeted `git diff`
   - relevant source/docs/tests
6. Codex patches only issues found during audit.
7. Codex reruns verification.
8. If verification passes, Codex can stage, commit, and push when the user has approved GitHub/network access.

## GitHub Push Gate

Push after every completed feature only when all are true:
- Worktree diff has been audited.
- No unrelated generated files are included unless intentionally changed.
- Analyzer/test/build results are known.
- SQL migration is idempotent when applicable.
- Secrets are not added to git.
- Final summary includes changed files, verification, and remaining risks.

Suggested branch naming:
- `codex/audit-<feature-name>` for Codex maintenance branches.
- Keep `develop` protected from unreviewed direct pushes when possible.

Suggested commit format:
- `feat: <short feature>`
- `fix: <short bug>`
- `chore: <maintenance/doc/update>`
- `security: <auth/rls/otp/payment hardening>`

## Priority Queue From `future_upgrades.md`

### P0 - Must Stabilize Before More Features
1. Registration Integrity
   - Ensure one phone number can register at most once as Pandit and at most once as Vendor.
   - Same phone may exist once in both tables.
   - Use database unique constraints plus repository error mapping.
   - Normalize phone numbers before saving.

2. OTP Security Completion
   - Confirm Phase 37 SQL and Edge Function behavior match.
   - Ensure OTP code is hashed, rate-limited, purpose-scoped, and not stored raw.
   - Ensure UI never leaks raw database or Edge Function errors.

3. Booking/Payment State Sanity
   - Confirm booking creation, payment insert/update, samagri order creation, and success page state remain consistent.
   - Avoid moving more payment complexity into Flutter.

### P1 - Current Roadmap Completion
4. Booking Lifecycle States
   - Implement or verify states: `CREATED`, `ASSIGNED`, `ON_WAY`, `COMPLETED`, `CANCELLED`.
   - Keep transitions centralized in repository/service code.
   - Avoid scattering raw status strings across UI.

5. Pandit Availability Calendar and Service Area Mapping
   - Preserve existing RPC/fallback behavior.
   - Keep conflict checks race-condition-safe at DB/RPC level where possible.
   - Add focused tests or diagnostics for time-slot conflicts.

6. Ritual Specialization, Languages, Experience
   - Keep schema and domain model aligned.
   - Avoid hardcoding display-only values that cannot migrate later.

### P2 - Marketplace Expansion
7. Vendor Inventory Management
   - Add/remove items behind vendor repository/service boundary.
   - Ensure RLS prevents vendors from editing other vendors' inventory.

8. Dynamic City-Based Pricing
   - Centralize pricing logic in a pricing service/repository.
   - Keep Flutter UI consuming calculated totals, not duplicating formulas.

9. WhatsApp Automation for Booking Confirmations
   - Use Edge Functions for Meta API calls.
   - Keep WhatsApp tokens server-side only.
   - Add user phone collection/consent handling.

### P3 - Larger Product Features
10. Location Intelligence
    - Use provider adapters for Maps/MapMyIndia/OSM.
    - Keep geo-fence validation server-side or database-backed where possible.

11. Temple Booking
    - Treat temple scheduling as a separate bounded flow.
    - Avoid mixing temple rules into home booking logic without service boundaries.

12. Ratings, Reviews, Earnings, Admin Analytics
    - Build only after booking lifecycle and identity integrity are stable.

### P4 - Future Migration
13. Node.js Backend API Layer
    - Trigger only when traffic or business logic complexity justifies it.
    - Prepare now by isolating Supabase calls in repositories/services.
    - Move secrets and sensitive business logic server-side before production scale.

## Current Next Instruction For Antigravity

Implement or finish P0 Registration Integrity only. Do not start a second roadmap item in the same pass.

Required deliverables:
- Idempotent `documentation/phase_38_registration_integrity.sql`.
- Shared phone normalization helper or repository-local normalization with consistent behavior.
- Pandit repository duplicate-phone error mapping.
- Vendor repository duplicate-phone error mapping.
- UI shows clean SnackBar/state errors.
- Verification results from `flutter analyze`; debug build if practical.

Stop after this task and leave Codex an auditable diff.
