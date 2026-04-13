# frozen_string_literal: true

require "rails_helper"

RSpec.describe Entities::Recipe do
  subject(:recipe) do
    described_class.new(
      id: 631754,
      title: "Lemony Zucchini Fritters",
      image_url: "https://img.spoonacular.com/recipes/631754-556x370.jpg",
      source_url: "https://www.foodista.com/recipe/zucchini-fritters",
      ready_in_minutes: 45,
      servings: 3
    )
  end

  describe "equality" do
    it "equals another recipe with the same id regardless of other attributes" do
      other = described_class.new(
        id: 631754, title: "Different Title",
        image_url: "", source_url: "", ready_in_minutes: 0, servings: 0
      )
      expect(recipe).to eq(other)
    end

    it "does not equal a recipe with a different id" do
      other = described_class.new(
        id: 999, title: "Lemony Zucchini Fritters",
        image_url: "", source_url: "", ready_in_minutes: 45, servings: 3
      )
      expect(recipe).not_to eq(other)
    end

    it "can be used as a hash key" do
      same_id = described_class.new(
        id: 631754, title: "x", image_url: "", source_url: "", ready_in_minutes: 0, servings: 0
      )
      hash = { recipe => "found" }
      expect(hash[same_id]).to eq("found")
    end
  end
end
