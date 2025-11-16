require_relative "../repositories/itinerary_repository"
require "json"

module Mateoplanner
  module Handlers
    class FinalizeEnhancementHandler
      def initialize(event_bus)
        @event_bus = event_bus
        @repository = Repositories::ItineraryRepository.new
      end

      def call(event)
        puts "[FinalizeEnhancementHandler] Finalizing enhancement for #{event.itinerary_id}"

        @repository.update(
          event.itinerary_id,
          expert_enhanced_content: JSON.generate(event.enhanced_content),
          status: "completed",
          review_completed_at: Time.now
        )

        puts "[FinalizeEnhancementHandler] Enhancement completed for #{event.itinerary_id}"
      rescue => e
        puts "[FinalizeEnhancementHandler] Error: #{e.message}"
      end
    end
  end
end
