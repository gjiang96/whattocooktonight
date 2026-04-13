# frozen_string_literal: true

module Entities
  class Recipe
    attr_reader :id, :title, :image_url, :source_url,
                :ready_in_minutes, :servings,
                :cuisines, :diets, :ingredients

    def initialize(id:, title:, image_url:, source_url:,
                   ready_in_minutes:, servings:,
                   cuisines: [], diets: [], ingredients: [])
      @id               = id
      @title            = title
      @image_url        = image_url
      @source_url       = source_url
      @ready_in_minutes = ready_in_minutes
      @servings         = servings
      @cuisines         = cuisines.freeze
      @diets            = diets.freeze
      @ingredients      = ingredients.freeze
    end

    def ==(other)
      other.is_a?(Recipe) && id == other.id
    end

    alias eql? ==

    def hash
      id.hash
    end
  end
end
