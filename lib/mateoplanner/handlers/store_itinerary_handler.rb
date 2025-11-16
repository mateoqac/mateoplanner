require_relative "../repositories/itinerary_repository"
require "json"

module Mateoplanner
  module Handlers
    class StoreItineraryHandler
      def initialize(event_bus)
        @event_bus = event_bus
        @repository = Repositories::ItineraryRepository.new
      end

      def call(event)
        puts "[StoreItineraryHandler] Storing AI-generated itinerary #{event.itinerary_id}"

        @repository.update(
          event.itinerary_id,
          ai_generated_content: JSON.generate(event.content)
        )

        puts "[StoreItineraryHandler] Itinerary stored for #{event.itinerary_id}"
      rescue => e
        puts "[StoreItineraryHandler] Error: #{e.message}"
      end
    end
  end
end
