# frozen_string_literal: true

class FetchRandomRecipe
  def initialize(recipe_repo: Repositories::RecipeRepository.new)
    @recipe_repo = recipe_repo
  end

  def call(tags: [])
    @recipe_repo.fetch_random_recipe(tags: tags)
  end
end
