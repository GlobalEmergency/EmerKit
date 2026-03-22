# CLAUDE.md - Project Rules for AI Assistants

## Project Overview

EmerKit is a cross-platform Flutter app with 24 clinical tools for emergency healthcare professionals. Developed by Global Emergency (globalemergency.online).

- **Package name**: `online.globalemergency.emerkit`
- **Dart package**: `navaja_suiza_sanitaria` (legacy, do not rename)
- **Repo**: https://github.com/GlobalEmergency/EmerKit

## Architecture

**Feature-First DDD** with a shared layer.

```
lib/
├── shared/              # Cross-cutting: widgets, entities, DI, theme, router
│   ├── di/              # Service locator pattern for dependency injection
│   ├── domain/entities/ # Severity, ToolCategory
│   ├── presentation/
│   │   ├── widgets/     # ToolScreenBase, ResultBanner, InfoCard, ScoredItemSelector, ToolInfoPanel
│   │   ├── theme/
│   │   └── router/      # GoRouter configuration
│   └── utils/
├── features/            # One folder per tool
│   └── <feature>/
│       ├── domain/      # Pure Dart calculators and data (NO Flutter imports)
│       └── presentation/# Screens and feature-specific widgets
├── version.json         # Single source of truth for app version
└── app.dart             # MaterialApp entry point (class EmerKitApp)
```

## Pre-Push Checklist (MANDATORY)

Before every push, run these commands **in order**. All must pass:

```bash
dart format .                        # 1. Format - must have 0 changes
flutter analyze                      # 2. Lint - must have 0 issues (no warnings, no info)
flutter test                         # 3. Test - all 86+ tests must pass
bash scripts/propagate-version.sh --check  # 4. Version sync check
```

If you change app code (`lib/`, `assets/`, `pubspec.yaml`), you MUST bump `version.json` before pushing.

## Key Commands

```bash
dart format .                        # Format all code
dart format --set-exit-if-changed .   # Check format (CI mode)
flutter analyze                      # Static analysis (0 issues required)
flutter test                         # Run all tests (86+)
flutter build apk --debug            # Debug APK
flutter build apk --release          # Release APK
flutter pub get                      # Install dependencies
flutter run                          # Run on connected device
bash scripts/propagate-version.sh    # Propagate version.json to pubspec.yaml + assets
```

## Versioning

- Version lives in `version.json` (single source of truth)
- `scripts/propagate-version.sh` syncs it to `pubspec.yaml` and `assets/version.json`
- Build number is computed: `MAJOR * 10000 + MINOR * 100 + PATCH`
- When `version.json` changes on main, CI auto-creates tag + GitHub Release + deploys to stores
- PRs that change app code (`lib/`, `assets/`, `pubspec.yaml`) MUST bump the version
- PRs that only touch CI, docs, or config do NOT need a version bump

## Code Conventions

### Imports
- **Cross-feature**: use `package:navaja_suiza_sanitaria/...`
- **Within same feature**: use relative imports
- **NEVER** import across features directly (use shared layer)

### File Naming Patterns
| Type | Pattern | Example |
|---|---|---|
| Calculator | `<feature>_calculator.dart` | `glasgow_calculator.dart` |
| Data | `<feature>_data.dart` | `glasgow_data.dart` |
| Screen | `<feature>_screen.dart` | `glasgow_screen.dart` |
| Test | `<feature>_calculator_test.dart` | `glasgow_calculator_test.dart` |

### Dart Style
- `analysis_options.yaml` enforces: `prefer_const_constructors`, `prefer_const_declarations`, `avoid_print`
- Linter: `flutter_lints`
- **ZERO** warnings and info issues allowed — fix them, do NOT suppress with `// ignore:`
- Always run `dart format .` before committing

## Critical Rules

### Calculators are Pure Dart
Calculators in `domain/` must NOT import `package:flutter/...`. They contain only pure Dart logic. This allows them to be tested without Flutter framework overhead and keeps domain logic framework-independent.

