# Dev News

> A modern tech news client featuring real-time feeds, offline caching, and native article reading.

Dev News delivers the latest programming and developer community discussions directly to mobile devices. Built to consume the Lobste.rs API, the app pairs clean dark-mode typography with offline resilience. Articles fetched from the remote server are cached locally to ensure readers retain full access to community posts even with intermittent or zero internet connectivity.

## Features

- **Live Tech Feed** — streams newest articles from Lobste.rs REST endpoint with custom timeout handling.
- **Offline-First Reading** — caches articles into local device storage using SharedPreferences with automatic cache fallbacks.
- **Connection Status Indicator** — visual warning banner alerting readers when viewing cached offline content.
- **Custom Particle Loading** — interactive particle sphere rendering during network fetch operations.
- **Article Reader & External Launcher** — detailed post screens with metadata, topic tag chips, and external browser link opening.
- **Pull-to-Refresh** — native swipe gesture to synchronize the latest community feed.

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter ^3.12.2 |
| State management | Provider ^6.1.1 |
| Local storage | SharedPreferences ^2.2.2 |
| Backend | REST API (Lobste.rs API via http ^1.6.0) |
| Other | url_launcher ^6.2.5 |

## Screenshots

> 📸 Screenshots coming soon.

## Architecture

```
lib/
├── main.dart                       # App entry point, ChangeNotifierProvider root & feed UI
├── models/
│   └── post.dart                   # Post model with JSON serialization & parsing
├── providers/
│   └── post_provider.dart          # State orchestration, network requests & cache sync
├── screens/
│   └── post_detail_screen.dart     # Article detail view with tag chips & link handler
├── services/
│   ├── api_service.dart            # Lobste.rs REST client & HTTP parsing
│   └── cache_service.dart          # Local JSON persistence via SharedPreferences
├── utils/
│   └── time_ago.dart               # Human-readable relative timestamp formatter
└── widgets/
    └── particle_sphere.dart        # Custom interactive loading visualization
```

The codebase uses a clean separation of concerns with a provider-driven architecture. Network operations (`api_service.dart`) and disk persistence (`cache_service.dart`) are isolated behind dedicated service abstractions, managed by `PostProvider` to expose clean state flags (`isLoading`, `errorMessage`, `isShowingCachedData`) to the UI layer.

## How to run

### Prerequisites

- Flutter >=3.12.2
- Dart SDK >=3.12.2

### Setup

```bash
git clone https://github.com/elham-THEsecond/dev-news.git
cd dev-news
flutter pub get
flutter run
```



## License

MIT — see [LICENSE](LICENSE).
