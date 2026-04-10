# Setup

## Prerequisites

- macOS (tested on macOS 25/26)
- [Homebrew](https://brew.sh)

## Backend

### 1. Install Ruby

Ruby 3.3 is managed via Homebrew (no rbenv needed):

```bash
brew install ruby@3.3
```

Add to your shell profile (`~/.zshrc` or `~/.bash_profile`):
```bash
export PATH="/usr/local/opt/ruby@3.3/bin:$PATH"
```

### 2. Install PostgreSQL

```bash
brew install postgresql@16
brew services start postgresql@16
```

### 3. Install dependencies

```bash
cd backend
bundle install
```

### 4. Configure environment

Copy the example env file and fill in your values:
```bash
cp .env.example .env
```

| Variable | Description | Required |
|----------|-------------|----------|
| `SPOONACULAR_API_KEY` | API key from spoonacular.com/food-api (free tier) | Yes |
| `ALLOWED_ORIGINS` | Comma-separated origins for CORS (default: `http://localhost:8081`) | No |

### 5. Create the database

```bash
bundle exec rails db:create
```

### 6. Run the server

```bash
bundle exec rails server
```

API available at `http://localhost:3000`.

### 7. Run the tests

```bash
bundle exec rspec
```

---

## Mobile

> Setup instructions will be added in issue #8 (Initialize Expo app).
