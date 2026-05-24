# APP FLOW — OVERVIEW
This document explains how a normal user will move through the Pooja & Havan Service App.  
It is intentionally written in simple language so even a non-technical person can understand.

---

## 1. ENTRY POINTS INTO THE APP
A user can reach the app through:
- Mobile App (Android / iOS)
- Web Browser Version
- Shared Links (e.g., “Book a Pandit”, “Buy Samagri”)

---

## 2. PRIMARY FLOW STRUCTURE
The app works in **four simple steps**:

### STEP 1 — **App Opens → Splash Screen**
- Shows animated app logo.
- Very short introduction (1–1.5 seconds).
- Moves automatically to Landing Page.

---

### STEP 2 — **Landing Page**
User sees four main options:

1. **Book a Pooja**
2. **Buy Samagri**
3. **Havan at Temple**
4. **Explore Services**

No location is asked yet — the user first chooses the *type of service*.

---

### STEP 3 — **Location Selection (Smart Flow)**
After the user selects any of the 4 options, the app asks:

**“Where do you want this service?”**

User gets 3 choices:
- **Use Current Location**
- **Search Manually (City Name)**
- **Choose From Suggestions (Top Cities, Recently Used)**

Why this flow?
- A user living in Ghaziabad may book a Pooja in Haridwar.
- A user in Delhi may request Samagri delivery in Noida.
- You designed this requirement intentionally.

---

### STEP 4 — **Service-Specific Options**
Based on the selected service:

1. **Book a Pooja → Ritual List**
   - Grih Pravesh
   - Maha Mrityunjay Jaap
   - Satyanarayan Pooja
   - Marriage Rituals
   - etc.

2. **Buy Samagri → Packages**
   - Basic Pooja Samagri Kit
   - Hawan Samagri Kit
   - Custom Samagri selection
   - Vendor-wise options

3. **Havan at Temple → Temple List**
   - Nearby temples (if user allowed location)
   - Destination temples (e.g., Haridwar Ghat)
   - Only Pandits approved for that temple are shown (your requirement)

4. **Explore Services → Categories**
   - Mundan
   - Marriage Rituals
   - Shradh / Tarpan
   - Festival Poojas
   - Other special ceremonies

---

## 3. CHECKOUT FLOW (Common Across All Services)
Regardless of service type, checkout steps are same:

1. **Select Pandit / Package / Temple**
2. **Choose Date & Time**
3. **Enter Details (Name, Address, Special Requests)**
4. **Review & Payment**
5. **Order Confirmation**
6. **Tracking Page**
   - Pandit assignment
   - Contact number
   - Reminders
   - Live updates (future)

---

## 4. KEY FLOW PRINCIPLES
These principles guide our app design:

### ✔ Location comes **after** service selection  
Users should not be forced to choose the current city first.

### ✔ Temple-based rituals show only “approved pandits”  
Your business rule to avoid mismatched priests.

### ✔ Both “home rituals” and “temple rituals” supported  
Unique advantage over competitors.

### ✔ Explore Services allows non-technical users to discover all offerings  
Especially helpful for elderly users.

### ✔ No confusion: consistent theme across entire app  
Saffron–gold premium UI.

---

## 5. FUTURE FLOW EXTENSIONS
These are planned and will integrate smoothly:

- Vendor onboarding flow  
- Pandit onboarding flow  
- Admin dashboard  
- Additional payment modes (Wallet, COD handling rules)  
- Push notifications  
- Multi-language flow  
- International service flow (for NRIs)
- WhatsApp Automated Booking Confirmations (requires collecting phone number at checkout)

---

## 6. SIMPLE VISUAL FLOW (TEXT VERSION)

[Splash Screen]
↓
[Landing Page]
↓ (User chooses 1 of 4)
[Service Type Selected]
↓
[Ask Location]
↓
[Show Options (Pandit / Temple / Samagri)]
↓
[Details Form]
↓
[Payment]
↓
[Confirmation + Tracking]


---

## 7. REAL LIFE EXAMPLE (VERY IMPORTANT)
### Scenario:
You live in **Ghaziabad**.  
Your relative wants **Maha Mrityunjay Jaap in Haridwar**.

### Flow:
1. Open app  
2. Tap **Book a Pooja**  
3. Select **Maha Mrityunjay Jaap**  
4. Location screen opens  
5. Type **Haridwar**  
6. Choose date  
7. Select Pandit approved for Har Ki Pauri  
8. Pay  
9. Receive confirmation

This scenario is exactly why the app follows a **service-first → location-second** model.

---

## 8. APP FLOW IS NOW LOCKED
This flow is final and approved.  
Any additions will follow the same structure.

