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
│         Interface Layer         │  Controllers, Serializers
├─────────────────────────────────┤
│        Application Layer        │  Services (app/services/)
├─────────────────────────────────┤
│          Domain Layer           │  Entities, Value Objects (app/domain/)
├─────────────────────────────────┤
│      Infrastructure Layer       │  API Clients, Repositories (app/infrastructure/)
└─────────────────────────────────┘
```

### Interface Layer (`app/controllers/`, `app/serializers/`)
Receives HTTP requests, calls one service, serialises the result. No business logic lives here.
- `Api::V1::RecipesController` — wires the HTTP endpoint to the service
- `RecipeSerializer` — converts a `Recipe` entity to the JSON response shape

### Application Layer (`app/services/`)
One class per business operation. Each exposes a single `#call` method and returns a `Result` (success/failure). Orchestrates domain objects and infrastructure — never performs I/O directly.
- `FetchRandomRecipe` — delegates to the recipe repository, returns a `Result`

### Domain Layer (`app/domain/`)
Pure Ruby. No Rails, no HTTP, no database. Contains:
- **Entities** — objects with identity (e.g. `Entities::Recipe`, identified by Spoonacular id)
- **Value Objects** — immutable, equality by value (e.g. `ValueObjects::Ingredient`)
- **`Result`** — a simple `Struct` returned by every service and repository. Lets callers branch on `success?` rather than rescuing exceptions for expected failures.

### Infrastructure Layer (`app/infrastructure/`)
All I/O lives here — external API clients and (later) database repositories.
- `ApiClients::SpoonacularClient` — HTTP calls to Spoonacular via Faraday
- `Repositories::RecipeRepository` — translates raw Spoonacular JSON into `Recipe` entities, catches `ExternalApiError` and returns a failure `Result`

> **Autoloading note:** Rails' Zeitwerk loader uses each direct subdirectory of `app/` as a constant namespace root. Files in `app/infrastructure/api_clients/` resolve to `ApiClients::*`, not `Infrastructure::ApiClients::*`. The directory enforces the layer boundary; the module prefix reflects the type.

---

## Request lifecycle: `GET /api/v1/recipes/random`

A concrete walkthrough of how a single request moves through the layers:

```
HTTP GET /api/v1/recipes/random?tags=vegetarian
    │
    ▼
Api::V1::RecipesController#random          ← Interface
    │   parses tags, calls the service
    ▼
FetchRandomRecipe#call(tags:)              ← Application
    │   delegates to the repository
    ▼
Repositories::RecipeRepository             ← Infrastructure
    │   calls the client, maps JSON → domain
    ▼
ApiClients::SpoonacularClient              ← Infrastructure
    │   Faraday GET to api.spoonacular.com
    ▼
{raw JSON}
    │
    ▼ (mapped back up the stack)
Entities::Recipe + ValueObjects::Ingredient    ← Domain
    │   wrapped in a Result(success?: true)
    ▼
RecipeSerializer.call(recipe)              ← Interface
    │
    ▼
JSON response
```

Each arrow crosses exactly one layer boundary. On failure (e.g. Spoonacular returns 503), the repository catches the `ExternalApiError`, wraps it in a failure `Result`, and the controller renders a 503 with an error body — no exception ever escapes the layer it originated in.

---

## Frontend: Layered Architecture

```
Screens  →  Hooks  →  API clients  →  Rails API
    ↓
Components (presentational only)
```

- **Screens** — layout and navigation wiring only
- **Hooks** — all data fetching, loading/error state, derived state
- **API clients** (in `src/services/`) — the only layer that calls the Rails API; returns typed domain objects. Named "services" in the filesystem to match React Native convention, but they are API clients, not business-operation services like the backend's `app/services/`.
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
