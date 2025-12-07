# Service Flow Documentation
Pooja & Havan Service Marketplace App  
Version: 1.0  
Last Updated: 2025-11-30

---

# 1. Purpose
This document explains the **complete service flow** for all user journeys in the Pooja–Havan marketplace app. It is written in simple, layman-friendly language so any team member, developer, stakeholder, or investor can understand how the app works.

This covers:
- Book Pooja (Home Rituals)
- Buy Samagri
- Havan at Temple
- Explore Ritual Services (Mundan, Marriage, Shradh, etc.)
- Location selection flow (Home → City → Pandit/Temple)
- Service fulfillment flow
- Business rules

---

# 2. High-Level Overview

When a user opens the app:
1. **Splash Screen**
2. **Landing Screen** (4 main options)
3. Based on selection → user picks location → sees service providers.

The entire app follows a **Location-First** approach:
> Every service depends on *where the ritual will happen*.  
> Example: A user lives in Ghaziabad but wants a Havan in Haridwar.

---

# 3. Core Principles

### ✔ Location is selected BEFORE choosing a pandit/temple  
### ✔ Each service has its own catalog  
### ✔ Users see only those pandits/temples allowed to perform that ritual  
### ✔ Prices can vary city-wise  
### ✔ Ritual details shown clearly before booking  
### ✔ App always offers:  
- Home Ritual  
- Temple Ritual  
- Samagri Delivery  
- Ritual-specific service list  

---

# 4. Service Categories

## 4.1 Book a Pooja (Home Rituals)
- Grih Pravesh  
- Satyanarayan Katha  
- Maha Mrityunjay Jaap  
- Navgrah Pooja  
- Laxmi Ganesh Pooja  
- Marriage-related rituals  
- Pregnancy / newborn rituals  

Performed at the user's home.

### Flow:
1. User selects **Book Pooja**
2. User selects **location of ritual**
3. User sees **list of pandits** available in that area
4. User selects a **ritual type** (or picks from featured rituals)
5. User sees:
   - Description
   - Samagri included/not included
   - Time duration
   - Price
   - Reviews
6. User books + selects the date/time
7. Payment
8. Confirmation + tracking

---

## 4.2 Buy Samagri
Complete pooja kits delivered at home.

### Flow:
1. Select **Buy Samagri**
2. Choose location (delivery city)
3. Choose Samagri Kit:
   - General Pooja Samagri Kit
   - Havan Samagri Kit
   - Grih Pravesh Kit
   - Marriage Ritual Kit  
4. Add to cart → checkout → delivery

---

## 4.3 Havan at Temple
User performs rituals at a proper temple or ghat instead of home.

### Examples:
- Haridwar Ghat Havan  
- Kashi Ganga Aarti Havan  
- Vrindavan Temple Rituals  

### Important rule:  
**A pandit must be approved by the temple to perform the ritual.  
Not all pandits can perform rituals at all temples.**

### Flow:
1. Select **Havan at Temple**
2. Choose **city of ritual** (e.g., Haridwar)
3. See list of **temples** supporting havan
4. Select temple → see:
   - Allowed pandits
   - Ritual types available
   - Price per temple rules
5. Choose date/time
6. Book + pay
7. Confirmation

---

## 4.4 Explore Services
This category contains “Everything Else”.

### Some examples:
- Mundan Ceremony
- Marriage Rituals Package
- Shradh / Tarpan rituals
- Naamkaran
- Pitru Dosh Shanti
- Rudrabhishek
- Astrology Consultation
- Vastushastra Consultation
- Havan for New Business

### Flow:
1. Select **Explore Services**
2. Choose city
3. See list of categories
4. Select ritual
5. See pandits available
6. Book + pay

---

# 5. Location Flow (Very Important)

### A user can:
- Live in Ghaziabad  
- Book a pooja in Haridwar  
- Use temple service in Mathura  
- Buy samagri for Noida  

So each flow must start with:

```
Where do you want this service?
```

Locations work in 3 ways:

### 5.1 Detect Current Location  
Via GPS.

### 5.2 Search City Manually  
User types “Haridwar”.

### 5.3 Recently Used Locations  
Stored locally.

---

# 6. Service Selection Flow

```
Landing Page
   ↓
Select Service Category
   ↓
Choose Location (City)
   ↓
Show Relevant Results (Pandits / Temples / Samagri Kits)
   ↓
Select Ritual / Offering
   ↓
Details Screen
   ↓
Book → Payment → Confirmation
```

---

# 7. Detailed Step-by-Step Flow (All Services)

## 7.1 Example: Book a Pooja (Home)
1. Tap **Book a Pooja**
2. Enter/Detect City
3. Show list of rituals OR pandits directly
4. Choose ritual (e.g., Satyanarayan Katha)
5. Ritual info screen
6. Choose pandit
7. Select date/time
8. Pay
9. Receive confirmation + WhatsApp message
10. Pandit tracks job in partner app

---

## 7.2 Example: Havan at Temple
1. Tap **Havan at Temple**
2. Choose “Haridwar”
3. Show list of temples supporting Havan
4. Select temple
5. Show allowed pandits only
6. Select ritual
7. Book
8. Pay
9. Confirmation

---

## 7.3 Example: Buy Samagri
1. Select **Buy Samagri**
2. Enter delivery city
3. Browse Samagri kits
4. Add to cart → checkout
5. Pay
6. Track delivery

---

## 7.4 Example: Explore Services
1. Select **Explore Services**
2. Choose city
3. Show list of services
4. Select category (e.g., Mundan)
5. Show pandits
6. Book
7. Pay  
8. Confirm

---

# 8. Business Rules

### 8.1 Location-based Services  
- Every service must have city-based pricing
- Pandits assigned to review per city
- Some rituals available only in some cities

### 8.2 Temple Rituals  
- Temple must be verified  
- Pandit must be permitted by temple authority  

### 8.3 Samagri Delivery  
- Only in supported cities  
- Delivery partners managed externally  

### 8.4 Multi-city Bookings  
Allowed (e.g., user in Delhi books Haridwar).

---

# 9. Future Updates

We will enhance:
- Ritual catalog (extensive list)
- Temple partnerships
- Pandit ratings + reviews
- Dynamic pricing
- Festival-based packages
- Multi-language support (Hindi + English)
- Auto-generated invoices
- Real-time pandit tracking

---

# 10. Summary

This document fully explains:
- All 4 service flows
- How location system works
- How pandits/temples/samagri interact
- User journeys  
- Business rules  
- Future scope  

This will be used for:  
✔ Development  
✔ Testing  
✔ Business discussions  
✔ Investor pitch  
✔ App documentation  

