require "rom"
require "rom-sql"

module Mateoplanner
  module DB
    def self.setup
      ROM.container(:sql, "sqlite://db/mateoplanner.db") do |config|
        config.gateways[:default].use_logger(Logger.new($stdout))

        config.relation(:itineraries) do
          schema(infer: true)
          auto_struct true
        end

        config.relation(:admins) do
          schema(infer: true)
          auto_struct true
        end
      end
    end
  end
end
