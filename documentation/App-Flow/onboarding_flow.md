# 🕉️ Pooja & Havan Marketplace App  
# Onboarding Flow (Step-by-step Guide)

This document explains the **onboarding flow** of the Shubh Pooja app in simple terms so that anyone — developer, business user, or new team member — can understand how a user enters the app and starts their journey.

---

## 1) Splash Screen (App Intro)

### Purpose  
- To show the app branding briefly  
- To give a premium feel  
- To prepare the app for routing

### Behaviour  
- Shown for **2 seconds**  
- Automatically routes to the **Landing Page**

```
┌─────────────┐
│  SPLASH     │ (2 sec)
└──────┬──────┘
       │
       ▼
```

---

## 2) Landing Page (Main Home Entry)

### Purpose  
This is the **first main screen** the user sees.

It shows **four clean options**:

1. **Book a Pooja** (Pandit for home rituals)  
2. **Buy Samagri** (Pooja items & kits)  
3. **Havan at Temple** (Perform rituals at mandirs/ghats)  
4. **Explore Services** (Mundan, marriage rituals, shradh, etc.)

### Why this screen first?  
Because users decide **WHAT** they want to do *before* deciding **WHERE** they want to do it.

### Layout Diagram

```
┌────────────────────────────────────┐
│ Shubh Pooja (Header + Icon)        │
├────────────────────────────────────┤
│ What would you like to do today?   │
│                                    │
│ [ Book a Pooja        ] [ Buy Samagri     ]  
│                                    │
│ [ Havan at Temple     ] [ Explore Services ]  
└────────────────────────────────────┘
```

All 4 options are clearly visible **without scrolling**.

---

## 3) Service → Location Flow

After user chooses a service (example: Book a Pooja), we take them to the **Location Page**.

### Why?  
Because location affects:  
- Service availability  
- Pandit availability  
- Temple availability  
- Travel charges  
- Samagri delivery

### Location Page allows two methods:

---

### A) Detect Current Location  
- Uses mobile GPS  
- Finds nearest city (via Nominatim/OpenStreetMap)  
- Sets `latitude` and `longitude`  
- Moves to the next screen based on service type

Diagram:

```
Choose Service
     │
     ▼
Location Page
     │
     ├── Detect Current Location
     │        │
     │        ▼
     │   Reverse Geocode
     │        │
     │        ▼
     └── Location Selected → Continue Flow
```

---

### B) Enter City Manually  
- User types a city name  
- Suggestions appear  
- They pick one  
- Coordinates saved  
- Flow continues

Diagram:

```
Enter City Name → Show Suggestions → User Selects → Location Saved
```

---

## 4) After Location Selection

Next step depends on which service was chosen:

### 💠 If user selected **Book a Pooja**  
```
Location → Select Ritual → Available Pandits → Booking Flow
```

### 💠 If user selected **Buy Samagri**  
```
Location → Shop Items → Add to Cart → Checkout
```

### 💠 If user selected **Havan at Temple**  
```
Location → Available Temples → Select Ritual Package → Book Slot
```

### 💠 If user selected **Explore Services**  
```
Location → List of Services → Select Service → Booking Flow
```

---

# 🧩 Full Onboarding Flow Summary Diagram

```
┌──────────┐
│ Splash   │
└─────┬────┘
      ▼
┌──────────┐
│ Landing  │ (Book Pooja / Samagri / Temple / Explore)
└─────┬────┘
      ▼
┌──────────┐
│ Location │ (Detect GPS OR Enter City)
└─────┬────┘
      ▼
┌──────────────────────┐
│ Service-Specific Flow │
└──────────────────────┘
```

---

## ✔ Notes for Developers  
- Implemented using **GoRouter**  
- Splash → auto-navigate using `Future.delayed`  
- Landing Page uses **mobile vs web adaptive layout**  
- Location Page uses:
  - `geolocator`
  - `permission_handler`
  - `Nominatim` search via our custom `GeocodingService`
- State managed with **Riverpod StateNotifier**

---

## ✔ Notes for Business  
- User always starts with selecting the service  
- Only then we ask for location (same as CarWale flow)  
- Works for cases like:
  - User in Ghaziabad booking a pooja in Haridwar  
  - User not wanting to share GPS  
  - User doing pooja in temple outside home city  

---

If you want, I can also add **A flowchart PNG** later using ASCII → vector style.

