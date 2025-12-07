PROJECT HANDOFF REFERENCE  
(Pooja & Havan Service Marketplace App)

──────────────────────────────────────────────────────────
1. PROJECT NAME
Pooja & Havan Service Marketplace App  
Flutter • Android • iOS • Web

──────────────────────────────────────────────────────────
2. PRIMARY GOAL
A marketplace where users can:  
• Book Pandits for home rituals  
• Perform Havan / Pooja at selected Temples or open holy places  
• Buy Pooja Samagri  
• Explore a list of ritual services (mundan, marriage, shradh, etc.)  
• Choose service location (home city or destination city)

──────────────────────────────────────────────────────────
3. CURRENT DEVELOPMENT STATUS (LATEST)
✓ Flutter project set up  
✓ Clean Architecture folder structure implemented (src-based)  
✓ Theme system ready (AppColors, AppTextStyles, AppTheme)  
✓ Primary button implemented  
✓ Routing implemented using GoRouter  
✓ Splash screen implemented  
✓ Landing page (latest compact design, no overflow) ready  
✓ Location module implemented (current location + manual city search)  
✓ Nominatim/OpenStreetMap integrated  
✓ Documentation folder created with subfolders:
   - App-flow
   - Architecture
   - Backend
   - MOM
   - Project-Handoff
   - Requirements
   - UI-design

──────────────────────────────────────────────────────────
4. USER PRIORITIES & RULES FOR CHATGPT
• DO NOT restart the project  
• Continue EXACTLY from the last progress  
• Always give FULL files, not patches  
• One step at a time  
• Use FREE tools only (Supabase, OSM, Razorpay test)  
• Clean Architecture + Riverpod  
• Modern Indian pastel+gold theme  
• UI must remain premium like CRED, Zomato, CarWale  
• Variation in screens allowed but theme unchanged  
• Always update internal documents (requirements, flows, MoM)  
• Must remember ALL past decisions  
• Do NOT lose context between sessions

──────────────────────────────────────────────────────────
5. MAJOR MODULES (PLANNED)
• User onboarding  
• Service selection  
• Location selection (home or destination city)  
• Pandit selection  
• Samagri purchase  
• Temple selection for havan  
• Vendor dashboard  
• Admin dashboard  
• Payment (UPI / Razorpay test mode)  
• Push notifications  
• Order tracking  
• Website (Privacy, T&C, About, Contact)  
• Deployment (Play Store + App Store + Web)

──────────────────────────────────────────────────────────
6. FLOWS DECIDED SO FAR
A. Landing Page → four primary options:
   1. Book a Pooja  
   2. Buy Samagri  
   3. Havan at Temple  
   4. Explore Services  

B. After choosing option:
   → Ask: “Where do you want this service?”  
      • My Current Location  
      • Choose Another City  
   → Then show list of Pandits / Temples / Service Providers

C. Explore Services will list rituals:
   • Mundan  
   • Marriage rituals  
   • Shradh  
   • Grih Pravesh  
   • Mahamrityunjay Jaap  
   • Many more (extensible)

──────────────────────────────────────────────────────────
7. CODE STATUS (LATEST STABLE)
• Splash page working  
• Landing page compact grid working  
• Location page UI + controller working  
• City search autocomplete working (Nominatim)  
• Web layout and mobile layout separate (adaptive)  
• NO current runtime errors  
• Only UI tuning pending

──────────────────────────────────────────────────────────
8. PENDING WORK (NEXT STEPS)
1. Fix landing page header alignment  
2. Add spacing adjustments  
3. Create Service Module pages  
4. Create Explore Services screen  
5. Create Temple selection module  
6. Connect flows to real navigation  
7. Store location in state for full app  
8. Begin backend DB structure  
9. Continue documentation expansion  
10. Prepare investor-ready app flow diagrams

──────────────────────────────────────────────────────────
9. TECHNOLOGY STACK (CURRENT)
• Flutter 3.24+  
• Dart 3.x  
• Riverpod (state management)  
• GoRouter (navigation)  
• Supabase (backend option, free)  
• OpenStreetMap + Nominatim (geocoding)  
• Razorpay (test mode)  
• GitHub (version control)

──────────────────────────────────────────────────────────
10. PROJECT STRUCTURE (DEVELOPED)
lib/src/
   core/
      routing/
      theme/
      services/
   features/
      landing/
      location/
      service/
   shared/
      widgets/
documentation/
   App-flow/
   Architecture/
   Backend/
   MOM/
   Project-Handoff/
   Requirements/
   UI-design/

──────────────────────────────────────────────────────────
11. DEVELOPMENT PRINCIPLES
• Write fully documented, production-quality code  
• Keep architecture clean & modular  
• Make UI simple, premium & culturally relevant  
• Keep performance in mind (avoid heavy animations)  
• Ensure easy scaling for future services  
• Always remember real-world ritual flow logic  
• Use safe defaults, avoid hacks

──────────────────────────────────────────────────────────
12. WHAT CHATGPT MUST DO IN NEW SESSION
• Load THIS reference  
• Continue from last stable code  
• Never overwrite existing design direction  
• Maintain Saffron+Gold theme  
• Maintain compact cards layout  
• Do not re-explain old concepts  
• Just continue development smoothly  

──────────────────────────────────────────────────────────
13. OWNER DETAILS
Developer: Himanshu Chaturvedi  
Assistant: ChatGPT (SME + Architect + Document Writer)

──────────────────────────────────────────────────────────
END OF PROJECT HANDOFF REFERENCE
