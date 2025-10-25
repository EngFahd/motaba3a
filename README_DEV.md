# Mutabaa App - Developer Documentation

> **For Junior Flutter Developers**  
> This document provides complete setup instructions, architecture guidelines, and development rules for the Mutabaa project.

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Setup Instructions](#setup-instructions)
3. [Architecture (MVVM with BLoC)](#architecture-mvvm-with-bloc)
4. [Folder Structure](#folder-structure)
5. [Firebase Setup](#firebase-setup)
6. [Development Rules](#development-rules)
7. [Code Guidelines](#code-guidelines)
8. [Performance Requirements](#performance-requirements)
9. [Testing](#testing)
10. [Deployment](#deployment)

---

## 🎯 Project Overview

**Mutabaa** is a car service management app built with Flutter that helps workshops manage service requests, track clients, and monitor vehicle repairs.

### Tech Stack
- **Framework:** Flutter (Stable Channel)
- **Language:** Dart
- **Architecture:** MVVM using BLoC/Cubit
- **Backend:** Firebase (Auth, Firestore, Storage, Analytics)
- **State Management:** flutter_bloc (Cubit pattern)
- **Design:** [Figma Design Link](https://www.figma.com/design/DGpf7fZQSVithcDl7jlhvd/MutabaaApp)

---

## 🚀 Setup Instructions

### Prerequisites

```bash
# Check Flutter installation
flutter doctor

# Required: Flutter 3.0+, Dart 3.0+
```

### Step 1: Clone & Install

```bash
# Navigate to project
cd /Users/gojo/Documents/Projects/motaba3a

# Install dependencies
flutter pub get

# Check for issues
flutter analyze
```

### Step 2: Firebase Configuration

1. **Download Firebase config files:**
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

2. **Or use FlutterFire CLI:**
```bash
# Install CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### Step 3: Run the App

```bash
# List devices
flutter devices

# Run on device
flutter run

# Or specify device
flutter run -d <device-id>
```

---

## 🏗️ Architecture (MVVM with BLoC)

This project uses **MVVM architecture** implemented with **BLoC/Cubit**:

```
┌──────────────────┐
│   View (UI)      │  ← Flutter Widgets (StatelessWidget preferred)
└────────┬─────────┘
         │ reads state & calls methods
┌────────▼─────────┐
│ ViewModel (Cubit)│  ← Business Logic + State Management
└────────┬─────────┘
         │ uses
┌────────▼─────────┐
│ Repository       │  ← Data abstraction layer
└────────┬─────────┘
         │ calls
┌────────▼─────────┐
│ Service          │  ← Firebase operations
└──────────────────┘
```

### Why BLoC/Cubit as ViewModel?

**BLoC/Cubit IS MVVM** - It's a modern, robust implementation of the ViewModel pattern:

- **View:** UI widgets (no logic)
- **ViewModel:** Cubit classes (business logic + state)
- **Model:** Data classes + Repositories + Services

**Advantages over traditional Provider:**
✅ More predictable state management  
✅ Better testability without UI  
✅ Clear state flow with Equatable  
✅ Industry standard for scalable apps  
✅ Time-travel debugging support  

---

## 📁 Folder Structure

```
lib/
├── core/                          # Core utilities & constants
│   ├── constants/
│   │   └── app_constants.dart     # Colors, styles, config
│   ├── utils/
│   │   └── validators.dart        # Form validators
│   └── widgets/                   # Reusable widgets (moved from widgets/)
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_overlay.dart
│       └── service_card.dart
│
├── data/                          # Data layer
│   ├── models/                    # Data models
│   │   ├── user_model.dart
│   │   ├── service_request_model.dart
│   │   └── vehicle_model.dart
│   ├── repositories/              # Data abstraction
│   │   ├── auth_repository.dart
│   │   └── service_repository.dart
│   └── services/                  # Firebase services
│       ├── auth_service.dart      # Firebase Auth
│       ├── firestore_service.dart # Cloud Firestore
│       ├── storage_service.dart   # Firebase Storage
│       └── analytics_service.dart # Firebase Analytics
│
├── ui/                            # UI layer
│   ├── viewmodels/                # Business logic (Cubits)
│   │   ├── auth/
│   │   │   ├── auth_cubit.dart
│   │   │   └── auth_state.dart
│   │   └── service/
│   │       ├── service_cubit.dart
│   │       └── service_state.dart
│   ├── views/                     # Screens
│   │   ├── login_view.dart
│   │   ├── home_view.dart
│   │   ├── search_view.dart
│   │   └── create_request_view.dart
│   └── routes/
│       └── app_routes.dart        # Navigation
│
└── main.dart                      # App entry point
```

---

## 🔥 Firebase Setup

### Required Services

| Service | Purpose | Status |
|---------|---------|--------|
| **Authentication** | User login/register | ✅ Implemented |
| **Cloud Firestore** | Data storage | ✅ Implemented |
| **Firebase Storage** | File uploads | ✅ Service ready |
| **Firebase Analytics** | Usage tracking | ✅ Service ready |

### Firestore Collections

```javascript
/users/{userId}
  - uid: string
  - name: string
  - phoneNumber: string
  - email: string
  - userType: "workshop" | "client"
  - createdAt: timestamp
  - updatedAt: timestamp

/service_requests/{requestId}
  - workshopId: string
  - clientId: string
  - clientName: string
  - clientPhone: string
  - vehicle: {make, model, year}
  - serviceTypes: array
  - price: number
  - entryDate: timestamp
  - exitDate: timestamp
  - status: "pending" | "inProgress" | "completed" | "cancelled"
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Service requests
    match /service_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.workshopId == request.auth.uid;
    }
  }
}
```

---

## 📝 Development Rules

### 1. Code Structure Rules

✅ **DO:**
- Keep each screen under 100 lines (extract to widgets)
- Use `const` constructors wherever possible
- Follow MVVM: View → ViewModel (Cubit) → Repository → Service
- Write small, reusable widgets in `core/widgets/`
- Use `BlocBuilder` or `BlocConsumer` in views
- Handle all Firebase logic in Service layer
- Create repositories to abstract data access

❌ **DON'T:**
- Put business logic in widgets
- Access Firebase directly from views
- Create large monolithic widgets
- Skip error handling

### 2. Naming Conventions

```dart
// Files: snake_case
auth_service.dart
user_model.dart

// Classes: UpperCamelCase
class AuthService {}
class UserModel {}

// Variables & functions: lowerCamelCase
String userName;
void signIn() {}

// Constants: lowerCamelCase
const primaryColor = Color(0xFF1455D4);

// Private: prefix with _
String _privateMethod() {}
```

### 3. Git Commit Rules

```bash
# Good commits:
git commit -m "feat: add user authentication"
git commit -m "fix: resolve login button crash"
git commit -m "refactor: extract service card widget"
git commit -m "docs: update README with setup steps"

# Prefixes: feat, fix, refactor, docs, test, chore
```

---

## 💻 Code Guidelines

### Creating a New Feature

**Example: Adding a new "Profile" feature**

#### Step 1: Create Model
```dart
// data/models/profile_model.dart
class ProfileModel {
  final String uid;
  final String name;
  final String bio;
  
  ProfileModel({required this.uid, required this.name, required this.bio});
  
  factory ProfileModel.fromMap(Map<String, dynamic> map) { ... }
  Map<String, dynamic> toMap() { ... }
}
```

#### Step 2: Create Repository
```dart
// data/repositories/profile_repository.dart
class ProfileRepository {
  final FirestoreService _firestoreService;
  
  ProfileRepository(this._firestoreService);
  
  Future<ProfileModel> getProfile(String uid) async {
    final doc = await _firestoreService.getDocument('users', uid);
    return ProfileModel.fromMap(doc.data()!);
  }
}
```

#### Step 3: Create Cubit & States
```dart
// ui/viewmodels/profile/profile_state.dart
abstract class ProfileState extends Equatable {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  ProfileLoaded(this.profile);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// ui/viewmodels/profile/profile_cubit.dart
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  
  ProfileCubit(this._repository) : super(ProfileInitial());
  
  Future<void> loadProfile(String uid) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile(uid);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
```

#### Step 4: Create View
```dart
// ui/views/profile_view.dart
class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return CircularProgressIndicator();
        }
        if (state is ProfileLoaded) {
          return Text(state.profile.name);
        }
        return SizedBox();
      },
    );
  }
}
```

---

## ⚡ Performance Requirements

### Must Meet:
- ✅ App opens in **under 2 seconds** on mid-range devices
- ✅ Smooth 60 FPS navigation
- ✅ No jank during scrolling
- ✅ Efficient list rendering with `ListView.builder`

### Optimization Checklist:
- [ ] Use `const` constructors for static widgets
- [ ] Implement lazy loading for data
- [ ] Optimize images before upload
- [ ] Use `RepaintBoundary` for complex widgets
- [ ] Profile with Flutter DevTools regularly
- [ ] Add Firestore indexes for queries
- [ ] Cache frequently accessed data

### Performance Tools:
```bash
# Run in profile mode
flutter run --profile

# Analyze performance
# Open DevTools in browser

# Check app size
flutter build apk --analyze-size
```

---

## 🧪 Testing

### Unit Tests (Cubits)
```dart
import 'package:bloc_test/bloc_test.dart';

blocTest<AuthCubit, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] on successful login',
  build: () => AuthCubit(mockRepository),
  act: (cubit) => cubit.signIn('test@test.com', 'password'),
  expect: () => [
    AuthLoading(),
    AuthAuthenticated(mockUser),
  ],
);
```

### Widget Tests
```dart
testWidgets('Login button shows loading spinner', (tester) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => mockAuthCubit,
      child: LoginView(),
    ),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Run Tests
```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/cubits/auth_cubit_test.dart
```

---

## 📦 Deployment

### Build Commands

**Android (APK):**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android (App Bundle - Recommended):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
flutter build ios --release
# Then open in Xcode and archive
```

### Pre-Deployment Checklist
- [ ] All `flutter analyze` issues fixed
- [ ] All tests passing
- [ ] Firebase Security Rules reviewed
- [ ] App tested on real devices (Android & iOS)
- [ ] Performance profiled and optimized
- [ ] Figma design match verified
- [ ] Error handling tested

---

## 🎨 Figma Design Rules

⚠️ **CRITICAL:** Do NOT modify the Figma design under any circumstance.

### Using Figma:
1. **Inspect Mode:** Get exact colors, spacing, fonts
2. **Export Assets:** Download icons/images as PNG or SVG
3. **Layout Reference:** Match component positions exactly
4. **Typography:** Use specified font sizes and weights

### When Unclear:
- Take a screenshot and ask for clarification
- Don't guess or improvise
- Document any design questions

---

## 📊 Analytics Events

Track key user actions:

```dart
// Login
analyticsService.logLogin('email');

// Service request created
analyticsService.logServiceRequestCreated(
  vehicleType: 'Toyota',
  price: 100.0,
);

// Screen views (automatic with observer)
analyticsService.logScreenView(screenName: 'Home');
```

---

## 🐛 Troubleshooting

### Common Issues:

**1. BLoC not found:**
```dart
// Solution: Wrap with BlocProvider
BlocProvider(
  create: (_) => AuthCubit(authRepository),
  child: MyWidget(),
)
```

**2. State not updating:**
```dart
// Solution: Implement Equatable props
@override
List<Object?> get props => [user, isLoading];
```

**3. Firebase not initialized:**
```dart
// Solution: Check main.dart
await Firebase.initializeApp();
```

---

## 📞 Support & Resources

- **BLoC Documentation:** https://bloclibrary.dev
- **Firebase Docs:** https://firebase.google.com/docs
- **Flutter Docs:** https://docs.flutter.dev
- **Project Figma:** [Design Link](https://www.figma.com/design/DGpf7fZQSVithcDl7jlhvd/MutabaaApp)

---

## ✅ Acceptance Criteria

Before marking feature as complete:

- [ ] UI matches Figma design 100%
- [ ] MVVM architecture followed (View → Cubit → Repository → Service)
- [ ] Firebase operations work correctly
- [ ] `flutter analyze` shows no errors
- [ ] Code is refactored into small widgets
- [ ] Performance is smooth (60 FPS)
- [ ] Error handling implemented
- [ ] Analytics events tracked
- [ ] Tests written (if applicable)

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Maintained By:** Development Team


