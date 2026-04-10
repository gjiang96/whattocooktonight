# Architecture

## Overview

WhatToCookTonight is split into two independent apps:

| App | Location | Purpose |
|-----|----------|---------|
| Rails API | `backend/` | Business logic, data, external integrations |
| React Native (Expo) | `mobile/` | iOS (and Android) frontend |

The mobile app talks to the Rails API over HTTP. There is no shared code between them.

---

## Backend: Layered Architecture

The backend enforces four layers. Each layer only depends on the one directly below it.

```
┌─────────────────────────────────┐
│         Interface Layer         │  Controllers, Serializers, Jobs
├─────────────────────────────────┤
│        Application Layer        │  Use Cases (app/use_cases/)
├─────────────────────────────────┤
│          Domain Layer           │  Entities, Value Objects (app/domain/)
├─────────────────────────────────┤
│      Infrastructure Layer       │  API Clients, Repositories (app/infrastructure/)
└─────────────────────────────────┘
```

### Interface Layer (`app/controllers/`, `app/serializers/`)
Receives HTTP requests, calls one use case, serialises the result. No business logic lives here.

### Application Layer (`app/use_cases/`)
One class per business operation. Each exposes a single `#call` method and returns a `Result` (success/failure). Orchestrates domain objects and infrastructure — never performs I/O directly.

### Domain Layer (`app/domain/`)
Pure Ruby. No Rails, no HTTP, no database. Contains:
- **Entities** — objects with identity (e.g. `Recipe`)
- **Value Objects** — immutable, equality by value (e.g. `Ingredient`)

### Infrastructure Layer (`app/infrastructure/`)
All I/O lives here — HTTP clients and (later) database repositories.

> **Autoloading note:** Rails' Zeitwerk loader uses each direct subdirectory of `app/` as a constant namespace root. Files in `app/infrastructure/api_clients/` resolve to `ApiClients::*`, not `Infrastructure::ApiClients::*`. The directory enforces the layer boundary; the module prefix reflects the type.

---

## Frontend: Layered Architecture

```
Screens  →  Hooks  →  Services  →  Rails API
    ↓
Components (presentational only)
```

- **Screens** — layout and navigation wiring only
- **Hooks** — all data fetching, loading/error state, derived state
- **Services** — the only layer that calls the API; returns typed domain objects
- **Components** — receive props, emit events, no side effects

---

## Key Design Decisions

### Why Rails API-only?
The mobile app needs a backend for recipe data, shopping list generation, and (later) user accounts. Rails API mode strips the HTML rendering stack, keeping the server lean.

### Why Expo?
Managed Expo workflow lets us build for iOS without maintaining a full Xcode/native setup from day one. Ejecting is an option later if we need a custom native module.

### Why Spoonacular instead of scraping?
Scraping recipe sites is fragile (HTML changes break parsers) and legally grey. Spoonacular's structured API gives us clean JSON with nutritional data, ingredients, and dietary tags out of the box. Free tier covers development (150 req/day).

### Why not store recipes in our own DB (yet)?
For the single-day MVP we call Spoonacular on demand. We'll add a local recipe cache once we have multi-day meal plans and want to avoid repeated API calls for the same recipes.
