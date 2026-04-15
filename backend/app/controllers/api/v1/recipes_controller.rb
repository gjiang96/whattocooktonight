# frozen_string_literal: true

module Api
  module V1
    class RecipesController < ApplicationController
      def random
        tags = params[:tags]&.split(",")&.map(&:strip) || []
        result = FetchRandomRecipe.new.call(tags: tags)

        if result.success?
          render json: { recipe: RecipeSerializer.call(result.value) }
        else
          render json: { error: "Recipe service unavailable" }, status: :service_unavailable
        end
      end
    end
  end
end
