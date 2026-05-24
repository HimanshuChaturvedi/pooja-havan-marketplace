Requirements Document – Pooja & Havan Service Marketplace

This document explains what the app should do in simple language so even a non-technical person can understand.

1.1 Purpose of the App

The app helps users book Pooja/Havan services across India.
A user can:

Book a Pandit for home rituals.

Buy Pooja Samagri.

Book Havan/Pooja at a temple (where Pandits are allowed).

Explore all ritual-based services such as Mundan, Marriage, Shradh, etc.

This will be a pan-India marketplace for spiritual services.

1.2 Target Users

General users
Anyone who wants to perform a Pooja/Havan at home, temple, or any holy place.

Pandits / Priests
Registered priests who provide Pooja services.

Temples / Religious Institutions
Verified temples that allow rituals on their premises.

Samagri Vendors
Sellers delivering Pooja items.

1.3 Platforms

The app will run on:

Android

iOS

Web App

Future: Admin Panel

1.4 Core Features
1.4.1 User Flow

User opens the app

Splash screen

Landing page → choose what they want to do:

Book a Pooja

Buy Samagri

Havan at Temple

Explore Services

Based on selection → ask:
“Where do you want this service?”
(Example: User lives in Ghaziabad but wants service in Haridwar.)

Show Pandits / Temples / Vendors near that location.

1.4.2 Location Handling

Two types:

A. AUTO LOCATION

Detect using device GPS

Reverse geocode to find city/state

Ask permission

B. MANUAL LOCATION

User types a city name
Example:

Haridwar

Varanasi

Nashik

Then user selects from suggestions.

1.4.3 Service Categories

Examples:

✔ Maha Mrityunjay Jaap
✔ Satyanarayan Katha
✔ Grih Pravesh Pooja
✔ Rudra Abhishek
✔ Mundan Ceremony
✔ Kundali & Astrology
✔ Marriage Rituals
✔ Death-related rituals (Shradh)

1.4.4 Vendor / Pandit Onboarding

Simple registration

Upload ID proof

Upload specializations

Upload temple permission (if applicable)

1.4.5 Booking & Payments

Select Pandit / Temple / Samagri

Choose time

Complete booking

Pay using:

UPI

Razorpay test mode (initially free)

1.4.6 Notifications

Booking confirmation

Pandit arrival

Payment updates

1.5 Future Features

Subscription model

Festival-based Pooja packages

Multi-language support

Referral system

WhatsApp Automated Booking Confirmations (requires phone number collection)

1.6 Free Tools & Cost Constraints

Since the project must use free or very low-cost options:

Supabase (authentication, database, storage)

OpenStreetMap / Nominatim (geocoding)

Razorpay Test Mode (payments)

Flutter (single codebase)

GitHub (code & documentation)

No paid APIs or cloud until the userbase grows.

1.7 Constraints

Must run on low-end Android phones

Should work with poor network conditions

App size must be small

UI must be premium & smooth like Swiggy / CRED

Entire theme must follow:
✔ Saffron
✔ Gold
✔ White
✔ Minimal shadows

1.8 Assumptions

Most users will search for a service in a city different than where they live

Most bookings happen for:

Home

Temple

Ghats / open places

Pandits are not authorized in every temple, so temple permission is important

Ritual timings may vary, so flexibility is needed

1.9 Updating the Stack Based on Requirements & Userbase

This is horizontal scaling strategy, written in simple language.

Phase 1 — Start (0–5,000 users)

Use free-tier tools only:

Supabase

Auth

Database

Storage

Flutter App (current setup)

OpenStreetMap/Nominatim for city search & reverse geocoding

Razorpay Test Mode

Free hosting on:

Supabase Edge Functions

Vercel / Netlify (for web build)

💰 Cost: ₹0

Phase 2 — Growing (5,000–50,000 users)

Upgrade minimal required components:

Move search to:

ElasticSearch (open-source) OR

Meilisearch (free self-hosted)

Use Supabase paid tier (~$25/mo)

Add Cloudflare CDN for images

💰 Cost: ₹2,500–3,000/month maximum

Phase 3 — Expansion (50,000–5,00,000 users)

Move backend from Supabase to:
✔ FastAPI or Node.js microservices
✔ PostgreSQL on AWS / GCP / Railway

Introduce Redis Caching

Use GeoSearch API (ElasticSearch)

Add Load Balancer

Phase 4 — Large Scale (5 lakh+ users)

Full microservice architecture

Separate engines:

Search Service

Booking Service

Payment Service

Vendor Management Service

Start using:

AWS S3

CloudFront CDN

RDS Postgres

App performance must be monitored:

Firebase Analytics

Sentry

IN SIMPLE WORDS

We start free → slowly upgrade only those parts which get pressure → spend money ONLY when needed.

1.10 Risks

Fraudulent Pandits or fake temples

Incorrect GPS detection

Last-minute cancellations

Unverified vendors

City search may return foreign cities (we will implement India filter)

1.11 Non-Functional Requirements

App must load in <2 seconds

Location detection must take <1.5 seconds

UI must be consistent everywhere

Must handle offline mode gracefully