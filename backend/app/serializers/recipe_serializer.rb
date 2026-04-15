# frozen_string_literal: true

class RecipeSerializer
  def self.call(recipe)
    {
      id:               recipe.id,
      title:            recipe.title,
      image_url:        recipe.image_url,
      source_url:       recipe.source_url,
      ready_in_minutes: recipe.ready_in_minutes,
      servings:         recipe.servings,
      cuisines:         recipe.cuisines,
      diets:            recipe.diets,
      ingredients:      recipe.ingredients.map { |i| serialize_ingredient(i) }
    }
  end

  def self.serialize_ingredient(ingredient)
    {
      name:   ingredient.name,
      amount: ingredient.amount,
      unit:   ingredient.unit
    }
  end
  private_class_method :serialize_ingredient
end
