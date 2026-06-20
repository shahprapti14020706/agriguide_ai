# AgriGuide AI

AI-powered agriculture intelligence companion for farmers.

## Phase 1 Scope

This repository currently contains the Flutter foundation only:

- Project metadata and dependencies
- Clean architecture folder structure
- App constants
- Theme setup
- Route definitions
- Service locator setup
- Placeholder-safe Firebase initialization
- Minimal app shell for compile verification

Feature screens and business workflows are intentionally not implemented yet.

## Prerequisites

- Flutter SDK 3.22 or newer
- Dart SDK 3.4 or newer
- Android Studio or VS Code with Flutter tooling
- Firebase CLI and FlutterFire CLI when Firebase setup is required

## Setup

Install dependencies:

```bash
flutter pub get
```

Run without Firebase keys:

```bash
flutter run
```

Firebase is disabled by default so the app can run before real project keys are
available.

## Firebase Setup

When a Firebase project is ready, configure it with FlutterFire:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates a real `lib/firebase_options.dart`. After that, run with:

```bash
flutter run --dart-define=ENABLE_FIREBASE=true
```

## Environment Defines

Supported compile-time values:

```bash
--dart-define=APP_ENV=development
--dart-define=ENABLE_FIREBASE=false
--dart-define=OPENWEATHER_API_KEY=your_key
--dart-define=AGMARKNET_BASE_URL=your_url
```

## Architecture

```text
lib/
  app/
  core/
  di/
  models/
  services/
  repositories/
  providers/
  widgets/
assets/
  images/
  icons/
  translations/
  models/
```

The next phase should add authentication services, repositories, providers, and
screens while preserving this structure.
