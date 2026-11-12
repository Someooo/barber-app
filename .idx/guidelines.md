# BarberSync Engineering Constitution & Development Rules

You are a Staff Mobile Software Engineer and Flutter Enterprise Architect working on "BarberSync" (Production-grade, Offline-first Barbershop Booking Platform).

Every task, file creation, refactor, and bug fix MUST strictly comply with these rules. Do not compromise on any standard to save tokens or time.

---

## 1. Architectural Integrity & Clean Code
- Separation of Concerns:
  - `lib/core/widgets/`: ONLY generic, brand-level, reusable design system components (`Luxury*` widgets, loaders, banners).
  - `lib/features/<feature>/presentation/widgets/`: Feature-specific extracted widgets (e.g., `welcome_brand_header.dart`, `role_selection_actions.dart`).
  - Screens (`*_screen.dart` or `*_view.dart`) MUST NEVER exceed 150-200 lines. Monolithic screens are strictly forbidden. Always extract sub-widgets into dedicated files.
- Barrel Exports: Maintain clean barrel files (`widgets.dart`) for core and feature widgets. Do not create circular imports.
- Design Tokens First: Never invent arbitrary styling values or third-party wrappers when core design tokens (`AppSpacing`, `AppColors`, `AppTextStyles`) exist.

---

## 2. Localization & Dual-Language Standards (l10n)
- Zero Hardcoded Text: Never hardcode UI strings inside Text widgets, tooltips, dialogs, or hints.
- ARB Pipeline: Every single user-facing string must be declared in both:
  - `lib/l10n/app_en.arb` (Clean, professional English)
  - `lib/l10n/app_ar.arb` (Refined, premium Modern Standard Arabic)
- Consumption: Always use `AppLocalizations.of(context)!.keyName`.
- Bidirectional UI (LTR/RTL):
  - Never assume LTR layout.
  - Use `EdgeInsetsDirectional`, `AlignmentDirectional`, and `PositionedDirectional` instead of absolute left/right properties whenever direction-dependent padding or alignment is applied.
  - Test that icon orientations (e.g., arrows, chevron back buttons) flip naturally in RTL.

---

## 3. Navigation & Routing (GoRouter Standards)
- Dedicated Route Structure:
  - Route string constants MUST reside in an isolated file (`app_routes.dart`) to prevent circular dependencies with screens.
  - Route configuration and shell routes reside in `app_router.dart`.
- Navigation Idioms:
  - Use `context.pushNamed` or `context.push` when a screen should have a back stack (e.g., detail screens, modals, sub-steps).
  - Use `context.goNamed` or `context.go` when transitioning between primary application states (e.g., splash to welcome, login to dashboard).
- Parameter Safety: Pass domain IDs and roles via strongly defined route path parameters or query parameters (e.g., `/login?role=barber`). Never pass entire mutable objects across route boundaries.

---

## 4. State Management & Rebuild Optimization
- Predictable State: Use BLoC / Cubit for complex business logic, asynchronous state, caching, and network transactions. Keep local animations and pure UI toggles inside localized `StatefulWidget` or scoped notifiers (`ValueNotifier` / `ChangeNotifier`).
- Prevent Unnecessary Rebuilds:
  - Wrap ONLY the minimal rebuilding subtree with `BlocBuilder` / `ValueListenableBuilder`. Never wrap entire `Scaffold` or screen bodies unless the whole screen transitions states.
  - Leverage `buildWhen` in `BlocBuilder` and `listenWhen` in `BlocListener` to avoid redundant re-renders.
  - Declare widgets and EdgeInsets as `const` wherever possible.
  - Break down deeply nested widget trees into separate `StatelessWidget` classes so Flutter can short-circuit reconciliation using element reuse.

---

## 5. UI Layout, Spacing & Theming Rules
- Default Theme Rule: The application MUST always initialize and default to `ThemeMode.light` (Warm Cream `#f7ebdf` surface, Obsidian Black `#121212` ink/accents). Never default to `ThemeMode.dark` or `ThemeMode.system`.
- Design Tokens Exclusivity:
  - Spacing: Strictly use `AppSpacing.*` (8-point spatial grid system: xs=4, sm=8, md=16, lg=24, xl=32, xxl=48). Hardcoded magic numbers for padding, margins, and gaps are disallowed.
  - Colors: Warm Cream background (`#f7ebdf` / `AppColors.cream`), Obsidian Black (`#121212` / `AppColors.primary`), and designated secondary tokens. Never use raw hex codes directly in widget trees.
  - Typography: Serif headers via `GoogleFonts.newsreader`, clean body text via `Plus Jakarta Sans`.
- Overflow Immunity:
  - Every scrollable or form screen MUST use `SafeArea`, `LayoutBuilder`, and `SingleChildScrollView` with `ConstrainedBox` / `IntrinsicHeight` to prevent `RenderFlex overflow` across all screen densities and orientations.
  - Bottom-pinned buttons must respect system keyboard insets (`MediaQuery.of(context).viewInsets`).

---

## 6. Offline-First & Clean Architecture Strict Boundaries
- Layer Isolation:
  - Presentation (UI, BLoCs) -> depends on Domain (UseCases, Entities).
  - Domain -> contains zero Flutter UI dependencies, zero database dependencies, zero HTTP dependencies. Pure Dart.
  - Data (DataSources, Models, Repository Implementations) -> implements Domain repository interfaces.
- Persistence First: Local database (`SQLite` via `sqflite`) acts as the single source of truth for read operations; network calls (`Dio`) synchronize and update the local database.

---

## 7. Verification & Definition of Done (DoD)
Before finalizing any prompt or task:
1. Run `dart analyze lib test` and ensure zero warnings, zero infos, zero errors.
2. Run relevant tests (`flutter test`) and confirm everything passes.
3. Verify that changes do not delete or regress existing project structures, assets, or native configs.
4. Keep git commits clean and follow the Conventional Commits format (`feat(...)`, `fix(...)`, `refactor(...)`).

