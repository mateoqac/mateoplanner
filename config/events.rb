require_relative "../lib/mateoplanner/events/event_bus"
require_relative "../lib/mateoplanner/handlers/generate_itinerary_handler"
require_relative "../lib/mateoplanner/handlers/store_itinerary_handler"
require_relative "../lib/mateoplanner/handlers/update_review_status_handler"
require_relative "../lib/mateoplanner/handlers/finalize_enhancement_handler"

module Mateoplanner
  module EventsConfig
    def self.setup
      event_bus = Events::EventBus.instance

      # Wire up event handlers
      generate_handler = Handlers::GenerateItineraryHandler.new(event_bus)
      store_handler = Handlers::StoreItineraryHandler.new(event_bus)
      review_handler = Handlers::UpdateReviewStatusHandler.new(event_bus)
      finalize_handler = Handlers::FinalizeEnhancementHandler.new(event_bus)

      # Subscribe handlers to events
      event_bus.subscribe("ItineraryRequested", &generate_handler.method(:call))
      event_bus.subscribe("ItineraryGenerated", &store_handler.method(:call))
      event_bus.subscribe("ReviewStarted", &review_handler.method(:call))
      event_bus.subscribe("ItineraryEnhanced", &finalize_handler.method(:call))

      puts "[EventsConfig] Event handlers registered"

      event_bus
    end
  end
end
