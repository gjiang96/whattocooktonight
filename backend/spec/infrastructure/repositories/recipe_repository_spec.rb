# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repositories::RecipeRepository do
  subject(:repo) { described_class.new(client: client) }

  let(:client) { instance_double(ApiClients::SpoonacularClient) }

  let(:raw_recipe) do
    {
      "id"                  => 631754,
      "title"               => "Lemony Zucchini Fritters",
      "image"               => "https://img.spoonacular.com/recipes/631754-556x370.jpg",
      "sourceUrl"           => "https://www.foodista.com/recipe/zucchini-fritters",
      "readyInMinutes"      => 45,
      "servings"            => 3,
      "cuisines"            => [],
      "diets"               => ["vegetarian"],
      "extendedIngredients" => [
        { "name" => "zucchini", "amount" => 2.0,  "unit" => "pcs" },
        { "name" => "flour",    "amount" => 0.5,  "unit" => "cup" },
        { "name" => "eggs",     "amount" => 2.0,  "unit" => ""    }
      ]
    }
  end

  describe "#fetch_random_recipe" do
    context "when the client returns a recipe" do
      before do
        allow(client).to receive(:fetch_random_recipe)
          .with(tags: [])
          .and_return({ "recipes" => [raw_recipe] })
      end

      it "returns a success result" do
        expect(repo.fetch_random_recipe.success?).to be true
      end

      it "maps the raw response to a Recipe entity" do
        recipe = repo.fetch_random_recipe.value

        expect(recipe).to be_a(Entities::Recipe)
        expect(recipe.id).to eq(631754)
        expect(recipe.title).to eq("Lemony Zucchini Fritters")
        expect(recipe.ready_in_minutes).to eq(45)
        expect(recipe.servings).to eq(3)
        expect(recipe.diets).to eq(["vegetarian"])
      end

      it "maps extendedIngredients to Ingredient value objects" do
        ingredients = repo.fetch_random_recipe.value.ingredients

        expect(ingredients.length).to eq(3)
        expect(ingredients.first).to eq(
          ValueObjects::Ingredient.new(name: "zucchini", amount: 2.0, unit: "pcs")
        )
      end

      it "passes tags through to the client" do
        allow(client).to receive(:fetch_random_recipe)
          .with(tags: %w[italian vegetarian])
          .and_return({ "recipes" => [raw_recipe] })

        repo.fetch_random_recipe(tags: %w[italian vegetarian])

        expect(client).to have_received(:fetch_random_recipe).with(tags: %w[italian vegetarian])
      end
    end

    context "when the client raises an ExternalApiError" do
      before do
        allow(client).to receive(:fetch_random_recipe)
          .and_raise(ApiClients::ExternalApiError, "Spoonacular API returned 402")
      end

      it "returns a failure result" do
        expect(repo.fetch_random_recipe.success?).to be false
      end

      it "includes the error message" do
        expect(repo.fetch_random_recipe.error).to match(/402/)
      end
    end
  end
end
