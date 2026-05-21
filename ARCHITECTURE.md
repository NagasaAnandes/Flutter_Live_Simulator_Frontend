## Flutter Live Commerce Simulator - Architecture Foundation

### Overview

This is a **realtime-centric, overlay-driven** mobile application architecture designed for livestream commerce. The architecture prioritizes socket synchronization, feature modularity, and production-grade scalability.

---

## Architecture Layers

### 🏗️ Core Layer (`lib/core/`)

The foundation of the application. Contains infrastructure, configuration, and cross-cutting concerns.

#### Responsibilities:

- **Infrastructure**: Socket service, dependency injection, routing
- **Configuration**: Theme, constants, app configuration
- **Utilities**: Helper functions, formatters, logging

#### Key Components:

```
core/
├── constants/          # App-wide constants, magic numbers
├── dependency_injection/ # GetIt service locator setup
├── router/            # GoRouter configuration & routes
├── services/          # Core application services
├── socket/            # Socket.IO service for realtime
├── theme/             # Dark livestream UI theme
└── utils/             # Utility functions, formatters, loggers
```

---

### 🔗 Shared Layer (`lib/shared/`)

Reusable components and models that are NOT feature-specific.

#### Responsibilities:

- **Models**: Common data structures used across features
- **Widgets**: Reusable UI components (AppBar, Loader, Error states)
- **Animations**: Shared animation configurations
- **Enums**: Common enumerations (UserRole, ConnectionStatus, etc.)

#### Key Components:

```
shared/
├── animations/   # Shared animation utilities
├── models/       # Common data models (RoomSnapshot, Overlays, etc.)
├── widgets/      # Reusable UI components
└── enums/        # Shared enumerations
```

**Important**: Put something in shared only if it's used by 2+ features. Otherwise, keep it feature-local.

---

### ⚙️ Features Layer (`lib/features/`)

Feature-oriented modules. Each feature is independent and self-contained.

#### Responsibilities:

- **Bloc/Cubit**: State management and business logic
- **Repository**: Data access abstraction
- **Models**: Feature-specific data structures
- **Screens**: Feature UI entry points
- **Widgets**: Feature-specific UI components

#### Architecture Pattern:

```
feature/
├── bloc/           # BLoCs for feature orchestration (socket sync)
├── cubit/          # Cubits for local UI state
├── models/         # Feature-specific data models
├── repository/     # Data access layer
├── screens/        # UI screens (entry points)
├── widgets/        # Reusable feature widgets
└── overlay/        # Overlay display (recorder only)
```

#### State Management Philosophy:

- **BLoC**: Used for features that need realtime socket synchronization
  - Examples: RoomBloc, OperatorBloc, CommenterBloc
  - Responsible for listening to socket events
  - Orchestrates feature state across the app

- **Cubit**: Used for simple local UI state
  - Examples: RecorderCubit
  - Manages local interactions (start/stop recording)
  - No external dependencies or socket sync

#### Implemented Features:

1. **Room Feature** (`features/room/`)
   - Manages live session state
   - Socket synchronization for room updates
   - Viewer count, stream status, etc.

2. **Recorder Feature** (`features/recorder/`)
   - Local recording state management
   - Recording controls (start, pause, stop)
   - NOT responsible for socket sync

3. **Operator Feature** (`features/operator/`)
   - Operator control panel state
   - Realtime operator updates via socket

4. **Commenter Feature** (`features/commenter/`)
   - Comment management
   - Real-time comment synchronization
   - Comment feed state

5. **Overlay Feature** (`features/overlay/`)
   - Product overlays
   - Discount overlays
   - Comment overlays
   - Animated overlay display

---

## Dependency Injection

### Setup Location

`core/dependency_injection/injection.dart`

### Registration Pattern

```dart
// Services (singletons)
getIt.registerSingleton<SocketService>(SocketService());

// Repositories
getIt.registerSingleton<RoomRepository>(
  RoomRepository(socketService: getIt<SocketService>())
);

// BLoCs
getIt.registerSingleton<RoomBloc>(
  RoomBloc(repository: getIt<RoomRepository>())
);

// Cubits
getIt.registerSingleton<RecorderCubit>(RecorderCubit());
```

### Access Anywhere

```dart
final socketService = getIt<SocketService>();
```

---

## Socket Architecture

