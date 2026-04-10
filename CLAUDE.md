# WhatToCookTonight — Claude Code Guidelines

## Project Overview
A meal planning app with a Rails API backend and React Native (Expo) mobile frontend.
The backend scrapes/fetches recipes, generates meal plans, and produces shopping lists.

---

## Automatic Skill Activation

Apply these skills automatically — do not wait to be asked:

**When working on any Rails or Ruby file** (`.rb`, `.erb`, `Gemfile`, migrations, controllers, models, use cases, domain objects, serializers, specs):
- Apply the `ruby` skill — idiomatic Ruby 3.x patterns, error handling, performance
- Apply the `rails-best-practices` skill — N+1 prevention, strong params, security, scopes, testing

**When working on any React Native file** (`.tsx`, `.ts`, `.jsx`, screens, components, hooks, services):
- Apply the `react-native` skill — Expo conventions, navigation, state management, secure storage
- Apply the `react-native-performance` skill — re-render diagnosis, bundle size, FlatList, animations

Skills live in `.claude/skills/`. They are always active for the relevant context — treat their rules as non-optional defaults, not suggestions.

---

## Architecture: Domain-Driven Design

This project enforces a strict layered architecture. Keep layers separate — no layer should reach past its immediate neighbor.

```
┌─────────────────────────────────┐
│         Interface Layer         │  Controllers, Serializers, Jobs
├─────────────────────────────────┤
│        Application Layer        │  Use Cases (app/use_cases/)
├─────────────────────────────────┤
│          Domain Layer           │  Entities, Value Objects, Domain Services (app/domain/)
├─────────────────────────────────┤
│      Infrastructure Layer       │  Repos, External APIs, DB (app/infrastructure/)
└─────────────────────────────────┘
```

### Layer Responsibilities

**Domain Layer** (`app/domain/`)
- Pure Ruby objects: no ActiveRecord, no HTTP, no Rails dependencies
- Entities: objects with identity and lifecycle (e.g. `Recipe`, `MealPlan`)
- Value Objects: immutable, equality by value (e.g. `Ingredient`, `ShoppingList`)
- Domain Services: operations that don't belong to a single entity
- No side effects. Always unit-testable in isolation.

**Application Layer** (`app/use_cases/`)
- Orchestrates domain objects to fulfill a single business operation
- One class, one public method (`#call`)
- Handles cross-cutting concerns: transactions, authorization checks, event dispatching
- Returns a result object (success/failure), never raises for business logic errors
- Example: `UseCases::GenerateMealPlan`, `UseCases::BuildShoppingList`

**Infrastructure Layer** (`app/infrastructure/`)
- All I/O: database, external APIs, file system
- Repositories translate between domain objects and ActiveRecord/external responses
- External API clients live here (e.g. `Infrastructure::SpoonacularClient`)
- Domain code never instantiates infrastructure directly — always injected

**Interface Layer** (controllers, jobs, serializers)
- Controllers are thin: validate params, call one use case, render result
- No business logic in controllers
- Jobs delegate to use cases — they are just async triggers

---

## Rails Backend Conventions

### Directory Structure
```
app/
  controllers/api/v1/    # Thin controllers only
  domain/
    entities/            # Pure Ruby entity classes
    value_objects/       # Immutable value objects
    services/            # Domain services
  use_cases/             # One file per use case
  infrastructure/
    repositories/        # ActiveRecord <-> Domain translation
    api_clients/         # External HTTP clients
  serializers/           # JSON serialization (jsonapi-serializer or alba)
  workers/               # Sidekiq jobs (delegate to use cases)
```

### Models
- ActiveRecord models are persistence objects only — treat them as the infrastructure layer
- No business logic in models. Validations for DB integrity are acceptable.
- Use models only inside repositories

### Controllers
```ruby
# Good
def create
  result = UseCases::GenerateMealPlan.new(repo: MealPlanRepository.new).call(params: meal_plan_params)
  result.success? ? render_success(result.value) : render_error(result.error)
end

# Bad — business logic in controller
def create
  recipes = Recipe.where(cuisine: params[:cuisine]).sample(params[:days])
  ...
end
```

