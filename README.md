# Motaba3a (متابعة) - Car Service Management App

A Flutter-based car service management application built with **MVVM architecture** using **BLoC/Cubit** and **Firebase** backend. This app helps workshop owners manage service requests, track clients, and monitor vehicle repairs efficiently.

## 📱 Features

- **Authentication**: Email/password login and registration
- **Service Management**: Create, view, and track service requests
- **Client Search**: Search clients by phone number
- **Real-time Updates**: Live data synchronization with Firestore
- **Offline Support**: Local caching with Hive
- **Arabic RTL Support**: Full right-to-left layout
- **BLoC State Management**: Predictable, testable state management

## 🏗️ Architecture

### MVVM with BLoC/Cubit

```
┌─────────────┐
│    View     │  ← UI Layer (Widgets)
└──────┬──────┘
       │
┌──────▼──────┐
│    Cubit    │  ← State Management (BLoC)
└──────┬──────┘
       │
┌──────▼──────┐
│ Repository  │  ← Data Layer (Firebase)
└──────┬──────┘
       │
┌──────▼──────┐
│   Firebase  │  ← Backend Services
└─────────────┘
```

### Folder Structure

```
lib/
├── cubits/           # BLoC/Cubit state management
│   ├── auth/         # Authentication cubit & states
│   └── service/      # Service request cubit & states
├── models/           # Data models (User, ServiceRequest, Vehicle)
├── views/            # UI screens (Login, Home, Search, CreateRequest)
├── repositories/     # Firebase operations (Auth, Firestore)
├── widgets/          # Reusable UI components
├── routes/           # Navigation and routing
├── utils/            # Constants, validators, helpers
└── main.dart         # App entry point with BlocProvider setup
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase project with:
  - Authentication enabled (Email/Password)
  - Cloud Firestore database
  - Firebase Storage (optional)
- iOS/Android development environment

### Quick Setup (15 minutes)

See **[SETUP_GUIDE.md](SETUP_GUIDE.md)** for detailed step-by-step instructions.

**Short version:**

```bash
# 1. Clone and install dependencies
cd /path/to/motaba3a
flutter pub get

# 2. Configure Firebase (download config files from Firebase Console)
# - Place google-services.json in android/app/
# - Place GoogleService-Info.plist in ios/Runner/

# 3. Run the app
flutter run
```

## 🔥 Firebase Configuration

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /service_requests/{requestId} {
      allow read: if request.auth != null && 
        (resource.data.workshopId == request.auth.uid || 
         resource.data.clientId == request.auth.uid);
      
      allow create: if request.auth != null && 
        request.resource.data.workshopId == request.auth.uid;
      
      allow update, delete: if request.auth != null && 
        resource.data.workshopId == request.auth.uid;
    }
  }
}
```

## 📦 Dependencies

### Core Dependencies

```yaml
# State Management
flutter_bloc: ^8.1.3
equatable: ^2.0.5

# Firebase
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.13.6
firebase_storage: ^11.5.6
firebase_messaging: ^14.7.9
firebase_analytics: ^10.7.4
firebase_remote_config: ^4.3.8

# Local Storage
hive: ^2.2.3
hive_flutter: ^1.1.0
shared_preferences: ^2.2.2

# Utilities
cached_network_image: ^3.3.0
intl: ^0.18.1
uuid: ^4.2.1
```

## 🎓 BLoC Architecture

This app uses **BLoC (Business Logic Component)** pattern with **Cubit** for state management.

### Why BLoC?

✅ **Predictable State**: Every state change is explicit  
✅ **Testable**: Easy to unit test without widgets  
✅ **Separation of Concerns**: Clear boundaries  
✅ **Reactive**: Built on Dart Streams  

### Key Concepts

**Cubit**: Simplified BLoC that emits states

```dart
class AuthCubit extends Cubit<AuthState> {
  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

**State**: Immutable classes representing UI states

```dart
abstract class AuthState extends Equatable {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
```

**UI Integration**: Using BlocConsumer

```dart
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    return LoginForm(isLoading: state is AuthLoading);
  },
)
```

📖 **Full Guide**: See [BLOC_ARCHITECTURE.md](BLOC_ARCHITECTURE.md) for complete documentation.

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/cubits/auth/auth_cubit_test.dart
```

### Testing Cubits

```dart
import 'package:bloc_test/bloc_test.dart';

blocTest<AuthCubit, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
  build: () => AuthCubit(mockRepository),
  act: (cubit) => cubit.signIn('test@test.com', 'password'),
  expect: () => [
    const AuthLoading(),
    AuthAuthenticated(mockUser),
  ],
);
```

## 🎨 Design Reference

The app design is available in Figma:
- **Link**: [Motaba3a Figma Design](https://www.figma.com/design/DGpf7fZQSVithcDl7jlhvd/MutabaaApp?node-id=11-2&t=ibISAQkdbr1ebrYG-1)
- **Note**: Do not edit the Figma file. Use it for reference and asset export only.

## 🔧 Development Workflow

### BLoC Best Practices

1. **States should be immutable**: Use `const` constructors and `copyWith` methods
2. **Use Equatable**: Prevent unnecessary rebuilds by properly implementing equality
3. **Keep Cubits thin**: Heavy logic belongs in repositories
4. **Cancel subscriptions**: Always override `close()` to clean up streams
5. **Separate concerns**: Each Cubit should handle one feature

### Code Style

```dart
// Good: Short comments explaining "why"
// Cancel subscription to prevent memory leaks
_subscription?.cancel();

// Bad: Comments explaining "what" (obvious from code)
// This cancels the subscription
_subscription?.cancel();
```

## 📊 Performance

### Optimizations

- ✅ `const` constructors for static widgets
- ✅ `ListView.builder` for efficient lists
- ✅ Real-time Firestore streams (no polling)
- ✅ Local caching with Hive
- ✅ Lazy loading of screens
- ✅ State comparison with Equatable

### Profiling

```bash
flutter run --profile
# Then use Flutter DevTools for analysis
```

## 🚢 Deployment

### Build for Production

**Android:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### CI/CD

See `.github/workflows/flutter.yml` for GitHub Actions setup.

## 🐛 Troubleshooting

### Common Issues

1. **BLoC not found**
   ```
   Solution: Ensure BlocProvider is above the widget using it
   ```

2. **State not updating**
   ```
   Solution: Check if Equatable props are implemented correctly
   ```

3. **Firebase not initialized**
   ```
   Solution: Verify Firebase.initializeApp() in main.dart
   ```

4. **Memory leaks**
   ```
   Solution: Cancel stream subscriptions in Cubit.close()
   ```

## 📚 Documentation

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Quick setup instructions
- [BLOC_ARCHITECTURE.md](BLOC_ARCHITECTURE.md) - Complete BLoC guide
- [Figma Design](https://www.figma.com/design/DGpf7fZQSVithcDl7jlhvd/MutabaaApp) - UI/UX reference

## 📄 License

[Add your license here]

## 👥 Contributors

- Junior Flutter Developer (following PRD guidelines)

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Review documentation files above

---

**Built with ❤️ using Flutter, BLoC, and Firebase**
# motaba3a
# motaba3a
# motaba3a
# motaba3a
