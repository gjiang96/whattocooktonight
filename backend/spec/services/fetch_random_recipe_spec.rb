# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchRandomRecipe do
  subject(:use_case) { described_class.new(recipe_repo: recipe_repo) }

  let(:recipe_repo) { instance_double(Repositories::RecipeRepository) }

  let(:recipe) do
    Entities::Recipe.new(
      id: 631754, title: "Lemony Zucchini Fritters",
      image_url: "https://img.spoonacular.com/recipes/631754-556x370.jpg",
      source_url: "https://www.foodista.com/recipe/zucchini-fritters",
      ready_in_minutes: 45, servings: 3
    )
  end

  describe "#call" do
    context "when the repository returns a recipe" do
      let(:success_result) { Result.new(success?: true, value: recipe, error: nil) }

      before do
        allow(recipe_repo).to receive(:fetch_random_recipe)
          .with(tags: [])
          .and_return(success_result)
      end

      it "returns a success result with the recipe" do
        result = use_case.call
        expect(result.success?).to be true
        expect(result.value).to eq(recipe)
      end
    end

    context "when tags are provided" do
      let(:success_result) { Result.new(success?: true, value: recipe, error: nil) }

      before do
        allow(recipe_repo).to receive(:fetch_random_recipe)
          .with(tags: %w[italian vegetarian])
          .and_return(success_result)
      end

      it "passes tags through to the repository" do
        use_case.call(tags: %w[italian vegetarian])
        expect(recipe_repo).to have_received(:fetch_random_recipe).with(tags: %w[italian vegetarian])
      end
    end

    context "when the repository returns a failure" do
      let(:failure_result) { Result.new(success?: false, value: nil, error: "Spoonacular API returned 402") }

      before do
        allow(recipe_repo).to receive(:fetch_random_recipe)
          .with(tags: [])
          .and_return(failure_result)
      end

      it "returns the failure result" do
        result = use_case.call
        expect(result.success?).to be false
        expect(result.error).to eq("Spoonacular API returned 402")
      end
    end
  end
end
