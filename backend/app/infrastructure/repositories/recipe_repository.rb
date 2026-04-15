# frozen_string_literal: true

module Repositories
  class RecipeRepository
    def initialize(client: ApiClients::SpoonacularClient.new)
      @client = client
    end

    def fetch_random_recipe(tags: [])
      raw = @client.fetch_random_recipe(tags: tags)
      recipe = map_recipe(raw["recipes"].first)
      Result.new(success?: true, value: recipe, error: nil)
    rescue ApiClients::ExternalApiError => e
      Result.new(success?: false, value: nil, error: e.message)
    end

    private

    def map_recipe(data)
      Entities::Recipe.new(
        id:               data["id"],
        title:            data["title"],
        image_url:        data["image"],
        source_url:       data["sourceUrl"],
        ready_in_minutes: data["readyInMinutes"],
        servings:         data["servings"],
        cuisines:         data["cuisines"] || [],
        diets:            data["diets"] || [],
        ingredients:      map_ingredients(data["extendedIngredients"] || [])
      )
    end

    def map_ingredients(raw_ingredients)
      raw_ingredients.map do |i|
        ValueObjects::Ingredient.new(
          name:   i["name"],
          amount: i["amount"],
          unit:   i["unit"]
        )
      end
    end
  end
end
