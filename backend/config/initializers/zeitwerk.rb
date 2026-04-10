# frozen_string_literal: true

# Configure Zeitwerk autoloader for DDD namespaces.
#
# Rails adds each direct subdirectory of app/ as an autoload root, which means
# app/infrastructure/ would resolve to ApiClients::SpoonacularClient rather than
# Infrastructure::ApiClients::SpoonacularClient.
#
# We fix this by:
# 1. Adding app/ itself as an autoload root in application.rb
# 2. Ignoring the DDD subdirs as separate roots (app/ covers them)
# 3. Collapsing standard Rails directories so they stay flat (ApplicationRecord, not Models::ApplicationRecord)

# Zeitwerk is configured via config/application.rb.
# No additional configuration needed — Rails handles DDD directories
# as autoload roots, giving them their direct namespace from the directory name.
#   app/infrastructure/api_clients/spoonacular_client.rb => ApiClients::SpoonacularClient
#   app/domain/entities/recipe.rb                        => Entities::Recipe
#   app/use_cases/fetch_random_recipe.rb                 => FetchRandomRecipe
