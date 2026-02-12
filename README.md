
![Free iPhone Air](https://github.com/user-attachments/assets/3412d9c3-d588-416d-ac57-e00bbc96fc15)

# MangaVault

A feature-rich iOS application for manga enthusiasts to discover, track, and manage their manga collections. Built with SwiftUI and modern Apple frameworks.

![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![iOS](https://img.shields.io/badge/iOS-17.0+-green)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-purple)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technologies](#technologies)
- [Project Structure](#project-structure)
- [Key Implementation Details](#key-implementation-details)
- [Getting Started](#getting-started)
- [API Reference](#api-reference)
- [Author](#author)

---

## Overview

MangaVault is a comprehensive manga collection management app that connects to a cloud-based API to provide users with access to an extensive manga database. Users can browse thousands of manga titles, search with advanced filters, track their personal collections, and receive AI-powered reading recommendations.

### Highlights

- **Extensive Manga Database** - Browse and search thousands of manga titles
- **Personal Collection Management** - Track owned volumes and reading progress
- **Cloud Synchronization** - Collections sync across devices with offline support
- **AI-Powered Insights** - Get personalized reader profiles using Apple Intelligence
- **Home Screen Widgets** - Quick access to currently reading manga
- **Universal App** - Optimized layouts for both iPhone and iPad

---

## Features

### Manga Discovery

| Feature | Description |
|---------|-------------|
| **Browse Catalog** | Paginated list of all manga with infinite scroll |
| **Best Manga** | Curated carousel of top-rated titles |
| **Advanced Search** | Filter by genre, theme, demographic, author, and title |
| **Author Directory** | Browse authors and view their complete works |
| **Detailed Information** | View synopsis, scores, status, volumes, and more |

### Collection Management

| Feature | Description |
|---------|-------------|
| **Track Ownership** | Mark individual volumes as owned |
| **Reading Progress** | Track which volume you're currently reading |
| **Complete Collections** | Flag when you own all volumes |
| **Collection Stats** | View statistics about your manga library |
| **Multiple Views** | List, grid, and categorized collection views |

### Cloud & Offline

| Feature | Description |
|---------|-------------|
| **User Authentication** | Secure JWT-based login and registration |
| **Cloud Sync** | Collections automatically sync to the cloud |
| **Offline Mode** | Full functionality without internet connection |
| **Pending Changes** | Offline edits queue and sync when online |
| **Secure Storage** | Credentials stored in device Keychain |

### AI Features

| Feature | Description |
|---------|-------------|
| **Reader Profile** | AI analyzes your collection to create a personality profile |
| **Reading Patterns** | Identifies your reading habits and preferences |
| **Recommendations** | Personalized manga suggestions based on your taste |
| **Streaming Responses** | Real-time AI response generation with live updates |

### Widget

| Size | Description |
|------|-------------|
| **Small** | Shows current manga with progress bar |
| **Medium** | Displays up to 3 manga you're reading |
| **Large** | Full view of 5 manga with detailed progress |

---

### iPhone

| Manga List | Manga Detail | Collection |
|:----------:|:------------:|:----------:|
| Browse catalog with search | Full manga information | Personal library management |

| Advanced Search | AI Profile | Widget |
|:---------------:|:----------:|:------:|
| Multi-filter search | AI-generated insights | Home screen widget |

### iPad

| Split View | Collection Grid |
|:----------:|:---------------:|
| Master-detail navigation | Optimized grid layout |

---

## Architecture

MangaVault follows the **MVVM (Model-View-ViewModel)** architecture pattern with a clean separation of concerns.

```
┌─────────────────────────────────────────────────────────────────┐
│                          PRESENTATION                            │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                         Views                                ││
│  │   SwiftUI Views • Components • ViewModifiers                ││
│  └─────────────────────────────────────────────────────────────┘│
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                      ViewModels                              ││
│  │   @Observable • State Management • Business Logic           ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐│
│  │   DataSources    │  │   Repositories   │  │     Models     ││
│  │   (Actors)       │  │   (Protocols)    │  │     (DTOs)     ││
│  └──────────────────┘  └──────────────────┘  └────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                        PERSISTENCE                               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐│
│  │    SwiftData     │  │     Keychain     │  │   App Groups   ││
│  │  (Local Cache)   │  │ (Secure Storage) │  │ (Widget Share) ││
│  └──────────────────┘  └──────────────────┘  └────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                          NETWORK                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              NetworkRepository (URLSession)                  ││
│  │         REST API • JWT Auth • Error Handling                ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Design Patterns

| Pattern | Usage |
|---------|-------|
| **MVVM** | Separation of UI and business logic |
| **Repository** | Abstract data source operations behind protocols |
| **Actor Model** | Thread-safe state management for auth and collections |
| **Singleton** | Shared instances for ViewModels and services |
| **Dependency Injection** | Protocols enable testability and flexibility |
| **Observer** | `@Observable` macro for reactive UI updates |

---

## Technologies

### Core Frameworks

| Framework | Purpose |
|-----------|---------|
| **SwiftUI** | Declarative UI framework |
| **SwiftData** | Type-safe local persistence |
| **WidgetKit** | Home screen widgets |
| **FoundationModels** | Apple Intelligence integration |

### Networking & Security

| Technology | Purpose |
|------------|---------|
| **URLSession** | HTTP networking with async/await |
| **Security.framework** | Keychain token storage |
| **CryptoKit** | SHA256 hashing for cache keys |
| **JWT** | Token-based authentication |

### Concurrency

| Feature | Purpose |
|---------|---------|
| **Swift Concurrency** | async/await throughout the codebase |
| **Actors** | Thread-safe data sources |
| **Sendable** | Compile-time thread safety |
| **MainActor** | UI-bound state management |

### Additional

| Technology | Purpose |
|------------|---------|
| **Network.framework** | Connectivity monitoring |
| **App Groups** | Shared data between app and widget |
| **Combine** | Reactive programming patterns |

---

## Project Structure

```
SDP26/
├── SDP26/                              # Main App Target
│   ├── System/                         # Core System
│   │   ├── SDP26App.swift             # App entry point
│   │   ├── NetworkMonitor.swift       # Connectivity monitoring
│   │   ├── SharedImageCache.swift     # Cross-target image cache
│   │   ├── WidgetDataManager.swift    # Widget refresh control
│   │   └── AI/                        # Apple Intelligence
│   │       ├── MangaCollectionTool.swift
│   │       └── UserMangaProfile.swift
│   │
│   ├── Views/                          # SwiftUI Views
│   │   ├── ContentView.swift          # Main navigation
│   │   ├── LoginView.swift            # Authentication
│   │   ├── RegisterView.swift         # User registration
│   │   ├── MangaListView.swift        # Manga catalog
│   │   ├── MangaDetailView.swift      # Manga details
│   │   ├── CollectionView.swift       # User collection
│   │   ├── AuthorsListView.swift      # Author directory
│   │   ├── ProfileView.swift          # User profile
│   │   ├── AIProfileAnalysisView.swift # AI insights
│   │   ├── Components/                # Reusable components
│   │   │   ├── CachedAsyncImage.swift
│   │   │   ├── MangaRow.swift
│   │   │   ├── StatusBanner.swift
│   │   │   └── AuthFormFields.swift
│   │   └── iPad/                      # iPad-specific layouts
│   │
│   ├── ViewModels/                     # State Management
│   │   ├── AuthViewModel.swift        # Auth state
│   │   ├── MangaViewModel.swift       # Manga listing
│   │   ├── CollectionVM.swift         # Collection management
│   │   ├── AIProfileAnalysisViewModel.swift
│   │   └── [Additional ViewModels]
│   │
│   ├── Model/                          # Data Models (DTOs)
│   │   ├── MangaDTO.swift
│   │   ├── AuthorDTO.swift
│   │   ├── UserMangaCollectionDTO.swift
│   │   └── [Additional DTOs]
│   │
│   ├── DataModel/                      # Data Layer
│   │   ├── MangaCollectionModel.swift # SwiftData entity
│   │   ├── CollectionDataSource.swift # Collection operations
│   │   ├── AuthDataSource.swift       # Auth operations
│   │   └── KeychainStorage.swift      # Secure storage
│   │
│   └── Network/                        # API Layer
│       ├── NetworkRepository.swift    # API implementation
│       └── URL.swift                  # Endpoint definitions
│
└── MangaWidget/                        # Widget Extension
    ├── MangaWidget.swift              # Widget implementation
    └── MangaWidgetBundle.swift        # Widget configuration
```

---

## Key Implementation Details

### Offline-First Synchronization

The app implements an online-first strategy with offline fallback:

```swift
// Sync Strategy
1. Fetch from API (cloud is source of truth)
2. Sync to local SwiftData cache
3. Check for pending offline changes
4. Push pending changes to API
5. Re-fetch to verify final state
6. Fall back to local cache if offline
```

When offline, changes are queued in `PendingCollectionChange` and automatically synchronized when connectivity is restored.

### Secure Authentication

```swift
// Token Lifecycle
1. Login → Receive JWT + expiration
2. Store in Keychain (never UserDefaults)
3. Proactive refresh when < 1 hour remaining
4. Bearer token for authenticated requests
5. Secure cleanup on logout
```

### AI Integration

The app leverages Apple's Foundation Models framework to provide AI-powered insights:

```swift
// AI Profile Generation
1. MangaCollectionTool provides collection data to AI
2. LanguageModelSession processes with custom instructions
3. Streaming response updates UI in real-time
4. Structured output via @Generable protocol
```

### Widget Data Sharing

```swift
// App → Widget Data Flow
CollectionVM.loadCollection()
    → preCacheImagesForWidget()
    → SharedImageCache.saveImage()  // App Groups container
    → WidgetDataManager.refreshWidget()
```

---

## Getting Started

### Requirements

- Xcode 15.0+
- iOS 17.0+ / iPadOS 17.0+
- Swift 5.9+
- Apple Developer Account (for widget and AI features)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/MangaVault.git
```

2. Open in Xcode
```bash
cd MangaVault
open SDP26.xcodeproj
```

3. Configure signing
   - Select your development team
   - Update bundle identifiers if needed

4. Configure App Groups
   - Enable App Groups capability
   - Use identifier: `group.mangavault.shared`

5. Build and run
   - Select your target device
   - Press `Cmd + R`

### Configuration

The app connects to a hosted API by default. No additional configuration is required for the standard setup.

---

## API Reference

### Base URL
```
https://mymanga-acacademy-5607149ebe3d.herokuapp.com
```

### Endpoints

#### Manga
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/list/mangas?page=X&per=20` | Paginated manga list |
| GET | `/list/bestMangas?page=X&per=20` | Top-rated manga |
| GET | `/search/mangasBeginsWith/{name}` | Search by title |
| POST | `/search/manga?page=X&per=20` | Advanced search |

#### Authors
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/list/authorsPaged?page=X&per=20` | Author list |
| GET | `/search/author/{name}` | Search authors |
| GET | `/list/mangaByAuthor/{id}?page=X` | Author's works |

#### Authentication
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/users` | App-Token | Register user |
| POST | `/users/jwt/login` | Basic | Login |
| POST | `/users/jwt/refresh` | Bearer | Refresh token |
| GET | `/users/jwt/me` | Bearer | Current user |

#### Collection
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/collection/manga` | Bearer | Get collection |
| POST | `/collection/manga` | Bearer | Add/update item |
| DELETE | `/collection/manga/{id}` | Bearer | Remove item |

---

## Author

**José Luis Corral López**

iOS Developer

---

## License

This project is available for portfolio demonstration purposes.

---

<p align="center">
  Built with SwiftUI
</p>
