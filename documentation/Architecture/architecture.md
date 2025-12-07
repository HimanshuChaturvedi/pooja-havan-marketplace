doc/Architecture — Complete Architecture Overview
🧱 APP ARCHITECTURE

Clean Architecture + Riverpod

lib/
├── src/
│   ├── core/          → routing, services, exceptions
│   ├── features/      → module-wise screens
│   ├── theme/         → colors, typography, components
│   ├── shared/        → utils, extensions, widgets

🟠 Layers
1. Presentation Layer

Screens: Landing, Location, Explore Services

Widgets: Cards, Buttons

Animations

State Managed by Riverpod

2. Application Layer

Controllers/State Notifiers

UseCases

Business logic (e.g., “selectCity”, “detectLocation”)

3. Infrastructure Layer

Geocoding service

Local storage

APIs (later)

⚙ Technical Stack
Category	Choices
Framework	Flutter
Architecture	Clean Architecture
State Management	Riverpod
API	Optional (Supabase/Firebase)
Payment	Razorpay UPI Test