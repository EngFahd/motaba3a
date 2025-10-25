# BLoC Architecture Guide - Motaba3a

This document explains the **BLoC (Business Logic Component)** architecture implementation using **Cubit** in the Motaba3a app.

## 📚 Table of Contents

- [Why BLoC?](#why-bloc)
- [Architecture Overview](#architecture-overview)
- [Folder Structure](#folder-structure)
- [Core Concepts](#core-concepts)
- [Implementation Guide](#implementation-guide)
- [Best Practices](#best-practices)
- [Testing](#testing)

---

## Why BLoC?

**BLoC/Cubit** offers several advantages over Provider:

✅ **Predictable State Management**: Every state change is explicit and traceable  
✅ **Better Testability**: Cubits are easy to test without widgets  
✅ **Separation of Concerns**: Clear boundary between UI and business logic  
✅ **Time-Travel Debugging**: Can replay state changes with BLoC Observer  
✅ **Stream-Based**: Built on Dart Streams for reactive programming  

---

## Architecture Overview

```
┌──────────────┐
│     View     │  ← UI Layer (Flutter Widgets)
│   (Widget)   │
└──────┬───────┘
       │ Emits Events / Reads State
       │
┌──────▼───────┐
│    Cubit     │  ← Business Logic Layer
│   (State     │     - Processes actions
│  Management) │     - Emits new states
└──────┬───────┘
       │ Calls methods
       │
┌──────▼───────┐
│  Repository  │  ← Data Layer
│              │     - Firebase operations
│              │     - API calls
└──────┬───────┘
       │
┌──────▼───────┐
│   Firebase   │  ← Backend Services
└──────────────┘
```

---

## Folder Structure

```
lib/
├── cubits/              # BLoC/Cubit layer
│   ├── auth/
│   │   ├── auth_cubit.dart     # Authentication logic
│   │   └── auth_state.dart     # Auth states
│   └── service/
│       ├── service_cubit.dart  # Service request logic
│       └── service_state.dart  # Service states
│
├── models/              # Data models
├── repositories/        # Data access layer
├── views/              # UI screens
├── widgets/            # Reusable widgets
└── main.dart          # App entry with BlocProviders
```

---

## Core Concepts

### 1. **Cubit**

A simplified version of BLoC that emits new states in response to method calls.

```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthInitial());

  final AuthRepository _authRepository;

  // Method that changes state
  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());  // Emit loading state
    
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      emit(AuthAuthenticated(user));  // Emit success state
    } catch (e) {
      emit(AuthError(e.toString()));  // Emit error state
    }
  }
}
```

### 2. **State**

Immutable classes representing different UI states. Uses `Equatable` for comparison.

```dart
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

### 3. **BlocProvider**

Provides Cubit instances to the widget tree using dependency injection.

```dart
BlocProvider(
  create: (_) => AuthCubit(authRepository),
  child: MyApp(),
)
```

### 4. **BlocBuilder**

Rebuilds UI when state changes.

```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    if (state is AuthAuthenticated) {
      return Text('Welcome ${state.user.name}');
    }
    return LoginForm();
  },
)
```

### 5. **BlocConsumer**

Combines `BlocBuilder` + `BlocListener` for both UI updates and side effects.

```dart
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    // Side effects (navigation, snackbars, etc.)
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    // UI building
    return LoginView(isLoading: state is AuthLoading);
  },
)
```

---

## Implementation Guide

### Step 1: Define States

Create a state file for each feature:

```dart
// lib/cubits/auth/auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
```

### Step 2: Create Cubit

```dart
// lib/cubits/auth/auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }
}
```

### Step 3: Provide Cubit

```dart
// main.dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AuthCubit(authRepository)),
    BlocProvider(create: (_) => ServiceCubit(serviceRepository)),
  ],
  child: MyApp(),
)
```

### Step 4: Use in UI

```dart
// lib/views/login_view.dart
class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return LoginForm(
          isLoading: state is AuthLoading,
          onSubmit: (email, password) {
            context.read<AuthCubit>().signIn(email, password);
          },
        );
      },
    );
  }
}
```

---

## Best Practices

### 1. **Keep Cubits Thin**

Business logic should be minimal. Heavy logic goes in repositories or services.

```dart
// ❌ Bad - Too much logic in Cubit
class ServiceCubit extends Cubit<ServiceState> {
  Future<void> createRequest(ServiceRequestModel request) async {
    // Validating, transforming, formatting... (too much!)
    if (request.price < 0) { /* validation */ }
    final formattedRequest = /* heavy transformation */;
    await _repository.create(formattedRequest);
  }
}

