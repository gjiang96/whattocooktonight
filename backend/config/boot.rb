ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap"
Bootsnap.setup(
  cache_dir: "tmp/cache",
  development_mode: ENV["RAILS_ENV"] == "development",
  load_path_cache: false, # disabled: freezes $LOAD_PATH, conflicts with vendored gems in CI
  compile_cache_iseq: true,
  compile_cache_yaml: true
)
