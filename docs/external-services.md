# External Services

## Spoonacular

**What it's used for:** Fetching random recipes with full ingredient lists, cuisine tags, and dietary information.

**Website:** https://spoonacular.com/food-api

**Auth:** API key passed as a query parameter (`apiKey=...`).

**Rate limits (free tier):** 150 requests/day, 1 request/second.

**Key endpoint used:**

```
GET https://api.spoonacular.com/recipes/random
  ?number=1
  &apiKey={SPOONACULAR_API_KEY}
  &tags={comma,separated,tags}   ← optional, used for cuisine/dietary filtering
```

**Response shape (relevant fields):**
```json
{
  "recipes": [{
    "id": 642583,
    "title": "Farfalle with Peas, Ham and Cream",
    "image": "https://img.spoonacular.com/recipes/642583-556x370.jpg",
    "sourceUrl": "https://...",
    "readyInMinutes": 45,
    "servings": 4,
    "cuisines": ["Italian"],
    "diets": ["gluten free"],
    "extendedIngredients": [
      { "name": "farfalle pasta", "amount": 200.0, "unit": "g" }
    ]
  }]
}
```

**Rails integration:** `ApiClients::SpoonacularClient` in `app/infrastructure/api_clients/spoonacular_client.rb`.

**Error handling:** Any non-200 response raises `ApiClients::ExternalApiError`. Callers (repositories, use cases) are responsible for catching this and returning an appropriate `Result.failure`.

**Gotchas:**
- `tags` param filters by both cuisine AND diet in a single field — pass `"italian"` or `"vegetarian"` directly as lowercase strings.
- `cuisines` in the response is an array; it can be empty even when a tag was passed.
- Free tier quota resets daily at midnight UTC. In development, avoid running specs against the real API — WebMock stubs all requests in the test environment.
