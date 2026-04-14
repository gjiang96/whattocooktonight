# What To Cook Tonight

A meal planning app that takes the "what's for dinner?" decision off your plate.

Tell it your dietary preferences or cuisine mood — it picks a recipe, shows you what to cook, and hands you the ingredient list so you can shop without thinking.

---

## What it does

- Suggests a random recipe for tonight based on optional filters (cuisine, dietary requirements)
- Shows the full ingredient list with quantities
- Generates a shopping list for the meal

**Planned:** multi-day meal plans, user accounts, saved preferences.

---

## How it's built

| Layer | Technology |
|-------|-----------|
| API backend | Ruby on Rails 8 (API-only mode) |
| Mobile app | React Native via Expo (iOS + Android) |
| Recipe data | [Spoonacular API](https://spoonacular.com/food-api) |
| Database | PostgreSQL 16 |

The backend follows a layered domain-driven design — controllers stay thin, business logic lives in use cases, and domain objects are pure Ruby with no framework dependencies. See [`docs/architecture.md`](docs/architecture.md) for the full picture.

---

## Project structure

```
backend/    Rails API
mobile/     React Native (Expo) app — coming soon
docs/       Architecture decisions, API reference, setup guide
```

---

## Getting started

### Prerequisites

- macOS with [Homebrew](https://brew.sh)
- Ruby 3.3 — `brew install ruby@3.3`
- PostgreSQL 16 — `brew install postgresql@16 && brew services start postgresql@16`
- A free [Spoonacular API key](https://spoonacular.com/food-api) (150 requests/day on the free tier)

### Setup

```bash
cd backend
bundle install
cp .env.example .env   # then add your SPOONACULAR_API_KEY
bundle exec rails db:create
bundle exec rails server
```

API runs at `http://localhost:3000`.

See [`docs/setup.md`](docs/setup.md) for the full setup guide including all environment variables.

---

## Docs

| Doc | What's in it |
|-----|-------------|
| [`docs/architecture.md`](docs/architecture.md) | Layered architecture, design decisions |
| [`docs/tech-stack.md`](docs/tech-stack.md) | All dependencies and why they were chosen |
| [`docs/external-services.md`](docs/external-services.md) | Spoonacular integration details |
| [`docs/setup.md`](docs/setup.md) | Local development setup |
| [`docs/api.md`](docs/api.md) | API endpoint reference |