### Use Cases
- Always return a result wrapper, never raise for expected failures
- Use a simple Result type:
```ruby
Result = Struct.new(:success?, :value, :error, keyword_init: true)
```

### Value Objects
- Freeze on initialize
- Override `==` and `eql?` to compare by value
- Example: `Ingredient` with name, quantity, unit

---

## Testing Standards (Rails)

**Framework:** RSpec + FactoryBot + Shoulda Matchers

### Rules
- Every use case must have a unit test with all paths covered (success + each failure case)
- Domain objects (entities, value objects, services) must have unit tests — no DB, no mocks of domain
- Repositories get integration tests against a real test DB — no mocking ActiveRecord
- Controllers get request specs testing HTTP contract only (status codes, response shape)
- Minimum coverage target: **90%**
- No `before(:all)` — use `let` and `before(:each)`
- Factories over fixtures

### Test Structure
```
spec/
  domain/          # Pure unit tests, no DB
  use_cases/       # Unit tests, repositories mocked/stubbed
  infrastructure/  # Integration tests, real DB
  requests/        # API contract tests
  factories/
```

### Example Use Case Test Pattern
```ruby
RSpec.describe UseCases::GenerateMealPlan do
  subject(:use_case) { described_class.new(recipe_repo: recipe_repo) }

  let(:recipe_repo) { instance_double(Infrastructure::Repositories::RecipeRepository) }

  describe '#call' do
    context 'when sufficient recipes exist' do
      it 'returns a meal plan with the requested number of days' do ...
    end

    context 'when no recipes match the filter' do
      it 'returns a failure result' do ...
    end
  end
end
```

---

## React Native (Expo) Conventions

### Directory Structure
```
src/
  screens/           # Screen components — layout and navigation only
  components/        # Reusable UI components (no business logic)
  hooks/             # Custom hooks for data fetching and state
  services/          # API clients (one file per resource)
  domain/            # TypeScript types/interfaces mirroring backend domain
  utils/             # Pure functions, no side effects
```

### Layer Rules
- **Screens** orchestrate layout and call hooks — no direct API calls, no business logic
- **Components** are pure presentational — receive props, emit events, nothing else
- **Hooks** own all data fetching, loading/error state, and local business logic
- **Services** are the only place that calls the API — return typed domain objects

### TypeScript
- Strict mode always on (`"strict": true` in tsconfig)
- No `any` types — use `unknown` and narrow explicitly
- Domain types live in `src/domain/` and mirror the Rails domain layer

### Example Pattern
```typescript
// services/recipeService.ts — infrastructure
export const recipeService = {
  getMealPlan: async (filters: MealPlanFilters): Promise<MealPlan> => { ... }
}

// hooks/useMealPlan.ts — application logic
export const useMealPlan = (filters: MealPlanFilters) => {
  const [mealPlan, setMealPlan] = useState<MealPlan | null>(null)
  // fetching, error handling, derived state
  return { mealPlan, isLoading, error }
}

// screens/MealPlanScreen.tsx — interface
export const MealPlanScreen = () => {
  const { mealPlan, isLoading } = useMealPlan(filters)
  return <MealPlanView mealPlan={mealPlan} />
}
```

---

## Testing Standards (React Native)

**Framework:** Jest + React Testing Library (RNTL)

### Rules
- Hooks get unit tests via `renderHook` — mock services, test all state transitions
- Components get snapshot tests + interaction tests for non-trivial behavior
- Services get unit tests with mocked `fetch`/axios
- No testing implementation details — test behavior from the user's perspective
- No `act()` wrappers manually unless absolutely necessary — prefer `waitFor`

---

## General Rules (Both Sides)

- **No business logic in the interface layer** — controllers, screens, and jobs are just wiring
- **Small, focused classes** — one responsibility per class/hook/component
- **No premature abstraction** — only abstract when you have 2+ real use cases for it
- **Explicit over implicit** — avoid metaprogramming and magic unless it's a Rails convention
- **Dependency injection** — pass collaborators in, don't instantiate them internally
- **No commented-out code** — delete it, git history exists
- **Meaningful names** — name things after what they represent in the domain, not what they do technically
