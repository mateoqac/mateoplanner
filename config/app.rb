require "hanami"

module Mateoplanner
  class App < Hanami::App
    config.logger.level = :debug

    # Load environment variables
    require "dotenv/load" if Hanami.env?(:development, :test)
  end
end

# Initialize event system
require_relative "events"
Mateoplanner::EventsConfig.setup

require_relative "routes"