### No Cross-Feature Domain Imports
Features must NOT import from another feature's `domain/`. If two features share logic, move it to `lib/shared/domain/`.

### Every Feature Needs domain/
Every feature folder must have a `domain/` subfolder with at least a `_data.dart` file containing `infoSections` and `references`.

### Tool Screen Pattern
Every tool screen follows this pattern:
- `ToolScreenBase` as the scaffold
- `ResultBanner` at the top (result always visible first)
- Tool body below (interactive part)
- Info button in AppBar (opens `ToolInfoPanel` via bottom sheet)
- Reset button in AppBar
- Each tool has two modes: **emergency mode** (quick use) and **study mode** (detailed info + references)

### Testing Rules
- Use `flutter_test`, NOT `package:test`
- Test **clinical use cases**, not class methods
- Use descriptive group names that describe the clinical scenario
- Follow the AAA pattern (Arrange, Act, Assert)
- Tests live in `test/domain/` at project root

```dart
// CORRECT: clinical use case
group('Paciente con minima puntuacion (coma profundo)', () {
  test('GCS 3 es Grave', () {
    final r = calculator.calculate(eye: 1, verbal: 1, motor: 1);
    expect(r.total, 3);
    expect(r.severity.level, SeverityLevel.severe);
  });
});
```

### Shared Widgets
Reuse these widgets from `lib/shared/presentation/widgets/`:
- `ToolScreenBase` -- base scaffold for tool screens
- `ResultBanner` -- colored result display banner
- `InfoCard` -- informational cards
- `ScoredItemSelector` -- selector for scored items (e.g., Glasgow eye/verbal/motor)
- `ToolInfoPanel` -- panel with tool description and references
- `SectionHeader` -- section divider headers

### Dependency Injection
Uses a **service locator pattern** in `lib/shared/di/`. All calculators are registered in `register_services.dart` and called from `main.dart`.

### Navigation
Uses **GoRouter** (`go_router` package). Routes defined in `lib/shared/presentation/router/`.

### Tool Registration
All tools are registered in `lib/features/home/presentation/tool_registry.dart` with:
- `id`: unique identifier
- `name`: display name (Spanish)
- `icon`: Material icon
- `route`: GoRouter path
- `category`: one of ToolCategory enum values

### Categories (ToolCategory enum)
- `soporteVital` -- Life Support
- `valoracion` -- Assessment
- `signosValores` -- Signs & Values
- `oxigenoterapia` -- Oxygen Therapy
- `tecnicas` -- Techniques
- `proteccion` -- Protection
- `comunicacion` -- Communication

## Adding a New Tool

1. Create `lib/features/<tool>/domain/<tool>_calculator.dart` (pure Dart)
2. Create `lib/features/<tool>/domain/<tool>_data.dart` (static data with `infoSections` + `references`)
3. Create `lib/features/<tool>/presentation/<tool>_screen.dart` (use `ToolScreenBase` + `ResultBanner`)
4. Add route in `lib/shared/presentation/router/`
5. Register in `lib/features/home/presentation/tool_registry.dart`
6. Register calculator in `lib/shared/di/register_services.dart`
7. Write tests in `test/domain/<tool>_calculator_test.dart`
8. Run full pre-push checklist: `dart format . && flutter analyze && flutter test`

## CI/CD Pipeline

### PR checks (fast ~1-2 min)
- Version bump required (only if app code changed)
- Version sync check (`propagate-version.sh --check`)
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`

### Push to main
- Same as PR + `flutter build apk --debug`

### Release (on version.json change)
- `ensure-tags.yml` → creates tag + GitHub Release
- Calls `build-android.yml` → signed APK/AAB → Google Play (internal track)
- Calls `build-ios.yml` → IPA → TestFlight

## Commit Convention

Conventional Commits: `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `test`, `docs`, `refactor`, `ci`, `chore`
- Scopes: `glasgow`, `triage`, `ictus`, `o2`, `rcp`, `tep`, `nihss`, `rankin`, `shared`, `ci`, `docs`, `ui`
