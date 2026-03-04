# Bharat Pooja Setu (भारत पूजा सेतु)
> **Connecting Bharat with Dharma.**

## 🕉️ Project Crux
Bharat Pooja Setu is a digital bridge (Setu) designed to streamline the connection between devotees (Users) and spiritual experts (Pandits). It solves the fragmentation in pilgrimage bookings (Haridwar, Varanasi, etc.) and ensures transparent, fixed pricing for sacred rituals.

### Core Problems Solved:
1.  **Unorganized Pilgrimage**: Eliminates the chaos of finding verified Pandits at Tirth Sthals.
2.  **Pricing Opacity**: Fixes "Dakshina" beforehand to prevent user exploitation and ensure Pandit stability.
3.  **Accessibility**: Brings Vedic rituals (Home, Temple, Village) to a modern mobile interface.

---

## 🚀 Roadmap & Phases

### Phase 1: Play Store Readiness (Completed)
- **UI/UX**: Transitioned to "Bright Divine" theme (Saffron/Cream/Maroon).
- **Hardened UI**: Fixed visibility issues (BackdropFilter replaced with solid glass-effect cards).
- **Submission**: Setup for Closed Testing with 20 testers.

### Phase 2: Advanced Ritual Flow (Current)
- **Multi-Location Support**: Logic for Home, Temple, Tirth (Pilgrimage), and Village/Other.
- **Location Detection (GPS)**: Integrated location sensing to find rituals and Pandits specific to the user's area.
- **Location Freeze**: Ability to lock/freeze bookings within specific Pilot regions (e.g., Ghaziabad).
- **Authorized Pandits**: Mapping specific Pandits to specific Tirth spots/Temples where only authorized priests are allowed.

### Phase 3: Scaling & Enhancement (Future)
- **Database Migration**: Seamless transition from Local Data to Supabase.
- **AI Vastu Scanner**: Revolutionary AR/Camera-based tool to scan homes/offices for Vastu compliance and suggest remedies.
- **Multilingual Support**: Full Hindi & Hinglish localization.
- **Shubh Muhurat**: Integrated Hindu Calendar and Rahu Kaal tracking.
- **Ratings & Trust**: Star-rating system for verified Pandits.

---

## 🛠️ Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod / Flutter Hooks (Stable & Reactive)
- **Persistence**: Local Repository Pattern (Migratable to Supabase)
- **Infrastructure**: geolocator (GPS), go_router (Navigation), Google Fonts (Outfit).

---

## 🔄 User Flow (v2)
1.  **Landing**: Entry point explaining the Pilot status.
2.  **Mode Selection**: User chooses location type (Home / Temple / Tirth / Village).
3.  **Location Detection**: App fetches GPS coordinates + Reverse Geocodes City/Area.
4.  **Ritual Browsing**: Dynamic list filtered by Location + Availability.
5.  **Pandit Selection**: Selection from authorized/verified list for that specific ritual/spot.
6.  **Summary**: Zero-default summary (only shows what is selected) with live price calculation.
7.  **Payment/Confirmation**: WhatsApp integrated transaction logs.

---

## 🏛️ Architecture Philosophy
- **Decoupled Data**: Uses the **Repository Pattern** (`RitualRepository`). UI doesn't care where the data comes from (Local or Cloud).
- **Divine Aesthetics**: Minimalistic, premium design using curated Saffron Dawn color palette.
- **SME-Led Code**: Focus on business logic stability (Location Freeze, Authorized Mapping) before technical complexities.

## 🔮 AI Future Vision (The "Dharma-Tech" Edge)
The AI in Bharat Pooja Setu is not just a chatbot; it is a **Proactive Spiritual Strategist**. It doesn't just answer questions; it **identifies needs**.

1.  **AI Vastu Consultant**: Computer Vision for house scans and instant ritual suggestions.
2.  **Proactive Requirement Generator**: AI analyzes user life stages (e.g., "Recently moved", "Birth in family") and creates personalized ritual roadmaps (Sanskar Plans) automatically. It **creates the requirement** before the user even realizes it.
3.  **Vedic Problem Solver**: Uses deep LLM insights (Gemini) to link real-world problems (stress, business loss, health) to specific Vedic remedies and rituals.
4.  **AI Smart Muhurat**: Explains the "Science & Stars" behind every shubh timing to build deeper trust.

---
*Maintained by Antigravity (SME & Coder)*
