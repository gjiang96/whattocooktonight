# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /api/v1/recipes/random", type: :request do
  let(:spoonacular_url) { "https://api.spoonacular.com/recipes/random" }

  let(:spoonacular_response) do
    {
      "recipes" => [
        {
          "id"                  => 631754,
          "title"               => "Lemony Zucchini Fritters",
          "image"               => "https://img.spoonacular.com/recipes/631754-556x370.jpg",
          "sourceUrl"           => "https://www.foodista.com/recipe/zucchini-fritters",
          "readyInMinutes"      => 45,
          "servings"            => 3,
          "cuisines"            => [],
          "diets"               => [ "vegetarian" ],
          "extendedIngredients" => [
            { "name" => "zucchini", "amount" => 2.0, "unit" => "pcs" }
          ]
        }
      ]
    }
  end

  context "when Spoonacular returns a recipe" do
    before do
      stub_request(:get, spoonacular_url)
        .with(query: hash_including("number" => "1"))
        .to_return(
          status: 200,
          body: spoonacular_response.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "returns 200" do
      get "/api/v1/recipes/random"
      expect(response).to have_http_status(:ok)
    end

    it "returns the recipe as JSON" do
      get "/api/v1/recipes/random"
      body = response.parsed_body

      expect(body["recipe"]["id"]).to eq(631754)
      expect(body["recipe"]["title"]).to eq("Lemony Zucchini Fritters")
      expect(body["recipe"]["ready_in_minutes"]).to eq(45)
      expect(body["recipe"]["servings"]).to eq(3)
      expect(body["recipe"]["diets"]).to eq([ "vegetarian" ])
    end

    it "includes ingredients" do
      get "/api/v1/recipes/random"
      ingredients = response.parsed_body["recipe"]["ingredients"]

      expect(ingredients.length).to eq(1)
      expect(ingredients.first).to eq("name" => "zucchini", "amount" => 2.0, "unit" => "pcs")
    end

    it "passes tags to Spoonacular when provided" do
      stub_request(:get, spoonacular_url)
        .with(query: hash_including("tags" => "italian,vegetarian"))
        .to_return(
          status: 200,
          body: spoonacular_response.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      get "/api/v1/recipes/random", params: { tags: "italian,vegetarian" }
      expect(response).to have_http_status(:ok)
    end
  end

  context "when Spoonacular is unavailable" do
    before do
      stub_request(:get, spoonacular_url)
        .with(query: hash_including("number" => "1"))
        .to_return(status: 503, body: "Service Unavailable")
    end

    it "returns 503" do
      get "/api/v1/recipes/random"
      expect(response).to have_http_status(:service_unavailable)
    end

    it "returns an error message" do
      get "/api/v1/recipes/random"
      expect(response.parsed_body["error"]).to eq("Recipe service unavailable")
    end
  end
end
