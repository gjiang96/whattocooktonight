# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiClients::SpoonacularClient do
  subject(:client) { described_class.new(api_key: "test_key") }

  let(:base_url) { "https://api.spoonacular.com/recipes/random" }

  let(:recipe_payload) do
    {
      "recipes" => [
        {
          "id" => 642583,
          "title" => "Farfalle with Peas, Ham and Cream",
          "image" => "https://img.spoonacular.com/recipes/642583-556x370.jpg",
          "sourceUrl" => "https://www.foodista.com/recipe/farfalle",
          "readyInMinutes" => 45,
          "servings" => 4,
          "cuisines" => [ "Italian" ],
          "diets" => [],
          "extendedIngredients" => [
            { "name" => "farfalle pasta", "amount" => 200.0, "unit" => "g" },
            { "name" => "peas", "amount" => 100.0, "unit" => "g" },
            { "name" => "ham", "amount" => 150.0, "unit" => "g" }
          ]
        }
      ]
    }
  end

  describe "#fetch_random_recipe" do
    context "when the request succeeds" do
      before do
        stub_request(:get, base_url)
          .with(query: hash_including("apiKey" => "test_key", "number" => "1"))
          .to_return(
            status: 200,
            body: recipe_payload.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns the parsed response body" do
        result = client.fetch_random_recipe
        expect(result).to eq(recipe_payload)
      end

      it "requests exactly one recipe" do
        client.fetch_random_recipe
        expect(WebMock).to have_requested(:get, base_url)
          .with(query: hash_including("number" => "1"))
      end
    end

    context "when tags are provided" do
      before do
        stub_request(:get, base_url)
          .with(query: hash_including("tags" => "vegetarian,italian"))
          .to_return(
            status: 200,
            body: recipe_payload.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "passes tags as a comma-separated query parameter" do
        client.fetch_random_recipe(tags: %w[vegetarian italian])
        expect(WebMock).to have_requested(:get, base_url)
          .with(query: hash_including("tags" => "vegetarian,italian"))
      end
    end

    context "when no tags are provided" do
      before do
        stub_request(:get, base_url)
          .with(query: hash_excluding("tags"))
          .to_return(
            status: 200,
            body: recipe_payload.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "omits the tags parameter entirely" do
        client.fetch_random_recipe
        expect(WebMock).to have_requested(:get, base_url)
          .with(query: hash_excluding("tags"))
      end
    end

    context "when the API returns a non-200 response" do
      before do
        stub_request(:get, base_url)
          .with(query: hash_including("apiKey" => "test_key"))
          .to_return(
            status: 402,
            body: { "message" => "Your daily quota is exceeded." }.to_json
          )
      end

      it "raises an ExternalApiError" do
        expect { client.fetch_random_recipe }
          .to raise_error(ApiClients::ExternalApiError, /402/)
      end
    end

    context "when the API returns a 500 error" do
      before do
        stub_request(:get, base_url)
          .with(query: hash_including("apiKey" => "test_key"))
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises an ExternalApiError" do
        expect { client.fetch_random_recipe }
          .to raise_error(ApiClients::ExternalApiError, /500/)
      end
    end
  end
end
