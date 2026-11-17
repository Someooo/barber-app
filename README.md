# BarberSync

[![Flutter CI](https://github.com/Someooo/barber-app/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/Someooo/barber-app/actions/workflows/flutter_ci.yml)

Enterprise, offline-first, single-barbershop booking and management platform built with Flutter, Clean Architecture, `flutter_bloc`, `go_router`, `firebase_auth`, and `cloud_firestore`.

---

## Luxury Aesthetic & Dual-Language Support

- **Light Mode (Default):** Warm Cream (`#f7ebdf`) surface with Obsidian (`#121212`) ink and Luxury Gold (`#c5a059` / `#a17653`) accents.
- **Dark Mode:** Obsidian (`#121212`) surface with high-contrast neutral text and gold accents.
- **Bilingual (`EN` / `AR`):** Full English (LTR) and Modern Standard Arabic (RTL) localization via `flutter_localizations` and ARB code generation (`app_en.arb`, `app_ar.arb`), with direction-aware `EdgeInsetsDirectional`, `AlignmentDirectional`, and `PositionedDirectional` layouts.

---

## Three-Role Single-Barbershop Architecture

1. **Customer (`UserRole.customer`)**
   - Browse luxury services and the horizontal **Master Barbers** carousel (`MasterBarberCard`).
   - Instant multi-service booking with real-time slot conflict checks (`BookingFlowScreen`).
   - Track upcoming/rescheduled appointments, view barber notices/reasons, cancel bookings, and manage profile photo (`image_picker` + `path_provider`) and theme/language preferences.
2. **Barber (`UserRole.barber`)**
   - Automatic barber profile sync (`EnsureBarberProfileUseCase`) so registered barbers appear in the customer carousel.
   - Manage personal appointments (`Today` / `Upcoming` / `History`) with **Complete**, **Reschedule (with mandatory reason & slot check)**, and **Cancel (with mandatory reason)** actions.
   - Toggle real-time `Available Today` status.
3. **Shop Owner + Master Barber (`UserRole.owner`)**
   - Exclusive to the pre-configured Shop Owner account (`0799081839` / `+962799081839`); hidden from public role selection.
   - **5-Tab Management Shell (`OwnerShellScreen`):**
     - **Overview:** Shop-wide KPIs (Total Revenue, Active Appointments, Total Barbers, Total Services) and recent activity.
     - **My Schedule:** Personal barber schedule with full Complete / Reschedule / Cancel capabilities.
     - **Services:** Add and delete barbershop services in real time.
     - **Barbers:** Add and delete barbers (with deletion protection on the owner's own card).
     - **Profile:** `Available Today` switch, profile photo picker, and theme/language toggles.

---

## Architecture & Performance Engineering

- **Clean Architecture:** Strict layer isolation across `domain` (pure Dart entities, repository contracts, use cases), `data` (models, `FirebaseFirestoreCustomerDataSource`, `InMemoryFirestoreCustomerDataSource`, repository implementations), and `presentation` (BLoCs, screens, pure modular widgets).
- **Routing & Guards:** `GoRouter` with `GoRouterRefreshStream` and strict role-based redirects (`/customer/home`, `/barber/dashboard`, `/owner/dashboard`).
- **Cloud Firestore & Transactions:** `FirebaseFirestoreCustomerDataSource` uses atomic `firestore.runTransaction` checks for instant booking creation and rescheduling to prevent double-bookings across devices. Security is enforced via `firestore.rules`.
- **Rendering Performance:** `RepaintBoundary` isolation on cards, avatars, buttons, switches, loaders, and `TextFormField` leaves; leaf-only `BlocBuilder` / `ValueListenableBuilder` predicates; zero `MaterialApp.router` rebuilds on feature state changes; Impeller-ready UI composition.

---

## Project Setup & Commands

1. **Install dependencies & generate localizations:**
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
2. **Firebase Configuration:**
   - Ensure `lib/firebase_options.dart` is configured for your Firebase project.
   - Deploy `firestore.rules` to Cloud Firestore.
3. **Format, Analyze & Test:**
   ```bash
   dart format lib test
   dart analyze lib test
   flutter test
   ```

---

## CI/CD Pipeline (GitHub Actions)

The repository includes an automated workflow at `.github/workflows/flutter_ci.yml` triggered on pushes and pull requests to `main` (and manually via `workflow_dispatch`):

1. Installs dependencies (`flutter pub get`) and generates localizations (`flutter gen-l10n`).
2. Enforces formatting (`dart format --output=none --set-exit-if-changed lib test`), static analysis (`dart analyze lib test`), and the full test suite (`flutter test`).
3. Builds `build/app/outputs/flutter-apk/app-debug.apk` and uploads it as the `barbersync-debug-apk` artifact (retained for 7 days).
4. **Downloading the APK:** Open the **Actions** tab on GitHub, select the latest **Flutter CI** workflow run, and download `barbersync-debug-apk` under **Artifacts**.
