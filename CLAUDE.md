# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Near Social Multiplatform is a Flutter client for the NEAR Social decentralized social network. It supports iOS, Android, and Web platforms.

**Web preview:** https://near-social-mobile-777.web.app

## Build Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (required after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Development
flutter run                    # Run on connected device
flutter run -d chrome          # Run on web

# Production builds
flutter build web --web-renderer html --release    # Web
flutter build apk --obfuscate --split-debug-info=debug_info  # Android
flutter build ios --release    # iOS

# Analysis
flutter analyze
flutter test
```

## Architecture

### Modular Structure (flutter_modular)

```
AppModule (root)
├── CoreModule (global DI: blockchain service, auth, crypto, repositories)
├── AuthModule (/auth) - QR code login, encryption setup
└── HomeModule (/home) - Protected by AuthGuard
    ├── Posts feed, Widgets, Users, Notifications
    ├── Key Manager, Settings, Mintbase NFT Manager
    └── Controllers: PostsController, UserListController, etc.
```

### State Management

Uses **RxDart BehaviorSubject** pattern:
```dart
class SomeController extends Disposable {
  final BehaviorSubject<State> _streamController = BehaviorSubject.seeded(State());
  Stream<State> get stream => _streamController.stream.distinct();
  State get state => _streamController.value;
}
```

### Data Layer

Repository pattern with pluggable implementations:
- `UserDataRepository` (abstract) → `LocalUserDataRepository` (decentralized, uses FlutterSecureStorage)
- Models use `json_serializable` for code generation (`.g.dart` files)
- Models use `Equatable` for value equality

### Routing

Routes defined in `lib/routes/routes.dart`. Navigation via `Modular.to.pushNamed()`.

Key routes: `/auth/qr_reader`, `/home/posts_feed`, `/home/profile?accountId=`, `/home/widget`, `/home/settings`

## Key Files

| Path | Purpose |
|------|---------|
| `lib/modules/app_module.dart` | Root module, top-level routes |
| `lib/modules/core_module.dart` | Global dependency injection |
| `lib/modules/home/home_module.dart` | Home feature routes and bindings |
| `lib/modules/vms/core/auth_controller.dart` | Authentication state |
| `lib/modules/home/apis/near_social.dart` | NEAR Social API client |
| `lib/routes/routes.dart` | Named route definitions |
| `lib/config/theme.dart` | NEARColors, app theme |
| `lib/config/constants.dart` | StorageKeys, NearUrls |
| `lib/data/repositories/` | Data abstraction layer |

## Network

- HTTP client: **Dio** with smart retry interceptors
- Primary RPC: `https://free.rpc.fastnear.com/`
- NEAR Social API: `https://api.near.social`
- Custom retry logic in `lib/network/` with failover support

## Security

- All sensitive data encrypted via `FlutterSecureStorage`
- Platform-specific crypto runners (JS for web, native for mobile)
- Biometric authentication via `local_auth`
- Jailbreak detection utilities

## Key Dependencies

- `flutter_modular` - Routing and DI
- `rxdart` - Reactive state streams
- `flutterchain` (git) - NEAR blockchain integration
- `near_wallet_selector` (git) - Wallet connection
- `dio` + `dio_smart_retry` - HTTP with retry
- `flutter_secure_storage` - Encrypted storage
- `json_serializable` - Model code generation
- `easy_localization` - i18n (English only currently)
- `flutter_screenutil` - Responsive UI

## Decentralization Approach

The app operates in decentralized mode:
- No backend server required
- Data stored locally in encrypted storage
- Authentication via signature verification (if user can sign, they own the account)
- Chat features currently disabled for decentralization focus
