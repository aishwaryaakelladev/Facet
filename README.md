# Facet — Server-Driven UI iOS App

A production-quality iOS app built around the **Server-Driven UI (SDUI)** pattern — the same architecture used by Airbnb, DoorDash, and Spotify to ship UI changes without App Store releases.

> Built with SwiftUI · Clean Architecture · SOLID Principles · Zero third-party dependencies

---

## What is Server-Driven UI?

In a traditional iOS app the layout is hardcoded. In an SDUI app the **server decides what to render** — it sends a JSON payload describing which components to show and in what order. The app is a pure renderer.

```
Server JSON  ──▶  Component Registry  ──▶  SwiftUI Views
   (what)              (how to map)            (render)
```

Changing the home screen requires only a backend JSON edit — **no App Store update, no review cycle**.

---

## Features

| Feature | Details |
|---|---|
| Server-Driven Layout | Home screen fully composed from JSON at runtime |
| 4 Component Types | Hero Banner, Horizontal Carousel, Article Card List, Quote Block |
| Interactive Detail Pages | Tap any component → full detail screen with share sheet |
| Pull-to-Refresh | Re-fetches layout from server on demand |
| Graceful Degradation | Unknown component types render `EmptyView` — app never crashes |
| Role-Based Login | End-user feed view vs. Admin dashboard |
| Admin Dashboard | Add / delete / reorder components, preview as end-user |
| Publish to Gist | Admin PATCHes GitHub Gist via API — end users see changes instantly |
| Zero dependencies | No CocoaPods, no SPM packages — pure Swift + SwiftUI |

---

## Architecture

```
Facet/
├── App/
│   ├── FacetApp.swift          # @main — injects SessionStore + NavigationRouter
│   ├── SessionStore.swift      # Auth state (EnvironmentObject)
│   └── AppConfiguration.swift  # Gist URL configuration
│
├── Domain/                     # Pure Swift — no UIKit/SwiftUI imports
│   ├── Models/
│   │   ├── ScreenLayout.swift  # ComponentItem + ScreenLayout
│   │   ├── ComponentPayload.swift  # Typed enum for each component
│   │   └── AuthUser.swift      # UserRole enum + AuthUser struct
│   ├── UseCases/
│   │   ├── FetchScreenUseCase.swift
│   │   └── LoginUseCase.swift
│   └── Repositories/
│       ├── ScreenRepositoryProtocol.swift
│       └── AuthRepositoryProtocol.swift
│
├── Data/
│   ├── DTOs/
│   │   └── ScreenLayoutDTO.swift   # Codable + polymorphic decoder
│   ├── Mappers/
│   │   └── ScreenLayoutMapper.swift
│   ├── Network/
│   │   └── NetworkService.swift
│   ├── Repositories/
│   │   └── RemoteScreenRepository.swift  # + MockScreenRepository
│   ├── Auth/
│   │   └── LocalAuthRepository.swift
│   └── Gist/
│       └── GistUpdateService.swift  # GitHub Gist PATCH API
│
└── Presentation/
    ├── Navigation/
    │   ├── NavigationRouter.swift   # NavigationPath wrapper
    │   └── AppDestination.swift     # Hashable destination enum
    ├── Screen/
    │   ├── ScreenView.swift
    │   └── ScreenViewModel.swift
    ├── ComponentRenderer.swift      # Open/Closed — switch on payload type
    ├── Components/
    │   ├── HeroBannerView.swift
    │   ├── HorizontalCarouselView.swift
    │   ├── CardListView.swift
    │   └── QuoteBlockView.swift
    ├── Detail/
    │   └── ComponentDetailView.swift
    ├── Auth/
    │   ├── LoginView.swift
    │   └── LoginViewModel.swift
    └── Admin/
        ├── AdminDashboardView.swift
        ├── AdminDashboardViewModel.swift
        ├── AddComponentView.swift
        └── AdminSettingsView.swift
```

### SOLID Principles Applied

| Principle | Implementation |
|---|---|
| **S** — Single Responsibility | Each `ComponentView` renders exactly one component type |
| **O** — Open/Closed | `ComponentRenderer` switches on payload type — add a new component by adding a new case + view only |
| **L** — Liskov Substitution | `MockScreenRepository` substitutes `RemoteScreenRepository` transparently in tests and previews |
| **I** — Interface Segregation | `FetchScreenUseCaseProtocol` is a narrow single-method protocol |
| **D** — Dependency Inversion | `ScreenViewModel` depends on `FetchScreenUseCaseProtocol`, never on a concrete class |

---

## How It Works

### The JSON Schema

The server returns a `ScreenLayout` describing an ordered list of components:

```json
{
  "screenId": "home",
  "title": "Good Morning",
  "components": [
    {
      "id": "c1",
      "type": "hero_banner",
      "data": {
        "imageUrl": "https://...",
        "headline": "Tuesday Digest",
        "subtitle": "5 things to know today"
      }
    },
    {
      "id": "c2",
      "type": "quote_block",
      "data": {
        "quote": "Design is how it works.",
        "author": "Steve Jobs"
      }
    }
  ]
}
```

### Polymorphic Decoding

`ComponentDTO` uses a custom `Decodable` init to decode `data` into the correct concrete type based on `type`:

```swift
switch type {
case "hero_banner":   data = try container.decode(HeroBannerDTO.self, forKey: .data)
case "quote_block":   data = try container.decode(QuoteDTO.self, forKey: .data)
default:              data = UnknownComponentDTO()  // graceful degradation
}
```

### Navigation

Tapping any component pushes a typed destination onto `NavigationPath`:

```
Tap card  →  router.push(.articleDetail(card))
          →  NavigationStack fires navigationDestination
          →  ComponentDetailView renders the right page
          →  Back button pops automatically
```

---

## User Roles

| Role | Credentials | Experience |
|---|---|---|
| End User | `user` / `user123` | Content feed with interactive components |
| Admin | `admin` / `admin123` | Dashboard to add/edit/publish content |

### Admin Publish Flow

1. Login as `admin` / `admin123`
2. Tap **gear icon** → enter your GitHub Gist ID and Personal Access Token
3. Load existing content from your Gist automatically
4. Tap **+** to add Articles, Quotes, or Banners
5. Swipe to delete · drag to reorder
6. Tap **eye** to preview exactly what end users will see
7. Tap **Publish** → JSON is `PATCH`ed to GitHub Gist via API
8. End users see changes on next pull-to-refresh — **no App Store release needed**

---

## Setup

### 1. Clone & Open

```bash
git clone https://github.com/aishwaryaakelladev/Facet.git
cd Facet
open Facet.xcodeproj
```

### 2. Host the JSON (free, 2 minutes)

1. Go to [gist.github.com](https://gist.github.com)
2. Create a new public gist, filename `home.json`, paste contents of `Facet/home.json`
3. Click **Raw** → copy the URL
4. Open `App/AppConfiguration.swift` and replace the placeholder URL

### 3. Run

Select any iOS Simulator → **Cmd+R**

> In `DEBUG` builds the app uses `MockScreenRepository` — no Gist URL needed to run locally.

---

## Tech Stack

- **Language:** Swift 6
- **UI:** SwiftUI
- **Architecture:** Clean Architecture + MVVM
- **Navigation:** `NavigationStack` with typed `NavigationPath`
- **Networking:** `async/await` + `URLSession`
- **Persistence:** `AppStorage` (UserDefaults) for admin credentials
- **Backend:** GitHub Gist (free, versioned, CDN-backed)
- **Dependencies:** None

---

## Requirements

- iOS 17.0+
- Xcode 16+
- Swift 6

---

## License

MIT
