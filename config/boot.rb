require "bundler/setup"
Bundler.require(:default, ENV.fetch("HANAMI_ENV", "development"))

# Load lib directory
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# Load base classes first
require_relative "../app/action"

# Autoload application actions only (skip views)
Dir[File.join(__dir__, "../app/actions/**/*.rb")].sort.each { |f| require f }

# Autoload lib directory
Dir[File.join(__dir__, "../lib/**/*.rb")].sort.each { |f| require f }
