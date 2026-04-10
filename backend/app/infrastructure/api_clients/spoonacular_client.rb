# frozen_string_literal: true

module ApiClients
  class SpoonacularClient
    BASE_URL = "https://api.spoonacular.com"

    def initialize(api_key: ENV.fetch("SPOONACULAR_API_KEY"))
      @api_key = api_key
      @connection = Faraday.new(BASE_URL)
    end

    def fetch_random_recipe(tags: [])
      params = { number: 1, apiKey: @api_key }
      params[:tags] = tags.join(",") if tags.any?

      response = @connection.get("/recipes/random", params)

      unless response.success?
        fail ApiClients::ExternalApiError,
             "Spoonacular API returned #{response.status}"
      end

      JSON.parse(response.body)
    end
  end
end
