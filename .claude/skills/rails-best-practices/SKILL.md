---
name: rails-best-practices
description: Use when writing, reviewing, or generating Ruby on Rails code. Enforces ActiveRecord patterns, N+1 prevention, strong parameters, security best practices, controller design, migration conventions, and performance optimization. Auto-activates for all Rails code tasks.
---

# Rails Best Practices

## Overview

Comprehensive Rails best practices covering ActiveRecord, controllers, security, performance, testing, and code organization. Drawn from rails-bestpractices.com community standards and Rails core conventions.

## ActiveRecord

### N+1 Query Prevention

Always eager load associations. Never lazy-load inside loops.

```ruby
# Bad — N+1 query
posts = Post.all
posts.each { |post| puts post.author.name }

# Good — eager load
posts = Post.includes(:author).all
posts.each { |post| puts post.author.name }

# When filtering on association, use eager_load (JOIN)
Post.eager_load(:author).where(authors: { verified: true })

# Batch processing for large datasets
Post.includes(:author).find_each(batch_size: 500) { |post| ... }
```

### Scopes Over Class Methods for Queries

```ruby
# Good
scope :published, -> { where(published: true) }
scope :recent, -> { order(created_at: :desc).limit(10) }
scope :by_cuisine, ->(cuisine) { where(cuisine: cuisine) }

# Chainable
Recipe.published.by_cuisine("Italian").recent
```

### Avoid default_scope

`default_scope` causes invisible filtering that breaks expectations. Use named scopes instead.

```ruby
# Bad
default_scope { where(active: true) }

# Good
scope :active, -> { where(active: true) }
```

### Use Database Indexes

Add indexes for every column used in WHERE, ORDER BY, JOIN, and foreign keys.

```ruby
# Migration
add_index :recipes, :cuisine
add_index :recipes, [:user_id, :published_at]
add_index :recipe_ingredients, :ingredient_id
```

### Use select to Limit Columns

```ruby
# Only fetch what you need
Recipe.select(:id, :title, :cuisine).where(published: true)
```

## Controllers

### Thin Controllers — One Use Case Per Action

```ruby
# Good
def create
  result = UseCases::CreateRecipe.new(repo: recipe_repo).call(params: recipe_params)
  result.success? ? render_success(result.value) : render_error(result.error)
end

# Bad — business logic in controller
def create
  @recipe = Recipe.new(recipe_params)
  @recipe.ingredients = parse_ingredients(params[:raw_ingredients])
  @recipe.save ? render_success : render_error
end
```

### Strong Parameters — Always

```ruby
def recipe_params
  params.require(:recipe).permit(:title, :cuisine, :description,
                                  dietary_tags: [],
                                  ingredients: [:name, :quantity, :unit])
end
```

Never use `params` directly. Never use `permit!`.

### Avoid Modifying params Hash

```ruby
# Bad
params[:recipe][:user_id] = current_user.id

# Good — pass separately
UseCases::CreateRecipe.new.call(params: recipe_params, user: current_user)
```

## Time and Timezones

Always use timezone-aware methods. Never use raw Ruby time.

```ruby
# Bad
Time.now
Date.today
DateTime.now

# Good
Time.zone.now
Date.current
Time.current
1.day.ago  # ActiveSupport, zone-aware
```

## Error Handling

Be specific when rescuing. Never rescue `Exception` or bare `StandardError` silently.

```ruby
# Bad
rescue => e
  nil

# Good
rescue ActiveRecord::RecordNotFound => e
  Result.failure(:not_found)

rescue ActiveRecord::RecordInvalid => e
  Result.failure(e.record.errors.full_messages)
```

## Security

### SQL Injection Prevention

Never interpolate user input into SQL strings.

```ruby
# Bad — SQL injection vulnerability
Recipe.where("title = '#{params[:title]}'")

# Good — parameterized query
Recipe.where(title: params[:title])
Recipe.where("title LIKE ?", "%#{params[:title]}%")
```

### Mass Assignment Protection

Always use strong parameters. Never use `update_attributes` with raw params.

### Authentication Checks

Always check authentication and authorization before executing actions. Use before_action filters.

```ruby
before_action :authenticate_user!
before_action :authorize_owner!, only: [:update, :destroy]
```

## Code Organization

### Single Responsibility

Each class/module does one thing. Controllers route, use cases orchestrate, domain objects represent business concepts.

### DRY — But Not Premature

Extract duplication only when you have 3+ actual use cases for it. Prefer clarity over cleverness.

### Tell, Don't Ask

```ruby
# Bad — asking object for state then acting on it
if user.admin?
  user.grant_access(resource)
end

# Good — tell the object what to do
user.grant_access_if_admin(resource)
```

## Migrations

### Always Include a Down Migration

```ruby
def up
  add_column :recipes, :cuisine, :string
end

def down
  remove_column :recipes, :cuisine
end
```

### Never Change Existing Migrations

After a migration has been committed and run, create a new migration to fix it. Never edit the original.

### Log Inside Data Migrations

```ruby
def up
  say_with_time "Backfilling cuisine column" do
    Recipe.find_each { |r| r.update!(cuisine: detect_cuisine(r)) }
  end
end
```

## Performance

### Background Jobs for Slow Operations

Never run slow operations synchronously in the request cycle. Sidekiq for anything that takes >200ms.

```ruby
# Bad — slow in request cycle
def create
  RecipeImporter.new.import_from_api(query)  # external HTTP call
  render json: { status: :ok }
end

# Good — queue it
def create
  RecipeImportJob.perform_later(query)
  render json: { status: :accepted }
end
```

### Counter Caches for Counts

```ruby
belongs_to :recipe, counter_cache: true
# Avoid: recipe.ingredients.count (hits DB every time)
# Use: recipe.ingredients_count (cached column)
```

### Avoid N+1 in Serializers

Serializers are a common N+1 source. Always check SQL logs when building API responses.

## Testing

### RSpec Standards

- Every use case: unit test covering all success and failure paths
- Models: test validations, scopes, and domain methods
- Requests: test HTTP contract (status codes, response shape) — not business logic
- Factories with FactoryBot, never fixtures
- No `before(:all)` — use `let` and `before(:each)`
- Target: >90% coverage

```ruby
# Use subject and described_class
RSpec.describe Recipe do
  subject(:recipe) { build(:recipe) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:cuisine) }
  end

  describe ".published" do
    it "returns only published recipes" do
      published = create(:recipe, published: true)
      draft = create(:recipe, published: false)
      expect(Recipe.published).to contain_exactly(published)
    end
  end
end
```

### Test Doubles for External Services

Mock HTTP clients and external APIs in unit tests. Integration tests hit real test doubles or VCR cassettes, not production APIs.
