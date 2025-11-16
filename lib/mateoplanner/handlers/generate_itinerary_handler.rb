require_relative "../services/ai_itinerary_generator"
require_relative "../repositories/itinerary_repository"
require_relative "../events/itinerary_generated"

module Mateoplanner
  module Handlers
    class GenerateItineraryHandler
      def initialize(event_bus)
        @event_bus = event_bus
        @ai_generator = Services::AiItineraryGenerator.new
        @repository = Repositories::ItineraryRepository.new
      end

      def call(event)
        puts "[GenerateItineraryHandler] Processing itinerary request #{event.itinerary_id}"

        # Generate AI itinerary
        content = @ai_generator.generate(event.preferences)

        # Publish ItineraryGenerated event
        @event_bus.publish(
          Events::ItineraryGenerated.new(
            itinerary_id: event.itinerary_id,
            content: content
          )
        )

        puts "[GenerateItineraryHandler] Itinerary generated for #{event.itinerary_id}"
      rescue => e
        puts "[GenerateItineraryHandler] Error: #{e.message}"
      end
    end
  end
end
