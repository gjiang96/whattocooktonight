# API Reference

Base URL (development): `http://localhost:3000`

All responses are JSON. All endpoints are under `/api/v1/`.

---

## Recipes

### GET /api/v1/recipes/random

Returns a single randomly selected recipe with its full ingredient list.

> **Status:** Planned — implemented in issue #7

**Query parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tags` | string | No | Comma-separated filter tags (cuisine or dietary). E.g. `italian`, `vegetarian`. |

**Success response `200`:**
```json
{
  "recipe": {
    "id": 642583,
    "title": "Farfalle with Peas, Ham and Cream",
    "image_url": "https://img.spoonacular.com/recipes/642583-556x370.jpg",
    "source_url": "https://www.foodista.com/recipe/farfalle",
    "cuisine": "Italian",
    "dietary_tags": [],
    "ready_in_minutes": 45,
    "servings": 4,
    "ingredients": [
      { "name": "farfalle pasta", "quantity": 200.0, "unit": "g" },
      { "name": "peas", "quantity": 100.0, "unit": "g" }
    ]
  }
}
```

**Error response `503`** (upstream Spoonacular unavailable):
```json
{ "error": "Recipe service unavailable" }
```
