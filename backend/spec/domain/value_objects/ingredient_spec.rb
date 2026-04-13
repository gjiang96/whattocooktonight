# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValueObjects::Ingredient do
  subject(:ingredient) { described_class.new(name: "garlic", amount: 2.0, unit: "cloves") }

  describe "#initialize" do
    it "strips whitespace from name and unit" do
      i = described_class.new(name: "  garlic  ", amount: 1.0, unit: "  cloves  ")
      expect(i.name).to eq("garlic")
      expect(i.unit).to eq("cloves")
    end

    it "coerces amount to float" do
      i = described_class.new(name: "salt", amount: "1", unit: "tsp")
      expect(i.amount).to eq(1.0)
    end
  end

  describe "equality" do
    it "equals another ingredient with the same name, amount, and unit" do
      other = described_class.new(name: "garlic", amount: 2.0, unit: "cloves")
      expect(ingredient).to eq(other)
    end

    it "does not equal an ingredient with a different amount" do
      other = described_class.new(name: "garlic", amount: 3.0, unit: "cloves")
      expect(ingredient).not_to eq(other)
    end

    it "does not equal an ingredient with a different unit" do
      other = described_class.new(name: "garlic", amount: 2.0, unit: "tbsp")
      expect(ingredient).not_to eq(other)
    end

    it "can be used as a hash key" do
      duplicate = described_class.new(name: "garlic", amount: 2.0, unit: "cloves")
      hash = { ingredient => "present" }
      expect(hash[duplicate]).to eq("present")
    end
  end

  describe "#to_s" do
    it "includes amount, unit, and name when unit is present" do
      expect(ingredient.to_s).to eq("2.0 cloves garlic")
    end

    it "omits unit when unit is blank" do
      i = described_class.new(name: "eggs", amount: 2.0, unit: "")
      expect(i.to_s).to eq("2.0 eggs")
    end
  end
end