// ✅ Good - Logic in repository/service
class ServiceCubit extends Cubit<ServiceState> {
  Future<void> createRequest(ServiceRequestModel request) async {
    emit(const ServiceLoading());
    try {
      await _repository.createRequest(request);  // Repository handles logic
      emit(const ServiceSuccess());
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }
}
```

### 2. **Use Equatable for State Comparison**

Prevents unnecessary rebuilds:

```dart
class ServiceLoaded extends ServiceState {
  final List<ServiceRequestModel> requests;
  
  const ServiceLoaded(this.requests);
  
  @override
  List<Object?> get props => [requests];  // Compares lists
}
```

### 3. **Handle Loading States Properly**

Always show loading indicators:

```dart
BlocBuilder<ServiceCubit, ServiceState>(
  builder: (context, state) {
    if (state is ServiceLoading) {
      return CircularProgressIndicator();
    }
    if (state is ServiceLoaded) {
      return ListView(children: state.requests.map(...));
    }
    return SizedBox();
  },
)
```

### 4. **Cancel Subscriptions**

Always cancel streams in `close()`:

```dart
class ServiceCubit extends Cubit<ServiceState> {
  StreamSubscription? _subscription;

  void loadRequests() {
    _subscription = _repository.getRequests().listen((requests) {
      emit(ServiceLoaded(requests));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### 5. **Separate State from Events**

Don't mix success/error states with loaded states:

```dart
// ❌ Bad
class ServiceState {
  final List<Request> requests;
  final String? errorMessage;
  final String? successMessage;
}

// ✅ Good - Separate states
abstract class ServiceState {}
class ServiceLoaded extends ServiceState {
  final List<Request> requests;
}
class ServiceError extends ServiceState {
  final String message;
}
class ServiceOperationSuccess extends ServiceState {
  final String message;
}
```

---

## Testing

### Unit Testing Cubits

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthCubit', () {
    late AuthCubit authCubit;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      authCubit = AuthCubit(mockRepository);
    });

    tearDown(() {
      authCubit.close();
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
      build: () {
        when(mockRepository.signInWithEmail(any, any))
            .thenAnswer((_) async => mockUser);
        return authCubit;
      },
      act: (cubit) => cubit.signIn('test@test.com', 'password'),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(mockUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(mockRepository.signInWithEmail(any, any))
            .thenThrow(Exception('Login failed'));
        return authCubit;
      },
      act: (cubit) => cubit.signIn('test@test.com', 'wrong'),
      expect: () => [
        const AuthLoading(),
        const AuthError('Exception: Login failed'),
      ],
    );
  });
}
```

### Widget Testing with BLoC

```dart
testWidgets('shows loading indicator when AuthLoading', (tester) async {
  final mockCubit = MockAuthCubit();
  when(mockCubit.state).thenReturn(const AuthLoading());

  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: mockCubit,
      child: MaterialApp(home: LoginView()),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

## Debugging

### BlocObserver

Track all state changes globally:

```dart
// lib/utils/simple_bloc_observer.dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

// main.dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}
```

---

## Migration from Provider

If migrating from Provider:

| Provider | BLoC/Cubit |
|----------|------------|
| `ChangeNotifier` | `Cubit<State>` |
| `notifyListeners()` | `emit(newState)` |
| `Consumer<ViewModel>` | `BlocBuilder<Cubit, State>` |
| `Provider.of<T>(context)` | `context.read<Cubit>()` |
| `context.watch<T>()` | `context.watch<Cubit>().state` |

---

## Resources

- **Official Docs**: https://bloclibrary.dev
- **Flutter BLoC Package**: https://pub.dev/packages/flutter_bloc
- **Equatable**: https://pub.dev/packages/equatable
- **Bloc Test**: https://pub.dev/packages/bloc_test

---

**Happy Coding with BLoC! 🚀**


