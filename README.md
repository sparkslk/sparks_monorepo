<img src = ".\apps\frontend\assets\logowhite.png" class="logo" width="120" title="Sparks"/>
# Sparks Monorepo

A full-stack ADHD management mobile application built with **Flutter (frontend)** and **Dart (backend with PostgreSQL)**, organized as a Dart/Flutter monorepo.
This repository demonstrates a scalable, maintainable approach for modern cross-platform app development with a shared codebase.

---

## Project Structure

```
sparks_monorepo/
├── apps/
│   └── frontend/      # Flutter mobile app
├── packages/
│   ├── backend/       # Dart backend server (Shelf + PostgreSQL)
│   └── shared/        # Shared Dart models & code
├── melos.yaml         # Monorepo configuration
└── README.md
```


---

## Features

- Modern Flutter mobile UI
- Dart backend API (Shelf) with PostgreSQL integration
- Shared Dart package for models and DTOs
- Secure password hashing
- RESTful API endpoints for authentication
- Monorepo structure using [melos](https://pub.dev/packages/melos)

---

## Getting Started

### 1. Prerequisites

- [Dart SDK](https://dart.dev/get-dart)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [PostgreSQL](https://www.postgresql.org/)
- [Melos](https://pub.dev/packages/melos):

```sh
dart pub global activate melos
```


### 2. Clone the Repository

```sh
git clone <your-repo-url>
cd sparks_monorepo
```


### 3. Bootstrap the Monorepo

```sh
melos bootstrap
```


---

## Backend Setup

### 1. Configure PostgreSQL

- Ensure PostgreSQL is running and accessible.

- Update database credentials in `packages/backend/lib/handlers.dart` if needed.


### 2. Run the Backend Server

```sh
cd packages/backend
dart run bin/server.dart
```

- By default, the backend listens on port `8080`.
- Endpoints: (Examples)
    - `POST /api/auth/register` — User registration
    - `POST /api/auth/login` — User login

---

## Frontend Setup

### 1. Run the Flutter App

```sh
cd apps/frontend
flutter pub get
flutter run
```

- Make sure the API base URL in your Flutter app matches your backend server address and port.
    - For Android emulator: use `http://10.0.2.2:8080`
    - For physical device: use your PC's LAN IP (e.g., `http://192.168.1.100:8080`)
    - For deployed backend: use your server's public IP


### 2. Assets

- Place your logo and feature icons in `apps/frontend/assets/` and declare them in `pubspec.yaml`.

---

## Shared Package

- Contains Dart models (e.g., `User`) used by both frontend and backend.
- Located in `packages/shared`.

---

## Development Tips

- Use the **Project** view in Android Studio or VS Code to see the full monorepo structure.
- For local backend access from an emulator, always use `10.0.2.2` as the host.
- Check backend logs for errors during development.
- Use Postman to test API endpoints independently.