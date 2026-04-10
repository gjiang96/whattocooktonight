# Tech Stack

## Backend

| Technology | Version | Purpose |
|-----------|---------|---------|
| Ruby | 3.3.x (Homebrew) | Language |
| Rails | 8.1.x | API framework (`--api` mode) |
| PostgreSQL | 16.x | Primary database |
| Faraday | 2.x | HTTP client for external API calls |
| Rack CORS | — | Cross-origin request handling for the mobile app |
| dotenv-rails | — | `.env` file support in development |
| Puma | 5+ | Web server |

### Testing
| Gem | Purpose |
|-----|---------|
| RSpec Rails | Test framework |
| FactoryBot Rails | Test data factories |
| Shoulda Matchers | Concise model/controller matchers |
| Faker | Realistic fake data in factories |
| SimpleCov | Code coverage (90% minimum enforced) |
| WebMock | Stub external HTTP in tests — no real network calls |

---

## Mobile

| Technology | Version | Purpose |
|-----------|---------|---------|
| React Native | via Expo SDK | Cross-platform iOS/Android framework |
| Expo | Managed workflow | Build tooling, native module access |
| TypeScript | Strict mode | Language |
| TanStack Query | — | Server state management (data fetching, caching) |
| Zustand | — | Client-side state |
| Expo Router | — | File-based navigation |
| expo-secure-store | — | Encrypted storage for auth tokens |

### Testing
| Tool | Purpose |
|------|---------|
| Jest | Test runner |
| React Native Testing Library | Component and hook tests |

---

## Infrastructure / Tooling

| Tool | Purpose |
|------|---------|
| Homebrew | macOS package manager |
| PostgreSQL 16 (Homebrew) | Local database server (`brew services start postgresql@16`) |