### SocketService (`core/socket/socket_service.dart`)

The central hub for realtime communication.

**Responsibilities:**

- Connection lifecycle management
- Emit/listen to socket events
- Reconnection logic
- Connection state tracking

**NOT Responsible For:**

- Business event handling (delegated to BLoCs)
- State management (delegated to BLoCs/Cubits)

**Usage Pattern:**

```dart
// In BLoC event handlers:
_socketService.on('room:updated', (data) {
  add(UpdateRoomEvent(data));
});

_socketService.emit('room:join', {'roomId': roomId});
```

---

## Router Configuration

### Location

`core/router/app_router.dart`

### Route Definition

```dart
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', name: 'home', builder: ...),
    GoRoute(path: '/recorder', name: 'recorder', builder: ...),
    // ...
  ],
);
```

### Navigation

```dart
context.go('/recorder');
context.pushNamed('operator');
```

---

## Theme System

### Location

`core/theme/app_theme.dart`

### Features:

- Dark livestream commerce aesthetic
- Clean, modern typography
- Material 3 support
- Consistent color palette
- Button and input styling

### Usage

```dart
MaterialApp(
  theme: AppTheme.dark,
)
```

---

## Data Persistence

### Hive Storage

- Used for offline-first architecture
- Local user preferences
- Cached data
- Initialized in `main.dart`

### Access

```dart
final box = Hive.box(AppConstants.hiveBoxName);
box.put('key', value);
```

---

## Code Organization Principles

### ✅ DO:

- Keep features independent
- Use BLoC for socket-synchronized state
- Use Cubit for simple local state
- Put shared code in `shared/` layer
- Follow feature-oriented structure
- Use strong typing everywhere
- Create meaningful abstractions

### ❌ DON'T:

- Create god files (put everything in one file)
- Mix business logic with UI
- Create unnecessary abstractions
- Put feature-specific code in shared/
- Hardcode values (use constants)
- Ignore error handling
- Create circular dependencies

---

## Project Structure at a Glance

```
lib/
├── core/                    # Infrastructure & configuration
│   ├── constants/
│   ├── dependency_injection/
│   ├── router/
│   ├── services/
│   ├── socket/
│   ├── theme/
│   └── utils/
│
├── shared/                  # Reusable, non-feature-specific
│   ├── animations/
│   ├── models/
│   ├── widgets/
│   └── enums/
│
├── features/                # Feature modules
│   ├── room/
│   ├── recorder/
│   ├── operator/
│   ├── commenter/
│   └── overlay/
│
└── main.dart               # App entry point
```

---

## Next Steps (Phase 1+)

1. **Implement Business Logic** - Add actual socket event handlers in BLoCs
2. **Connect UI** - Replace placeholder screens with real UI
3. **Integrate Camera** - Implement camera functionality in recorder
4. **Add Animations** - Implement flutter_animate for overlays
5. **Realtime Synchronization** - Connect socket events to state updates
6. **Testing** - Add unit, widget, and integration tests

---

## Best Practices

### BLoC Development

```dart
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc(this._repository, this._socketService) : super(const RoomInitial()) {
    on<JoinRoomEvent>(_onJoinRoom);
  }

  Future<void> _onJoinRoom(JoinRoomEvent event, Emitter<RoomState> emit) async {
    emit(const RoomLoading());
    try {
      await _repository.joinRoom(event.roomId);
      _setupSocketListeners();
      emit(RoomJoined(event.roomId));
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }
}
```

### Error Handling

```dart
try {
  // operation
} on SocketException {
  // handle socket error
} on NetworkException {
  // handle network error
} catch (e) {
  Logger.error('Unexpected error: $e', StackTrace.current);
}
```

### Type Safety

- Always use strong typing
- Avoid `dynamic` types
- Use sealed classes for state hierarchies
- Use enums for fixed values

---

## Support Files Generated

- ✅ App Theme (dark livestream commerce UI)
- ✅ Socket Service Foundation
- ✅ Router Configuration
- ✅ Dependency Injection Setup
- ✅ Shared Models (RoomSnapshot, Overlays, Comments)
- ✅ Feature Stubs (Room, Recorder, Operator, Commenter, Overlay)
- ✅ BLoCs & Cubits Scaffolding
- ✅ Bootstrap Configuration in main.dart

All files include comprehensive documentation and are production-ready for implementation.
